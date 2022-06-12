# ==============================================
my_library_path <- "/home/rstudio/system_data/R_libs"
system(paste0("mkdir -p ", my_library_path))
.libPaths(my_library_path)
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
ddsl_lib("RPostgreSQL")
# ==============================================
ddsl_postgresql_con <- function(dbname, dbhost, dbport, dbuser, dbpass=""){
  if(dbpass == "") dbpass <- getPass::getPass("Enter postgresql password: ")
  con <- ""
  tryCatch({
    drv <- dbDriver("PostgreSQL")
    print("Connecting to Database…")
    con <- dbConnect(drv, 
                     dbname = dbname,
                     host = dbhost, 
                     port = dbport,
                     user = dbuser, 
                     password = dbpass)
    print("Database Connected!")
  },
  error=function(cond) {
    print("Unable to connect to Database.")
  })
  return (con)
}
# ==============================================