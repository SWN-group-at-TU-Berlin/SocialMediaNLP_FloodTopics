#-------------------------------------------------------------------------------
# Load tweets
# Find most specific location
# remove stopwords and search words
# export geojson
#-------------------------------------------------------------------------------

library(sf)
library(jsonlite)
library(lubridate)


# read in the libraries we're going to use
library(tidyverse) # general utility & workflow functions
library(tidytext) 

library(scico)
library(bcp)



# file
json_data <- stream_in(file("tweets.jsonl"))


# tweet text to lowercase
json_data$text= tolower(json_data$text)

# Date format
json_data$dmy_ =  ymd_hms(json_data$date)
json_data$Date = date(json_data$date)

#-------------------------------------------------------------------------------
# Remove tweets about migration, insults or unrelated topics
#-------------------------------------------------------------------------------

out_fl = which(grepl("\\w*fl?chtl\\w*",json_data$text))
out_ay = which(grepl("\\w*asyl\\w*",json_data$text))
out_mig = which(grepl("\\w*migran\\w*",json_data$text))

json_data = json_data[-c(out_fl, out_ay, out_mig),]

json_data = json_data[-c(which(grepl("\\w*ezb-geldflut\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*fachkr?fte-flut\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*app-flut\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*pegida\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*islam\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*nazi\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*#nowplaying\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*#sex\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*#arsch\\w*",json_data$text))),]
json_data = json_data[-c(which(grepl("\\w*#obamacare\\w*",json_data$text))),]

#-------------------------------------------------------------------------------
# Get locations from locations subset and replace them with placeholders
# for associated Admin unit
#-------------------------------------------------------------------------------

# get sorted dataframe from list 

for (i in 1:length(json_data$locations)){
  json_data$locations[[i]]$id_list = i
}

locations_df = do.call(rbind.data.frame, json_data$locations)

sorted_type = c("town", "landmark" ,"adm5","adm4","adm3","adm2","adm1","country","continent")
locations_df$type = factor(locations_df$type, levels = sorted_type)

levels(locations_df$type) = c("stadt", "orientierungspunkt" ,"gemeindeverband",
                              "stadtgemeinde","landkreis","bezirk","bundesland",
                              "land","kontinent")

json_data$text_geo = json_data$text

# Replace toponyms in text

for (i in 1:nrow(json_data)){
  locations = locations_df[which(locations_df$i == i),]

  for (j in 1:nrow(locations)){

    json_data$text_geo[i] = gsub(paste0("\\w*", paste0(locations$toponym[j], "\\w*")),
                                 as.character(locations$type[j]),
                                 json_data$text_geo[i])
  }
}


levels(locations_df$type) = sorted_type

locations_df_2 = locations_df %>% 
  arrange(type) %>% 
  group_by(id_list) %>% 
  slice(1)

geojson_data = cbind(locations_df_2, json_data)
if(all(geojson_data$id_list == rownames(geojson_data))){geojson_data = geojson_data[,-which(names(geojson_data)=="id_list")]}

geojson_data$year = year(geojson_data$date)

#-------------------------------------------------------------------------------
# Clean text
# - remove stopwords
# - remove special characters
# - remove typos in palce names
#-------------------------------------------------------------------------------

remove_words = function(json_data){
  
  text = json_data$text_geo
  
  text = gsub(pattern = '[?]', replacement = "ae",text)
  text = gsub(pattern = '[?]', replacement = "ue",text)
  text = gsub(pattern = '[?]', replacement = "oe",text)
  text = gsub(pattern = '[?]', replacement = "oe",text)
  text = gsub(pattern = '\\w*germany\\w*', replacement = "land",text)
  text = gsub(pattern = '\\w*rheinlandpfalz\\w*', replacement = "bundesland",text)
  text = gsub(pattern = '\\w*rheinland pfalz\\w*', replacement = "bundesland",text)
  
  to_be_removed = c(
    "flut", "hochwasser", "ueberflutung", "ueberschwemmung", "ueberflutung", "sintflut"
  )
  
  text_no_search_words = text
  
  for (remove_word in to_be_removed){
  text_no_search_words = gsub(paste0("\\w*", remove_word, "\\w*"), "hochwasser",text_no_search_words)
  }
  
  text_no_search_words = rm_twitter_url( text_no_search_words)
  
  text_no_links =  gsub("\n", "",text_no_search_words)
  
  text_no_links =  gsub("\\w*@\\w*", "benutzer",text_no_links)
  
  text_no_links = gsub("[^[:alnum:]]", " ", gsub(" ?(f|ht)tp(s?)://(.*)[.][a-z]+", "",text_no_links ))
  
  text_no_numbers = gsub('[[:digit:]]+', 'nummer', text_no_links)

  return(text_no_numbers)
}

#-------------------------------------------------------------------------------
# Export cleaned data
#-------------------------------------------------------------------------------


geojson_data$text_clean = remove_words(geojson_data)

geom <- as.data.frame(do.call(rbind,geojson_data$coordinates))
names(geom) = c("X", "Y")
geojson_data = cbind(geojson_data, geom)

geojson_data = geojson_data %>% st_as_sf(coords = c("X", "Y"), crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

#plot(st_geometry(geojson_data))
geojson_data =geojson_data[,-c(4,12)]

st_write(geojson_data,"tweets_clean.geojson", append = FALSE)

