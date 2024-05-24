library(tidyverse)
library(scico)
library(lubridate)
library(ggpubr)

setwd("final_model")

#-------------------------------------------------------------------------------
# define disaster start, end and duration
#-------------------------------------------------------------------------------

source("../1_generate_disaster_info_data.R")

#-------------------------------------------------------------------------------
# Find top n topics & calculate Frequency
#-------------------------------------------------------------------------------

source("../2_process_BERTopic_results.R")


#-------------------------------------------------------------------------------
# Add flood info to time_data
#-------------------------------------------------------------------------------

time_dat_plot = time_dat

time_dat_plot$disaster_name = NA

for (i in 1:length(disaster_length2)){

  time_dat_plot$disaster_name = 
    ifelse(time_dat_plot$Timestamp %within% 
        interval(disaster_length2[[i]][1],disaster_length2[[i]][2]), 
      id[i], 
      time_dat_plot$disaster_name
      )

}

time_dat_plot = time_dat_plot %>% 
                  group_by(disaster_name, words) %>% 
                  mutate(Frequency = sum(Frequency)) %>%
                  slice(1) %>% 
                  ungroup()



#-------------------------------------------------------------------------------

# Library
library(fmsb)

for (i in 1:length(id)){
  
  radardata = time_dat_plot[which(time_dat_plot$disaster_name == id[i]),]
# 
#   if(length(unique(radardata$Topic)) > 10){
#     radardata = radardata %>% filter(Frequency > 20)}
#   
#   if(id[i] == "Niederbayern \n (Simbach)"){
#     radardata = radardata %>% filter(Frequency > 30)}
#   
#   if(id[i] == "Ahr" ){
#     radardata = radardata %>% filter(Frequency > 50)}
#   
# select topic, words, frequency
  radardata = radardata[,c(2,4)]
  print(paste0(id[i], length(unique(radardata$Topic))))
  
  data_long = pivot_wider(radardata,names_from = Topic, values_from = Frequency, values_fill = 0)

  
# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each topic to show on the plot!
  data <- rbind(rep(max(radardata$Frequency),nrow(data_long)) , rep(0,nrow(data_long)) , data_long)

  #data = data[,c(2:ncol(data))]

# Check your data, it has to look like this!
# head(data)
 

# The default radar chart 
  png(filename =paste0(name_disaster[i], "topics.png"), width = 20, height = 20, units = "cm", res = 300)
  
  radarchart(data , axistype=1 , 
           
           #custom polygon
           pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 , 
           
           #custom the grid
           cglcol="grey", cglty=1, axislabcol="grey", 
           caxislabels=seq(from = 0, to = max(radardata$Frequency),by = max(radardata$Frequency)/4), cglwd=0.8,
           
           #custom labels
           vlcex=0.8,
           
           title = id[i])

dev.off()

}

time_dat_plot_2 = time_dat_plot %>% 
  group_by(disaster_name, group) %>% 
  mutate(Frequency = sum(Frequency)) %>%
  slice(1) %>% 
  ungroup()

library(stringr)

levels(time_dat_plot_2$group) = c("Signal and detect","Provide warnings","Document what is happening","Discuss causes \n and responsibility","requests for help","preparedness information","news coverage","response information","disaster response,\n recovery, and rebuilding","awareness, donations","Information on \ncondition and location","Express Emotions", "mental/behavioral\nhealth support", "(Re)connect", "traditional communication\nactivities")#, "not categorized")


#group1 = word(string = time_dat_plot_2$group, start = 2, end = 5, sep = fixed(" "))
#group2 = ifelse(lengths(gregexpr("[A-z]\\W+", time_dat_plot_2$group)) + 1L >= 6 ,word(string = time_dat_plot_2$group, start = 5, end = 6, sep = fixed(" ")), "")

#unique(time_dat_plot_2$group)

#time_dat_plot_2$group = paste(group1, group2, sep = "\n")
time_dat_plot_2$group = as.character(time_dat_plot_2$group)

#-------------------------------------------------------------------------------

radardata = time_dat_plot_2[,c(4,6,8)]
#radardata = radardata[-which(radardata$group == "not categorized"),]
radardata = na.omit(radardata)

radardata_wide = pivot_wider(radardata,names_from = group, values_from = Frequency, values_fill = 0)
radardata_wide = as.data.frame(radardata_wide)
rownames(radardata_wide) = radardata_wide$disaster_name
radardata_wide = radardata_wide[,-1]
# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each variable to show on the plot!
data <- rbind(rep(max(radardata$Frequency),ncol(radardata_wide)) , rep(0,ncol(radardata_wide)) , radardata_wide)

# Color vector
colors_border=scico(n = nrow(radardata_wide), palette = "berlin")


png(filename =paste0("grouped", "topics.png"), width = 25, height = 20, units = "cm", res = 300)
par(xpd=TRUE)
# plot with default options:
radarchart( data, axistype=1 , 
            #custom polygon
            pcol=colors_border, plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=round(seq(0,max(radardata$Frequency),max(radardata$Frequency/4)),0), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)

# Add a legend
legend(x=1.2, y=1.5, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_border , text.col = "black", cex=0.8, pt.cex=1.5)

dev.off()

#-------------------------------------------------------------------------------

for (i in 1:length(id)){
  
  radardata = time_dat_plot_2[,c(4,6,8)]
  #hist(radardata$Frequency, breaks = 1000 )
  #radardata = radardata[radardata$Frequency > 10,]
  radardata = radardata[radardata$Topic != -1,]
  radardata = radardata[,-1]
  
  data = radardata[which(radardata$disaster_name == id[i]),]
  
  data = pivot_wider(data, names_from = group, values_from = Frequency, values_fill = 0)
  
  
  
  # To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each topic to show on the plot!
  min_max_data = radardata[which(radardata$disaster_name == id[i]),]
  data <- rbind(rep(max(min_max_data$Frequency),nrow(data)) , rep(0,nrow(data)) , data)
  
  data = data[,c(2:ncol(data))]
  
  # Check your data, it has to look like this!
  # head(data)
  
  # The default radar chart 
  png(filename =paste0(name_disaster[i], "groups.png"), width = 20, height = 20, units = "cm", res = 300)
  radarchart(data , axistype=1 , 
             
             #custom polygon
             pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 , 
             
             #custom the grid
             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
             
             #custom labels
             vlcex=0.8,
             
             title = id[i])
  
  dev.off()
  
}



#-------------------------------------------------------------------------------


# Create data: note in High school for several students
set.seed(99)
data <- as.data.frame(matrix( sample( 0:20 , 15 , replace=F) , ncol=5))
colnames(data) <- c("math" , "english" , "biology" , "music" , "R-coding" )
rownames(data) <- paste("mister" , letters[1:3] , sep="-")

# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each variable to show on the plot!
data <- rbind(rep(20,5) , rep(0,5) , data)

# Color vector
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )

# plot with default options:
radarchart( data  , axistype=1 , 
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)







#-------------------------------------------------------------------------------

time_dat_subset = time_dat_plot[!is.na(time_dat_plot$disaster_name),]
time_dat_subset = time_dat_subset[,c(2:4,9,10)]

# Transform data in a tidy format (long format)
#data <- time_dat_subset %>% gather(key = "top_3", value="freq", - disaster_name, -group) 
data = time_dat_subset[,-c(2)]

data$disaster_name = as.factor(data$disaster_name)

data = data %>% arrange(disaster_name, Frequency)

#-------------------------------------------------------------------------------

# Set a number of 'empty bar' to add at the end of each disaster_name
empty_bar <- 6
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$disaster_name), ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$disaster_name <- rep(levels(data$disaster_name), each=empty_bar)
data <- rbind(data, to_add)
data <- data %>% arrange(disaster_name)
data$id <- seq(1, nrow(data))

# Get the name and the y position of each label
label_data <- data
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)

# prepare a data frame for base lines
base_data <- data %>% 
  group_by(disaster_name) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

# prepare a data frame for grid (scales)
grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

# Make the plot
p <- ggplot(data, aes(x=as.factor(id), y=Frequency, fill=disaster_name)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  
  geom_bar(aes(x=as.factor(id), y=Frequency, fill=top_3), stat="identity", alpha=0.5) +
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 80, xend = start, yend = 80), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 60, xend = start, yend = 60), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 40, xend = start, yend = 40), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  
  # Add text showing the Frequency of each 100/75/50/25 lines
  annotate("text", x = rep(max(data$id),4), y = c(20, 40, 60, 80), label = c("20", "40", "60", "80") , color="grey", size=3 , angle=0, fontface="bold", hjust=1) +
  
  geom_bar(aes(x=as.factor(id), y=Frequency, fill=disaster_name), stat="identity", alpha=0.5) +
  ylim(-100,120) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm"),
    text = element_text(size = 10)
  ) +
  coord_polar() + 
  #geom_text(data=label_data, aes(x=id, y=Frequency+10, label=top_3), hjust=label_data$hjust, color="black", 
            #fontface="bold",alpha=0.6, size=2.5)+ #angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  geom_segment(data=base_data, aes(x = start, y = -5, xend = end, yend = -5), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
  geom_text(data=base_data, aes(x = title, y = -18, label=disaster_name), #hjust=c(1,1,0,0), 
            colour = "black", alpha=0.8, size=4, fontface="bold", inherit.aes = FALSE)

ggsave("circle.png", width = 30,  height = 25, units = "cm")

#-------------------------------------------------------------------------------
# 
# 
# for (i in 1:length(disaster_length2)){
#   
#   time_dat_subset = 
#     time_dat[time_dat$Timestamp %within% interval(disaster_length2[[i]][1],disaster_length2[[i]][2]),]
#   
#   time_dat_sub_freq = time_dat_subset %>% group_by(Words) %>% summarise(Freq = sum(Frequency))
#   
#   
#     p = ggplot(time_dat, aes(x=Timestamp, y=Frequency, fill=top_3)) + 
#     geom_bar(stat = "identity") + ylab("topic_frequency") + 
#     scale_x_datetime(limits = disaster_length2[[i]])+
#     theme_void()+
#     scale_fill_scico_d(palette = 'lapaz')+
#     ggtitle("")+
#     theme(text = element_text(size = 30), axis.text.x = element_text(angle = 90, hjust = 1), 
#           axis.text.y = element_text(),legend.position="bottom", legend.direction = "horizontal")
#   
#   
#   
#   
#   
# }

