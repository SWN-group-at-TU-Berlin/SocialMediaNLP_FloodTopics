library(tidyverse)
library(lubridate)
library(ggthemes)

setwd("final_model")

#-------------------------------------------------------------------------------
# Read data 
#-------------------------------------------------------------------------------

# Data frame with every tweet and associated topic representation
info_dat = read.csv("info_df.csv")
# Time series of tweets and topics aggregated on a weekly basis
time_dat_week = read.csv("weekly_topics_over_time_1.csv")
# Time series of tweets and topics aggregated on a daily basis
time_dat = read.csv("daily_topics_over_time_1.csv")
# Manual grouping strategy data
group_dat = read.csv2("topics_grouped.csv")

#-------------------------------------------------------------------------------
# Format Columns
#-------------------------------------------------------------------------------

time_dat$Timestamp = ymd_hms(time_dat$Timestamp,tz = "CET")

#Generate Top_2 and Top_3 words with separator

info_dat = separate(data = info_dat, col = Top_n_words, into = paste0("w",1:3), sep = " - ")

info_dat$top_2 = paste(info_dat$Topic, paste(info_dat$w1,info_dat$w2, sep = "\n"))
info_dat$top_3 = paste(info_dat$Topic, paste(info_dat$top_2,info_dat$w3, sep = "\n"))

#-------------------------------------------------------------------------------
# Barplot noise
#-------------------------------------------------------------------------------
if(TRUE){
info_dat_1 = info_dat %>% 
  filter(Topic == -1) %>% 
  mutate(freq = n()) %>% 
  slice(1)

topics_out = group_dat$Topic[group_dat$Spalte1 == "out"]

info_dat_2 = info_dat %>% 
  filter(Topic != -1 | !(Topic %in% topics_out)) %>% 
  #group_by(Topic) %>% 
  mutate(freq = n()) %>% 
  slice(1)

info_dat_3 = info_dat %>% 
  filter(Topic != -1 & Topic %in% topics_out) %>% 
  #group_by(Topic) %>% 
  mutate(freq = n()) %>% 
  slice(1)

barplot_dat = rbind(info_dat_1, info_dat_2)
barplot_dat = rbind(barplot_dat, info_dat_3)

barplot_dat$Topic = c("2. Noise", "1. Topics assigned", "3. Removed")

p = ggplot(na.omit(barplot_dat), aes(x = c(1,1,1), y = freq, fill = Topic, label = paste(Topic, paste0("n=",freq), sep = "\n"))) +
  geom_bar(stat = "identity") +
  geom_text(size = 3, position = position_stack(vjust = 0.5))+
  #theme_void()+
  theme_clean()+
  theme(axis.line.y = element_blank(), axis.title.y = element_blank(), 
        axis.text.y = element_blank(), axis.ticks.y = element_blank())+
  scale_fill_manual(values = c("#9EB0FF" , "#7B321C", "#FFACAC"))+
  theme(legend.position = "none")+
  ylab("number of tweets")+
  theme(axis.text.x = element_text(size = 8), axis.title.x = element_text( size = 8), axis.ticks.x.bottom = element_line(), axis.line.x = element_line())+
  scale_y_continuous(expand = c(0,0), limits = c(-1000,57000))+
  coord_flip()

ggsave(paste0("noise.png"), width = 150 ,height = 30, units = "mm")

}

#-------------------------------------------------------------------------------
# Aggregate Data for further analysis
#   1. Aggregate info data by frequency and select only representative documents
#   2. 
#-------------------------------------------------------------------------------

info_dat_rep = info_dat[which(info_dat$Representative_document == "True"),]

topic_count = time_dat %>% 
  group_by(Topic) %>% 
  summarise(topic=Topic[1], count = sum(Frequency))

info_dat_rep = info_dat_rep %>%
  group_by(Topic) %>% 
  slice(1)

info_dat_rep = merge(topic_count, info_dat_rep, by.x = "topic", by.y = "Topic")

info_dat_top_n = info_dat %>%
  group_by(Topic) %>% 
  slice(1) %>% 
  select(c("Topic","top_3"))

info_dat_freq = info_dat %>% 
  group_by(Topic) %>% 
  mutate(freq = n()) %>% 
  slice(1)


#-------------------------------------------------------------------------------
# Remove noise & manually labelled topics, subset data and 
#-------------------------------------------------------------------------------


group_dat$Spalte2[which(group_dat$Spalte2 == "")] = "not categorized"
group_dat = group_dat[-which(group_dat$Spalte1 == "out" | group_dat$Spalte2 == "noise"),]
info_dat = info_dat[which(info_dat$Topic %in% group_dat$Topic),]
time_dat = time_dat[which(time_dat$Topic %in% c(group_dat$Topic)),]

#group_dat = group_dat[,c(3,4)]
#info_dat = info_dat[,c(3,5)]
#time_dat = time_dat[,c(2,4,5)]

print(paste("number of topics group_dat after filter", length(unique(group_dat$Topic))))
print(paste("number of topics info_dat after filter", length(unique(info_dat$Topic))))
print(paste("number of topics time_dat after filter", length(unique(time_dat$Topic))))

# Re-format the time data

time_dat$group = as.factor(time_dat$Topic)
time_dat$words = as.factor(time_dat$Topic)

levels(time_dat$group) = group_dat$Spalte2

info_dat = info_dat[order(info_dat$Topic),]
levels(time_dat$words) = unique(info_dat$top_3)

time_dat$words = as.character(time_dat$words)






