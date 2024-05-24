#-------------------------------------------------------------------------------

library(jsonlite)
library(lubridate)
library(tidyverse)
library(scico)

# file
json_data <- stream_in(file("tweets_user.jsonl"))

json_data$dmy_ =  ymd_hms(json_data$date)
json_data$Date = date(json_data$date)
json_data$month = dmy(paste(1,paste(month(json_data$Date),year(json_data$Date), sep = "-"), sep = "-"))
json_data$user_id = as.character(json_data$author$id)

length(unique(json_data$user_id))

json_authors_in = json_data %>% count(user_id, month, sort = FALSE)
json_authors_out = json_authors_in[-which(json_authors_in$user_id == "201443803"),]
json_authors_only = json_authors_in[which(json_authors_in$user_id == "201443803"),]

json_authors_merge = json_data %>% count(user_id,sort = TRUE)


json_authors_merge$user_id = as.character(json_authors_merge$user_id)
head(json_authors_merge, n = 20)
summary(json_authors_merge$n)

tail(json_data$text[which(json_data$user_id == "201443803")])
tail(json_data$text[which(json_data$user_id == "77838776")])
tail(json_data$text[which(json_data$user_id == "240646015")])
tail(json_data$text[which(json_data$user_id == "969481898828451840")])
tail(json_data$text[which(json_data$user_id == "4491262043")])

tail(json_data$text[which(json_data$user_id == "419109247")])
tail(json_data$text[which(json_data$user_id == "736701277460172800")])
tail(json_data$text[which(json_data$user_id == "90524645")])
tail(json_data$text[which(json_data$user_id == "553450152")])
tail(json_data$text[which(json_data$user_id == "722553638892224512")])

json_data_percent = json_authors_in %>% 
                    mutate(group = ifelse(user_id == "201443803",1,0)) %>% 
                    group_by(month,group) %>% 
                    summarise(group_count = sum(n, na.rm = TRUE)) %>% 
                    ungroup()

json_data_1 = json_data_percent[which(json_data_percent$group == 1),]
json_data_0 = json_data_percent[which(json_data_percent$group == 0),]

names(json_data_1) = paste0(names(json_data_1), "1")

merge_percent = merge(json_data_1, json_data_0, by.x = "month1", by.y = "month", all = TRUE)

merge_percent$percent = merge_percent$group_count1*(100/merge_percent$group_count)
hist(merge_percent$percent, main = "Percent of monthly posts by 201443803")

merge_percent[c(17,20,41,42),]

# plot topic proportions per decade as bar plot
p = ggplot(json_authors_in, aes(x=month, y=n, fill=user_id)) + 
  geom_bar(stat = "identity") + ylab("proportion") + 
  #scale_fill_manual(values = paste0(alphabet(20), "FF"), name = "week") + 
  theme_void()+
  scale_fill_scico_d()+
  theme(legend.position = "none",axis.text.x = element_text(angle = 90, hjust = 1), axis.text.y = element_text())
p
