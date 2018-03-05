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
setwd("~/Desktop/info_final/byState")
rent <- fread('State_Zri_MultiFamilyResidenceRental.csv', stringsAsFactors = F)

usa <- map_data('usa')

# map 50
data("fifty_states") # this line is optional due to lazy data loading

states <- data.frame(state.abb, state.name)
colnames(states) <- c('abb', 'RegionName')
byState <- select(rent, colnames(rent)[c(2,4:length(colnames(rent)))])
new <- left_join(byState, states)
new <- new[!duplicated(new$abb)]
new$RegionName <- tolower(new$RegionName)

data('fifty_states')
colnames(fifty_states) <- c("long",  "lat"   ,"order" ,"hole",  "piece", "RegionName",    "group")
mapThis <- left_join(fifty_states, new, by = 'RegionName')

cycle <- colnames(mapThis)[8:94]
cycle$ind <- seq(1:length(cycle))
colors <- mapThis[8:94]
#prep map
data('fifty_states')
colnames(fifty_states) <- c("long",  "lat"   ,"order" ,"hole",  "piece", "RegionName",    "group")
mapThis <- left_join(fifty_states, new, by = 'RegionName')
#a <- as.numeric(mapThis['Year'][1:nrow(mapThis['Year']),])
#a <- unique(a)
source('rentCostByState.R', local = T)
# Define server logic for choosing value to plot
shinyServer(function(input, output) {
  output$valuePlot <- renderPlot({ 
    #mapThis <- filter(mapThis, Year == a[input$slider1])
    ggplot(mapThis, aes(long, lat)) + geom_polygon(aes(group = group, fill = mapThis[cycle[[input$slider1]]])) + coord_fixed(1.3) + ggtitle('Zillow Rent Prices per state per year')
    
    
  })
})
