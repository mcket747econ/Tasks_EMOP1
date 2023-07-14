library(readxl)
library(writexl)
library(dplyr)



##GCVI

user <- "Matt"


if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Appending_Raw_VI_Data")
  input <- file.path(project,"Input/Final_Paper_Regressions_Dataset_GCI")
  output <- file.path(project,"Output")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}



files5 <- list.files(input)

DFGCI <- read.csv(file.path(input,files5[1]))


DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[2])) )

DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[3])) )

DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[4])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[5])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[6])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[7])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[8])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[9])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[10])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[11])) )
DFGCI <- rbind(DFGCI,read.csv(file.path(input,files5[12])) )

DFGCI_final <- subset(DFGCI,select=c(region,mean,stdDev,year))

DFGCI_final <- DFGCI_final %>%
  rename(
    commune_name = region ,
    GCVI_mean=mean ,
    GCVI_std=stdDev
  )
write_xlsx(DFGCI_final,file.path(output,"df_gcvi_final.xlsx"))
write_xlsx(DFGCI_final,file.path("Final_GCVI_Regressions/Input","df_gcvi_final.xlsx"))

###NDVI_________________________________________________________________________________________________________________
user <- "Matt"


if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Appending_Raw_VI_Data")
  input <- file.path(project,"Input/Final_RegressionsData_NDVI")
  output <- file.path(project,"Output")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}



files5 <- list.files(input)

DFNDVI <- read.csv(file.path(input,files5[1]))


DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[2])) )

DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[3])) )

DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[4])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[5])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[6])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[7])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[8])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[9])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[10])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[11])) )
DFNDVI <- rbind(DFNDVI,read.csv(file.path(input,files5[12])) )

DFNDVI_final <- subset(DFNDVI,select=c(NAME_4,mean,stdDev,year))

DFNDVI_final <- DFNDVI_final %>%
  rename(
    commune_name = NAME_4 ,
    NDVI_mean=mean ,
    NDVI_std=stdDev
  )
write
write_xlsx(DFNDVI_final,file.path(output,"df_ndvi_final.xlsx"))

###GNDVI__________________________________________________________________________________________________________
user <- "Matt"


if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Appending_Raw_VI_Data")
  input <- file.path(project,"Input/Final_Regressions_Dataset_GNDVI")
  output <- file.path(project,"Output")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}



files5 <- list.files(input)

DFGNDVI <- read.csv(file.path(input,files5[1]))


DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[2])) )

DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[3])) )

DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[4])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[5])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[6])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[7])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[8])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[9])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[10])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[11])) )
DFGNDVI <- rbind(DFGNDVI,read.csv(file.path(input,files5[12])) )

DFGNDVI_final <- subset(DFGNDVI,select=c(region,mean,stdDev,year))

DFGNDVI_final <- DFGNDVI_final %>%
  rename(
    commune_name = region ,
    GNDVI_mean=mean ,
    GNDVI_std=stdDev
  )
write_xlsx(DFGNDVI_final,file.path(output,"df_gndvi_final.xlsx"))











































###EVI_________________________________________________________________________________________________________________
if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Appending_Raw_VI_Data")
  input <- file.path(project,"Input/Final_Regressions_EVI_Correct")
  output <- file.path(project,"Output")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}



files5 <- list.files(input)

DFEVI <- read.csv(file.path(input,files5[1]))


DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[2])) )

DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[3])) )

DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[4])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[5])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[6])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[7])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[8])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[9])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[10])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[11])) )
DFEVI <- rbind(DFEVI,read.csv(file.path(input,files5[12])) )

DFEVI_final <- subset(DFEVI,select=c(region,mean,stdDev,year))

DFEVI_final <- DFEVI_final %>%
  rename(
    commune_name = region ,
    evi_mean=mean ,
    evi_std=stdDev
  )
write_xlsx(DFEVI_final,file.path(output,"df_evi_final.xlsx"))
