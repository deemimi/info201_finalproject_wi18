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
# Define UI for application that draws map for various data
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Rent Rates"),
  
  # Sidebar with a slider input
  sidebarLayout(
    sidebarPanel(
      #Select Input for cereal data to be plotted
      sliderInput("slider1", label = h3("By month from 2010 - 2018"), min = 1, 
                  max = length(cycle)-1, value = 20)
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