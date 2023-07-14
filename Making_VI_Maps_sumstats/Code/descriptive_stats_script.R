#Script To Obtain Descriptive Statistics For the Mali Project
#Matt McKetty _4_22

packages <- c(
  "tidyverse",
  "sf",
  "haven",
  "lfe",
  "stargazer",
  "scales",
  "readxl",
  "writexl",
  "ggplot2",
  "cowplot",
  "patchwork",
  "RColorBrewer",
  "corrplot",
  "gridExtra"
  
)
options(scipen = 999)

###FixStarGaze
# detach("package:stargazer",unload=T)
# # Delete it
# remove.packages("stargazer")
# # Download the source
# download.file("https://cran.r-project.org/src/contrib/stargazer_5.2.3.tar.gz", destfile = "stargazer_5.2.3.tar.gz")
# # Unpack
# untar("stargazer_5.2.3.tar.gz")
# # Read the sourcefile with .inside.bracket fun
# stargazer_src <- readLines("stargazer/R/stargazer-internal.R")
# # Move the length check 5 lines up so it precedes is.na(.)
# stargazer_src[1990] <- stargazer_src[1995]
# stargazer_src[1995] <- ""
# # Save back
# writeLines(stargazer_src, con="stargazer/R/stargazer-internal.R")
# # Compile and install the patched package
# install.packages("stargazer", repos = NULL, type="source")

pacman::p_load(packages, character.only = TRUE)

# Global setting ===========
# user <- "Matt"
# 
# if (user == "Matt") {
#   dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
#   gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
# }

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




# Load EMOP GPS data
df <- read_dta(
  file.path(
    input, 
    "emop_halfyear_cons_for_regressions.dta"
  )
)

cons_list <- c(
  "annual_consom_total","annual_consom_food",
  "tot_inc","tot_exp",
  "annual_consom_nonfood",
  "consom_total", "consom_food", 
  "consom_nonfood", "grain_cons",
  "grain_auto", "grain_purchase",
  "grain_gift","meat_cons", "meat_gift",
  "meat_auto", "meat_purchase",
  "rice_cons", "rice_gift",
  "rice_auto", "rice_purchase",
  "educ_cons", "leisure_cons",
  "alcool_achat", "sante_achat", 
  "cloth_achat", "logement_achat", 
  "meuble_achat", "transport_achat", 
  "comm_achat", "restaurant_achat", "bien_autre_achat",
  "milk_cons","fish_cons","vegetable_cons","bread_cons","oil_cons","tea_cons",
  "butter_cons", "peanut_cons","maggi_cons","sugar_cons")                                                                                  

percap_cons_list <- c(
  "percap_consom_total", "percap_consom_food", 
  "percap_consom_nonfood", "percap_grain_cons",
  "percap_grain_auto", "percap_grain_purchase",
  "percap_grain_gift"
)

extra_percap_cons_list <- c(
  "percap_meat_cons", "percap_meat_gift",
  "percap_meat_auto", "percap_meat_purchase",
  "percap_rice_cons", "percap_rice_gift",
  "percap_rice_auto", "percap_rice_purchase",
  "percap_educ_cons", "percap_leisure_cons"
  
)

df$children613 = df$size_hh -(df$children05 + df$n_member14)
df$OECD = (df$n_member14-(df$n_member14-1)) + 0.5*(df$n_member14-1)+ 0.3*(df$children05+df$children613)



# df <- filter(df, consom_total > 0, consom_food > 0,
#   consom_nonfood > 0,grain_cons > 0,
#   grain_auto > 0, grain_purchase > 0,
#   grain_gift > 0)

# Create outcome variables
df_reg <- df %>% 
  mutate(
    # across(
    #   .col = all_of(cons_list),
    #   .fns = function(x) x / sqrt(size_hh), #Square-Root Scale
    #   .names = "percap_sqrt_{col}"
    # ),
    across(
      .col = all_of(cons_list),             #OECd-Modified Scale
      .fns = function(x) x / ((n_member14-(n_member14-1))*1 +0.5*(n_member14 - 1)+0.3*(children05+children613)),
      .names = "pc_od_{col}"
    ),
    # across(
    #   .col = c(all_of(cons_list), starts_with("percap_")),
    #   .fns = function(x) x / 1000,
    #   .names = "{col}"
    # ),
    #across(
    #.col = all_of(cons_list)
    #.fns = function(x)x/((n_member14-(n_member14-1))*1 +0.5*(n_member14 - 1)
    #+0.3*(children05+children613))
    
    
    across(
      .col = c(all_of(cons_list), starts_with("pc_")),
      .fns = function(x) ifelse(x <= 0, NA, log(x)),
      .names = "lg_{col}"
    ),
    across(
      .col = c(all_of(cons_list), starts_with("pc_")),
      .fns = function(x) asinh(x),
      .names = "ihs_{col}"
    ),
    gci_year = ifelse(half_year==1, year-1, year),
    half_year = as.factor(half_year)
  )


# Load NDVI data
# dat_ndvi <- read_csv(file.path(dropbox, "data/NDVI/ndvi_modis_yr_comm.csv"))

# # Load Mali commune shapefile data
# dat <- read_rds(file.path(dropbox, "data/raw/GADM/gadm36_MLI_4_sf.rds"))
# 
# # Collapse EMOP data at commune level so that we can merge it with shapefile
# df_gps <- df_reg %>% 
#   group_by(commune_name) %>%
#   slice(1) %>%
#   select(commune_name, y, x) %>%
#   rename(y = y, x=x)
# 
# # Convert df_gps to sf file
# df_sf <- st_as_sf(
#   df_gps, 
#   coords = c("x", "y"), # For coords, longitude first, and latitude second. 
#   crs = "WGS84"
#   ) 
# 
# # Merge GPS coordinates and shapefile data so that for each commune we obtain commune polygon
# df_polygon <- st_join(
#   df_sf,
#   dat[c("NAME_4")]
#   )
# 
# df_ndvi <- as_tibble(left_join(df_polygon, dat_ndvi, by = c("NAME_4" = "id")))

# Merge EMOP Expenditure data and NDVI data.
# For the first three quarters, use the previous-year NDVI.
# For the last quarter, use the same-year NDVI
DFGC_final <- read_xlsx(file.path(input,"df_gcvi_final.xlsx"))
df_reg <- left_join(df_reg, DFGC_final, by = c("commune_name", "gci_year" = "year"))
df_reg$food_share <- df_reg$consom_food/df_reg$consom_total
df_reg$GCVI_meansc_sq <- (df_reg$GCVI_mean)^2
df_reg <- df_reg[df_reg$annual_consom_food != 0 & df_reg$annual_consom_nonfood!=0,]
df_reg$log_gci <- log(df_reg$GCVI_mean)


df_nona <- data.frame(df_reg %>% filter(!if_all(c(pc_od_consom_nonfood,pc_od_grain_cons),is.na)))
stargazer(df_reg %>% filter(!if_any(c(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood,
                               pc_od_grain_cons,pc_od_grain_auto,pc_od_grain_gift,pc_od_grain_purchase,
                               pc_od_rice_cons,pc_od_rice_auto,pc_od_rice_gift,pc_od_rice_purchase,
                               pc_od_meat_cons,pc_od_oil_cons),is.na)),
          out = "descriptive_stats.txt",omit.summary.stat = c("min",  "max"),
          covariate.labels = c("Total Per-Capita Consumption","Total Per-Capita Food Consumption","Total Per Capita Non-Food Consumption",
          "Total Per-Capita Grain Consumption", "Total Per-Capita Grain Auto-Consumption", "Total Per-Capita Grain Gift Consumption","Total Per-Capita Purchased Grain Consumption",
          "Total Per-Capita Rice Consumption", "Total Per-Capita Rice Auto-Consumption", "Total Per-Capita Rice Gift Consumption","Total Per-Capita Purchased Rice Consumption",
          "Total Per-Capita Meat Consumption", "Total Per-Capita Peanut Oil Auto-Consumption")) 
         
stargazer(df_reg %>% filter(urban ==0) %>%
          select(c(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood,
                                      pc_od_grain_cons,pc_od_grain_auto,pc_od_grain_gift,pc_od_grain_purchase,
                                      pc_od_rice_cons,pc_od_rice_auto,pc_od_rice_gift,pc_od_rice_purchase,
                                      pc_od_meat_cons,pc_od_oil_cons)),
          out = "descriptive_stats.txt",omit.summary.stat = c("min", "max"),
          covariate.labels = c("Per-Capita Consumption","Per-Capita Food Consumption","PerCapita Non-Food Consumption",
                               "Total Per-Capita Grain Consumption", "Total Per-Capita Grain Auto-Consumption", "Total Per-Capita Grain Gift Consumption","Total Per-Capita Purchased Grain Consumption",
                               "Total Per-Capita Rice Consumption", "Total Per-Capita Rice Auto-Consumption", "Total Per-Capita Rice Gift Consumption","Total Per-Capita Purchased Rice Consumption",
                               "Total Per-Capita Meat Consumption", "Total Per-Capita Peanut Oil Auto-Consumption"))

# stargazer(df_new_cl %>% select(c(pc_od_consom_nonfood,pc_od_consom_alcool,pc_od_consom_sante,
#                                  pc_od_cloth_achat,pc_od_logement_achat,pc_od_educ_cons,pc_od_comm_tel_achat,
#                                  pc_od_transport_achat,pc_od_restaurant_achat,pc_od_,pc_od_rice_purchase,
#                                  pc_od_meat_cons,pc_od_oil_cons)),
#           out = "descriptive_stats.txt",omit.summary.stat = c("min", "max"),
#           covariate.labels = c("Total Per Capita Non-Food Consumption",
#                                "Total Per-Capita Alcohol Consumption","Total Per-Capita Health Consumption",
#                                "Total Per-Capita Clothing Consumption","Total Per-Capita Housing Consumption",
#                                "Total Per-Capita Education ", "Total Per-Capita Telephone(2018 and 2019 Only)", 
#                                "Total Per-Capita Transportation","Total Per-Capita Restaurant Spending",
#                                "Total Per-Capita Other Non-Food Expenditures"))

stargazer(as.data.frame(df_reg %>% filter(urban ==0) %>%
            select(c(pc_od_grain_cons,pc_od_grain_auto,pc_od_grain_gift,pc_od_grain_purchase,pc_od_rice_cons,pc_od_meat_cons,
                     pc_od_cloth_achat,pc_od_logement_achat,pc_od_educ_cons,
                     ))), title = "Descriptive Statistics- Rural Households(OECD Equivalence Scale-CFA Francs)",
          out =file.path(output,"descriptive_stats_rural.tex"),omit.summary.stat = c("min", "max"),
          covariate.labels = c("Grain Consumption","Grain Auto-Consumption", " Grain Gift Consumption"," Purchased Grain Consumption",
                               "Rice Consumption","Meat Consumption",
                               " Clothing Consumption"," Housing Consumption",
                               " Education "
                               ))





# df_new_cl_df <- data.frame(df_new_cl)
# stargazer(df_new_cl_df %>% select(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood),
#           out = file.path(output,"descriptive_stats_rural.tex"),omit.summary.stat = c("min", "max"),
#           covariate.labels = c("Total Per-Capita Consumption","Total Per-Capita Food Consumption", "Nonfood"))
# 
# mean(df_new_cl$pc_od_annual_consom_nonfood)
# sum(is.na(df_new_cl$pc_od_consom_nonfood))
          

df_nona <- df_reg %>% drop_na(GCVI_mean)
df_nona <- data.frame(df_nona)
GCVI_mean_byyear <- df_nona%>% group_by(year) %>% summarise_at(vars(GCVI_mean),list(mean))
consump_by_year <- df_nona%>% group_by(year) %>% summarise_at(vars(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood),list(mean))
consump_by_year_rural <- df_nona%>% filter(urban==0) %>%group_by(year) %>% summarise_at(vars(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood),list(mean))
consump_by_year_urban <- df_nona%>% filter(urban==1) %>%group_by(year) %>% summarise_at(vars(pc_od_consom_total,pc_od_consom_food,pc_od_consom_nonfood),list(mean))

GCVI_mean_consump <- merge(GCVI_mean_byyear,consump_by_year,by="year")
GCVI_mean_consump_rural <- merge(GCVI_mean_byyear,consump_by_year_rural,by="year")
GCVI_mean_consump_urban <- merge(GCVI_mean_byyear,consump_by_year_urban,by="year")

coeff <- 1/15000

# ggplot(GCVI_mean_consump, aes(x=year)) +
#   
#   geom_line( aes(y=GCVI_mean)) + 
#   geom_line( aes(y=pc_od_consom_total/15000)) + # Divide by 10 to get the same range than the temperature
#   
#   scale_y_continuous(
#     
#     # Features of the first axis
#     name = "Mean GCI",
#     
#     # Add a second axis and specify its features
#     sec.axis = sec_axis(~.*coeff, name="Per-Capita Consumption"))
# + theme_ipsum()

train_sec <- function(primary, secondary, na.rm = TRUE) {
  # Thanks Henry Holm for including the na.rm argument!
  from <- range(secondary, na.rm = na.rm)
  to   <- range(primary, na.rm = na.rm)
  # Forward transform for the data
  forward <- function(x) {
    rescale(x, from = from, to = to)
  }
  # Reverse transform for the secondary axis
  reverse <- function(x) {
    rescale(x, from = to, to = from)
  }
  list(fwd = forward, rev = reverse)
}

sec <- with(GCVI_mean_consump,train_sec(GCVI_mean,pc_od_consom_total))


g <- ggplot(GCVI_mean_consump, aes(year))+
  # ggtitle('Relationship Between GCVI and Per-Capita Expenditure ') +
  geom_line(aes(y = GCVI_mean, color = "Averaged Maximum GCVI"),size=2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_total), color = "Mean Expenditure(OECD)"),size =2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_food), color = "Mean Food Expenditure(OECD)"),size =2) +
  # geom_line(aes(y = sec$fwd(pc_od_consom_nonfood), color = "Mean Non-Food Expenditure(OECD)"),size =2) +
  scale_y_continuous(
    name = "Averaged Maximum GCVI",
    sec.axis = sec_axis(~sec$rev(.), name = "Per-Capita Expenditure(CFA Francs)")) +
  scale_x_continuous(labels = scales::number_format(accuracy = 1)) +
  theme(legend.title =element_text(colour = "Black",size =12,face="bold"),legend.key.size = unit(.2, 'cm'),legend.text=element_text(colour="Black",size=7,face="bold"), 
       legend.position = "bottom",axis.text = element_text(face="bold"),axis.title = element_text(face="bold"))+
  labs(x="Year") +
  scale_color_discrete(name="Legend")

g
ggsave("gcvi_all_consom.png",g,path=output_gcvi, 
       width = 5, height = 5, dpi = 300, units = "in", device='png')



##Rural
  # theme(legend.title = "Legend",legend.text=element_text(colour="Blue",size=10,face="bold"))

train_sec <- function(primary, secondary, na.rm = TRUE) {
  # Thanks Henry Holm for including the na.rm argument!
  from <- range(secondary, na.rm = na.rm)
  to   <- range(primary, na.rm = na.rm)
  # Forward transform for the data
  forward <- function(x) {
    rescale(x, from = from, to = to)
  }
  # Reverse transform for the secondary axis
  reverse <- function(x) {
    rescale(x, from = to, to = from)
  }
  list(fwd = forward, rev = reverse)
}

sec <- with(GCVI_mean_consump_rural,train_sec(GCVI_mean,pc_od_consom_total))


g_rural <- ggplot(GCVI_mean_consump_rural, aes(year))+
  # ggtitle('Relationship Between GCVI and Per-Capita Expenditure For Rural Households') +
  geom_line(aes(y = GCVI_mean, color = "Averaged Maximum GCVI"),size=2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_total), color = "Mean Expenditure(OECD)"),size =2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_food), color = "Mean Food Expenditure(OECD)"),size =2) +
  # geom_line(aes(y = sec$fwd(pc_od_consom_nonfood), color = "Mean Non-Food Expenditure(OECD)"),size =2) +
  scale_y_continuous(
    name = "Averaged Maximum GCVI",
    sec.axis = sec_axis(~sec$rev(.), name = "Per-Capita Expenditure(CFA Francs)")) +
  scale_x_continuous(labels = scales::number_format(accuracy = 1)) +
  theme(legend.title =element_text(colour = "Black",size =12,face="bold"),legend.key.size = unit(.2, 'cm'),legend.text=element_text(colour="Black",size=7,face="bold"), 
      legend.position = "bottom",axis.text = element_text(face="bold"),axis.title = element_text(face="bold"))+
  labs(x="Year") +
  scale_color_discrete(name="Legend")

g_rural
ggsave("gcvi_all_consom_rural.png",g_rural,path=output_gcvi, 
       width = 5, height = 5, dpi = 300, units = "in", device='png')


#---------------------------------------------------------------------------------------
#Urban Households
sec <- with(GCVI_mean_consump_urban,train_sec(GCVI_mean,pc_od_consom_total))


g_urban <- ggplot(GCVI_mean_consump_urban, aes(year))+
  # ggtitle('Relationship Between GCVI and Per-Capita Expenditure For Urban Households') +
  geom_line(aes(y = GCVI_mean, color = "Averaged Maximum GCVI"),size=2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_total), color = "Mean Expenditure(OECD)"),size =2) +
  geom_line(aes(y = sec$fwd(pc_od_consom_food), color = "Mean Food Expenditure(OECD)"),size =2) +
  # geom_line(aes(y = sec$fwd(pc_od_consom_nonfood), color = "Mean Non-Food Expenditure(OECD)"),size =2) +
  scale_y_continuous(
    name = "Averaged Maximum GCVI",
    sec.axis = sec_axis(~sec$rev(.), name = "Per-Capita Expenditure(CFA Francs)"),
    breaks = pretty_breaks(),
    labels = scales::comma,
    ) +
  scale_x_continuous(labels = scales::number_format(accuracy = 1)) +
  theme(legend.title =element_text(colour = "Black",size =12,face="bold"),legend.key.size = unit(.2, 'cm'),legend.text=element_text(colour="Black",size=7,face="bold"), 
       legend.position = "bottom",axis.text = element_text(face="bold"),axis.title = element_text(face="bold"))+
  labs(x="Year") +
  scale_color_discrete(name="Legend")

g_urban
ggsave("gcvi_all_consom_urban.png",g_urban,path=output_gcvi, 
       width = 5, height = 5, dpi = 300, units = "in", device='png')









