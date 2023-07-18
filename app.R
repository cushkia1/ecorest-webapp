#########################################################################################################################
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :::::::::::::::::::::::::::::::::::::::::::::::: Ecorest x Shiny Project ::::::::::::::::::::::::::::::::::::::::::::::
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# 
# Version: 0.20
# Status: In Development
# Push Date: 10/20/22
# Push Author: CS
# Merge Count: 1
#########################################################################################################################







#########################################################################################################################
# Style Guide: 
# 1) Comments such as those in this box structure exist purely for documentation, therefore, requiring a different style 
#    of writing and formatting.
# 2) Any other comments outside of these boxes will follow the same rules:
#      1. Comments with a space between itself and the # denote a piece of code that has been commented out
#      2. Comments without a space between itself and the # denote a comment on either the code below it or the line to
#         the left of it
#########################################################################################################################







#########################################################################################################################
# This section identifies and downloads libraries used throughout the program
#########################################################################################################################


#Load R package outside for the app to run it only once when the user enters the app
library(ecorest) 
library(shiny)
library(stringr)
# library(shinyWidgets)
library(shinydashboard)
library(shinycssloaders)
library(dplyr)
library(DT)
library(vroom)
# library(reactlog)
library(openxlsx)
library(rhandsontable)


#########################################################################################################################
# This section controlls all HTML outputs. These are all static elements.
#########################################################################################################################


ui <-dashboardPage(   #open user-interface
  
  #prints the title for the webpage
  dashboardHeader(title = "ecorest"),
  
  #########################################################################################################################
  # Handles elements of the sidebar
  # Acts as a general directory for HTML formatting
  #########################################################################################################################
  
  dashboardSidebar(  #sidebar layout
    sidebarMenu(  #each menu tab
      menuItem("Home Page", icon=icon("star"), startExpanded=TRUE, #menu tab
               menuSubItem("ReadMe", tabName="rdm"), #menu subtab
               menuSubItem("Website",tabName="dcmnt") #menu subtab
      ),
      menuItem("Model Selection", icon=icon("folder-open"), startExpanded=TRUE, #menu tab
               menuSubItem("Choose model", tabName="slctmod"), #menu subtab
               menuSubItem("Visualize model", tabName="vizmod") #menu subtab
      ),
      menuItem("Habitat Suitability Calculator",icon=icon("calculator"), startExpanded=TRUE, #menu tab
               menuSubItem("Manual Input", tabName="SIcalc"), #menu subtab
               menuSubItem("CSV Input", tabName="HUcalc") #menu subtab
               
      ),
      menuItem("Cost-effective Incremental Cost Analysis",icon=icon("calculator"), startExpanded=TRUE, #menu tab
               menuSubItem("Annualizer", tabName="Anlzr"), #menu subtab
               menuSubItem("CEICA Plotter", tabName="CEICAplot") #menu subtab
      ),
      menuItem("Download Outputs",icon=icon("book"), startExpanded=TRUE, #menu tab
               menuSubItem("Export Files", tabName="Exportfiles") #menu subtab
      )
    ),
    textOutput("res") #communicates with server to render the menu
  ),
  
  #########################################################################################################################
  # Handles elements within each sidebar 
  # Defines the contents within each tab
  # The framework for the inputs and outputs are given
  #########################################################################################################################
  
  dashboardBody( #main body, describes whats inside each of the tabs above
    tabItems(
      
      #########################################################################################################################
      # Contains ReadMe for ecorest webapp
      ### Currrently under development...
      # Prerequisite: None
      # Box 1. Prints ecorest package website to screen
      #########################################################################################################################
      
      tabItem(tabName="rdm", # tab that links to documentation
              title="ReadMe", #section to choose model from bluebook 
              fluidPage(
                tags$iframe(src = './readme.html', 
                            width = '100%', height = '800px', 
                            frameborder = 0, scrolling = 'auto'
                )
              )
      ),
      
      #########################################################################################################################
      # Prints out documentation
      ### Currrently under development...
      # Prerequisite: None
      # Box 1. Prints ecorest package website to screen
      # Use this link to style https://stackoverflow.com/questions/24049159/change-the-color-and-font-of-text-in-shiny-app
      #########################################################################################################################
      
      tabItem(tabName="dcmnt", # tab that links to documentation
              fluidPage(
                tags$iframe(src = './CRAN_ecorest.html', 
                            width = '100%', height = '800px', 
                            frameborder = 0, scrolling = 'auto'
                )
              )
      ),
      
      #########################################################################################################################
      # Handles elements of bb model and user model 
      # Box 1. BB model input
      # Box 2. User model
      #########################################################################################################################
      
      tabItem(tabName="slctmod", #tab to choose model
              fluidRow(
                box(
                  title="Bluebook model", #section to choose model from bluebook 
                  solidHeader = TRUE,
                  status = "primary",
                  
                  #allows the user to choose a model from a list
                  selectInput("mod", #stores chosen model name in input$mod
                              label = "Select model", 
                              choices =c( "Pick a model from the list", names((ecorest::HSImodels))), #a drop down with all model names appears
                              multiple= FALSE),
                ),
                box(
                  title="User-specified model", #section to input user's own mod 
                  solidHeader = TRUE,
                  status = "primary",
                  helpText("This box should ONLY be interacted with IF the user wants to use a specified model"), 
                  checkboxInput("usermod", "I have a user specified model", FALSE), #the user ticks this box to choose to use their own model. 
                  br(),br(),
                  helpText("Example format below."),
                  downloadButton("example0","Example format download"),
                  br(),br(),
                  fileInput("file_usermod_metadata", "Upload metadata (.csv)", #user uploads csv file and is put into input$file1
                            multiple = FALSE,
                            accept =   ".csv"),
                  br(),br(),
                  helpText("Example format below."),
                  downloadButton("example1","Example format download"),
                  br(),br(),
                  fileInput("file1", "Upload model (.csv)", #user uploads csv file and is put into input$file1
                            multiple = FALSE,
                            accept =   ".csv")
                )
              )
      ),
      
      #########################################################################################################################
      # Handles elements for viewing the chosen model
      # Prerequisite: Model input
      # Box 1. Metadata Table
      # Box 2. HSIplotter
      #########################################################################################################################
      
      tabItem(tabName="vizmod", #tab to look at the chosen model
              fluidRow(
                box(
                  tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-x: auto; }"))), 
                  title="Metadata",
                  width = "100%",
                  solidHeader = T,
                  status = "primary",
                  helpText("View your metadata and verify if this is the model you need. If the model does not meet your needs,
                              please use the user-specified option in the Choose model tab
                               to build your own model."),
                  helpText("The search tab to the left can be used to find a specificied category."),
                  DT::dataTableOutput("metatable"), #table to view model metadata
                  style="height:500px; overflow-x:scroll;" #enables scrolling in table
                )
              ),
              fluidRow(
                box(
                  width = "100%",
                  title="Suitability plots (HSIplotter)", 
                  solidHeader = T,
                  status = "primary",
                  div(style='overflow-x: scroll;overflow-y: scroll',plotOutput("HSIplotter")) #prints out HSI plotter with scrolling enabled
                )
              )
      ),
      
      #########################################################################################################################
      # Handles elements for calculating model relevant calculations
      # Prerequisite: Model input
      # Box 1. HSI calculator -user text box entry
      # Box 2. HSI calculator -user file entry
      # Box 3. Output for Box 1
      # Box 4. Output for Box 2
      #########################################################################################################################
      
      tabItem(tabName="SIcalc", #tab to calculate and show SI values
              fluidRow(
                box(title="HSI/HU Calculator (I want to look at one calculation)", #section for simple SI calculation
                    solidHeader = T,
                    status = "primary",
                    #Steps for HUcalc
                    helpText("HSIcalc computes habitat units given a set of suitability indices, a habitat suitability index equation,
                              and habitat quantity."),
                    helpText("Enter habitat size associated with suitability indices (i.e., length, area, or volume). Output for habitat quantity will show up as 'HU'(Habitat Unit) on bottom table."),
                    #Text box for user to write the project area 
                    br(),br(),
                    numericInput(inputId= "area_one", #the user inputs area in this textbox which can be found in input$area_one
                                 label= "Area", 
                                 "Must be numeric"), #Message in text box
                    #Dropdown box for user to choose 
                    br(),br(),
                    helpText("Choose which function to use as the combination equation for overall habitat quality."),
                    selectInput(inputId="HSIfunc_one", label = "Select function", #user must select function
                                choices = c("Pick a function from the list", "HSIarimean", "HSIeqtn (only for bluebook)", "HSIgeomean", "HSImin")
                                ,multiple= FALSE),
                    br(),br(),
                    #Get number of variables from user in order to create inputs on the fly
                    helpText("Enter your data below."),
                    uiOutput("HSI_variable_inputs_one.1"),
                    uiOutput("HSI_variable_inputs_one.2"),
                    uiOutput("HSI_variable_inputs_one.3"),
                    uiOutput("HSI_variable_inputs_one.4"),
                    uiOutput("HSI_variable_inputs_one.5"),
                    uiOutput("HSI_variable_inputs_one.6"),
                    uiOutput("HSI_variable_inputs_one.7"),
                    uiOutput("HSI_variable_inputs_one.8"),
                    uiOutput("HSI_variable_inputs_one.9"),
                    uiOutput("HSI_variable_inputs_one.10")
                ),
                box(title="HSI/HU Calculator (I want to look at multiple calculations)", #section for simple SI calculation
                    solidHeader = T,
                    status = "primary",
                    #Steps for HUcalc
                    helpText("Choose which function to use as the combination equation for the overall habitat quality."),
                    selectInput(inputId="HSIfunc_multi", label = "Select function", #user must select function
                                choices = c("Pick a function from the list", "HSIarimean", "HSIeqtn (only for bluebook)", "HSIgeomean", "HSImin")
                                ,multiple= FALSE),
                    br(),br(),
                    # rHandsontableOutput("HSI_variable_inputs_multi"),
                    helpText("Click 'Edit' to enter data in table. Double click cells on table to enter data. Click 'Calculate' to view outputs. If you have more than 10 scenarios, use the CSV Input subtab instead."),
                    radioButtons("manual_ready", "Compiler", c("Edit", "Calculate")),
                    DTOutput("HSI_variable_inputs_multi"),
                    # actionButton("go",label = "Calculate")
                )
              ), #where should this go so it's rendered?
              fluidRow(
                box(title="Output", #section shows output for simple SI calculation
                    solidHeader = T,
                    status = "primary",
                    div(style='overflow-x: scroll;overflow-y: scroll',tableOutput("HSI_one")),
                ),
                box(title="Output", #section shows output for simple SI calculation
                    solidHeader = T,
                    status = "primary",
                    DT::dataTableOutput("HSI_multi"), #table to view outputs
                    style="height:500px; overflow-x:scroll;", #enables scrolling in table
                    helpText("For calculations with more than 11 samples, please use the CSV Input in the following tab.")
                )
              )
      ),
      
      #########################################################################################################################
      # Handles elements for calculating using HU function
      # Prerequisite: HSI function file input
      # Box 1. HU calculator 
      # Box 2. Output for Box 1
      #########################################################################################################################
      
      tabItem(tabName="HUcalc",
              fluidRow(
                box(title="HSI calculator (Import csv with multiple scenarios included", #section for file input SI calculation
                    solidHeader = T,
                    height = "50%",
                    status = "primary",
                    helpText("HSIcalc computes suitability indices given a set of suitability curves and project-specific inputs.
                              Suitability indices may be computed based on either linear interpolation (for continuous variables)
                              or a lookup method (for categorical variables)."),
                    helpText("After selecting a model, upload your field data as a .csv file."), 
                    helpText("Follow instructions in the 'HSI calculator' section of reference guide for proper data structure."),
                    br(),br(),
                    helpText("Below is an example format"),
                    downloadButton("example2","Example Format Download"),
                    br(),br(),
                    
                    #User needs to upload their input .csv for the SIcalc()
                    fileInput("file2", "Upload .csv File", #user's data can be found in input$file2
                              multiple = FALSE,
                              accept =   ".csv"),
                    div(style='overflow-x: scroll;overflow-y: scroll',DT::dataTableOutput("head")) #prints table with preview of the input file
                ),
                box(title="HU Calculator",
                    #width = "100%",
                    height = "50%",
                    solidHeader = T,
                    status = "primary",
                    #HUcalc description
                    helpText("HUcalc computes habitat units given a set of suitability indices, a habitat suitability index equation,
                              and habitat quantity."),
                    br(),br(),
                    helpText("Enter habitat size (numeric) associated with patch quality (i.e., length, area, or volume)"),
                    #Text box for user to write the project area
                    numericInput(inputId= "area", #ID for server
                                 label= "Area",
                                 "Must be numeric"), #Message in text box
                    br(),br(),
                    helpText("Choose which HSI function to use as the combination equation:"),
                    selectInput(inputId="HSIfunc", label = "Select function", #user must select function
                                choices = c("Pick a function from the list", "HSIarimean", "HSIeqtn (only for bluebook)", "HSIgeomean", "HSImin")
                                ,multiple= FALSE),
                    uiOutput("warimean_example"),
                    uiOutput("warimean_output")
                )
              ),
              fluidRow(
                box(title="HSI Output", #section shows output foinput file SI calcualtion
                    solidHeader = T,
                    status = "primary",
                    div(style='overflow-x: scroll;overflow-y: scroll',tableOutput("SIc"))
                ),
                box(title="HU Output",
                    solidHeader = T,
                    #width = "100%",
                    status = "primary",
                    # verbatimTextOutput("HUc")
                    div(style='overflow-x: scroll;overflow-y: scroll',tableOutput("HUc"))
                )
              )
      ),
      
      
      
      #########################################################################################################################
      # Handles elements for the annualizer
      # Prerequisite: None
      # Box 1. Requires user input file for timevec and benefits
      # Box 2. Output for Box 1
      #########################################################################################################################
      
      tabItem(tabName="Anlzr", #tab to show CEICA
              fluidRow(
                box(
                  title="Manual Input",
                  solidHeader = T,
                  status = "primary",
                  rHandsontableOutput("anlzr_variable_inputs"),
                  br(),br(),
                  radioButtons("anlzr_ready", "Compiler", c("Edit", "Calculate"))
                ),
                box(
                  title="CSV Inputs", #section takes in the user input for the CIECA
                  solidHeader = T,
                  status = "primary",
                  # width = "100%",
                  helpText("This box should ONLY be interacted with IF the user wants to enter data in wide format instead of the default long format."), 
                  checkboxInput("annualizer_format", "Wide Format", FALSE), #the user ticks this box to choose to use their own model. 
                  br(),
                  uiOutput("annualizer_csv_input")
                )
              ),
              fluidRow(
                box(
                  title="Manual Output", #section to output anlzr
                  solidHeader = T,
                  status = "primary",
                  verbatimTextOutput("anlzr_manual")
                ),
                box(
                  title="CSV Output", #section to output CEICA plot
                  solidHeader = T,
                  # width = "100%",
                  status = "primary",
                  tableOutput("anlzr")
                )
              )
      ),
      
      #########################################################################################################################
      # Handles elements for CEICA plot
      # Prerequisite: None
      # Box 1. Requires user input file for CEICA plot and executes function
      # Box 2. Output for Box 1
      #########################################################################################################################
      
      tabItem(tabName="CEICAplot", #tab to show CEICA
              fluidRow(
                box(
                  title="Manual Input (one project alternative at a time)",
                  solidHeader = T,
                  status = "primary",
                  rHandsontableOutput("CEICA_variable_inputs"),
                  br(),br(),
                  radioButtons("CEICA_ready", "Compiler", c("Edit", "Calculate"))
                ),
                box(
                  title="CSV Input", #section takes in the user input for the CIECA
                  solidHeader = T,
                  # width = "100%",
                  status = "primary",
                  helpText("CEICAplotter Plots Cost-effective Incremental Cost Analysis (CEICA) in *.jpeg format"),
                  br(),br(),
                  helpText("Please enter a vector of numerics or characters as unique restoration action identifiers, 
                           a vector of restoration benefits, 
                           a vector of restoration costs, a numeric vector of 0's and 1's indicating whether a plan is cost-effective (1) or non-cost-effective (0), 
                           and a numeric vector of 0's and 1's indicating whether a plan is a best buy (1) or not (0), 
                           all in one file"),
                  helpText("Below is an example format"),
                  downloadButton("example6","Example Format Download"),
                  br(),br(),
                  fileInput("file5", "Upload .csv File", #user input can be found in input$file3
                            multiple = FALSE,
                            accept =   ".csv")
                )
              ),
              fluidRow(
                box(
                  title="Manual Output", #section to output CEICA plot
                  solidHeader = T,
                  status = "primary",
                  tableOutput("BBfinder_manual"), #tabulates the BBfinder 
                  div(style='overflow-x: scroll;overflow-y: scroll',plotOutput("CEICA_manual")) #prints the CEICA plots with scroll wheel
                ),
                box(
                  title="CSV Output", #section to output CEICA plot
                  solidHeader = T,
                  # width = "100%",
                  status = "primary",
                  tableOutput("BBfinder"), #tabulates the BBfinder 
                  div(style='overflow-x: scroll;overflow-y: scroll',plotOutput("CEICA")) #prints the CEICA plots with scroll wheel
                )
              )
      ),
      
      
      #########################################################################################################################
      # Handles elements for generating report
      ### Currrently under development...
      # Prerequisite: Selection tab
      # Box 1. Allows user to download report in given format
      #########################################################################################################################
      
      tabItem(tabName="Exportfiles", #tab allows downloading of report
              fluidRow(
                box(
                  title="Export",
                  solidHeader = T,
                  width = "100%",
                  status = "primary",
                  helpText("Export a program output in .xlsx (for csv input calculations only)"),
                  br(),
                  downloadButton("report_meta","Download Metadata"),
                  br(),br(),
                  downloadButton("report_model","Download Model"),
                  br(),br(),
                  downloadButton("report_SI","Download SI Results"),
                  br(),br(),
                  downloadButton("report_HU","Download HU Results"),
                  br(),br(),
                  downloadButton("report_annualizer","Download Annualizer Results"),
                  br(),br(),
                  downloadButton("report_CEICA","Download CEICA Results"),
                  br(),br(),
                  helpText("Combine and export the reports above in .xlsx"),
                  br(),
                  downloadButton("report","Generate Report")
                )
              )
      )
    )
  )
)


#########################################################################################################################
# This section controlls functions linked to the inputs, outputs,and more
# The server side is handled here, were reactive elements are triggered
#########################################################################################################################

server <- function(input, output, session) { #this function constantly refreshes 
  output$res<-renderMenu({}) #calls the HTMl above and renders it
  
  values <- reactiveValues() #stores values reactively
  
  #########################################################################################################################
  # Function: example -downloadHandler-
  # Output: allows user to download example file
  #########################################################################################################################
  
  output$example0 <- downloadHandler(
    filename = "metadata example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_barredowl_metadata.csv",file)
    }
  )
  
  output$example1 <- downloadHandler(
    filename = "model example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_barredowl_model.csv",file)
    }
  )
  
  output$example2 <- downloadHandler(
    filename = "HSI example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_HSI.csv",file)
    }
  )
  
  output$example4 <- downloadHandler(
    filename = "annualizer long example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_annualizer_long.csv",file)
    }
  )
  
  output$example5 <- downloadHandler(
    filename = "annualizer wide example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_annualizer_wide.csv",file)
    }
  )
  
  output$example6 <- downloadHandler(
    filename = "CEICA example.csv",
    content = function(file) {
      file.copy("./EXAMPLE_CEICA.csv",file)
    }
  )
  
  
  #########################################################################################################################
  # Function: chosen_mod -reactive-
  # Output: content of model dependent on user's model type (bbmodel or usermod)
  #########################################################################################################################
  
  chosen_mod<- reactive({ #handles model content based on user choice
    if(input$usermod==FALSE){
      ecorest::HSImodels[[input$mod]]
    }
    else{
      # model_content = data.frame(lapply(model.input(),)) # was data.frame(lapply(model.input()),as.numeric())
      model_content = data.frame(as.matrix(model.input() %>% head))
    }
  })
  
  #########################################################################################################################
  # Function: metadata.input -reactive-
  # Output: content of metadata file input
  #########################################################################################################################
  
  metadata.input <- reactive({ #verifies and prints that the input file for the SI calculation     
    req(input$file_usermod_metadata) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file_usermod_metadata$name) 
    switch(ext,
           csv = vroom::vroom(input$file_usermod_metadata$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  #########################################################################################################################
  # Function: model.input -reactive-
  # Output: content of user model file input
  #########################################################################################################################
  
  model.input <- reactive({ #verifies and prints that the input file for the SI calculation     
    req(input$file1) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file1$name) 
    switch(ext,
           csv = vroom::vroom(input$file1$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  #########################################################################################################################
  # Function: model.input -table output-
  # Output: table with metadata content to website
  #########################################################################################################################
  
  output$metatable <- renderDataTable({ #Rendesr metadata for model section tab
    datatable(
      t(metatable()),
      options=list(paging=FALSE)
    )
  })
  
  
  metatable <- reactive({
    if(input$usermod==FALSE){
      filtered_table = HSImetadata[,1:ncol(HSImetadata)]%>%
        filter(stringr::str_detect(model, as.character(input$mod)))
    }
    else{
      filtered_table = metadata.input()
    }
    
    filtered_table = t(filtered_table[1,colSums(is.na(filtered_table))==0]) #filter empty columns and transpose
    
    colnames(filtered_table) = c(modname()) #fills column header with model name
    
    return(t(filtered_table))
  })
  
  #########################################################################################################################
  # Function: NA_model -reactive-
  # Output: count how many empty columns there are
  #########################################################################################################################
  
  NA_model <- reactive({
    req(chosen_mod()) #error handling
    j <- 1
    count <- 0
    while(j<=(length(colnames(chosen_mod())))){
      if(grepl("NA.", colnames(chosen_mod())[j], fixed = TRUE)){
        count = count + 1
      }
    }
    return(count)
  })
  
  #########################################################################################################################
  # Function: filter_model -reactive-
  # Output: model w/o empty w/o NA columns
  #########################################################################################################################
  
  filter_model <- reactive({
    req(chosen_mod()) #error handling
    temp.model <- chosen_mod()
    new.model <- temp.model #model placement for shifting columns
    head.model <- new.model
    skip_count <- 0 #number of NA columns taken out
    i <- 1
    j <- 1
    k <- 1
    while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
      head.model <- head.model[,2:length(colnames(head.model))]
      i = i + 1
    }
    while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
      j = j + 1
    }
    tail_count = length(colnames(head.model))-j
    while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
      head.model <- new.model[,1:length(colnames(head.model))-1]
      k = k + 1
    }
    # if(grepl("NA.", colnames(temp.model)[i], fixed = TRUE)){
    #   new.model <- new.model[,(i+1):length(colnames(temp.model))]
    #   skip_count = skip_count + 1
    #   head.model <- new.model[,1:(i-skip_count)]
    # }
    # while(j<=(length(colnames(new.model))-skip_count)){
    #   if(j-skip_count == 0 && grepl("NA.", colnames(new.model)[j], fixed = TRUE)){
    #     head.model <- new.model[,(j+1):length(colnames(new.model))]
    #     skip_count = skip_count + 1
    #     j = j + 1
    #   }
      # else if(grepl("NA.", colnames(new.model)[j], fixed = TRUE)){
      #   if(j == (length(colnames(new.model))))
      #     head.model <- new.model[,1:(j-1)]  
      #   else{
      #     # df_list <- list(new.model[,(1:(j-1))],new.model[,(j+1):(length(colnames(new.model)))])
      #     # head.model <- Reduce(function(x,y) merge(x,y, all=TRUE),df_list)
      #     # j = j + 1
      #     head.model <- new.model[,1:(j-1)]
      #   }
      #   j = j + 1
      # }
      # else{
      #   k <- 1
      #   # if(!grepl("NA.", colnames(new.model)[j], fixed = TRUE) && j == 1){
      #   #   head.model <- new.model[,1:2]
      #   #   j = j + 2
      #   # }
      #   # else{
      #   #   head.model <- new.model[,1:j+1]
      #   #   j = j + 2
      #   # }
      #   while(!grepl("NA.", colnames(new.model)[j], fixed = TRUE) && j < (length(colnames(new.model)))){
      #     # View(head.model)
      #     # head.model <- cbind(new.model[,j],colnames(new.model)[j])
      #     # head.model <- cbind(new.model[,j+1],colnames(new.model)[j+1])
      #     # j = j + 2
      #     k = k + 1
      #     j = j + 1
      #   }
      #   if(k == (length(colnames(new.model))) || j == (length(colnames(new.model))))
      #     head.model <- new.model
      #   else if(k > 1){
      #     df_list <- list(new.model[,(1:(j-1))],new.model[,(j+1):(length(colnames(new.model)))])
      #     head.model <- Reduce(function(x,y) merge(x,y, all=TRUE),df_list)
      #     j = j + 1
      #   }
      # }
      new.model <- head.model
    # }
    return(new.model)
  })
  
  #########################################################################################################################
  # Function: HSIplotter -image output-
  # Output: jpeg file of HSI plotted to website
  #########################################################################################################################
  
  #https://shiny.rstudio.com/articles/images.html
  output$HSIplotter <- renderImage({ #shows image for HSI plotter
    req(chosen_mod()) #error handling
    temp.model <- filter_model()
    outfile <- tempfile(fileext='.jpeg') #creates temporary file to store output in
    HSIplotter(temp.model,outfile) #puts HSI output into the temporary file
    
    list(src=outfile, #pastes image file to the tab
         contentType='image/jpeg',
         height="70%",
         length="70%",
         alt = paste("Habitat Suitability for ", input$mod)
    )
  },deleteFile = FALSE) #don't delete file
  
  
  HSIplotter_download <- reactive({
    temp.model <- chosen_mod()
    outfile <- tempfile(fileext='.jpeg') #creates temporary file to store output in
    HSIplotter(temp.model,outfile) #puts HSI output into the temporary file
  })
  
  
  #########################################################################################################################
  # Function: SIdata.input -reactive-
  # Output: content of file input for SI calculation
  #########################################################################################################################
  
  SIdata.input <- reactive({ #verifies and prints that the input file for the SI calculation     
    req(input$file2) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file2$name) 
    switch(ext,
           csv = vroom::vroom(input$file2$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  #########################################################################################################################
  # Function: head -table output-
  # Output: table with SI data contents (multiple)
  #########################################################################################################################
  
  #Render uploaded field csv
  output$head <- DT::renderDataTable({
    #head(SIdata.input())
    SIdata.input()
  }, escape=FALSE)
  
  
  #########################################################################################################################
  # Function: modname -reactive-
  # Output: name of chosen model is outputted
  #########################################################################################################################
  
  modname<- reactive ({
    if(input$usermod==FALSE)
      paste(input$mod, sep="")
    else{
      metadata = metadata.input()
      paste(metadata[1], sep="")
    }
  }) 
  
  #########################################################################################################################
  # Function: modname -text output-
  # Output: print name of chosen model to website
  #########################################################################################################################
  
  output$modname<-renderText({
    modname()
  })
  
  
  #########################################################################################################################
  # Function: SIc_comp -reactive-
  # Output: calculates values given the user file input
  #########################################################################################################################
  
  #SI file input calculation
  SIc_comp<- reactive({
    req(modname()) #error handling
    req(SIdata.input()) #error handling
    
    #import data
    model = HSImodels[[which(HSImetadata$model == modname())]]
    excel=SIdata.input()
    
    #import dimensions
    SI_col=ncol(excel) 
    SI_row=nrow(excel) 
    
    #find model's number of variables (model.nvar) 
    model.nvar = length(colnames(model))/2 #if the file input format is of type doubled
    # model.nvar = length(colnames(model)) #if the file input format is of type single
    
    #create empty dataframe with proper dimensions 
    SI_genframe <- data.frame(matrix(NA, nrow=SI_row, ncol=SI_col*2))
    excel_genframe <- data.frame(matrix(NA, nrow=SI_row, ncol=SI_col))
    excel_genframe <- excel
    excel_genframe <- as.data.frame(unclass(excel_genframe),                     # Convert all string columns to factor
                           stringsAsFactors = TRUE)
    
    str(model)
    str(excel_genframe)
    #compute suitability relative to each input 
    for(i in 1:SI_row){SI_genframe[i,(model.nvar+1):(model.nvar+model.nvar)] <- SIcalc(model, excel_genframe[i,])}
    
    colnames(SI_genframe) <- c(paste("SI.",colnames(model)[seq(1,length.out=model.nvar,by=2)]),
                               paste("SI.",colnames(model)[seq(2,length.out=model.nvar,by=2)]))
    
    return(SI_genframe[,(SI_col+1):(SI_col+SI_col)])
  })
  
  #########################################################################################################################
  # Function: SIc -table output-
  # Output: table with model calculation values
  #########################################################################################################################
  
  output$SIc <- renderTable({
    table = SIc_comp()
    colnames(table) = substr(colnames(SIc_comp()),1,10)
    return(table)
  },width="100%",spacing="s",digits=2,align="c")
  
  #########################################################################################################################
  # Function: variable_inputs_one.# -render UI-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  output$HSI_variable_inputs_one.1 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 1 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,1])){
        textInput("var1",label=var1_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,1])){
      }
      else
        numericInput("var1",label=var1_name(),"Must be numeric")
    }
    else if(var_num < 0 || var_num > 10)
      helpText("Please use a model with 0-10 suitability indexes.")
  })
  
  output$HSI_variable_inputs_one.2 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 2 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,3])){
        textInput("var1",label=var2_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,3])){
      }
      else
        numericInput("var2",label=var2_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.3 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 3 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,5])){
        textInput("var3",label=var3_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,5])){
      }
      else
        numericInput("var3",label=var3_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.4 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 4 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,7])){
        textInput("var4",label=var4_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,7])){
      }
      else
        numericInput("var4",label=var4_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.5 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 5 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,9])){
        textInput("var5",label=var5_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,9])){
      }
      else
        numericInput("var5",label=var5_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.6 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 6 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,11])){
        textInput("var6",label=var6_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,11])){
      }
      else
        numericInput("var6",label=var6_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.7 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 7 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,13])){
        textInput("var7",label=var7_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,13])){
      }
      else
        numericInput("var7",label=var7_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.8 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 8 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,15])){
        textInput("var8",label=var8_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,15])){
      }
      else
        numericInput("var8",label=var8_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.9 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 9 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,17])){
        textInput("var9",label=var9_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,17])){
      }
      else
        numericInput("var9",label=var9_name(),"Must be numeric")
    }
  })
  
  output$HSI_variable_inputs_one.10 <- renderUI({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 10 && var_num > 0 && var_num < 11){
      if(is.factor(temp.model[1,19])){
        textInput("var10",label=var10_name(),"Must be character string (factor)")
      }
      else if(is.na(temp.model[1,19])){
      }
      else
        numericInput("var10",label=var10_name(),"Must be numeric")
    }
  })
  
  #########################################################################################################################
  # Function: Area_multi -reactive-
  # Output: outputs user's entry for area from text entry box for SI calc multi
  #########################################################################################################################
  
  Area_multi<-reactive({
    temp.model = chosen_mod()
    var_num <- ncol(temp.model)/2
    v$data[,var_num+1]
  })
  
  HSIfunc_multi <- reactive({
    input$HSIfunc_multi
  })
  
  
  #########################################################################################################################
  # Function: observe
  # Output: checks for on the fly operations
  #########################################################################################################################
  
  # observeEvent(chosen_mod(),{ #clears table if the model is changed
  #   #clean model
  #   values[["DF"]]=NULL
  #   temp.model = chosen_mod()
  #   new.model <- temp.model #model placement for shifting columns
  #   head.model <- new.model
  #   skip_count <- 0 #number of NA columns taken out
  #   i <- 1
  #   j <- 1
  #   k <- 1
  #   while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
  #   head.model <- head.model[,3:length(colnames(head.model))]
  #   i = i + 2
  #   }
  #   while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
  #     j = j + 2
  #   }
  #   tail_count = length(colnames(head.model))-j
  #   while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
  #     head.model <- new.model[,1:length(colnames(head.model))-1]
  #     head.model <- new.model[,1:length(colnames(head.model))-1]
  #     k = k + 2
  #   }
  #   temp.model <- head.model
  #   DF <- data.frame(matrix(ncol=length(colnames(temp.model))/2,nrow=10))
  #   values[["DF"]]=DF
  #   n <- length(colnames(temp.model))/2
  #   cont <- c()
  #   for (i in 1:n) {
  #     if(is.factor(temp.model[1, 2 * i - 1]))
  #       cont <- cont + i
  #   }
  #   if(length(cont)>0)
  #     values[["char_cols"]] = cont
  #   else
  #     values[["char_cols"]] = NULL
  # })
  
  observe({
    # if(is.null(chosen_mod())){
    #   values[["DF"]] = NULL
    # }
    # else{
    #       #clean model
    #       temp.model = chosen_mod()
    #       new.model <- temp.model #model placement for shifting columns
    #       head.model <- new.model
    #       skip_count <- 0 #number of NA columns taken out
    #       i <- 1
    #       j <- 1
    #       k <- 1
    #       while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
    #         head.model <- head.model[,3:length(colnames(head.model))]
    #         i = i + 2
    #       }
    #       while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
    #         j = j + 2
    #       }
    #       tail_count = length(colnames(head.model))-j
    #       while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
    #         head.model <- new.model[,1:length(colnames(head.model))-1]
    #         head.model <- new.model[,1:length(colnames(head.model))-1]
    #         k = k + 2
    #       }
    #       temp.model <- head.model
    #       DF <- data.frame(matrix(ncol=length(colnames(temp.model))/2,nrow=10))
    #                        # ,stringsAsFactors = FALSE)
    #                        # factor = factor(letters[1:10], levels = letters[10:1],
    #                        #                 ordered = TRUE),
    #                        # factor_allow = factor(letters[1:10], levels = letters[10:1],
    #                        #                       ordered = TRUE))
    #       values[["DF"]] <- DF
    # }
    # if (!is.null(input$HSI_variable_inputs_multi)){
    #   DF = hot_to_r(input$HSI_variable_inputs_multi)
    # }
    # else{
    #   if(is.null(chosen_mod()))
    #     DF = NULL
    #   else{
    #     #clean model
    #     temp.model = chosen_mod()
    #     new.model <- temp.model #model placement for shifting columns
    #     head.model <- new.model
    #     skip_count <- 0 #number of NA columns taken out
    #     i <- 1
    #     j <- 1
    #     k <- 1
    #     while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
    #       head.model <- head.model[,3:length(colnames(head.model))]
    #       i = i + 2
    #     }
    #     while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
    #       j = j + 2
    #     }
    #     tail_count = length(colnames(head.model))-j
    #     while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
    #       head.model <- new.model[,1:length(colnames(head.model))-1]
    #       head.model <- new.model[,1:length(colnames(head.model))-1]
    #       k = k + 2
    #     }
    #     temp.model <- head.model
    #     DF <- data.frame(matrix(ncol=length(colnames(temp.model))/2,nrow=10))
    #                      # ,stringsAsFactors = FALSE)
    #                      # factor = factor(letters[1:10], levels = letters[10:1], 
    #                      #                 ordered = TRUE),
    #                      # factor_allow = factor(letters[1:10], levels = letters[10:1], 
    #                      #                       ordered = TRUE))
    #     # req(chosen_mod()) #error handling
    #     # n <- length(colnames(temp.model))/2
    #     # cont <- c()
    #     # for (i in 1:n) {
    #     #   if(is.factor(temp.model[1, 2 * i - 1]))
    #     #     cont <- cont + i
    #     # }
    #     # if(length(cont)>0)
    #     #   values[["char_cols"]] = cont
    #     # else
    #     #   values[["char_cols"]] = NULL
    #   # }
    # }
    # values[["DF"]] <- DF
    if(!is.null(input$CEICA_variable_inputs)){
      CEICA = hot_to_r(input$CEICA_variable_inputs)
    }
    else{
      CEICA <- data.frame(matrix(ncol=3,nrow=10))
    }
    values[["CEICA"]] <- CEICA
    if(!is.null(input$anlzr_variable_inputs)){
      anlzr = hot_to_r(input$anlzr_variable_inputs)
    }
    else{
      anlzr <- data.frame(matrix(ncol=2,nrow=10))
    }
    values[["anlzr"]] <- anlzr
  })
  
  
  #########################################################################################################################
  # Function: HSI_variable_inputs_one.# -renderDT-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  v <- reactiveValues(data = NULL)
  
  HSI_variable_inputs_multi <- reactive({
    #clean model
    req(chosen_mod())
    temp.model = chosen_mod()
    new.model <- temp.model #model placement for shifting columns
    head.model <- new.model
    skip_count <- 0 #number of NA columns taken out
    i <- 1
    j <- 1
    k <- 1
    while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
      head.model <- head.model[,3:length(colnames(head.model))]
      i = i + 2
    }
    while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
      j = j + 2
    }
    tail_count = length(colnames(head.model))-j
    while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
      head.model <- new.model[,1:length(colnames(head.model))-1]
      head.model <- new.model[,1:length(colnames(head.model))-1]
      k = k + 2
    }
    temp.model <- head.model
    final.model <- data.frame(matrix(ncol=length(colnames(temp.model))/2+1,nrow=10))
    var_num <- ncol(temp.model)/2
    var_names = data.frame(rep(NA, lnrow=var_num+1))
    for(i in 1:var_num){
      var_names[i] = substr(colnames(temp.model)[i*2-1],1,6)
    }
    var_names[var_num+1] = "Area"
    colnames(final.model) <- var_names
    v$data <- final.model
  }) 
  
  output$HSI_variable_inputs_multi <- renderDT({
    HSI_variable_inputs_multi()
    DT::datatable(v$data, editable = TRUE)
  }) 

  observeEvent(input$HSI_variable_inputs_multi_cell_edit, {
    info = input$HSI_variable_inputs_multi_cell_edit
    i = info$row
    j = info$col
    k = info$value
    v$data[i,j] <- k
  })
  
  
  #########################################################################################################################
  # Function: variable_inputs_one.# -render UI-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  # output$HSI_variable_inputs_multi <- renderRHandsontable({
  #   DF <- values[["DF"]]
  #   if (!is.null(DF)&&!is.null(chosen_mod())){
  #     if(is.null(values[["char_cols"]]))
  #       rhandsontable(DF, useTypes = FALSE, colHeaders = substr(colnames(HSI_multi()),1,6),stretchH = "all",)
  #     else{
  #       rhandsontable(DF, useTypes = FALSE, colHeaders = substr(colnames(HSI_multi()),1,6),stretchH = "all",) %>% hot_col(col=values[["char_cols"]],type="factor",strict=FALSE)
  #     }
  #   }
  #     # rhandsontable(DF, useTypes = as.logical(input$useType), colHeaders = substr(colnames(HSI_multi()),1,6),stretchH = "all")
  # }) 
  
  
  #########################################################################################################################
  # Function: variable_inputs_one.# -render UI-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  HSI_multi <- reactive({
    req(v$data)
    req(modname()) #error handling
    DF <- v$data
    
    #import data
    model = chosen_mod()
    
    #clean model
    temp.model = model
    new.model <- temp.model #model placement for shifting columns
    head.model <- new.model
    skip_count <- 0 #number of NA columns taken out
    i <- 1
    j <- 1
    k <- 1
    while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
      head.model <- head.model[,3:length(colnames(head.model))]
      i = i + 2
    }
    while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
      j = j + 2
    }
    tail_count = length(colnames(head.model))-j
    while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
      head.model <- new.model[,1:length(colnames(head.model))-1]
      head.model <- new.model[,1:length(colnames(head.model))-1]
      k = k + 2
    }
    model <- head.model
    
    #import dimensions
    SI_col=ncol(DF)-1
    SI_row=nrow(DF)

    #find model's number of variables (model.nvar) 
    model.nvar = length(colnames(model))/2 #if the file input format is of type doubled
    
    #create empty dataframe with proper dimensions 
    SI_genframe <- data.frame(matrix(NA, nrow=SI_row, ncol=SI_col*2+1))

    for(i in 1:nrow(na.omit(DF))){
      SI_genframe[i,(model.nvar+1):(model.nvar+model.nvar)] <- SIcalc(model, t(DF[i,1:SI_col]))
      SI_genframe[i,SI_col*2+1] <- as.numeric(Area_multi()[i])
    }
    colnames(SI_genframe) <- c(paste("SI.",colnames(model)[seq(1,length.out=model.nvar,by=2)]),
                               paste("SI.",colnames(model)[seq(2,length.out=model.nvar,by=2)]),
                               "Area")
    eqtn_placer <- rep(NA,SI_row)
    min_placer <- rep(NA,SI_row)
    ari_placer <- rep(NA,SI_row)
    geo_placer <- rep(NA,SI_row)
    HU_placer <- rep(NA,SI_row)
    if(input$manual_ready=="Calculate"){
      for(i in 1:SI_row){
        if(!anyNA(DF[i,SI_col])){
          if(input$usermod==FALSE)
            eqtn_placer[i] <- HSIeqtn(modname(),t(SI_genframe[i,(SI_col+1):(SI_col*2)]),HSImetadata)
          min_placer[i] <- HSImin(SI_genframe[i,(SI_col+1):(SI_col*2)])
          ari_placer[i] <- sum(SI_genframe[i,(SI_col+1):(SI_col*2)])/SI_col
          geo_placer[i] <- HSIgeomean(SI_genframe[i,(SI_col+1):(SI_col*2)])
          if(HSIfunc_multi()=="HSIarimean"){
            HU.out <- as.data.frame(matrix(NA, nrow = 10, ncol = 3))
            colnames(HU.out) <- c("Quality", "Quantity", "IndexUnits")
            HU.out$Quality[i] <- sum(SI_genframe[i,(SI_col+1):(SI_col*2)])/SI_col
            HU.out$Quantity[i] <- as.numeric(Area_multi()[i])
            HU.out$IndexUnits[i] <- HU.out$Quality[i] * HU.out$Quantity[i]
            HU_placer[i] <- HU.out$IndexUnits[i]
          }
          else if(HSIfunc_multi()=="HSIeqtn" && input$usermod==FALSE)
            HU_placer[i] <- eqtn_placer[i] * as.numeric(Area_multi()[i])
          else if(HSIfunc_multi()=="HSIgeomean")
            HU_placer[i] <- HUcalc(SI_genframe[i,(SI_col+1):(SI_col*2)],as.numeric(Area_multi()[i]),HSIgeomean)[[3]]
          else if(HSIfunc_multi()=="HSImin")
            HU_placer[i] <- HUcalc(SI_genframe[i,(SI_col+1):(SI_col*2)],as.numeric(Area_multi()[i]),HSImin)[[3]]
        }
      }
    }
    if(HSIfunc_multi()=='HSIarimean'){
      SI_genframe<-cbind(SI_genframe,HSIarimean=ari_placer)
    }
    else if(HSIfunc_multi()=='HSIeqtn' && input$usermod==FALSE){
      SI_genframe<-cbind(SI_genframe,HSIeqtn=eqtn_placer)
    }
    else if(HSIfunc_multi()=='HSIgeomean'){
      SI_genframe<-cbind(SI_genframe,HSIgeomean=geo_placer)
    }
    else if(HSIfunc_multi()=='HSImin'){
      SI_genframe<-cbind(SI_genframe,HSImin=min_placer)
    }
    SI_genframe<-cbind(SI_genframe,HU=HU_placer)
    return(SI_genframe[,(SI_col+1):(SI_col+SI_col+3)])
  })
  
  
  #########################################################################################################################
  # Function: variable_inputs_one.# -render UI-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  output$HSI_multi <- renderDataTable({
    # datatable(
    #   HSI_multi(),
    #   options=list(paging=FALSE))
    table = HSI_multi()
    colnames(table) = substr(colnames(HSI_multi()),1,10)
    datatable(table) %>%
      formatRound(columns = c(1:ncol(table)),digits = 2)
  })

  

  #########################################################################################################################
  # Function: variable_inputs_one.# -render UI-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  # observeEvent(input$save, {
  #   finalDF <- isolate(values[["DF"]])
  #   saveRDS(finalDF, file=file.path(outdir, sprintf("%s.rds", outfilename)))
  # })
  
  
  #########################################################################################################################
  # Function: var_name -text output-
  # Output: print labels of variables to each numeric input box for user input
  #         in the user entry calculations. Each function represents each box.
  #########################################################################################################################
  
  
  output$var1_name <- renderText({
    var1_name()
  })
  
  
  #########################################################################################################################
  # Function: var_name -reactive-
  # Output: find correct label for each box in numeric order. 
  #         Each function represents each box.
  #########################################################################################################################
  
  var1_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) { #counts the number of user inputs
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<1) #handles error for when user doesn't insert anything
      return("Data unavailable")
    
    if(cont[1]==TRUE){ #when user inserts one variable, do calc
      paste(colnames(temp.model[2 * 1 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var2_name <- renderText({
    var2_name()
  })
  
  var2_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<2)
      return("Data unavailable")
    
    if(cont[2]==TRUE){
      paste(colnames(temp.model[2 * 2 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var3_name <- renderText({
    var3_name()
  })
  
  var3_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<3)
      return("Data unavailable")
    
    if(cont[3]==TRUE){
      paste(colnames(temp.model[2 * 3 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var4_name <- renderText({
    var4_name()
  })
  
  var4_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<4)
      return("Data unavailable")
    
    if(cont[4]==TRUE){
      paste(colnames(temp.model[2 * 4 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var5_name <- renderText({
    var5_name()
  })
  
  var5_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<5)
      return("Data unavailable")
    
    if(cont[5]==TRUE){
      paste(colnames(temp.model[2 * 5 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var6_name <- renderText({
    var6_name()
  })
  
  var6_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<6)
      return("Data unavailable")
    
    if(cont[6]==TRUE){
      paste(colnames(temp.model[2 * 6 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var7_name <- renderText({
    var7_name()
  })
  
  var7_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<7)
      return("Data unavailable")
    
    if(cont[7]==TRUE){
      paste(colnames(temp.model[2 * 7 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var8_name <- renderText({
    var8_name()
  })
  
  var8_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<8)
      return("Data unavailable")
    
    if(cont[8]==TRUE){
      paste(colnames(temp.model[2 * 8 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var9_name <- renderText({
    var9_name()
  })
  
  var9_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<9)
      return("Data unavailable")
    
    if(cont[9]==TRUE){
      paste(colnames(temp.model[2 * 9 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  output$var10_name <- renderText({
    var10_name()
  })
  
  var10_name <- reactive({
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      cont[i] <- !is.na(temp.model[1, 2 * i - 1])
    }
    
    if(length(cont)<10)
      return("Data unavailable")
    
    if(cont[10]==TRUE){
      paste(colnames(temp.model[2 * 10 - 1]))#how to call certain columns that are the variables? how to identify them.
    }
  })
  
  #########################################################################################################################
  # Function: HUc_comp_one -reactive-
  # Output: compiles HSI eqtn and area from the user text input to calculate
  #         HU
  #########################################################################################################################
  
  HUc_comp_one <- reactive({ #does HU calc as defined by the example equations given by Kyle, instead of using the HU function
    return(HSI_comp_one_eqtn()*Area_one())
  })
  
  #########################################################################################################################
  # Function: Area_one -reactive-
  # Output: outputs user's entry for area from text entry box for SI calc
  #########################################################################################################################
  
  Area_one<-reactive({
    input$area_one
  })
  
  #########################################################################################################################
  # Function: Area_one -renderText-
  # Output: prints user's area entry to website
  #########################################################################################################################
  
  output$Area_one<- renderText({
    Area_one()
  })
  
  #########################################################################################################################
  # Function: HUc_one -renderText-
  # Output: prints out the HUc of the user entry to the website
  #########################################################################################################################
  
  output$HUc_one<- renderText({
    HUc_comp_one()
  })
  
  #########################################################################################################################
  # Function: HSIeqtn_one -renderText-
  # Output: outputs user's entry for area from text entry box for SI calc
  #########################################################################################################################
  
  output$HSIeqtn_one<-renderText({
    HSIeqtn_comp_one()
  })
  
  #########################################################################################################################
  # Function: HSIeqtn_comp_one -reactive-
  # Output: calculates HSI given the user's text input through the HSIeqtn func
  #########################################################################################################################
  
  HSI_comp_one<-reactive({ #handles the simple SI calculation
    req(chosen_mod()) #error handling
    temp.model <- chosen_mod()
    n <- length(colnames(temp.model))/2
    cont <- c()
    for (i in 1:n) {
      if(is.factor(temp.model[1, 2 * i - 1]))
        cont[i] <- temp.model[1, 2 * i - 1]
      else if(is.na(temp.model[1, 2 * i - 1])){}
      else
        cont[i] <- is.numeric(temp.model[1, 2 * i - 1])
    }

    #uses user input as data only if it exists
    if(cont[1]==TRUE && length(cont)==1)
      data = c(input$var1)
    if(cont[2]==TRUE && length(cont)==2)
      data = c(input$var1,input$var2)
    if(cont[3]==TRUE && length(cont)==3)
      data = c(input$var1,input$var2,input$var3)
    if(cont[4]==TRUE && length(cont)==4)
      data = c(input$var1,input$var2,input$var3,input$var4)
    if(cont[5]==TRUE && length(cont)==5)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5)
    if(cont[6]==TRUE && length(cont)==6)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5,input$var6)
    if(cont[7]==TRUE && length(cont)==7)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5,input$var6,input$var7)
    if(cont[8]==TRUE && length(cont)==8)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5,input$var6,input$var7,input$var8)
    if(cont[9]==TRUE && length(cont)==9)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5,input$var6,input$var7,input$var8,input$var9)
    if(cont[10]==TRUE && length(cont)==10)
      data = c(input$var1,input$var2,input$var3,input$var4,input$var5,input$var6,input$var7,input$var8,input$var9,input$var10)
    
    for (i in 1:n) {
      if(is.factor(temp.model[1, 2 * i - 1]))
        cont[i] <- temp.model[1, 2 * i - 1]
      else if(is.na(temp.model[1, 2 * i - 1])){}
      else
        cont[i] <- is.numeric(temp.model[1, 2 * i - 1])
    }
      
    new.model <- temp.model #model placement for shifting columns
    head.model <- new.model
    skip_count <- 0 #number of NA columns taken out
    i <- 1
    j <- 1
    k <- 1
    while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
      head.model <- head.model[,3:length(colnames(head.model))]
      i = i + 2
    }
    while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
      j = j + 2
    }
    tail_count = length(colnames(head.model))-j
    while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
      head.model <- new.model[,1:length(colnames(head.model))-1]
      head.model <- new.model[,1:length(colnames(head.model))-1]
      k = k + 2
    }
    new.model <- head.model
    return(SIcalc(new.model, data))
  })
  
  
  #########################################################################################################################
  # Function: HSI_one -reactive-
  # Output: inputs single HSI values into table 
  #########################################################################################################################
  
  HSI_one<-reactive({
    req(chosen_mod()) #error handling
    req(HSI_comp_one())
    #calculate HSI
    temp.model <- chosen_mod()
    new.model <- temp.model #model placement for shifting columns
    head.model <- new.model
    skip_count <- 0 #number of NA columns taken out
    i <- 1
    j <- 1
    k <- 1
    while(grepl("NA.", colnames(head.model)[1], fixed = TRUE && i<=length(colnames(head.model)))){
      head.model <- head.model[,3:length(colnames(head.model))]
      i = i + 2
    }
    while(!grepl("NA.", colnames(head.model)[j], fixed = TRUE) && j<=length(colnames(head.model))){
      j = j + 2
    }
    tail_count = length(colnames(head.model))-j
    while(grepl("NA.", colnames(head.model)[length(colnames(head.model))], fixed = TRUE) && k<=tail_count){
      head.model <- new.model[,1:length(colnames(head.model))-1]
      head.model <- new.model[,1:length(colnames(head.model))-1]
      k = k + 2
    }
    new.model <- head.model
    temp.model <- new.model
    var_num <- length(colnames(temp.model))/2
    HSI_comp_one_table = as.data.frame(matrix(NA, nrow = 3+var_num, ncol = 2))
    var_names = data.frame(rep(NA, lnrow=var_num+1))
    for(i in 1:var_num){
      HSI_comp_one_table[i,1] = substr(paste("SI.",colnames(temp.model)[i*2-1]),1,10)
    }
    colnames(HSI_comp_one_table) = c("Labels","Values")
    SI = HSI_comp_one()
    var_count = 0
    for(i in 1:var_num){
      if(var_num >= i && var_num > 0 && var_num < 11){
        HSI_comp_one_table[i,2]=SI[i]
      }
    }
    
    #calculate HU
    HU = NULL
    if(HSIfunc_one()=='HSIarimean'){
      HU.out <- as.data.frame(matrix(NA, nrow = 1, ncol = 3))
      colnames(HU.out) <- c("Quality", "Quantity", "IndexUnits")
        HU.out$Quality <- HSI_comp_one_arimean()
        HU.out$Quantity <- Area_one()
        HU.out$IndexUnits <- HU.out$Quality * HU.out$Quantity
      HU <- HU.out$IndexUnits
      HSI_comp_one_table[var_num+1,1]="HSIarimean"
      HSI_comp_one_table[var_num+1,2]=HSI_comp_one_arimean()
    }
    else if(HSIfunc_one()=='HSIeqtn' && input$usermod==FALSE){
      HU = HSIeqtn(modname(),HSI_comp_one(),HSImetadata) * Area_one()
      HSI_comp_one_table[var_num+1,1]="HSIeqtn"
      HSI_comp_one_table[var_num+1,2]=HSIeqtn(modname(),HSI_comp_one(),HSImetadata)
    }
    else if(HSIfunc_one()=='HSIgeomean'){
      HU = HUcalc(HSI_comp_one(),Area_one(),HSIgeomean)[[3]]
      HSI_comp_one_table[var_num+1,1]="HSIgeomean"
      HSI_comp_one_table[var_num+1,2]=HSI_comp_one_geomean()
    }
    else if(HSIfunc_one()=='HSImin'){
      HU = HUcalc(HSI_comp_one(),Area_one(),HSImin)[[3]]
      HSI_comp_one_table[var_num+1,1]="HSImin"
      HSI_comp_one_table[var_num+1,2]=HSI_comp_one_min()
    }
    HSI_comp_one_table[var_num+2,1]="Area"
    HSI_comp_one_table[var_num+2,2]=Area_one()
    HSI_comp_one_table[var_num+3,1]="HU"
    HSI_comp_one_table[var_num+3,2]=HU #HSIfunc_one for function option
    return(HSI_comp_one_table)
  })
  
  HSIfunc_one <- reactive({
    input$HSIfunc_one
  })
  
  #########################################################################################################################
  # Function: HSI_one -table output-
  # Output: controls the single calculation SI output
  #########################################################################################################################
  
  output$HSI_one<-renderTable({
    HSI_one()
  # },rownames=TRUE,na="",width="100%",spacing="s",digits=2,align="c")
  },na="",width="100%",spacing="s",digits=2,align="c")
  
  
  #########################################################################################################################
  # Function: HSI_one.x -render text-
  # Output: calculates SI for each index in single calculation HSI section
  #########################################################################################################################
  
  output$HSI_one.1<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 1 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[1],1,6),": ",HSI[1])
    }
  })
  
  output$HSI_one.2<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 2 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[3],1,6),": ",HSI[2])
    }
  })
  
  output$HSI_one.3<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 3 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[5],1,6),": ",HSI[3])
    }
  })
  
  output$HSI_one.4<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 4 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[7],1,6),": ",HSI[4])
    }
  })
  
  output$HSI_one.5<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 5 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[9],1,6),": ",HSI[5])
    }
  })
  
  output$HSI_one.6<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 6 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[11],1,6),": ",HSI[6])
    }
  })
  
  output$HSI_one.7<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 7 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[13],1,6),": ",HSI[7])
    }
  })
  
  output$HSI_one.8<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 8 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[15],1,6),": ",HSI[8])
    }
  })
  
  output$HSI_one.9<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 9 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[17],1,6),": ",HSI[9])
    }
  })
  
  output$HSI_one.10<-renderText({
    temp.model <- chosen_mod()
    var_num <- length(colnames(temp.model))/2
    if(var_num >= 10 && var_num > 0 && var_num < 11){
      HSI = HSI_comp_one()
      paste0(substr(colnames(temp.model)[19],1,6),": ",HSI[10])
    }
  })
  
  #########################################################################################################################
  # Function: HSI_comp_one_min -reactive-
  # Output: calculates HSImin for HSI section
  #########################################################################################################################
  
  HSI_comp_one_min<-reactive({
    #Compute suitability for each variable
    SI <- HSI_comp_one()
    
    #Compute overall habitat suitability with min method
    return(HSImin(SI))
  })
  
  #########################################################################################################################
  # Function: HSI_comp_one_arimean -reactive-
  # Output: calculates HSIarimean for HSI section
  #########################################################################################################################
  
  HSI_comp_one_arimean<-reactive({
    #Compute suitability for each variable
    SI <- HSI_comp_one()
    #Compute overall habitat suitability with arimean method
    return(HSIarimean(SI))
  })
  
  #########################################################################################################################
  # Function: HSI_comp_one_geomean -reactive-
  # Output: calculates HSIgeomean for HSI section
  #########################################################################################################################
  
  HSI_comp_one_geomean<-reactive({
    #Compute suitability for each variable
    SI <- HSI_comp_one()
    
    #Compute overall habitat suitability with geomean method
    return(HSIgeomean(SI))
  })
  
  #########################################################################################################################
  # Function: warimean_example -render UI-
  # Output: presents weighted values input file if warimean is the chosen option
  #########################################################################################################################
  
  output$warimean_example<-renderUI({
    if(input$HSIfunc=='HSIwarimean' || input$HSIfunc=='Show all'){
      downloadButton("example3","Example Format Download")
    }
  })
  
  #########################################################################################################################
  # Function: warimean_output -render UI-
  # Output: presents weighted values input file if warimean is the chosen option
  #########################################################################################################################
  
  output$warimean_output<-renderUI({
    if(input$HSIfunc=='HSIwarimean' || input$HSIfunc=='Show all'){
      fileInput("warimean.weights","Vector of Weights", #user uploads csv file and is put into input$warimean.weights
                multiple = FALSE,
                accept =   ".csv")
    }
  })
  
  #########################################################################################################################
  # Function: warimean.weights.input -reactive-
  # Output: content of warimean file input 
  #########################################################################################################################
  
  warimean.weights.input<-reactive({
    req(input$warimean.weights) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$warimean.weights$name) 
    switch(ext,
           csv = vroom::vroom(input$warimean.weights$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  #########################################################################################################################
  # Function: warimean.weights -reactive-
  # Output: converts content of warimean file input into usable form
  #########################################################################################################################
  
  warimean.weights<-reactive({
    weights=warimean.weights.input()
    return(t(weights[]))
  })
  
  area <- reactive({
    input$area
  })
  
  #########################################################################################################################
  # Function: HUc -reactive-
  # Output: calculates HU given the results of the SI calc
  #########################################################################################################################
  
  HUc <- reactive({ 
    SI_function = SIc_comp()
    SI_row = nrow(SI_function)
    SI_col = ncol(SI_function)
    HU = data.frame(rep(NA, lnrow=SI_row))
    if(input$HSIfunc=='HSIarimean'){
      for(i in 1:SI_row){
        HU.out <- as.data.frame(matrix(NA, nrow = 1, ncol = 3))
        colnames(HU.out) <- c("Quality", "Quantity", "IndexUnits")
        HSI <- sum(SI_function[i,1:SI_col])/SI_col #took out ", na.rm = TRUE"
        if (HSI < 0 | HSI > 1) {
          HU.out$Quality <- "Habitat suitability index not within 0 to 1 range."
        }
        else {
          HU.out$Quality <- HSI
        }
        HU.out$Quantity <- area()
        HU.out$IndexUnits <- HU.out$Quality * HU.out$Quantity
        HU[i] = HU.out$IndexUnits
      }
      return(HU)
    }
    else if(input$HSIfunc=='HSIgeomean'){
      for(i in 1:SI_row)
        HU[i] = HUcalc(SI_function[i,],area(),HSIgeomean)[3]
      return(HU)
    }
    else if(input$HSIfunc=='HSImin'){
      for(i in 1:SI_row)
        HU[i] = HUcalc(SI_function[i,],area(),HSImin)[3]
      return(HU)
    }
    else if(input$HSIfunc=='HSIeqtn' && input$usermod==FALSE){
      for(i in 1:SI_row)
        # HU[i] = HUcalc(SI_function[i,],area(),HSIeqtn,HSImetadata)
        HU[i] = HSIeqtn(modname(),t(SI_function[i,]),HSImetadata)* area()
      return(HU)
    }
    # else if(input$HSIfunc=='Show all'){
    #   return(HUc.all())
    # }
  })
  
  #########################################################################################################################
  # Function: HUc -renderPrint-
  # Output: prints out result of HUc calculation to website
  #########################################################################################################################
  
  output$HUc<-renderTable({
    table <- t(HUc())
    colnames(table) <- c("HU")
    return(table)
  },width="100%",spacing="s",digits=2,align="c")
  
  #########################################################################################################################
  # Function: HUc.all -reactive-
  # Output: calculates all HU functions at once and stores in dataframe
  #########################################################################################################################
  
  HUc.all<-reactive({
    SI_function = SIc_comp()
    #import dimensions
    temp.model <- chosen_mod()
    HU_row <- length(colnames(SI_function))
    HU_col <- 4 #number of total subfunctions in HU
    
    #create empty dataframe with proper dimensions 
    HU_genframe <- data.frame(matrix(NA, nrow=HU_row*nrow(SI_function), ncol=HU_col))
    
    # HU_genframe = data.frame(rep(NA, lnrow=HU_row))
    
    #populate dataframe
    colnames(HU_genframe) = c('HSIarimean','HSIeqtn','HSIgeomean','HSImin')
    HU_genframe = t(HU_genframe)
    
    #create colnames dependant on number of samples
    col_name <- data.frame(matrix(NA, nrow=2, ncol=HU_row*nrow(SI_function)))
    
    for(i in 1:nrow(SI_function)){
      if(i==1)
        j = 1
      else
        j = (i-1)*3+1
      
      col_name[1,j] <- paste("Quality.",i)
      col_name[1,j+1] <- paste("Quantity.",i)
      col_name[1,j+2] <- paste("IndexUnits.",i)
    }
    colnames(HU_genframe) <- col_name[1,]
    
    
    for(i in 1:nrow(SI_function)){
      HU.out <- as.data.frame(matrix(NA, nrow = 1, ncol = 3))
      colnames(HU.out) <- c("Quality", "Quantity", "IndexUnits")
      
      HSI <- mean(SI_function[i,1]) #took out ", na.rm = TRUE"
      if (HSI < 0 | HSI > 1) {
        HU.out$Quality <- "Habitat suitability index not within 0 to 1 range."
      }
      else {
        HU.out$Quality <- HSI
      }
      
      HU.out$Quantity <- input$area
      HU.out$IndexUnits <- HU.out$Quality * HU.out$Quantity
      
      if(i==1)
        j = 1
      else
        j = (i-1)*3+1
      
      HU_genframe[1,j] = HU.out$Quality
      HU_genframe[1,j+1] = HU.out$Quantity
      HU_genframe[1,j+2] = HU.out$IndexUnits
      # HU_genframe[2,j] = HUcalc(SI_function[i,],input$area,HSIeqtn,HSImetadata)$Quality
      # HU_genframe[2,j+1] = HUcalc(SI_function[i,],input$area,HSIeqtn,HSImetadata)$Quantity
      # HU_genframe[2,j+2] = HUcalc(SI_function[i,],input$area,HSIeqtn,HSImetadata)$IndexUnits
      HU_genframe[2,j] = HU.out$Quality
      HU_genframe[2,j+1] = HU.out$Quantity
      HU_genframe[2,j+2] = HU.out$IndexUnits
      HU_genframe[3,j] = HUcalc(SI_function[i,],input$area,HSIgeomean)$Quality
      HU_genframe[3,j+1] = HUcalc(SI_function[i,],input$area,HSIgeomean)$Quantity
      HU_genframe[3,j+2] = HUcalc(SI_function[i,],input$area,HSIgeomean)$IndexUnits
      HU_genframe[4,j] = HUcalc(SI_function[i,],input$area,HSImin)$Quality
      HU_genframe[4,j+1] = HUcalc(SI_function[i,],input$area,HSImin)$Quantity
      HU_genframe[4,j+2] = HUcalc(SI_function[i,],input$area,HSImin)$IndexUnits
    }
    
    return(HU_genframe[,])
  })
  
  
  #########################################################################################################################
  # Function: annualizer.long.input -reactive-
  # Output: outputs content of annualizer long file input
  #########################################################################################################################
  
  annualizer.long.input <- reactive({ #verifies and pastes CEICA file     
    req(input$file3) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file3$name) 
    switch(ext,
           csv = vroom::vroom(input$file3$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  
  #########################################################################################################################
  # Function: annualizer.wide.input -reactive-
  # Output: outputs content of annualizer wide file input
  #########################################################################################################################
  
  annualizer.wide.input <- reactive({ #verifies and pastes CEICA file     
    req(input$file4) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file4$name) 
    switch(ext,
           csv = vroom::vroom(input$file4$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  
  #########################################################################################################################
  # Function: annualizer_csv_input -renderUI-
  # Output: handles user UI for ipnut file choice (long vs wide)
  #########################################################################################################################
  
  output$annualizer_csv_input <- renderUI({
    if(input$annualizer_format==FALSE){
      tagList(
        helpText("LONG FORMAT"),
        helpText("Annualizer computes time-averaged quantities based on linear interpolation."),
        helpText("Please enter the numeric vector of time intervals and values to be interpolated."),
        helpText("Below is an example format"),
        downloadButton("example4","Example Format Download"),
        br(), br(),
        fileInput("file3", "Upload .csv File", #user input can be found in input$file3
                  multiple = FALSE,
                  accept =   ".csv")
      )
    }
    else{
      tagList(
        helpText("WIDE FORMAT"),
        helpText("Annualizer computes time-averaged quantities based on linear interpolation."),
        helpText("Please enter the numeric vector of time intervals and values to be interpolated."),
        helpText("Below is an example format"),
        downloadButton("example5","Example Format Download"),
        br(), br(),
        fileInput("file4", "Upload .csv File", #user input can be found in input$file3
                  multiple = FALSE,
                  accept =   ".csv"),
      )
    }
  })
  
  #########################################################################################################################
  # Function: annualizer.all -reactive-
  # Output: calculates annualizer
  #########################################################################################################################
  
  annualizer.all <- reactive({
    tv <- c()
    bf <- c()
    alt <- c()
    anl <- c()
    if(input$annualizer_format==FALSE){ #annualizer calculations for long format
      tv <- cbind(tv,annualizer.long.input()[[1,2]])
      bf <- cbind(bf,annualizer.long.input()[[1,3]])
      if(nrow(annualizer.long.input())==2)
        return(cbind(annualizer.long.input()[[2,1]],annualizer(tv,bf)))
      else{
        for(i in 2:(nrow(annualizer.long.input()))){
          if(i==(nrow(annualizer.long.input()))){
            if(annualizer.long.input()[i-1,1]!=annualizer.long.input()[i,1]){
              alt <- cbind(alt,annualizer.long.input()[[i-1,1]])
              anl <- cbind(anl,annualizer(tv,bf))
              tv <- c()
              bf <- c()
            }
            tv <- cbind(tv,annualizer.long.input()[[i,2]])
            bf <- cbind(bf,annualizer.long.input()[[i,3]])
            alt <- cbind(alt,annualizer.long.input()[[i,1]])
            anl <- cbind(anl,annualizer(tv,bf))
          }          
          else if(annualizer.long.input()[i-1,1]==annualizer.long.input()[i,1]){
            tv <- cbind(tv,annualizer.long.input()[[i,2]])
            bf <- cbind(bf,annualizer.long.input()[[i,3]])
          }
          else{
            alt <- cbind(alt,annualizer.long.input()[[i-1,1]])
            anl <- cbind(anl,annualizer(tv,bf))
            tv <- c()
            bf <- c()
            tv <- cbind(tv,annualizer.long.input()[[i,2]])
            bf <- cbind(bf,annualizer.long.input()[[i,3]])
          }
        }
      }
    }
    else{ #annualizer calculations for wide format
      for(i in 2:nrow(annualizer.wide.input())){
        alt <- cbind(alt,annualizer.wide.input()[[i,1]])
        for(j in 2:ncol(annualizer.wide.input())){
          tv <- cbind(tv,annualizer.wide.input()[[1,j]])
          bf <- cbind(bf,annualizer.wide.input()[[i,j]])
        }
        anl <- cbind(anl,annualizer(tv,bf))
        tv <- c()
        bf <- c()
      }
    }
    table <- cbind(t(alt),t(anl)) #tabulate calculations
    colnames(table) <- c("ALT","TIMEAVG")
    return(table)
  })
  
  
  #########################################################################################################################
  # Function: anlzr -renderTable-
  # Output: prints out table of result of annualizer calculations
  #########################################################################################################################
  
  output$anlzr <- renderTable({
    annualizer.all()
  },na="",width="100%",spacing="s",digits=2,align="c")
  
  
  #########################################################################################################################
  # Function: anlzr_variable_inputs -renderRHandsontable-
  # Output: prints annualizer input table
  #########################################################################################################################
  
  output$anlzr_variable_inputs <- renderRHandsontable({
    DF <- values[["anlzr"]]
    if (!is.null(DF)){rhandsontable(DF, useTypes = FALSE, colHeaders = c("timevec","benefits"),stretchH = "all",)
    }
    # rhandsontable(DF, useTypes = as.logical(input$useType), colHeaders = substr(colnames(HSI_multi()),1,6),stretchH = "all")
  })
  
 
  #########################################################################################################################
  # Function: anlzr_manual 
  # Output: handles equations for annualizer function manual
  #########################################################################################################################
  
  anlzr_manual <- reactive({
    req(values[["anlzr"]])
    req(modname()) #error handling
    DF <- values[["anlzr"]]
    if(input$anlzr_ready=="Calculate"){
      for(i in 1:10){
        if(is.na(DF[i,1])){
          i = 10
        }
        else{
          rows = i
        }
      }
      tv = t(DF[1:rows,1])
      bf = t(DF[1:rows,2])
      annualizer(tv,bf)
      return(annualizer(tv,bf))
    }
  })
  
  
  #########################################################################################################################
  # Function: anlzr_manual -renderPrint-
  # Output: prints out result of annualizer manual calculation to website
  #########################################################################################################################
  
  output$anlzr_manual <- renderPrint({
    if(input$anlzr_ready=="Calculate"){
      anlzr_manual()
    }
  })
  
  
  #########################################################################################################################
  # Function: CEICA_variable_inputs# -render Handsontable-
  # Output: print input boxes according to number of suitability indexes in the model
  #########################################################################################################################
  
  output$CEICA_variable_inputs <- renderRHandsontable({
    DF <- values[["CEICA"]]
    if (!is.null(DF)){rhandsontable(DF, useTypes = FALSE, colHeaders = c("altnames","benefit","cost"),stretchH = "all",)
    }
  })
  
  
  #########################################################################################################################
  # Function: CEICA_manual_input -image output-
  # Output: partitions data for CEICA function and outputs CEICA plot as image
  #########################################################################################################################
  
  output$CEICA_manual <- renderImage({ #handles image for printing
    req(values[["CEICA"]])
    data <- values[["CEICA"]] #gets input from user
    rows = 1
    if(input$CEICA_ready=="Calculate"){
      for(i in 1:10){
        if(is.na(data[i,1])){
          i = 10
        }
        else{
          rows = i
        }
      }
      if(!is.na(data[rows,3])){
        altnames <- as.vector(data[1:rows,1]) #puts input into respective variables
        benefit <- as.vector(data[1:rows,2])
        cost <- as.vector(data[1:rows,3])
        CE <- CEfinder(benefit,cost)
        BB <- BBfinder(benefit,cost,CE)[[1]][,4]
        outfile_CEICA <- tempfile(fileext='.jpeg') #create temporary file to copy to
        CEICAplotter(altnames,benefit,cost,CE,BB,outfile_CEICA) #copies CEICA output to temporary file
      }
    }
    else{
      outfile_CEICA <- tempfile(fileext='.jpeg') #create temporary file to copy to
    }
    list(src=outfile_CEICA, #print temporary file to tab
          contentType='image/jpeg',
          height=400,
          length=400,
          alt = paste("CEICA plotter for ", modname())
    )
  },deleteFile = FALSE)
  
  
  #########################################################################################################################
  # Function: CEICA.all -reactive-
  # Output: calculates CEICA
  #########################################################################################################################
  
  CEICA.all<-reactive({ #tabulates BBfinder
    data <- CEICAdata.input() #gets input from user
    altnames <- as.vector(data[[1]]) #puts input into respective variables
    benefit <- as.vector(data[[2]])
    cost <- as.vector(data[[3]])
    CE <- CEfinder(benefit,cost)
    BB <- BBfinder(benefit,cost,CE)[[1]]
    table<-cbind(altnames,BB)
    return(table)
  })
  
  
  #########################################################################################################################
  # Function: BBfinder_manual -renderTable-
  # Output: creates tabel for BBfinder
  #########################################################################################################################
  
  output$BBfinder_manual<-renderTable({ #tabulates BBfinder
    req(values[["CEICA"]])
    data <- values[["CEICA"]] #gets input from user
    rows = 1
    if(input$CEICA_ready=="Calculate"){
      for(i in 1:10){
        if(is.na(data[i,1])){
          i = 10
        }
        else{
          rows = i
        }
      }
      if(!is.na(data[rows,3])){
        altnames <- as.vector(data[1:rows,1]) #puts input into respective variables
        benefit <- as.vector(data[1:rows,2])
        cost <- as.vector(data[1:rows,3])
        CE <- CEfinder(benefit,cost)
        BB <- BBfinder(benefit,cost,CE)[[1]]
        table<-cbind(altnames,BB)
      }
    }
    # },rownames=TRUE,na="",width="100%",spacing="s",digits=2,align="c")
  },na="",width="100%",spacing="s",digits=2,align="c")
  
  
  #########################################################################################################################
  # Function: CEICAdata.input -reactive-
  # Output: outputs content of CEICA file input
  #########################################################################################################################
  
  CEICAdata.input <- reactive({ #verifies and pastes CEICA file     
    req(input$file5) #default is NULL so this waits until 1st file is uploaded for the code to run
    ext <- tools::file_ext(input$file5$name) 
    switch(ext,
           csv = vroom::vroom(input$file5$datapath, delim = ","), #datapath is the path to where the data has been uploaded
           validate("Invalid file; Please upload a .csv file") #add error message if the user puts another type of file
    )
  })
  
  #########################################################################################################################
  # Function: CEICA -image output-
  # Output: partitions data for CEICA function and outputs CEICA plot as image
  #########################################################################################################################
  
  output$CEICA <- renderImage({ #handles image for printing
    data <- CEICAdata.input() #gets input from user
    altnames <- as.vector(data[[1]]) #puts input into respective variables
    benefit <- as.vector(data[[2]])
    cost <- as.vector(data[[3]])
    CE <- CEfinder(benefit,cost)
    BB <- BBfinder(benefit,cost,CE)[[1]][,4]
    outfile_CEICA <- tempfile(fileext='.jpeg') #create temporary file to copy to
    CEICAplotter(altnames,benefit,cost,CE,BB,outfile_CEICA) #copies CEICA output to temporary file
    
    list(src=outfile_CEICA, #print temporary file to tab
         contentType='image/jpeg',
         height=400,
         length=400,
         alt = paste("CEICA plotter for ", modname())
    )
  },deleteFile = FALSE)
  
  
  #########################################################################################################################
  # Function: BBfinder -renderTable-
  # Output: creates table for BBfinder
  #########################################################################################################################
  
  output$BBfinder<-renderTable({ #tabulates BBfinder
    CEICA.all()
  },na="",width="100%",spacing="s",digits=2,align="c")
  
  
  #########################################################################################################################
  # Function: report_x -file output-
  # Output: outputs file with desired content to the user
  #########################################################################################################################
  
  output$report_meta <- downloadHandler(
    filename = function(){
      paste("Ecorest-Metadata-", modname(), "-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(metatable(), file, sheetName = 'metadata',row.names=FALSE)
    }
  )
  
  output$report_model <- downloadHandler(
    filename = function(){  
      paste("Ecorest-Model-", modname(), "-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(chosen_mod(), file, sheetName = 'model content',row.names=FALSE)
    }
  )
  
  output$report_SI <- downloadHandler(
    filename = function(){
      paste("Ecorest-SI-", modname(), "-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(SIc_comp(), file, sheetName = 'SIc_comp()',row.names=FALSE)
    }
  )
  
  output$report_HU <- downloadHandler(
    filename = function(){
      paste("Ecorest-HU-", modname(), "-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(HUc.all(), file, sheetName = 'HU',row.names=FALSE)
    }
  )
  
  output$report_annualizer <- downloadHandler(
    filename = function(){
      paste("Ecorest-Annualizer-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(annualizer.all(), file, sheetName = 'Annualizer',row.names=FALSE)
    }
  )
  
  output$report_CEICA <- downloadHandler(
    filename = function(){
      paste("Ecorest-CEICA-", Sys.Date(), ".xlsx", sep="")
    },
    content = function(file){
      write.xlsx(CEICA.all(), file, sheetName = 'CEICA',row.names=FALSE)
    }
  )
  
  
  #########################################################################################################################
  # Function: report -file output-
  # Output: saves all chosen outputs to their respective files and then appends them together into the final output file
  #########################################################################################################################
  
  output$report <- downloadHandler(
    filename = function(){
      paste('Ecorest-Report-', modname(), "-", Sys.Date(), ".xlsx", sep = "")
    },
    
    content = function(file){
      write.xlsx(report_data_list(), file, row.names=FALSE)
    }
  )
  
  #########################################################################################################################
  # Function: report_data_list -reactive-
  # Output: lists all exported data into one list so it can be put in their own sheet in a single excel
  #########################################################################################################################
  
  report_data_list<-reactive({
    list(
      metatable = metatable(),
      model_data = chosen_mod(),
      HSI = SIc_comp(),
      HU = HUc.all(),
      annualizer = annualizer.all(),
      CEICA = CEICA.all()
    )
  })
  
  
  #########################################################################################################################
  # Function: redirect -website redirect output-
  # Output: prints website page of ecorest
  #########################################################################################################################
  
  output$redirect<-renderUI({ #prints description of ecorest from web
    tags$a(href=input$website,input$website)
  })
  
  
}

# shiny::reactlogShow()
shinyApp(ui=ui, server=server) 