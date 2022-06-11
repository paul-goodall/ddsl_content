library(shiny)

# Define UI for random distribution app ----
ui <- fluidPage(

  # App title ----
  titlePanel("Run Code"),

      textAreaInput("code_input", "Code:", "", width = "80%"),
      actionButton("run_code", "Run"),
      verbatimTextOutput("code_output")

)

# Define server logic for random distribution app ----
server <- function(input, output) {

observeEvent(input$run_code, {
  output$code_output <- renderPrint({ system(isolate(input$code_input), intern=T) })
})

}

# Create Shiny app ----
shinyApp(ui, server)
