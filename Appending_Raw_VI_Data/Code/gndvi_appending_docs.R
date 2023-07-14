library(readxl)
library(writexl)
library(dplyr)

#GNDVI Calculation

# files <- list.files(path="C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GNDVI")
# DF <- read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GNDVI",files[1]))
# #reading each file within the range and append them to create one file
# for (f in files[-1]){
#   main <- "C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GNDVI"
#   part2 <- f
#   df <- read.csv(file.path(main, part2)) #read the file
#   DF <- rbind(DF,df) #append the current file
# 
# }
# #writing the appended file
# write.csv(DF,"Models_appended.csv", row.names=FALSE,quote=FALSE)
# DF_final <- subset(DF,select=c(NAME_4,mean,stdDev,year))
# DF_final <- DF_final %>%
#   rename(
#     commune_name = NAME_4 ,
#     gndvi_mean=mean ,
#     gndvi_std=stdDev
#   )


files5 <- list.files(path="C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2")

DFGNV <- read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[1]))


DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[2])) )

DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[3])) )

DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[4])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[5])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[6])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[7])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[8])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[9])) )
DFGNV <- rbind(DFGNV,read.csv(file.path("C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2",files5[10])) )
DFGNV_final <- subset(DFGNV,select=c(region,mean,stdDev,year))

DFGNV_final <- DFGNV_final %>%
  rename(
    commune_name = region ,
    gndvi_mean=mean ,
    gndvi_std=stdDev
  )
write.csv(DFGNV_final,"C:\\Users\\mcket\\Dropbox\\Mining-Mali\\data\\NDVI\\GEE GNDVI2\\DFGNV_final.csv")
