

packages <- c(
  "tidyverse",
  "sf",
  "haven",
  "lfe",
  "stargazer",
  "readxl",
  "writexl"
)

pacman::p_load(packages, character.only = TRUE)

# Global setting ===========
user <- "Matt"

if (user == "Matt") {
  setwd("C:/Users/mcket/OneDrive/Documents/Tasks_EMOP")
  # Tasks <- "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
  project <- file.path(getwd(),"Final_GCVI_Regressions")
  input <- file.path(project,"Input")
  output <- file.path(project,"Output")
  dropbox <- "C:/Users/mcket/Dropbox/Mining-Mali"
  gitlab <- "C:/Users/mcket/Box/Mali/mali_climate_conflict_matt_fork"
}

# Load EMOP Expenditure data
# df <- read_dta(
#   file.path(
#     dropbox, 
#     "data/cleaned/EMOP/matt_output/emop_halfyear_cons_2011_2019.dta"
#   )
# )

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
  "comm_achat","restaurant_achat", "bien_autre_achat",
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

# Merge EMOP consumption data and NDVI data.
# For the first three quarters, use the previous-year NDVI.
# For the last quarter, use the same-year NDVI
DFGC_final <- read_xlsx(file.path(input,"df_gcvi_final.xlsx"))
df_reg <- left_join(df_reg, DFGC_final, by = c("commune_name", "gci_year" = "year"))
df_reg$food_share <- df_reg$consom_food/df_reg$consom_total
df_reg$gci_meansc_sq <- (df_reg$GCVI_mean)^2
df_reg <- df_reg[df_reg$annual_consom_food != 0 & df_reg$annual_consom_nonfood!=0,]
df_reg$log_gci <- log(df_reg$GCVI_mean)


##################Testing That Consumption of Different Categories Sum Correctly

# df_reg$consom_difference <- df_reg$consom_total - (df_reg$consom_food + df_reg$consom_nonfood)
# 
# mean(df_reg$consom_difference)












###########################################################################
#knitr::opts_chunk$set(echo = TRUE)
# Function to run regressions and save outputs
reg_cons_ndvi <- function(
    df, output_file, outcome, table_caption, col_labels,
    rhs_var1 = "GCVI_mean",
    #rhs_var2 = "ramadan_1",
    # rhs_var3 = "ramadan_2",
    keep_var = c("GCVI_mean"),
    #keep_var = c("gndvi_mean","ndvi_meansc_sq"),
    cov_labels = c("Averaged Maximum GCVI")
    #cov_labels = c("NDVI Mean", "NDVI Mean-Squared")
) {
  
  # hh_control <- c(
  #  "children05", "n_member14", "hhead_f", "hhead_age",
  # "hhead_poly", "hhead_livest", "hhead_fish", "married"
  #)
  hh_control <- c(
    "literate_hhh","female_hhh", "n_member14", "fish_hhh", "age_hhh",
    "polyg_hhh", "herder_hhh", "farmer_hhh", "n_marrmale"
  )
  
  res_model <- map(outcome, function(x) {
    felm(
      as.formula(
        paste(x,
              #paste(rhs_var1,
              #paste(
              paste(rhs_var1,#paste(c(rhs_var, hh_control), collapse = " + "),
                    "hhid + half_year + year", "0", "commune_name", sep = " | "
              ),
              sep = " ~ ")
      ),
      data = df,
      na.action=na.omit
    )
    # plm(
    #   as.formula(
    #     paste(x,
    #           paste(rhs_var1),
    #           
    #     sep ="~")as.f
    # ),
    # data = df,
    # model = "within",
    # index = c("hhid","quarter_year")
    #   )
    
  })
  mean_outcome = map2_chr(
    res_model, outcome, function(x, y) formatC(colMeans(model.frame(x)[y]), 3, format = "f")
  )
  mean_gci_mean = map_chr(
    res_model, function(x) formatC(colMeans(model.frame(x)["GCVI_mean"]), 3, format = "f")
  )
  sd_gci_mean = map_chr(
    res_model, 
    function(x) formatC(sapply(model.frame(x)["GCVI_mean"], function(x) sd(x, na.rm = TRUE)), 3, format = "f")
  )
  num_col <- length(outcome)
  
  res_model %>%
    stargazer(
      dep.var.labels.include = FALSE,
      column.labels = col_labels,
      covariate.labels = cov_labels,
      keep = keep_var,
      font.size = "normalsize",
      title = table_caption,
      label = output_file,
      add.lines = list(
        c("Household FE", rep("Yes", num_col)),
        #c("Commune FE", rep("Yes", num_col)),
        c("Year FE", rep("Yes", num_col)),
        c("Half-Year FE", rep("Yes", num_col)),
        c("Controls", rep("No", num_col)),
        c("Mean of outcomes", mean_outcome),
        c("Mean of GCVI mean", mean_gci_mean),
        c("SD of GCVI mean", sd_gci_mean)
      ),
      type = "latex",
      # out = file.path(gitlab, "EMOP/Output/tex/mainregressions_logs/GCVI", output_file),
      out = file.path(project, "output", output_file),
      omit.stat = c("adj.rsq", "ser"),
      table.layout = "=#c-t-sa-n",
      digits = 3
    )
}

outcome <- c(
  "log_consom_total", "log_consom_food","ihs_consom_total",
  
  "ihs_consom_food","ihs_consom_nonfood", "ihs_grain_cons",
  "ihs_grain_auto", "ihs_grain_purchase",
  "ihs_grain_gift"
)

outcome_per_capita <- c(
  "log_percap_consom_total", "log_percap_consom_food", 
  "ihs_percap_consom_total","ihs_percap_consom_food",
  "ihs_percap_consom_nonfood", "ihs_percap_grain_cons",
  "ihs_percap_grain_auto", "ihs_percap_grain_purchase",
  "ihs_percap_grain_gift"
)

outcome_per_capita_sqrt <- c(
  "log_percap_sqrt_consom_total", "log_percap_sqrt_consom_food", 
  "ihs_percap_sqrt_consom_total", "ihs_percap_sqrt_consom_food",
  "ihs_percap_sqrt_consom_nonfood", "ihs_percap_sqrt_grain_cons",
  "ihs_percap_sqrt_grain_auto", "ihs_percap_sqrt_grain_purchase",
  "ihs_percap_sqrt_grain_gift"
)

nf_outcome_per_capita_oecd <- c(
  "lg_pc_od_consom_nonfood", "lg_pc_od_alcool_achat",
  "lg_pc_od_sante_achat", "lg_pc_od_cloth_achat",
  "lg_pc_od_logement_achat","lg_pc_od_educ_cons",
  "lg_pc_od_comm_achat","lg_pc_od_transport_achat",
  #"lg_pc_od_restaurant_achat",
  "lg_pc_od_bien_autre_achat"
)

f_outcome_per_capita_oecd <- c(
  "lg_pc_od_consom_food", "lg_pc_od_grain_cons",
  "lg_pc_od_rice_cons", "lg_pc_od_vegetable_cons",
  "lg_pc_od_meat_cons","lg_pc_od_fish_cons",
  "lg_pc_od_bread_cons","lg_pc_od_milk_cons",
  "lg_pc_od_oil_cons"
)

outcome_per_capita_oecd <- c(
  "lg_pc_od_consom_total", "lg_pc_od_consom_food", 
  #"ihs_percap_oecd_consom_total","ihs_percap_oecd_consom_food",
  "lg_pc_od_consom_nonfood", "lg_pc_od_grain_cons",
  "lg_pc_od_grain_auto", "lg_pc_od_grain_purchase",
  "lg_pc_od_grain_gift","lg_pc_od_meat_cons","lg_pc_od_educ_cons"
)
outcome_per_capita_oecd_1 <- c(
  "lg_pc_od_consom_total", "lg_pc_od_consom_food", 
  #"ihs_percap_oecd_consom_total","ihs_percap_oecd_consom_food",
  "lg_pc_od_consom_nonfood", "lg_pc_od_grain_cons",
  "lg_pc_od_rice_cons", "lg_pc_od_meat_cons",
  "lg_pc_od_fish_cons","lg_pc_od_educ_cons", "lg_pc_od_comm_achat"
)
extra_outcome_per_capita_oecd_nonfood<- c(
  "log_percap_oecd_meat_cons",#"ihs_percap_oecd_meat_auto", 
  "ihs_percap_oecd_meat_purchase",
  "ihs_percap_oecd_meat_gift", "ihs_percap_oecd_rice_cons",
  "ihs_percap_oecd_rice_auto", "ihs_percap_oecd_rice_purchase",
  "ihs_percap_oecd_rice_gift","ihs_percap_oecd_comm_tel_cons","ihs_percap_oecd_leisure_cons"
)


col_labels <- c(
  "log Total", "log Food", 
  #"log Total", "IHS Food",
  "log Non-food", "log Grain",
  "log Grain (auto)", "log Grain (buy)",
  "log Grain (gift)","log Meat","log Education"
)


col_labels_1 <- c(
  "log Total", "log Food", 
  #"log Total", "IHS Food",
  "log Non-food", "log Grain",
  "log Rice ", "log Meat",
  "log Fish","Log Education","log Communication"
)

extra_col_labels <- c(
  "log Meat", #"IHS Meat (auto)",
  "IHS Meat (buy)", "IHS Meat (gift)",
  "IHS Rice ", "IHS Rice (auto)",
  "IHS Rice (buy)","IHS Rice (gift)",
  "IHS Education", "IHS Leisure"
)


nf_col_labels <- c(
  "log Total Non-food", 
  "Log Alcohol",
  "log Sante", "log Clothing",
  "log Housing", "log Education",
  "log Communication",
  "log Transport",
  #"Log Restaurants",
  "Log Other Goods"
)

f_col_labels <- c(
  "log Total Food", 
  #"log Total", "IHS Food",
  "log Grain",
  "log Rice", "log Vegetables",
  "log Meat", "log Fish",
  "log Bread",
  "log Milk"
)

table_1_outcomes_ihs <- 
  c("ihs_pc_od_consom_total",
    "ihs_pc_od_consom_food",
    "ihs_pc_od_consom_nonfood")

table_1_labels_ihs <- 
  c("IHS Total Expenditure",
    "IHS Total Food Expenditure",
    "IHS Total Non-Food Expenditure")

#########Table 1 Regression
reg_cons_ndvi(
  df_reg,
  "emop_cons_per_capita_oecd_halfyear_reg.tex", 
  table_1_outcomes_ihs,
  "Relationship Between GCVI and Averaged Half-Year General Expenditure for Urban and Rural Households - OECD Equivalence Scale",
  table_1_labels_ihs
)





# all sample ==========================

# 
# reg_cons_ndvi(
#   df_reg,
#   "emop_cons_per_capita_nf_oecd_quarter_reg_gci.tex", 
#   nf_outcome_per_capita_oecd,
#   "Regression result (half-year, Non-Food per-capita Expenditure (OECD-Modified Scale)",
#   nf_col_labels
# )

# reg_cons_ndvi(
#   df_reg,
#   "extra_emop_cons_per_capita_oecd_quarter_reg.tex", 
#   extra_outcome_per_capita_oecd,
#   "Regression result (Additional quarterly, per-capita Expenditure (OECD-Modified Scale)",
#   extra_col_labels
#   )


table_2_outcomes_ihs <- 
  c("ihs_pc_od_grain_cons",
    "ihs_pc_od_grain_auto", "ihs_pc_od_grain_purchase",
    "ihs_pc_od_grain_gift","ihs_pc_od_meat_cons","ihs_pc_od_educ_cons")

table_2_labels_ihs <- 
  c("IHS Grain",
    "IHS Grain (auto)", "IHS Grain (buy)",
    "IHS Grain (gift)","IHS Meat","IHS Education")

# Table2Regression
reg_cons_ndvi(
  df_reg,
  "gcvi_table_2.tex", 
  table_2_outcomes_ihs,
  "Relationship Between GCVI and Averaged Half-Year General Expenditure for Urban and Rural Households - OECD Equivalence Scale",
  table_2_labels_ihs
)


##Table2.1

table_2_1_outcomes_ihs <- 
  c("ihs_pc_od_grain_auto", "ihs_pc_od_grain_purchase",
    "ihs_pc_od_grain_gift","ihs_pc_od_rice_auto","ihs_pc_od_rice_purchase","ihs_pc_od_rice_gift")

table_2_1_labels_ihs <- 
  c("IHS Grain (auto)", "IHS Grain (buy)",
    "IHS Grain (gift)","IHS Rice (auto)","IHS Rice (buy)","IHS Rice (gift)")

# Table2_1_Regression
reg_cons_ndvi(
  df_reg%>% filter(urban == 0),
  "gcvi_table_2_1.tex", 
  table_2_1_outcomes_ihs,
  "Relationship Between GCVI and Averaged Half-Year Food Expenditure for Rural Households(Continued) - OECD Equivalence Scale",
  table_2_1_labels_ihs
)



table_3_outcomes_ihs <- 
  c("ihs_pc_od_consom_total",
    "ihs_pc_od_consom_food",
    "ihs_pc_od_consom_nonfood")


table_3_labels_ihs <- 
  c("IHS Total Expenditure",
    "IHS Total Food Expenditure",
    "IHS Total Non-Food Expenditure")

# Table3_Regession
reg_cons_ndvi(
  df_reg %>% filter(urban == 0),
  "gcvi_table_3_rural.tex", 
  table_3_outcomes_ihs,
  "Relationship Between GCVI and Averaged Half-Year General Expenditure for Rural Households - OECD Equivalence Scale",
  table_3_labels_ihs)
  
  
  
  
  table_4_outcomes_ihs <- 
    c("ihs_pc_od_consom_food",
      "ihs_pc_od_grain_cons",
      "ihs_pc_od_rice_cons",
      "ihs_pc_od_meat_cons",
      "ihs_pc_od_oil_cons")
    
  table_4_labels_ihs <- c(
      "IHS Total Food", 
      "IHS Grain",
      "IHS Rice",
      "IHS Meat", 
      "IHS Peanut Oil"
    )
  
  # Table4Regession
  reg_cons_ndvi(
    df_reg %>% filter(urban == 0),
    "gcvi_table_4_rural.tex", 
    table_4_outcomes_ihs,
    "Relationship Between GCVI and Averaged Half-Year Food Expenditure for Rural Households - OECD Equivalence Scale",
    table_4_labels_ihs)
  
  nf_col_labels <- c(
    "log Total Non-food", 
    "Log Alcohol",
    "log Sante", "log Clothing",
    "log Housing", "log Education",
    "log Communication",
    "log Transport",
    #"Log Restaurants",
    "Log Other Goods")
  
  
  nf_outcome_per_capita_oecd <- c(
    "lg_pc_od_consom_nonfood", "lg_pc_od_alcool_achat",
    "lg_pc_od_sante_achat", "lg_pc_od_cloth_achat",
    "lg_pc_od_logement_achat","lg_pc_od_educ_cons",
    "lg_pc_od_comm_achat","lg_pc_od_transport_achat",
    "lg_pc_od_restaurant_achat",
    "lg_pc_od_bien_autre_achat"
  )
    
    table_4_1_outcomes_ihs <- c("ihs_pc_od_consom_nonfood", "ihs_pc_od_alcool_achat",
    "ihs_pc_od_sante_achat", 
    "ihs_pc_od_cloth_achat",
    "ihs_pc_od_logement_achat")
    
    table_4_1_labels_ihs <- c(
      "IHS Total Non-Food", 
      "IHS Alcohol",
      "IHS Health",
      "IHS Clothing",
      "IHS Housing")
    
    
    # Table4_1_Regession
    reg_cons_ndvi(
      df_reg %>% filter(urban == 0),
      "gcvi_table_4_1_rural.tex", 
      table_4_1_outcomes_ihs,
      "Relationship Between GCVI and Averaged Half-Year Non-Food Expenditure for Rural Households - OECD Equivalence Scale",
      table_4_1_labels_ihs)
    
    table_4_2_outcomes_ihs <- c("ihs_pc_od_educ_cons",
                                "ihs_pc_od_comm_achat",
                                "ihs_pc_od_transport_achat",
                                "ihs_pc_od_restaurant_achat",
                                "ihs_pc_od_bien_autre_achat")
    
    table_4_2_labels_ihs <- c(
      "IHS Education",
      "IHS Communication",
      "IHS Transportation",
      "IHS Restaurants",
      "IHS Other Non-Food Expenditure"
    )
    
    
    
    
    # Table4_2_Regession
    reg_cons_ndvi(
      df_reg %>% filter(urban == 0),
      "gcvi_table_4_2_rural.tex", 
      table_4_2_outcomes_ihs,
      "Relationship Between GCVI and Averaged Half-Year Non-Food Expenditure for Rural Households - OECD Equivalence Scale",
      table_4_2_labels_ihs)
    
    
  #Urban Households
  #Table 5
  table_5_outcomes_ihs <- 
    c("ihs_pc_od_consom_total",
      "ihs_pc_od_consom_food",
      "ihs_pc_od_consom_nonfood")
  
  
  table_5_labels_ihs <- 
    c("IHS Total Expenditure",
      "IHS Total Food Expenditure",
      "IHS Total Non-Food Expenditure")
  
  #Table_5_Regession
  reg_cons_ndvi(
    df_reg %>% filter(urban == 1),
    "gcvi_table_5_rural.tex", 
    table_5_outcomes_ihs,
    "Relationship Between GCVI and Averaged Half-Year General Expenditure for Urban Households - OECD Equivalence Scale",
    table_5_labels_ihs)

  #Table 6 Labels
  
  
  table_6_outcomes_ihs <- 
    c("ihs_pc_od_consom_food",
      "ihs_pc_od_grain_cons",
      "ihs_pc_od_rice_cons",
      "ihs_pc_od_meat_cons",
      "ihs_pc_od_oil_cons")
  
  table_6_labels_ihs <- c(
    "IHS Total Food", 
    "IHS Grain",
    "IHS Rice",
    "IHS Meat", 
    "IHS Peanut Oil"
  )
  
  #Table6Regression
  
  reg_cons_ndvi(
    df_reg %>% filter(urban == 1),
    "gcvi_table_6_rural.tex", 
    table_6_outcomes_ihs,
    "Relationship Between GCVI and Averaged Half-Year Food Expenditure for Urban Households - OECD Equivalence Scale",
    table_6_labels_ihs
    )
  
  
  table_7_1_outcomes_ihs <- c("ihs_pc_od_consom_nonfood", "ihs_pc_od_alcool_achat",
                              "ihs_pc_od_sante_achat", 
                              "ihs_pc_od_cloth_achat",
                              "ihs_pc_od_logement_achat")
  
  table_7_1_labels_ihs <- c(
    "IHS Total Non-Food", 
    "IHS Alcohol",
    "IHS Health",
    "IHS Clothing",
    "IHS Housing")
  
  
  # Table7_1_Regession
  reg_cons_ndvi(
    df_reg %>% filter(urban == 1),
    "gcvi_table_7_1_urban.tex", 
    table_7_1_outcomes_ihs,
    "Relationship Between GCVI and Averaged Half-Year Non-Food Expenditure for Urban Households - OECD Equivalence Scale",
    table_7_1_labels_ihs)
  
  table_7_2_outcomes_ihs <- c("ihs_pc_od_educ_cons",
                              "ihs_pc_od_comm_achat",
                              "ihs_pc_od_transport_achat",
                              "ihs_pc_od_restaurant_achat",
                              "ihs_pc_od_bien_autre_achat")
  
  table_7_2_labels_ihs <- c(
    "IHS Education",
    "IHS Communication",
    "IHS Transportation",
    "IHS Restaurants",
    "IHS Other Non-Food Expenditure"
  )
  
  # Table7_2_Regession
  reg_cons_ndvi(
    df_reg %>% filter(urban == 1),
    "gcvi_table_7_2_urban.tex", 
    table_7_2_outcomes_ihs,
    "Relationship Between GCVI and Averaged Half-Year Non-Food Expenditure for Urban Households - OECD Equivalence Scale",
    table_7_2_labels_ihs)
  

# 
# # urban sample ==========================
# # reg_cons_ndvi(
# #   df_reg %>% filter(urban == 1),
# #   "extra_emop_cons_per_capita_oecd_quarter_reg_urban.tex", 
# #   extra_outcome_per_capita_oecd,
# #   "Regression result (Additional quarterly, per-capita Expenditure (OECD-Modified Scale), Urban",
# #   extra_col_labels
# #   )
# 
# # rural sample ==========================
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
#   outcome_per_capita_oecd_1,
#   "Regression result (half-year, per-capita Expenditure (OECD-Modified), rural)",
#   col_labels_1
# )
# 
# 
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "nf_emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
#   nf_outcome_per_capita_oecd,
#   "Regression result (half-year, per-capita Non-Food Expenditure (OECD-Modified), rural)",
#   nf_col_labels
# )
# 
# 
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "f_emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
#   f_outcome_per_capita_oecd,
#   "Regression result (half-year, per-capita Food Expenditure (OECD-Modified), rural)",
#   f_col_labels
# )
# 
# 
# 
# 
# 
# 
# 
# # 
# # reg_cons_ndvi(
# #   df_reg %>% filter(urban == 0),
# #   "extra_emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
# #   extra_outcome_per_capita_oecd,
# #   "Regression result (Additional quarterly, per-capita Expenditure (OECD-Modified Scale), Rural",
# #   extra_col_labels
# # )
# 
# 
# # different NDVI effects for each quarter =======================
# ##All Sample
# 
# reg_cons_ndvi(
#   df_reg,
#   "emop_cons_per_capita_quarter_hetero_reg_oecd.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(half-year, per-capita Expenditure (OECD-Modified)): Heterogeneous GCI Effects by Half-Year,Full Sample",
#   col_labels,
#   "half_year:(log_gci)",
#   c("half_year"),
#   c(
#     "H1 X GCI mean", "H2 X GCI mean"
#   )
# )
# ###
# ###Rural Sample
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "emop_cons_per_capita_quarter_hetero_reg_oecd_rural.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(half-year, per-capita Expenditure (OECD-Modified)): Heterogeneous GCI Effects by Half-Year, Rural Sample",
#   col_labels,
#   "half_year:(log_gci)",
#   c("half_year"),
#   c(
#     "H1 X GCI mean", "H2 X GCI mean"
#   )
# )
# ###Urban
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 1),
#   "emop_cons_per_capita_quarter_hetero_reg_oecd_urban.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(half-year, per-capita Expenditure (OECD-Modified)): Heterogeneous GCI Effects by Half-Year, Urban Sample",
#   col_labels,
#   "half_year:(log_gci)",
#   c("half_year"),
#   c(
#     "H1 X GCI mean", "H2 X GCI mean"
#   )
# )
# # ggplot(df_reg, aes(x = log(consom_nonfood))) +
# #   geom_histogram()
# 
# # ggplot(df_reg, aes(x = log(consom_nonfood))) +
# #   geom_histogram()
# 
# df$hh_indexf <- 0 
# hh_index  <- function(df){
#   counter = 0
#   df$hh_indexf <- 0
#   df$hh_index <- 0 
#   for (i in df$hh_index) {
#     #for (j in df$half_year)
# 
#     df[df$hh_index==i,]$hh_indexf <-  100*((df[df$hh_index==i,]$pc_od_grain_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_fish_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_meat_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_vegetable_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_sugar_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_tea_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_oil_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_butter_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_sugar_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_peanut_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_maggi_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
#                                            +(df[df$hh_index==i,]$pc_od_milk_cons/df[df$hh_index==i,]$pc_od_consom_food)^2)
#   }
# }

#     
#     # counter = counter + 1
#     # print(counter)
#     if(counter==10){
#       print(paste("at:", counter))
#     }
#     if(counter %% 100 == 0){
#       print(paste("at:", counter))
#     }
#     
#     # if(counter == 1000){
#     #   sprintf("at:\n", counter)
#     # }
#     # if(counter == 10000){
#     #   sprintf(" at:\n", counter)
#     # }
#     # if(counter == 40000){
#     #   sprintf(" at :\n", counter)
#     # }
#     # if(counter == 70000){
#     #   sprintf(" at:\n", counter)
#     # }
#     counter = counter + 1
#     
#     
#     
#     #print(i)
#     
#     
#     
#     
#     
#   }
#   
#   
#   
#   
# }
# 
# 
# # (df[df$hh_index==i,]$pc_od_fish_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
# # 
# # (df[df$hh_index==i,]$pc_od_meat_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
# # +
# # (df[df$hh_index==i,]$pc_od_grain_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
# # +
# # (df[df$hh_index==i,]$pc_od_vegetable_cons/df[df$hh_index==i,]$pc_od_consom_food)^2
# # +
# # (df[df$hh_index==i,]$pc_od_sugar_cons/df[df$hh_index==i,]$pc_od_consom_food)^2)
# # 
# 
# 



