
#-------------------------------------------------------------------------------
# This script generates lists of disaster data information for 
# grouping and plotting the twitter data
#
#-------------------------------------------------------------------------------


disaster_length = list(as.POSIXct(ymd(c("2016-05-29", "2016-05-31"))),
                       as.POSIXct(ymd(c("2016-06-01", "2016-06-08"))),
                       as.POSIXct(ymd(c("2017-07-25", "2017-07-29"))),
                       as.POSIXct(ymd(c("2018-01-05", "2018-02-14"))),
                       as.POSIXct(ymd(c("2021-01-12", "2021-02-20"))),
                       as.POSIXct(ymd(c("2021-07-15", "2021-07-23"))))


peak_discharge = as.POSIXct(ymd(c("2016-06-01","2017-07-26","2018-01-25","2021-02-01","2021-07-15")))

disaster_length2 = list(as.POSIXct(c(NA,NA)),as.POSIXct(c(NA,NA)), as.POSIXct(c(NA,NA)), as.POSIXct(c(NA,NA)), as.POSIXct(c(NA,NA)))
 
 for (i in 1:5){
   disaster_length2[[i]][1] = peak_discharge[i] - days(20)
   disaster_length2[[i]][2] = peak_discharge[i] + days(20)
 }


name_disaster = c("Braunsbach,Simbach", "Goettingen,Brunsvik", "Bündingen,Rhine", "Hessen", "Ahr")
name_disaster2 = c("Braunsbach\nSimbach", "Goettingen\nBrunsvik", "Bündingen\nRhine", "Hessen", "Ahr")
id = c("E1", "E2", "E3", "E4", "E5")
group_id = c("EG1", "E2", "EG2", "EG2" , "EG1")
deaths = c(5,0,0,0,189)
type_disaster = c("flash", "flash", "riverine", "riverine", "riverine", "flash" )
ret_period = c(">100", ">100", "unknown", "2-20", "unknown", ">100")