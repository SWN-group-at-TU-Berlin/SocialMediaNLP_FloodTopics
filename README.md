
# Content Analysis of Multi-Annual Time Series of Flood-Related Twitter (X) Data

We extract and analyze topics emerging on Twitter (X) for
past flood events with different magnitudes based on the content of flood-related tweets posted in German between 2014 and 2021. We implemented Bidirectional Encoder Representations from Transformers (BERT) in combination with unsupervised clustering techniques to classify the tweets in different topic groups (BERTopic). This methodology enables us to automatically extract social media content over a multi-annual time period by addressing transferability issues that arise from commonly used bag-of-word representations.

## Prerequisites

### R version 4.2.3 (2023-03-15 ucrt) -- "Shortstop Beagle"
installed packages: 

    sf
    jsonlite
    lubridate
    tidyverse
    tidytext
    tm
    scico
    bcp

#### Python 3.7
installed packages

    nltk
    os
    import geopandas as gpd
    random
    numpy
    umap
    sklearn
    sentence_transformers
    bertopic
    hdbscan
    matplotlib
    seaborn
    spacy

### Input Requirements

This project uses data presented in:

        de Bruijn, J., de Moel, H., Jongman, B., de Ruiter, M., Wagemaker, J., & Aerts, J. C. J. H. (2019). 
        A global database of historic and real-time flood events based on social media.
        Scientific Data, 6(1), Article 311. 
        https://doi.org/10.1038/s41597-019-0326 

        de Bruijn, J. A., de Moel, H., Jongman, B., Wagemaker, J., & Aerts, J. C. J. H. (2018). 
        TAGGS: Grouping Tweets to Improve Global Geoparsing for Disaster Response. 
        Journal of Geovisualization and Spatial Analysis, 2(2), 1-14. Article 2. Advance online publication. 
        https://doi.org/10.1007/s41651-017-0010-6


### :file_folder: Folders and :page_facing_up: Scripts
        
```
script
│
└───preprocess
│     01_clean_text_and_geotags.R
│     02_changepoint_detection_analysis.R
│     03_actors_over_time.R
│
└───model
│     final_model_paralell.py
│
└───results
    │   1_generate_disaster_info_data.R
    │   2_process_BERTopic_results.R
    │   3_topic_ocurrence_per_event.R
    │   translate.R
    │   daily_topics_over_time_1.csv
    │   info_df.csv
    │   topics_grouped.csv
    │   weekly_topics_over_time_1.csv
    │ 
readme.md
	
```

:file_folder: **preprocessing**

:page_facing_up: *01_clean_text_and_geotags.R*

Twitter posts are prepared by cleaning, for example removing URLs, and filtering with nonflood related keywords

:page_facing_up: *02_changepoint_detection_analysis.R*

Time windows for flood events are defined based on Bayesian changepoint detection

:page_facing_up: *03_actors_over_time.R*

Script to determine which users posted most frequently

:file_folder:**modelling**

:page_facing_up: *final_model_paralell.py*

Content modelling - extracting topics from tweets (1) extract a vectorized representation of the text (embeddings) utilizing a Sentence Transformer model (SBERT version:paraphrase-multilingual-MiniLM-L12-
v2). (2) To handle the high-dimensional nature of the embeddings, we apply a dimensionality reduction technique, Uniform Manifold Approximation and Projection for Dimension Reduction (UMAP). (3) On this simplified representation we apply the HDBSCAN clustering algorithm to group similar embeddings together, forming clusters that represent distinct
topics within the data.

:file_folder: **results**

:page_facing_up: *1_generate_disaster_info_data.R*

Here the information from literature about the five selected flood events are compiled (return period, peak discharge, time window)

:page_facing_up: *2_process_BERTopic_results.R*

Modelling results are post-processed and the datasets are compiled

:page_facing_up: *3_topic_ocurrence_per_event.R*

Selecting topics based on the frequency of ocurrence during a 40-day flood window for each flood. Plotting timelines of events for each event.

:page_facing_up: *translate.R*

Generates data frame for text translation

:floppy_disk: *info_df.csv*

Each row represents one Tweet with its respective text and topic ID assigned by the model

:floppy_disk: *topics_grouped.csv*

Each row a topic with 10 keywords, representative tweet text and ocurrence count over the whoel time period (freq column)

:floppy_disk: *weekly_topics_over_time_1.csv*

Time series data of the topics that occur during each week and how many tweets are associated with the respective topic in a week (timestep)
