#-------------------------------------------------------------------------------

library(sf)
library(jsonlite)
library(lubridate)


# read in the libraries we're going to use
library(tidyverse) # general utility & workflow functions
library(tidytext) # tidy implementation of NLP methods
library(topicmodels) 

library(scico)


# file
json_data <- stream_in(file("C:/Users/veigel/Documents/projects/twitter/data/tweets_germany_all_time/tweets.jsonl"))

json_data$dmy_ =  ymd_hms(json_data$date)
json_data$Date = date(json_data$date)

json_data_daily = json_data %>% group_by(Date) %>% summarise(Date = Date[1], freq = n())

#-------------------------------------------------------------------------------
# find changepoints to identify events
#-------------------------------------------------------------------------------

json_data_ts = json_data %>% 
  group_by(Date) %>% 
  summarise(n_tweets = n())

x <- json_data_ts$n_tweets
bcp_x <- bcp(x, return.mcmc = TRUE)
plot(bcp_x)

bcp_sum <- as.data.frame(summary(bcp_x))
# Let's filter the data frame and identify the year:
bcp_sum$id <- 1:length(x)
(sel <- bcp_sum[which(bcp_x$posterior.prob > 0.7), ])
# Get the year:
json_data_ts$Date[sel$id] 

json_data_ts$chg_pt = 0
events = NA

#-------------------------------------------------------------------------------
# Manualy define events based on changepoint detection
#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2016-05-29", "2016-05-31"))] 
# Braunsbach & Schw?bisch Gm?nd &andere
# [488] "Ich habe ein @YouTube-Video positiv bewertet: https://t.co/WXDufvEbBI Hochwasser in Schw?bisch Gm?nd 29.05.2016"  
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2016-05-29", "2016-05-31"))] = 1
events[1] = "baseline"
events[2] = "Braunsbach,Schw?bisch Gm?nd"

#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2016-06-01", "2016-06-08"))] 
# Niederbayern (Simbach)
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2016-06-01", "2016-06-08"))] = 2
events[3] = "Simbach"

#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2017-07-25", "2017-07-29"))]
# M?nchen & Hildesheim (?) 
#[997] "Rettung in M?nchen - Nach Hochwasser: Zwei M?nner sitzen tagelang auf Isar-Insel fest  F?r vier Tage waren zwei M?. https://t.co/bqNfDT6ylw" 
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2017-07-25", "2017-07-29"))] = 3
events[4] = "Hildesheim"

#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2018-01-03", "2018-01-08"))]
# Hessen
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2018-01-03", "2018-01-08"))] = 4
events[5] = "Hessen"

#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2021-01-28", "2021-02-08"))]
#Rhein
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2021-01-28", "2021-02-08"))] = 5
events[6] = "Rhein"

#-------------------------------------------------------------------------------

json_data$text[which(json_data$Date %within% interval("2021-07-15", "2021-07-23"))]
#Ahr
json_data_ts$chg_pt[which(json_data_ts$Date %within% interval("2021-07-15", "2021-07-23"))] = 6
events[7] = "Ahr"

#-------------------------------------------------------------------------------
# PLOT
# Time series plots
# text indication
#-------------------------------------------------------------------------------


# json_data_ts_text = dplyr::filter(json_data, grepl('Braunsbach|Schw?bisch Gm?nd', text)) %>% 
#   group_by(Date) %>% 
#   summarise(n_tweets_bw = n())
# 
# json_data_ts = full_join(json_data_ts, json_data_ts_text, by = "Date")
# json_data_ts$chg_pt = as.factor(json_data_ts$chg_pt)
# 
# 
# json_data_ts$n_tweets_bw = ifelse(is.na(json_data_ts$n_tweets_bw), 0, json_data_ts$n_tweets_bw)
# 
# df = json_data_ts
# maxRange <- 1.1*(max(df$n_tweets_bw) + max(df$n_tweets))
# 
# precip_labels <- function(x) {(x / 100) * 12}
# 
# 
# df$chg_pt = factor(df$chg_pt, levels = unique(df$chg_pt),  labels = events)
# # Plot the data
# ggplot(data = df,
#        aes(x = Date)) +
#   geom_path(aes(y = n_tweets, colour = chg_pt, group = 1) )+
#   scale_y_continuous(name = "daily tweets")+
#     theme_light()


