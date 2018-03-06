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

# Don't delete this
source("load-viz-one.R")

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
print(mapThisPov)
a <- as.numeric(mapThisPov['Year'][1:nrow(mapThisPov['Year']),])
a <- unique(a)

# Define server logic for choosing value to plot
shinyServer(function(input, output) {
  output$povertyPlot <- renderPlot({ 
    mapThisPov <- filter(mapThisPov, Year == input$slider2)
    ggplot(mapThisPov, aes(long, lat)) + geom_polygon(aes(group = group, fill = as.numeric(Estimate)*10)) + coord_fixed(1.3) + ggtitle('Poverty Levels by state per year')
    
    
  })
  
  output$rentPlot <- renderPlot({ 
    #mapThis <- filter(mapThis, Year == a[input$slider1])
    ggplot(mapThis, aes(long, lat)) + geom_polygon(aes(group = group, fill = mapThis[cycle[[input$slider1]]])) + coord_fixed(1.3) + ggtitle('Zillow Rent Prices per state per year')
    
    
  })
  
})

