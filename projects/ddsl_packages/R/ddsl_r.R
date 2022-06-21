# ==============================================
my_library_path <- "/home/rstudio/data/R_libs"
system(paste0("mkdir -p ", my_library_path))
.libPaths(my_library_path)
# ==============================================
check_arg <- function(my_arg){
  if(is.null(my_arg)) stop("Arg:['", paste0(deparse(substitute(my_arg))),"'] cannot be NULL.  I'm putting a stop to this nonsense before somebody gets hurt.\n", call. = F)
}
# ==============================================
print_var <- function(my_var){
  cat(paste0(deparse(substitute(my_var)), " = ", my_var,))
}
# ==============================================
ddsl_lib <- function(my_lib, verbose=F){
  tryCatch({
    library(my_lib, character.only = T)
    if(verbose) print(paste0("Library ", my_lib," loaded successfully!"))
  },
  error=function(cond) {
    if(verbose) print(paste0("Library ", my_lib," not found.  Installing now."))
    install.packages(my_lib)
    library(my_lib, character.only = T)
  })
}
# ==============================================
ddsl_lib("getPass")
ddsl_lib('RPostgreSQL')
# ==============================================
ddsl_postgresql_con <- function(dbname, dbhost, dbport, dbuser, dbpass=""){
  if(dbpass == "") dbpass <- getPass::getPass("Enter postgresql password: ")
  
  print("Attempting to connect to PostgresQL…")
  success <- tryCatch(
    {
      # Just to highlight: if you want to use more than one 
      # R expression in the "try" part then you'll have to 
      # use curly brackets.
      # 'tryCatch()' will return the last evaluated expression 
      # in case the "try" part was completed successfully
      
      # message("This is the 'try' part")
      
      dbConnect(dbDriver("PostgreSQL"), 
                       dbname = dbname,
                       host = dbhost, 
                       port = dbport,
                       user = dbuser, 
                       password = dbpass)
      
      # readLines(con=url, warn=FALSE) 
      # The return value of `readLines()` is the actual value 
      # that will be returned in case there is no condition 
      # (e.g. warning or error). 
      # You don't need to state the return value via `return()` as code 
      # in the "try" part is not wrapped inside a function (unlike that
      # for the condition handlers for warnings and error below)
    },
    error=function(cond) {
      message("Attempt to connect to PostgresQL caused an error:")
      message(cond)
      # Choose a return value in case of error
      return(NULL)
    },
    warning=function(cond) {
      message("Attempt to connect to PostgresQL caused a warning:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you 
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>' 
    }
  )   
  
  pgcon <- NULL
  if(!is.null(success)){
    pgcon <- success
    print("Snowflake Connected!")
  }
  
  return (pgcon)
}
# ==============================================
ddsl_lib('DBI')
ddsl_lib('dplyr')
ddsl_lib('dbplyr')
ddsl_lib('odbc')
# =====
ddsl_snowflake_con <- function(uid, server, pwd="", database, warehouse, role=""){
  if(pwd == "") pwd <- getPass::getPass("Enter Snowflake password: ")
  
  print("Attempting to connect to Snowflake…")
  success <- tryCatch(
    {
      # Just to highlight: if you want to use more than one 
      # R expression in the "try" part then you'll have to 
      # use curly brackets.
      # 'tryCatch()' will return the last evaluated expression 
      # in case the "try" part was completed successfully
      
      # message("This is the 'try' part")
      
      dbConnect(odbc::odbc(), 
                           server = server,
                           uid = uid, 
                           pwd = pwd,
                           database = database,
                           warehouse = warehouse,
                           role=role,
                           driver = "SnowflakeDSIIDriver")
      
      # readLines(con=url, warn=FALSE) 
      # The return value of `readLines()` is the actual value 
      # that will be returned in case there is no condition 
      # (e.g. warning or error). 
      # You don't need to state the return value via `return()` as code 
      # in the "try" part is not wrapped inside a function (unlike that
      # for the condition handlers for warnings and error below)
    },
    error=function(cond) {
      message("Attempt to connect to Snowflake caused an error:")
      message(cond)
      # Choose a return value in case of error
      return(NULL)
    },
    warning=function(cond) {
      message("Attempt to connect to Snowflake caused a warning:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you 
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>' 
    }
  )   
  
  snowcon <- NULL
  if(!is.null(success)){
    snowcon <- success
    print("Snowflake Connected!")
  }

  return (snowcon)
}
# ==============================================
getQry <- function(filename){
  qry <- paste0(readLines(filename, warn=F), sep="", collapse="\n")
  cat("=========== QUERY START =============\n")
  cat(qry,"\n")
  cat("============ QUERY END ==============\n")
  return (qry)
}
# ==============================================
left <- function(str, n1){
  substr(str, 1, n1)
}
# ==============================================
right <- function(str, n1){
  nn <- nchar(str)
  substr(str, nn-n1+1, nn)
}
# ==============================================
runQry <- function(con, qry){
  
  res <- ""
  if(right(qry,4) == ".sql") qry <- getQry(qry)
  
  if(class(con)[1] == "Snowflake"){
    # Do something Snowflake-specific
  }
  
  if(class(con)[1] == "PostgreSQLConnection"){
    # Do something Postgres-specific
  }
  
  res <- dbGetQuery(con, qry)
  
  return (res)
}
# ==============================================
postgres_writeTable <- function(con, data, schemaname, tablename){
  data <- as_tibble(data)
  res <- runQry(con, paste0("SET search_path TO ", schemaname, ";"))
  DBI::dbWriteTable(con, name=tablename, value=data, row.names=F)
}
# ==============================================
runcom <- function(my_com){
  cat("running command [ ", my_com, " ]\n")
  system(my_com, intern = T)
}
# ==============================================
snowflake_dataprep <- function(my_data, my_snowname="", my_dirpath="", num_bindex=10){
  if(my_snowname == "") my_snowname <- toupper(deparse(substitute(my_data)))
  nn <- dim(my_data)[1]
  my_data$bindex <- ceiling(num_bindex * 1:nn/nn)
  numrows <- my_data %>% group_by(bindex) %>% summarise(n=n())
  numrows <- as.numeric(numrows$n)
  
  cat("Using snowname = ", my_snowname, "\n")
  
  success <- tryCatch(
    {
      # Just to highlight: if you want to use more than one 
      # R expression in the "try" part then you'll have to 
      # use curly brackets.
      # 'tryCatch()' will return the last evaluated expression 
      # in case the "try" part was completed successfully
      
      # message("This is the 'try' part")
      
      if(my_dirpath == "") my_dirpath <- getwd()
      my_path <- path.expand(file.path(normalizePath(my_dirpath), my_snowname))
      c(dir.create(my_path), my_path)
      # readLines(con=url, warn=FALSE) 
      # The return value of `readLines()` is the actual value 
      # that will be returned in case there is no condition 
      # (e.g. warning or error). 
      # You don't need to state the return value via `return()` as code 
      # in the "try" part is not wrapped inside a function (unlike that
      # for the condition handlers for warnings and error below)
    },
    error=function(cond) {
      message("Attempt to create dir caused an error:")
      message(cond)
      # Choose a return value in case of error
      return(NULL)
    },
    warning=function(cond) {
      message("Attempt to create dir caused a warning:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you 
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>' 
    }
  )   
  
  #cat("\nsuccess = [", success, "]\n")
  my_snowname_path <- NULL
  if(!is.null(success)){
    for(i in 1:num_bindex){
      my_snowname_path <- success[2]
      my_snowname_rds <- paste0(my_snowname_path, "/bindex", sprintf("%06d", i), ".rds")
      cat("writing my_snowname_rds = ", my_snowname_rds, "\t numrows = ", numrows[i], "\n")
      my_df <- my_data %>% filter(bindex == i) 
      saveRDS(my_df, file = my_snowname_rds)
    }
    cat("\nPrepped snowflake data successfully output to:\n", my_snowname_path, "\n")
  }
  return (my_snowname_path)
}
# ==============================================
snowflake_drop_tables <- function(my_con, my_dbase, my_schema, my_tablename){
  
  qry <- "
  SELECT 'Drop Table If Exists ' || TABLE_CATALOG || '.' || TABLE_SCHEMA || '.' || TABLE_NAME || ';' as COMS
  FROM  my_dbase.INFORMATION_SCHEMA.TABLES
  where TABLE_SCHEMA = 'my_schema' and TABLE_NAME like 'my_tablename%'
  "
  qry <- gsub('my_dbase', my_dbase, qry)
  qry <- gsub('my_schema', my_schema, qry)
  qry <- gsub('my_tablename', my_tablename, qry)
  res <- runQry(my_con, qry)
  coms <- as.character(res$COMS)
  for(qry in coms){
    cat(qry,"\n")
    res <- runQry(my_con, qry)
  }
}
# ==============================================
# ==============================================
snowflake_upload_rds <- function(my_con=NULL, rds_path=NULL, table_schema=NULL, snow_table_prefix="", overwrite=F){
  check_arg(my_con)
  check_arg(rds_path)
  check_arg(table_schema)
  
  rds_basename <- gsub(".rds", "", basename(rds_path))
  if(snow_table_prefix == "") snow_table_prefix <- basename(dirname(rds_path))
  snow_table_name <- toupper(paste0(snow_table_prefix, "_", rds_basename))
  
  qry <- paste0("use schema ", table_schema,";")
  suppressWarnings(DBI::dbSendQuery(my_con, qry))
  
  t1 <- Sys.time()
  my_data <- readRDS(rds_path)
  t2 <- Sys.time()
  suppressWarnings(dbWriteTable(snowcon_bcrit, snow_table_name, my_data, append = F))
  t3 <- Sys.time()
  cat("[", snow_table_name, "]   Timings: [Reading RDS = ", sprintf("%g", (t2-t1)), "] , [Uploading to Snowflake = ", sprintf("%g", (t3-t2)), "]\n")
}
# ==============================================
snowflake_batch_upload <- function(my_con=NULL, dset_path=NULL, snowflake_tablename="", final_schema=NULL, staging_schema="STAGING", overwrite=F){
  check_arg(my_con)
  check_arg(dset_path)
  check_arg(final_schema)
  
  my_bindex_filepaths <- Sys.glob(paste0(dset_path,"/bindex*rds"))
  my_bindex_filenames <- basename(my_bindex_filepaths)
  my_bindex_filestub  <- gsub(".rds", "", my_bindex_filenames)
  
  if(snowflake_tablename == "") snowflake_tablename <- basename(dset_path)
  #print_var(snowflake_tablename)
  
  # check which tables already exist:
  qry <- paste0("use schema ", staging_schema,";")
  suppressWarnings(DBI::dbSendQuery(my_con, qry) )
  qry <- "show tables"
  my_tables <- suppressWarnings(runQry(my_con, qry))
  #print(my_tables)
  output_dbase  <- as.character(my_tables$database_name)[1]
  my_tables <- as.character(my_tables$name)
  
  my_final_table <- paste0(output_dbase, ".", final_schema, ".", snowflake_tablename)
  
  # If tables exist:
  if(length(my_tables) > 0){
    ii <- which(tolower(my_tables) %like% tolower(snowflake_tablename))
    # If tables exist matching the right pattern:
    if(length(ii) > 0){
      done_bindex <- my_tables[ii]
      done_bindex <- gsub(paste0(snowflake_tablename, "_"), "", done_bindex)
      done_bindex <- paste0(tolower(done_bindex), ".rds")
      jj <- which(my_bindex_filenames %in% done_bindex)
      #print(done_bindex)
      #print(jj)
      if(overwrite){
        table_pattern <- paste0(snowflake_tablename,"_BINDEX")
        snowflake_drop_tables(my_con, my_dbase=output_dbase, my_schema=staging_schema, my_tablename=table_pattern)
      } else {
        my_bindex_filepaths <- my_bindex_filepaths[-jj]
        my_bindex_filenames <- basename(my_bindex_filepaths)
        my_bindex_filestub  <- gsub(".rds", "", my_bindex_filenames)
      }
    }
  }
  
  # Now upload each of the tables:
  for(my_filepath in my_bindex_filepaths){
    snowflake_upload_rds(my_con, rds_path=my_filepath, table_schema=staging_schema)
  }
  
  # Create final table:
  snowflake_union_tables(my_con=my_con,
                         my_input_dbase=output_dbase, 
                         my_input_schema=staging_schema, 
                         my_input_tablepattern=snowflake_tablename, 
                         my_output_dbase=output_dbase,
                         my_output_schema=final_schema,  
                         my_output_tablename=snowflake_tablename)
  
}
# ==============================================
snowflake_glob_tables <- function(my_con=NULL,  my_dbase=NULL, my_schema=NULL, my_tablepattern=NULL){
  check_arg(my_con)
  check_arg(my_dbase)
  check_arg(my_schema)
  check_arg(my_tablepattern)
  
  qry <- "
  SELECT TABLE_CATALOG || '.' || TABLE_SCHEMA || '.' || TABLE_NAME as COMS
  FROM  my_dbase.INFORMATION_SCHEMA.TABLES
  where TABLE_SCHEMA = 'my_schema' and TABLE_NAME like 'my_tablepattern%'
  "
  qry <- gsub('my_dbase', my_dbase, qry)
  qry <- gsub('my_schema', my_schema, qry)
  qry <- gsub('my_tablepattern', my_tablepattern, qry)
  res <- runQry(my_con, qry)
  my_tables <- as.character(res$COMS)
  #print(my_tables)
  return (my_tables)
}
# ==============================================
snowflake_union_tables <- function(my_con=NULL,  my_input_dbase=NULL, my_input_schema=NULL, my_input_tablepattern=NULL, my_output_dbase=NULL, my_output_schema=NULL,  my_output_tablename=NULL){
  check_arg(my_con)
  check_arg(my_input_dbase)
  check_arg(my_input_schema)
  check_arg(my_input_tablepattern)
  check_arg(my_output_tablename)
  if(is.null(my_output_dbase))  my_output_dbase  <- my_input_dbase
  if(is.null(my_output_schema)) my_output_schema <- my_input_schema
  
  my_tables <- snowflake_glob_tables(my_con=my_con,
                                     my_dbase=my_input_dbase,
                                     my_schema=my_input_schema,
                                     my_tablepattern=my_input_tablepattern)
  
  union_query <- paste0("select * from ", my_tables, collapse=" union all ")
  
  qry <- "drop table if exists my_output_dbase.my_output_schema.my_output_tablename;"
  qry <- gsub('my_output_dbase', my_output_dbase, qry)
  qry <- gsub('my_output_schema', my_output_schema, qry)
  qry <- gsub('my_output_tablename', my_output_tablename, qry)
  res <- runQry(my_con, qry)
  
  qry <- "
  create table my_output_dbase.my_output_schema.my_output_tablename as
  select t1.*
    from
  (
    union_query
  ) as t1
  "
  qry <- gsub('my_output_dbase', my_output_dbase, qry)
  qry <- gsub('my_output_schema', my_output_schema, qry)
  qry <- gsub('my_output_tablename', my_output_tablename, qry)
  qry <- gsub('union_query', union_query, qry)
  res <- runQry(my_con, qry)
  
  return (qry)
}
# ==============================================


