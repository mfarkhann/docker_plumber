# Use Template from https://github.com/sol-eng/plumber-logging
# Packages ----
library(shiny)
library(shinydashboard)
library(DT)
library(fs)
library(tidyverse)
library(here)

# Utils ----
read_plumber_log <- function(log_file) {
  readr::read_log(file = log_file, 
                  col_names = c("log_level",
                                "timestamp", 
                                "host_name", 
                                "remote_addr", 
                                "user_agent",
                                "host",
                                "method",
                                "endpoint",
                                "status",
                                "execution_time"))
}

# Config ----
log_dir = here::here("logs")

ui <- dashboardPage(
  dashboardHeader(title = "API Usage"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$head(
      tags$style(type="text/css",
                 ".recalculating { opacity: 1.0; }"
      ) 
    ),
    fluidRow(
      valueBoxOutput("total_requests", width = 6),
      valueBoxOutput("requests_per_second", width = 6)
    ),
    fluidRow(
      valueBoxOutput("percent_success", width = 6),
      valueBoxOutput("average_execution", width = 6)
    ),
    fluidRow(
      box(
        plotOutput("status_plot"),
        title = "Response Status Overview",
        width = 6
      ),
      box(
        plotOutput("endpoints_plot"),
        title = "Endpoints Overview",
        width = 6
      )
    ),
    fluidRow(
      box(
        DT::dataTableOutput("detail_data"),
        title = "Detail Data",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE
      )
    )
  )
)

server <- function(input, output, session) {
  # Create memoised read_plumber_log function to cache results
  mem_read_plumber_log <- memoise::memoise(function(file, timestamp) {
    read_plumber_log(file)
  })
  
  observe({
    # Invalidate memoise cache every 30 minutes to avoid cache explosion
    invalidateLater(30*60*1000)
    memoise::forget(mem_read_plumber_log)
  })
  
  log_data <- reactivePoll(1000, # 1 second
                           checkFunc = function() {
                             files <- dir_ls(log_dir)
                             file_info(files)$modification_time
                           },
                           valueFunc = function() {
                             files <- dir_ls(log_dir)
                             purrr::map2_df(files, file_info(files)$modification_time, mem_read_plumber_log)
                           }, session = session)
  
  filtered_log <- reactive({
    log_data()
  })
  
  output$total_requests <- renderValueBox({
    valueBox(value = nrow(filtered_log()),
             subtitle = "Total Requests")
  })
  
  output$requests_per_second <- renderValueBox({
    data <- filtered_log()
    n_requests <- nrow(data)
    seconds <- n_distinct(data$timestamp)
    valueBox(value = round(n_requests / seconds, 2),
             subtitle = "Requests per Second")
  })
  
  output$percent_success <- renderValueBox({
    p <- filtered_log() %>% 
      count(status) %>% 
      mutate(p = n/sum(n)) %>% 
      filter(status == 200) %>% 
      pull(p) %>% 
      round(4)
    valueBox(value = glue::glue("{p*100}%"),
             subtitle = "Success",
             color = ifelse(p >= .9, "green", "red"))
  })
  
  output$average_execution <- renderValueBox({
    avg_execution <- round(mean(filtered_log()$execution_time, na.rm = TRUE), digits = 4)
    valueBox(value = avg_execution,
             subtitle = "Average Execution Time (S)")
  })
  
  output$status_plot <- renderPlot({
    filtered_log() %>% 
      count(status = as.factor(status)) %>% 
      ggplot(aes(x = fct_reorder(status, n), y = n)) +
      geom_col() +
      theme_bw() +
      coord_flip() +
      labs(x = "Response Status",
           y = "Requests")
  })
  
  output$endpoints_plot <- renderPlot({
    filtered_log() %>% 
      count(method, host, endpoint) %>% 
      unite(method, method, host, sep = " ") %>% 
      unite(endpoint, method, endpoint, sep = "") %>% 
      top_n(10, wt = n) %>% 
      ggplot(aes(x = fct_reorder(endpoint, n), y = n)) +
      geom_col() +
      theme_bw() +
      coord_flip() +
      labs(x = "Endpoint",
           y = "Requests")
  })
  
  output$detail_data <- DT::renderDataTable({
    filtered_log()
  },
  options = list(scrollX = TRUE))
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)