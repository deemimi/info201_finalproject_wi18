library('httr')
library('dplyr')
library('mapproj')
library('ggplot2')
library('namespace')
library('fiftystater')
library('maptools')
library('maps')
library('data.table')
library("RColorBrewer")
library(shiny)


rentData <- read.csv('data/State_Zri_MultiFamilyResidenceRental.csv')


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # prepares poverty dataset
    url <- 'https://api.census.gov/data/timeseries/poverty/saipe?get=NAME,SAEPOVRTALL_LB90,SAEPOVRTALL_MOE,SAEPOVRTALL_PT,SAEPOVRTALL_UB90&for=state:*&time=from+1980'
    response <- GET(url)
    body <- content(response, 'text')
    povData <- data.frame(fromJSON(body), stringsAsFactors = F)
    colnames(povData) <- c('Name', "LowerBound", 'MarginOfError', 'Estimate', 'UpperBound', 'Year', 'state.name')
    povData <- povData[-1,]
    #prep data
    states <- data.frame(state.abb, state.name)
    byStatePov <- select(povData, Name, Estimate, Year, state.name)
    newPov <- left_join(byStatePov, states)
    newPov = subset(newPov, select = -c(state.abb) )
    newPov$Name <- tolower(newPov$Name)
    #prep map
    data('fifty_states')
    colnames(fifty_states) <- c("long",  "lat"   ,"order" ,"hole",  "piece", "Name",    "group")
    mapThisPov <- left_join(fifty_states, newPov, by = 'Name')
  
    # prepares zillow rent data
    rentData <-  spread
    
    dataset <- reactive({
      return(tbl_df(rentData)) %>% 
        filter(rentData)
    }) 
    
    
  })
  
})
