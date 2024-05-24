import os

os.environ['MPLCONFIGDIR'] = "/net/work/veigel/.cache/mpl"

#%%
import geopandas as gpd
import random
import numpy as np
import umap
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sentence_transformers import SentenceTransformer
from bertopic.backend import BaseEmbedder
from bertopic.dimensionality import BaseDimensionalityReduction
from bertopic import BERTopic
from bertopic.vectorizers import ClassTfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
import hdbscan
import matplotlib.pyplot as plt
import seaborn as sns

import spacy

import multiprocessing

#%%
# Set the number of cores to use
NUM_CORES = 4

# Set the number of threads per core for spaCy
NUM_THREADS_PER_CORE = 1

#%%

results_path = "/net/work/veigel/results/BERTopic/final_model/"

import nltk
from nltk.corpus import stopwords

# READ DATA
nltk.data.path.append("/net/work/veigel/data/words")

#%%
# ALL FUNCTIONS
# Function to parallelize named entity recognition
list_of_place_names = ["stadt", "orientierungspunkt", "gemeindeverband", "stadtgemeinde", "landkreis", "bezirk","bundesland", "land", "kontinent"]

def process_sentence(sentence):

    global nlp_de, nlp_en, list_of_place_names

    # Loop through each sentence in the list and replace named entities with the word "city"

    if 'de' in nlp_de.meta['lang']:
        doc = nlp_de(sentence)

    for ent in doc.ents:
        if ((ent.label_ == 'LOC') and not any(word in ent.text for word in list_of_place_names)):
            sentence = sentence.replace(ent.text, "ort")

    return sentence

#%%
# Function to parallelize BERTopic embeddings
def process_embedding(sentence):
    global model
    embeddings = model.encode(sentence)
    return embeddings


#%%
# Function to parallelize time series generation
def process_timestamp(timestamp):
    global topic_model, sample_tweets, nr_bin
    topics_over_time = topic_model.topics_over_time(sample_tweets, timestamp, nr_bins=nr_bin)
    return topics_over_time

#%%
# READ DATA
tweets = gpd.read_file('/net/work/veigel/data/tweets_clean_label.geojson', lines=True)
tweets = tweets[["text_clean", "label_num", "id", "date"]].dropna()
print("Reading done.")

random.seed(321)
#sample_tweets = random.sample(list(tweets["text_clean"]), k=100)
sample_tweets = list(tweets["text_clean"])

#%%
# SAMPLE FOR TRIAL
#random.seed(321)
#sample_tweets = list(tweets["text_clean"])

# NAMED ENTITY RECOGNITION
nlp_de = spacy.load('de_core_news_sm')

# Initialize an empty list to hold the processed sentences
processed_tweets = []

# Parallelize the named entity recognition step
with multiprocessing.Pool(processes=NUM_CORES) as pool:
    processed_tweets = pool.map(process_sentence, sample_tweets)

print("Named entity recognition completed.")



#%%
# BERTopic embeddings
modelPath1 = "/net/work/veigel/pretrained_models/mini"
model = SentenceTransformer(modelPath1)

# Create embeddings
with multiprocessing.Pool(processes=NUM_CORES) as pool:
    embeddings = pool.map(process_embedding, processed_tweets)

#%%
reducer =umap.UMAP(n_neighbors=200, min_dist=0.0, n_components=3, metric='cosine')
#combined_embeddings_reduced = reducer.fit_transform(X_train)
embeddings_reduced = reducer.fit_transform(embeddings)

#%%

german_stop_words = stopwords.words('german')
vectorizer_model = CountVectorizer(stop_words=german_stop_words)

#kmeans_model = KMeans(n_clusters=3)
hdbscan_model = hdbscan.HDBSCAN(min_cluster_size=20, metric='euclidean', cluster_selection_method='eom', prediction_data=True)
#hdbscan_model = ElasticNetSubspaceClustering(n_clusters=3)
ctfidf_model = ClassTfidfTransformer(reduce_frequent_words=True)

topic_model = BERTopic(
  embedding_model=model,    # Step 1 - Extract embeddings
  umap_model=reducer,
  vectorizer_model=vectorizer_model,
  hdbscan_model=hdbscan_model,  # Step 4 - Tokenize topics
  ctfidf_model=ctfidf_model,          # Step 5 - Extract topic words
  diversity=0.5,  # Step 6 - Diversify topic words
  n_gram_range=(1, 2),
  top_n_words=10)

topics, probs = topic_model.fit_transform(processed_tweets,embeddings=embeddings_reduced)

print("BERTopic training completed.")

#%%
topic_model.save(results_path + "/topic_model")

info_df = topic_model.get_document_info(sample_tweets)

#%%
info_df.to_csv(path_or_buf=results_path + 'info_df.csv')

#%%

# Time series generation
timestamps = tweets.date.to_list()
nr_bin = 500
# Parallelize the time series generation step
with multiprocessing.Pool(processes=NUM_CORES) as pool:
    topics_over_time = pool.map(process_timestamp, timestamps)

print("weekly time series generation completed.")

topics_over_time.to_csv(path_or_buf=results_path + 'weekly_topics_over_time.csv')

#%%

# Time series generation
nr_bin = 500*7

# Parallelize the time series generation step
with multiprocessing.Pool(processes=NUM_CORES) as pool:
    topics_over_time = pool.map(process_timestamp, timestamps)

print("daily time series generation completed.")

topics_over_time.to_csv(path_or_buf=results_path + 'daily_topics_over_time.csv')

