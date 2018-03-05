library('httr')
library('dplyr')
library('mapproj')
library('ggplot2')
library('namespace')
library('fiftystater')
library('maptools')
library('maps')
library('data.table')
library('jsonlite')
library("RColorBrewer")
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
a <- as.numeric(mapThisPov['Year'][1:nrow(mapThisPov['Year']),])
a <- unique(a)
mapThisPov <- filter(mapThisPov, Year == a[1])
# Define UI for application that draws map for various data
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Rent Rates"),
  
  # Sidebar with a slider input
  sidebarLayout(
    sidebarPanel(
      #Select Input for cereal data to be plotted
      sliderInput("slider1", label = h3("year of data"), min = a[1], 
                  max = a[length(a)], value = 1)
      #sliderInput("slider1", label = h3("By year from 1989 - 2016"), min = a[1], 
      #   max = a[length(a)], value = 1989)
      #  selectInput("data", "Select Data",
      # choices = c('Zillow Housing Prices', 'Poverty Estimates')
    ),
    
    mainPanel(
      plotOutput("valuePlot")
      
    )
  )
)
)