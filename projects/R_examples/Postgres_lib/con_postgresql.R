setwd("/Volumes/Abyss/rstudio/ddsl_content/projects/R_examples/Postgres_lib")
source("ddsl_r.R")

# =============================
dbname = "rstudio"
dbhost = "localhost"  
dbport = "5432"             
dbuser = "rstudio"      
dbpass = "password"     
# =============================

con <- ddsl_postgresql_con(dbname, dbhost, dbport, dbuser, dbpass)
dbListTables(con)

ddsl_lib("tidyverse")
ddsl_lib("data.table")
ddsl_lib("R.utils")

nyc_taxi_data <- as_tibble(fread("nyc_taxi_data_small.csv.gz", verbose=F, showProgress=T))
head(nyc_taxi_data)



nyc_taxi_data <- readRDS("../R_postgres_example/nyc_taxi_data_small_clean_easy.rds")
summary(nyc_taxi_data)

dbWriteTable(con, name="nyc_taxi_data", value=nyc_taxi_data)


df <- dbGetQuery(con, "SELECT * FROM nyc_taxi_data")
df

dbListFields(con, "nyc_taxi_data")

qry <- "SELECT
*
FROM
information_schema.columns
WHERE
table_schema = 'public' AND 
table_name = 'nyc_taxi_data'
"
df2<- dbGetQuery(con, qry)





