setwd("/Volumes/Abyss/rstudio/projects/R_examples/Postgres_lib")
source("ddsl_r.R")

# =============================
dbname = "rstudio"
dbhost = "localhost"  
dbport = "5432"             
dbuser = "rstudio"      
dbpass = "password"     
# =============================

con <- ddsl_postgresql_con(dbname, dbhost, dbport, dbuser, dbpass)


nyc_taxi_data <- readRDS("nyc_taxi_data_small_clean_easy.rds")
summary(nyc_taxi_data)
nyc_taxi_data_df <- as.data.frame(nyc_taxi_data)
dbWriteTable(con, name="nyc_taxi_data", value=nyc_taxi_data_df)


# Long-winded way of showing tables in PGres
df <- dbGetQuery(con, "SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';")
df

df <- dbGetQuery(con, "SELECT count(*) as nn FROM nyc_taxi_data")
df






