library(shiny)
library(tools)

my_gle_file_dir  <- "www/gle_files/"
my_gle_image_dir <- "www/images/"

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  # App title ----
  titlePanel("Graphics Layout Engine - WebGUI"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(
      
      selectInput("file_name", "Select template file:",{
        my_gle_filepaths <- Sys.glob(paste0(my_gle_file_dir, "*.gle"))
        my_gle_filenames <- gsub(my_gle_file_dir, "", my_gle_filepaths)
      }),
      textOutput("file_warning"),
      textInput("save_name", "GLE file save name:", "tutorial.gle"),
      actionButton("save_run_go", "Save and Compile"), uiOutput("tab"),
      uiOutput("dl_img_url"),
      br(),br(),
      textAreaInput("gle_code", "GLE Code:", "silly code", width = "800px", height = "880"),

    ),

    # Main panel for displaying outputs ----
    mainPanel(
      imageOutput("my_output_image", height="1200px")
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
# ===================================
  observe({
    x <- input$file_name
    save_file <- x
    
    if(x %in% c("tutorial.gle", "blank.gle")){
      save_file <- ""
    }
    updateTextInput(session, "save_name", value = save_file)
    my_file_code <- paste0(readLines(paste0(my_gle_file_dir, x), warn = F), collapse="\n")
    updateTextAreaInput(session, "gle_code", value = my_file_code)
  })
# ===================================
  observeEvent(input$save_run_go, {
    x <- isolate(input$save_name)
    save_file <- x
    cat("save_file =[",save_file,"]\n")
    go_execute <- 0
    if(save_file == ""){
      output$file_warning <- renderText({"You must enter a new filename for saving changes."})
    } else if(save_file %in% c("tutorial.gle", "blank.gle")){
      output$file_warning <- renderText({"Cannot overwrite [tutorial.gle] or [blank.gle] - choose another filename."})
    } else if(file_ext(save_file) != "gle"){
      output$file_warning <- renderText({"Filename must have the .gle suffix, e.g. filename.gle"})
    } else {
      output$file_warning <- renderText({""})
      go_execute <- 1
    }
    
    if(go_execute){
        gle_code <- isolate(input$gle_code)
        #cat(gle_code)
        gle_input_name  <- paste0(my_gle_file_dir, save_file)
        gle_output_name <- paste0(my_gle_image_dir, save_file)
        gle_output_name <- gsub(".gle", ".png", gle_output_name)
        cat(gle_code, file=gle_input_name)
        com <- paste0("gle -d png -o ", gle_output_name," ", gle_input_name)
        cat(com)
        system(com)
        
        output$my_output_image <- renderImage({
          list(src = gle_output_name,
               alt = gle_output_name)
        }, deleteFile = FALSE)
        
        url_name <- gsub("www/", "", gle_output_name)
        output$dl_img_url <- renderUI({
          tags$a(url_name, href=url_name, target="_blank")
        })
    }

  })
# ===================================
  
  


}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
