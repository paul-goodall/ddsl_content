
.libPaths("/home/rstudio/data/R_libs")
#install.packages('RPostgreSQL')
library(RPostgreSQL)
setwd("~/projects/R_examples/R_postgres_example")

# =============================
dsn_database = "rstudio"
dsn_hostname = "localhost"  
dsn_port = "5432"             
dsn_uid = "rstudio"      
dsn_pwd = "password"     
# =============================

tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to Database…")
  con <- dbConnect(drv, 
                      dbname = dsn_database,
                      host = dsn_hostname, 
                      port = dsn_port,
                      user = dsn_uid, 
                      password = dsn_pwd)
  print("Database Connected!")
},
error=function(cond) {
  print("Unable to connect to Database.")
})


nyc_taxi_data <- readRDS("nyc_taxi_data_small_clean_easy.rds")
summary(nyc_taxi_data)
nyc_taxi_data_df <- as.data.frame(nyc_taxi_data)
dbWriteTable(con, name="nyc_taxi_data", value=nyc_taxi_data_df)


# Long-winded way of showing tables in PGres
df <- dbGetQuery(con, "SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';")
df

df <- dbGetQuery(con, "SELECT count(*) as nn FROM nyc_taxi_data")
df






