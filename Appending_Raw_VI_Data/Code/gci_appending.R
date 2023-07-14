library(readxl)
library(writexl)
library(dplyr)

# #GCI Appending
# files5 <- list.files(path="C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GCI")
# DFGC <- read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GCI",files5[1]))
# #reading each file within the range and append them to create one file
# for (f2 in files5[-1]){
#   main <- "C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GCI"
#   part2 <- f2
#   df <- read.csv(file.path(main, part2)) #read the file
#    <- rbind(DF,df) #append the current file
#   
# }
# #writing the appended file
# # write.csv(DFGC,"Models_appended.csv", row.names=FALSE,quote=FALSE)
# # DFGC_final <- subset(DFGC,select=c(NAME_4,mean,stdDev,year))
# # DFGC_final <- DFGC_final %>%
# #   rename(
# #     commune_name = NAME_4 ,
# #     gci_mean=mean ,
# #     gci_std=stdDev 
# #   )

 files5 <- list.files(path="C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2")

  DFGC <- read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[1]))
 
  View(DFGC)
 DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[2])) )
 # View(DFGC)
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[3])) )
 # View(DFGC)
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[4])) )
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[5])) )
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[6])) )
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[7])) )
  DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[8])) )
 DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[9])) )
 DFGC <- rbind(DFGC,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2",files5[10])) )
 
 DFGC_final <- subset(DFGC,select=c(region,mean,stdDev,year))
 DFGC_final <- DFGC_final %>%
   rename(
     commune_name = region ,
     gci_mean=mean ,
     gci_std=stdDev
   )
 write.csv(DFGC_final,"C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GCI2\\DFGC_final.csv")
 
 
 