#with previous year NDVIremotes::install_github("r-spatial/rgee")

packages <- c(
  "tidyverse",
  "sf",
  "haven",
  "gridExtra",
  "cowplot",
  "patchwork",
  "RColorBrewer",
  "corrplot"
)

pacman::p_load(packages, character.only = TRUE)

# Global setting ===========
user <- "Matt"

# if (user == "Matt") {
#   input <- "C:/Users/mcket/input/Mining-Mali"
#   gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
# }


if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Making_VI_Maps_sumstats")
  input <- file.path(project,"Input")
  output <- file.path(project,"Output")
  output_gcvi <- file.path(output,"GCVI")
  output_ndvi <- file.path(output,"NDVI")
  output_gndvi <- file.path(output,"GNDVI")
  output_evi <- file.path(output,"EVI")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}

# Load NDVI data
dat_ndvi <- read_xlsx(file.path(input, "df_ndvi_final.xlsx"))

# Load Mali commune shapefile data
dat <- read_rds(file.path(input, "gadm36_MLI_4_sf.rds"))

df_ndvi <- right_join(dat, dat_ndvi, by = c("NAME_4" = "commune_name"))
df_ndvi <- merge(dat, dat_ndvi, by.x = c("NAME_4"),by.y= c("commune_name"),all.y=TRUE)

# df_anti_merge <- anti_join(dat, dat_ndvi, by.x = c("NAME_4"),by.y = c("commune_name"))

df_ndvi <- df_ndvi %>% 
  group_by(NAME_4) %>% 
  mutate(
    NDVI_mean_mean = mean(NDVI_mean),
    NDVI_mean_dev = (NDVI_mean - NDVI_mean_mean) / NDVI_mean_mean
  ) %>% 
  ungroup()

ndvi_map_list <- map(
  seq(2010,2019), 
  function(x) ggplot() +
    geom_sf(
      data = df_ndvi %>% filter(year == x), 
      aes(fill = NDVI_mean),
      lwd = 0.03
    ) +
    scale_fill_distiller(
      breaks = seq(0, 1, 0.1),
      limits = c(0, 1),
      type = "div",
      palette = "RdYlGn",
      direction = 1
    ) +
    theme_classic() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      legend.title = element_text(size = 20),
      legend.text = element_text(size = 15),
      plot.title = element_text(size = 45)
    ) +
    ggtitle(str_interp("Year: ${x}")) +
    guides(
      fill = guide_colourbar(
        title = "NDVI",
        title.position = "top",
        barwidth = 30,
        barheights = 6
      )
    )
)

combined <- eval(
  parse(text = paste(sapply(10:10, function(x) str_interp("ndvi_map_list[[${x}]]")), collapse = " + "))
) +
  plot_layout(guides = "collect") & theme(legend.position = "bottom")

ggsave(
  filename = file.path(output_ndvi, "ndvi_map.png"),
  plot = combined,
  height = 12,
  width = 12
)





# Load GNDVI data
dat_gndvi <- read_xlsx(file.path(input, "df_gndvi_final.xlsx"))

# Load Mali commune shapefile data
dat <- read_rds(file.path(input, "gadm36_MLI_4_sf.rds"))

df_gndvi <- right_join(dat, dat_gndvi, by = c("NAME_4" = "commune_name"))
df_gndvi <- merge(dat, dat_gndvi, by.x = c("NAME_4"),by.y= c("commune_name"),all.y=TRUE)

df_gndvi <- df_gndvi %>% 
  group_by(NAME_4) %>% 
  mutate(
    GNDVI_mean_mean = mean(GNDVI_mean),
    GNDVI_mean_dev = (GNDVI_mean - GNDVI_mean_mean) / GNDVI_mean_mean
    ) %>% 
  ungroup()
  
gndvi_map_list <- map(
  seq(2010,2019), 
  function(x) ggplot() +
    geom_sf(
      data = df_gndvi %>% filter(year == x), 
       aes(fill = GNDVI_mean_mean),
       lwd = 0.03
       ) +
    scale_fill_distiller(
      breaks = seq(0, 1, 0.1),
      limits = c(0, 1),
      type = "div",
      palette = "RdYlGn",
      direction = 1
      ) +
    theme_classic() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      legend.title = element_text(size = 20),
      legend.text = element_text(size = 15),
      plot.title = element_text(size = 45)
      ) +
    ggtitle(str_interp("Year: ${x}")) +
    guides(
      fill = guide_colourbar(
        title = "GNDVI",
        title.position = "top",
        barwidth = 30,
        barheights = 6
      )
    )
  )
  
combined <- eval(
  parse(text = paste(sapply(10:10, function(x) str_interp("gndvi_map_list[[${x}]]")), collapse = " + "))
  ) +
  plot_layout(guides = "collect") & theme(legend.position = "bottom")

ggsave(
  filename = file.path(output_gndvi, "gndvi_map.png"),
  plot = combined,
  height = 12,
  width = 12
)





####GCVI 
# Load gcvi data
dat_gcvi1 <- read_xlsx(file.path(input, "df_gcvi_final.xlsx"))
dat_gcvi <- dat_gcvi1 %>%  mutate(commune_name = recode(commune_name, "Sony Aliber" = "Sony-Aliber", 
                                                        "Guidimakan Keri Kafo"= "Guidimakan Keri Kaff",
                                                        "Same Diomgoma"= "Same Diomboma",
                                                        "Bougaribaya"= "Bougarybaya",
                                                        "Kourouninkoto"= "Kourounikoto",
                                                        "Nioro"= "Nioro Commune",
                                                        "Nioro Tougoune Rangabe"= "Nioro Tougoune Ranga",
                                                        "Tin-Essako"= "Tinessako",
                                                        "Sebecoro I"= "Sebecoro 1",
                                                        "Koulikoro Commune"= "Koulikoro",
                                                        "Timniri"= "Timiri",
                                                        "Niansanarie"= "Niansanari",
                                                        "Ouroube Doudde"= "Ouroube Doude",
                                                        "Baroueli"= "Baraoueli",
                                                        "Fakola"= "Fakola-Kol",
                                                        "Songo-Doubacore"= "Songo Doubakore",
                                                        "Hanzakoma"= "Hamzakona",
                                                        "Soboundou"= "Souboundou",
                                                        "Baguineda-Camp" = "Baguineda"
                                                        
))
# Load Mali commune shapefile data
dat <- read_rds(file.path(input, "gadm36_MLI_4_sf.rds"))
gcvi_nonmerged <- anti_join(dat, dat_gcvi, by = c("NAME_4" = "commune_name"))

df_gcvi <- right_join(dat, dat_gcvi, by = c("NAME_4" = "commune_name"))
df_gcvi <- merge(dat, dat_gcvi, by.x = c("NAME_4"),by.y= c("commune_name"),all.y=TRUE)

df_gcvi <- df_gcvi %>% 
  group_by(NAME_4) %>% 
  mutate(
    gcvi_mean_mean = mean(GCVI_mean),
    gcvi_mean_dev = (GCVI_mean - gcvi_mean_mean) / gcvi_mean_mean
  ) %>% 
  ungroup()

gcvi_map_list <- map(
  seq(2019,2019), 
  function(x) ggplot() +
    geom_sf(
      data = df_gcvi %>% filter(year == x), 
      aes(fill = GCVI_mean),
      lwd = 0.03
    ) +
    scale_fill_distiller(
      breaks = seq(0, 5.5, 1),
      limits = c(0, 5.5),
      type = "div",
      palette = "RdYlGn",
      direction = 1
    ) +
    theme_classic() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      legend.title = element_text(size = 20),
      legend.text = element_text(size = 15),
      plot.title = element_text(size = 45)
    ) +
    ggtitle(str_interp("Year: ${x}")) +
    guides(
      fill = guide_colourbar(
        title = "GCVI ",
        title.position = "top",
        barwidth = 30,
        barheights = 6
      )
    )
)

combined <- eval(
  parse(text = paste(sapply(1:1, function(x) str_interp("gcvi_map_list[[${x}]]")), collapse = " + "))
) +
  plot_layout(guides = "collect") & theme(legend.position = "bottom")

ggsave(
  filename = file.path(output_gcvi, "gcvi_map.png"),
  plot = combined,
  height = 12,
  width = 12
)
# ___________________________________________________________________________________________________________
##Standard Deviation Map

# ___________________________________________________________________________________________________________


dat_gcvi <- read_xlsx(file.path(input, "df_gcvi_final.xlsx"))

# Load Mali commune shapefile data
dat <- read_rds(file.path(input, "gadm36_MLI_4_sf.rds"))

df_gcvi <- right_join(dat, dat_gcvi, by = c("NAME_4" = "commune_name"))
df_gcvi <- merge(dat, dat_gcvi, by.x = c("NAME_4"),by.y= c("commune_name"),all.y=TRUE)

df_gcvi <- df_gcvi %>% 
  group_by(NAME_4) %>% 
  mutate(
    gcvi_mean_mean = mean(GCVI_mean),
    gcvi_mean_dev = (GCVI_mean - gcvi_mean_mean) / gcvi_mean_mean,
    gcvi_sd = sd(GCVI_mean,na.rm=TRUE)
  ) %>% 
  ungroup()
gcvi_map_list <- map(
  seq(2010,2019), 
  function(x) ggplot() +
    geom_sf(
      data = df_gcvi %>% filter(year == x), 
      aes(fill = gcvi_sd),
      lwd = 0.03
    ) +
    scale_fill_distiller(
      breaks = seq(0, 2, 0.2),
      limits = c(0, 2),
      type = "seq",
      palette ="Blues",
      direction = 1
    ) +
    theme_classic() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      legend.title = element_text(size = 20),
      legend.text = element_text(size = 15),
      plot.title = element_text(size = 45)
    ) +
    # ggtitle(str_interp("Year: ${x}")) +
    ggtitle(str_interp("Years: 2010-2019")) +
    guides(
      fill = guide_colourbar(
        title = "GCVI(Standard Deviation Across Years) ",
        title.position = "top",
        barwidth = 30,
        barheights = 6
      )
    )
)

combined <- eval(
  parse(text = paste(sapply(10:10, function(x) str_interp("gcvi_map_list[[${x}]]")), collapse = " + "))
) +
  plot_layout(guides = "collect") & theme(legend.position = "bottom")

ggsave(
  filename = file.path(output_gcvi, "gcvi_map_deviation.png"),
  plot = combined,
  height = 12,
  width = 12
)


####_________________________________________________________________________________________________________
###Correlation Matrix 


DFEVI_final <- read_xlsx(file.path(input,"df_evi_final.xlsx"))
DFGCI_final <- read_xlsx(file.path(input,"df_gcvi_final.xlsx"))
DFGNV_final <- read_xlsx(file.path(input,"df_gndvi_final.xlsx"))
DFNV_final_cl <- read_xlsx(file.path(input,"df_ndvi_final.xlsx"))
# DFNV_final_cl_hs <- read_xlsx("C:\\Users\\mcket\\input\\Mining-Mali\\data\\NDVI\\GEE NDVI2_HY\\DFNV_hy_final_cl.csv")
results = data.frame(matrix(ncol=4,nrow=7040))
colnames(results) = c('NDVI','GNDVI','GCVI','EVI')
results$NDVI = DFNV_final_cl$NDVI_mean[0:7040]
# results$NDVI_half_season = DFNV_final_cl_hs$ndvi_hy_mean
results$GNDVI = DFGNV_final$GNDVI_mean[0:7040]
results$GCVI = DFGCI_final$GCVI_mean[0:7040]
results$EVI = DFEVI_final$evi_mean[0:7040]
cor_data <- results[,c(1,2,3,4)]
cor_matrix = cor(cor_data,use="complete.obs")
colnames(cor_matrix) <- c("NDVI", "GNDVI", "GCVI", "EVI")
rownames(cor_matrix) <- c("NDVI", "GNDVI","GCVI", "EVI")
cor_matrix
cor_df <- data.frame(cor_matrix)
write_xlsx(cor_df,file.path(output,"correlation_matrix.xlsx"))
stargazer(cor_df,summary=F,title="Correlation Matrix",align=T,digits=4,out= file.path(output,"correlation_matrix.txt"),no.space=T,flip=F)
png(height=1000, width=1000, file=file.path(output,"vi_correlation.png"), type = "cairo")

corrplot(cor_matrix, method = "circle",addCoef.col="white",tl.cex = 2.0,tl.col = "black",col.lim=c(.5,1),col = COL2('PRGn'))
dev.off()










