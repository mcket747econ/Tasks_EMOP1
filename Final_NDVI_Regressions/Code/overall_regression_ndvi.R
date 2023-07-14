
#with previous year NDVIremotes::install_github("r-spatial/rgee")

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
  project <- file.path(getwd(),"Final_NDVI_Regressions")
  input <- file.path(project,"Input")
  output <- file.path(project,"Output")
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
    ndvi_year = ifelse(half_year==1, year, year - 1),
    half_year = as.factor(half_year)
  )


# Load NDVI data
# dat_ndvi <- read_csv(file.path(dropbox, "data/cleaned/NDVI/ndvi_modis_yr_comm_scaled.csv"))

# Load Mali commune shapefile data
# dat <- read_rds(file.path(input, "gadm36_MLI_4_sf.rds"))

# Collapse EMOP data at commune level so that we can merge it with shapefile
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
# ) 
# 
# # Merge GPS coordinates and shapefile data so that for each commune we obtain commune polygon
# df_polygon <- st_join(
#   df_sf,
#   dat[c("NAME_4")]
# )

# df_ndvi <- as_tibble(left_join(df_polygon, dat_ndvi, by = c("NAME_4" = "id")))
#Load NDVI Data
# Merge EMOP consumption data and NDVI data.
# For the first three quarters, use the previous-year NDVI.
# For the last quarter, use the same-year NDVI
df_ndvi <- read_xlsx(file.path(input, "df_ndvi_final.xlsx"))
df_reg <- left_join(df_reg, df_ndvi, by = c("commune_name", "ndvi_year" = "year"))
df_reg$ndvi_mean_sq <- (df_reg$NDVI_mean)^2
df_reg <- df_reg[df_reg$annual_consom_food != 0 & df_reg$annual_consom_nonfood!=0,]
df_reg$log_ndvi <- log(df_reg$NDVI_mean)



# Function to run regressions and save outputs
reg_cons_ndvi <- function(
    df, output_file, outcome, table_caption, col_labels,
    rhs_var1 = "NDVI_mean",
    #rhs_var2 = "ndvi_meansc_sq",
    keep_var = c("NDVI_mean"),
    #keep_var = c("ndvi_mean_scld","ndvi_meansc_sq"),
    cov_labels = c("Averaged Maximum NDVI")
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
              paste(rhs_var1,
                    #paste(c(rhs_var,rhs_var2), collapse = "+"),
                    #paste(c(rhs_var, hh_control), collapse = " + "),
                    "half_year + year+ hhid", "0", "commune_name", sep = " | "
              ),
              sep = " ~ ")
      ),
      data = df
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
  mean_ndvi_mean = map_chr(
    res_model, function(x) formatC(colMeans(model.frame(x)["NDVI_mean"]), 3, format = "f")
  )
  sd_ndvi_mean = map_chr(
    res_model, 
    function(x) formatC(sapply(model.frame(x)["NDVI_mean"], function(x) sd(x, na.rm = TRUE)), 3, format = "f")
  )
  num_col <- length(outcome)
  
  res_model %>%
    stargazer(
      dep.var.labels.include = FALSE,
      column.labels = col_labels,
      covariate.labels = cov_labels,
      keep = keep_var,
      font.size = "normalsize",
      label = output_file,
      title = table_caption,
      add.lines = list(
        c("Household FE", rep("Yes", num_col)),
        #c("Commune FE", rep("Yes", num_col)),
        c("Year FE", rep("Yes", num_col)),
        c("Half-Year FE", rep("Yes", num_col)),
        c("Controls", rep("No", num_col)),
        c("Mean of outcomes", mean_outcome),
        c("Mean of NDVI mean", mean_ndvi_mean),
        c("SD of NDVI mean", sd_ndvi_mean)
      ),
      type = "latex",
      out = file.path(output, output_file),
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

outcome_per_capita_oecd <- c(
  "lg_pc_od_consom_total", "lg_pc_od_consom_food", 
  #"ihs_percap_oecd_consom_total","ihs_percap_oecd_consom_food",
  "lg_pc_od_consom_nonfood", "lg_pc_od_grain_cons",
  "lg_pc_od_grain_auto", "lg_pc_od_grain_purchase",
  "lg_pc_od_grain_gift","lg_pc_od_meat_cons","lg_pc_od_educ_cons"
)

outcome_per_capita_oecd <- c(
  "lg_pc_od_consom_total", "lg_pc_od_consom_food", 
  #"ihs_percap_oecd_consom_total","ihs_percap_oecd_consom_food",
  "lg_pc_od_consom_nonfood", "lg_pc_od_grain_cons",
  "lg_pc_od_grain_auto", "lg_pc_od_grain_purchase",
  "lg_pc_od_grain_gift","lg_pc_od_meat_cons","lg_pc_od_educ_cons")
extra_outcome_per_capita_oecd <- c(
  "log_percap_oecd_meat_cons",#"ihs_percap_oecd_meat_auto", 
  "ihs_percap_oecd_meat_purchase",
  "ihs_percap_oecd_meat_gift", "ihs_percap_oecd_rice_cons",
  "ihs_percap_oecd_rice_auto", "ihs_percap_oecd_rice_purchase",
  "ihs_percap_oecd_rice_gift","ihs_percap_oecd_educ_cons","ihs_percap_oecd_leisure_cons"
)
extra_outcome_per_capita_oecd_ihs <- c(
  "ihs_pc_od_meat_cons",#"ihs_ihs_oecd_meat_auto", 
  "ihs_pc_od_meat_purchase",
  "ihs_ihs_od_meat_gift", "ihs_pc_od_rice_cons",
  "ihs_pc_od_rice_auto", "ihs_pc_od_rice_purchase",
  "ihs_pc_od_rice_gift","ihs_pc_od_educ_cons","ihs_pc_od_leisure_cons")

col_labels <- c(
  "log Total", "log Food", 
  #"log Total", "IHS Food",
  "log Non-food", "log Grain",
  "log Grain (auto)", "log Grain (buy)",
  "log Grain (gift)","log Meat","log Education"
)
outcome_per_capita_oecd_ihs <- c(
  "ihs_pc_od_consom_total", "ihs_pc_od_consom_food", 
  #"ihs_pc_oecd_consom_total","ihs_pc_oecd_consom_food",
  "ihs_pc_od_consom_nonfood", "ihs_pc_od_grain_cons",
  "ihs_pc_od_grain_auto", "ihs_pc_od_grain_purchase",
  "ihs_pc_od_grain_gift","ihs_pc_od_meat_cons","ihs_pc_od_educ_cons")
col_labels_ihs <- c(
  "IHS Total", "IHS Food", 
  #"IHS Total", "IHS Food",
  "IHS Non-food", "IHS Grain",
  "IHS Grain (auto)", "IHS Grain (buy)",
  "IHS Grain (gift)","IHS Meat","IHS Education"
)

extra_col_labels <- c(
  "log Meat", #"IHS Meat (auto)",
  "IHS Meat (buy)", "IHS Meat (gift)",
  "IHS Rice ", "IHS Rice (auto)",
  "IHS Rice (buy)","IHS Rice (gift)",
  "IHS Education", "IHS Leisure"
)
extra_col_labels_ihs <- c(
  "IHS Meat", #"IHS Meat (auto)",
  "IHS Meat (buy)", "IHS Meat (gift)",
  "IHS Rice ", "IHS Rice (auto)",
  "IHS Rice (buy)","IHS Rice (gift)",
  "IHS Education", "IHS Leisure"
)

table_1_outcomes_ihs <- 
  c("ihs_pc_od_consom_total",
    "ihs_pc_od_consom_food",
    "ihs_pc_od_consom_nonfood")

table_1_labels_ihs <- 
  c("IHS Total Consumption",
    "IHS Total Food Consumption",
    "IHS Total Non-Food Consumption")

#Table1_Labels_IHS_Robustness  
reg_cons_ndvi(
  df_reg,
  "emop_cons_per_capita_halfyear_reg.tex", 
  table_1_outcomes_ihs,
  "Regression result (Half-Year, General expenditure (OECD-Modified Scale)",
  table_1_labels_ihs
)


table_2_outcomes_ihs <- 
  c("ihs_pc_od_grain_cons",
    "ihs_pc_od_grain_auto", "ihs_pc_od_grain_purchase",
    "ihs_pc_od_grain_gift","ihs_pc_od_meat_cons","ihs_pc_od_educ_cons")

table_2_labels_ihs <- 
  c("IHS Grain",
    "IHS Grain (auto)", "IHS Grain (buy)",
    "IHS Grain (gift)","IHS Meat","IHS Education")

#Table2_Labels_IHS_Robustness  
reg_cons_ndvi(
  df_reg,
  "ndvi_table_2.tex", 
  table_2_outcomes_ihs,
  "Relationship Between NDVII and Half-Year General expenditure for Urban and Rural Households - OECD Equivalence Scale",
  table_2_labels_ihs
)

#Table_2_1
table_2_1_outcomes_ihs <- 
  c("ihs_pc_od_grain_auto", "ihs_pc_od_grain_purchase",
    "ihs_pc_od_grain_gift","ihs_pc_od_rice_auto","ihs_pc_od_rice_purchase","ihs_pc_od_rice_gift")

table_2_1_labels_ihs <- 
  c("IHS Grain (auto)", "IHS Grain (buy)", "IHS Grain (gift)","IHS Rice (auto)","IHS Rice (buy)","IHS Rice (gift)")

# Table2_1_Regression
reg_cons_ndvi(
  df_reg,
  "ndvi_table_2_1.tex", 
  table_2_1_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Food expenditure for Rural Households(Continued) - OECD Equivalence Scale",
  table_2_1_labels_ihs
)




#Table 3

table_3_outcomes_ihs <- 
  c("ihs_pc_od_consom_total",
    "ihs_pc_od_consom_food",
    "ihs_pc_od_consom_nonfood")


table_3_labels_ihs <- 
  c("IHS Total expenditure",
    "IHS Total Food expenditure",
    "IHS Total Non-Food expenditure")



# Table3_Regession
reg_cons_ndvi(
  df_reg %>% filter(urban == 0),
  "ndvi_table_3_rural.tex", 
  table_3_outcomes_ihs,
  "Relationship Between NDVI and Half-Year General expenditure for Rural Households - OECD Equivalence Scale",
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
  "ndvi_table_4_rural.tex", 
  table_4_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Food expenditure for Rural Households - OECD Equivalence Scale",
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
  "ndvi_table_4_1_rural.tex", 
  table_4_1_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Non-Food expenditure for Rural Households - OECD Equivalence Scale",
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
  "IHS Other Non-Food expenditure"
)

# Table4_2_Regession
reg_cons_ndvi(
  df_reg %>% filter(urban == 0),
  "ndvi_table_4_2_rural.tex", 
  table_4_2_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Non-Food expenditure for Rural Households - OECD Equivalence Scale",
  table_4_2_labels_ihs)


#Urban Households
#Table 5
table_5_outcomes_ihs <- 
  c("ihs_pc_od_consom_total",
    "ihs_pc_od_consom_food",
    "ihs_pc_od_consom_nonfood")


table_5_labels_ihs <- 
  c("IHS Total expenditure",
    "IHS Total Food expenditure",
    "IHS Total Non-Food expenditure")

#Table_5_Regession
reg_cons_ndvi(
  df_reg %>% filter(urban == 1),
  "ndvi_table_5_rural.tex", 
  table_5_outcomes_ihs,
  "Relationship Between NDVI and Half-Year General expenditure for Urban Households - OECD Equivalence Scale",
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
  "ndvi_table_6_rural.tex", 
  table_6_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Food expenditure for Urban Households - OECD Equivalence Scale",
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
  "ndvi_table_7_1_urban.tex", 
  table_7_1_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Non-Food expenditure for Urban Households - OECD Equivalence Scale",
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
  "IHS Other Non-Food expenditure"
)


# Table7_2_Regession
reg_cons_ndvi(
  df_reg %>% filter(urban == 1),
  "ndvi_table_7_2_urban.tex", 
  table_7_2_outcomes_ihs,
  "Relationship Between NDVI and Half-Year Non-Food Expenditure for Urban Households - OECD Equivalence Scale",
  table_7_2_labels_ihs)








# 
# 
# 
# 
# # all sample ==========================
# reg_cons_ndvi(
#   df_reg,
#   "emop_cons_per_capita_halfyear_reg.tex", 
#   outcome_per_capita_oecd,
#   "Regression result (Half-Year, General expenditure (OECD-Modified Scale)",
#   col_labels
# )
# 
# # reg_cons_ndvi(
# #   df_reg,
# #   "extra_emop_cons_per_capita_oecd_quarter_reg.tex", 
# #   extra_outcome_per_capita_oecd,
# #   "Regression result (Additional quarterly, per-capita consumption (OECD-Modified Scale)",
# #   extra_col_labels
# #   )
# # all sample ==========================
# 
# reg_cons_ndvi(
#   df_reg,
#   "emop_cons_per_capita_oecd_halfyear_reg_ihs.tex", 
#   outcome_per_capita_oecd_ihs,
#   "Regression result (Half Year, General consumption (OECD-Modified Scale)",
#   col_labels
# )
# 
# # reg_cons_ndvi(
# #   df_reg,
# #   "extra_emop_cons_per_capita_oecd_halfyear_reg_ihs.tex", 
# #   extra_outcome_per_capita_oecd_ihs,
# #   "Regression result (Half-Year, Geberal consumption (OECD-Modified Scale)",
# #   extra_col_labels
# #   )
# 
# # urban sample ==========================
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 1),
#   "emop_cons_per_capita_oecd_quarter_reg_urban.tex", 
#   outcome_per_capita_oecd,
#   "Regression result (quarterly, per-capita consumption (OECD-Modified), urban)",
#   col_labels
# )
# # reg_cons_ndvi(
# #   df_reg %>% filter(urban == 1),
# #   "extra_emop_cons_per_capita_oecd_quarter_reg_urban.tex", 
# #   extra_outcome_per_capita_oecd,
# #   "Regression result (Additional quarterly, per-capita consumption (OECD-Modified Scale), Urban",
# #   extra_col_labels
# #   )
# 
# # rural sample ==========================
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
#   outcome_per_capita_oecd,
#   "Regression result (quarterly, per-capita consumption (OECD-Modified), rural)",
#   col_labels
# )
# # 
# # reg_cons_ndvi(
# #   df_reg %>% filter(urban == 0),
# #   "extra_emop_cons_per_capita_oecd_quarter_reg_rural.tex", 
# #   extra_outcome_per_capita_oecd,
# #   "Regression result (Additional quarterly, per-capita consumption (OECD-Modified Scale), Rural",
# #   extra_col_labels
# # )
# 
# 
# 
# 
# # different NDVI effects for each quarter =======================
# ##All Sample
# 
# reg_cons_ndvi(
#   df_reg,
#   "emop_cons_per_capita_quarter_hetero_reg_oecd.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(quarterly, per-capita consumption (OECD-Modified)): Heterogeneous NDVI Effects by Quarter,Full Sample",
#   col_labels,
#   "half_year:(ndvi_mean)",
#   "half_year",
#   c(
#     "H1 X NDVI mean", "H2 X NDVI mean"
#   )
# )
# ###
# ###Rural Sample
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 0),
#   "emop_cons_per_capita_quarter_hetero_reg_oecd_rural.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(quarterly, per-capita consumption (OECD-Modified)): Heterogeneous NDVI Effects by Quarter, Rural Sample",
#   col_labels,
#   "half_year:(ndvi_mean)",
#   "half_year",
#   c(
#     "H1 X NDVI mean",  "H2 X NDVI mean"
#   )
# )
# ###Urban
# reg_cons_ndvi(
#   df_reg %>% filter(urban == 1),
#   "emop_cons_per_capita_quarter_hetero_reg_oecd_urban.tex", 
#   outcome_per_capita_oecd,
#   "Robustness Check(quarterly, per-capita consumption (OECD-Modified)): Heterogeneous NDVI Effects by Quarter, Urban Sample",
#   col_labels,
#   "half_year:(ndvi_mean)",
#   "half_year",
#   c(
#     "H1 X NDVI mean",  "H2 X NDVI mean"
#   )
# )
# # ggplot(df_reg, aes(x = log(consom_nonfood))) +
# #   geom_histogram()
# 
# # ggplot(df_reg, aes(x = log(consom_nonfood))) +
# #   geom_histogram()
# 
# ## R Markdown
# 
# 
# 
# ## Including Plots
# any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.
