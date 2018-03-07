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
library("stringr")

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


correl <- read.csv("CorrelationSig.csv")

newnewpov <- read.csv("PovDataNew.csv", header = F)
colnames(newnewpov) <- as.character(newnewpov[1,])
newnewpov <- newnewpov[-1,]
colnames(newnewpov)[1] <- "Name"

# Define server logic for choosing value to plot
shinyServer(function(input, output) {
  output$povertyPlot <- renderPlot({ 
    mapThisPov <- filter(mapThisPov, Year == input$slider2)
    ggplot(mapThisPov, aes(long, lat)) + geom_polygon(aes(group = group, fill = as.numeric(Estimate)*10)) + coord_fixed(1.3) + labs(title = paste("Poverty level by state in", input$slider2))
    ggplot(mapThisPov, aes(long, lat)) + geom_polygon(aes(group = group, fill = as.numeric(Estimate))) + coord_fixed(1.3) + labs(title = paste("Poverty level by state in", input$slider2)) + guides(fill=guide_legend("Poverty Rates (%)"))
  })
  
  output$rentPlot <- renderPlot({ 
    ggplot(mapThis, aes(long, lat)) + geom_polygon(aes(group = group, fill = mapThis[cycle[[input$slider1]]])) + coord_fixed(1.3) + labs(title = paste("Rent level by state", cycle[[input$slider1]])) + guides(fill=guide_legend("Average Rents ($)"))
  })

  output$dataTable <- renderTable({
    if (input$selectData == "Poverty Estimates") {
      dataset <- newnewpov
    } else if (input$selectData == "Correlation Dataset") {
      dataset <- correl
      dataset <- select(dataset, -X)
    } else {
      dataset <- rent[,2:90]
      dataset <- select(dataset, -SizeRank)
    }
    return (dataset)
  }, bordered = TRUE, hover = TRUE, striped = TRUE)
  
  output$text <- renderText({
    if (input$selectData == "Correlation Dataset") {
      x <- "According to our data, rent rates and poverty levels tend to correlate inversely for each state. This means that where rent rates are higher, poverty rates tend to be lower. Perhaps this is because where there is less poverty more people are able to afford more costly rent, therefore landlords would charge higher rates.

                      We have found that this correlation between Zillow rent rates and poverty levels is statistically significant for the following states:
                      Arizona, California, Florida, Georgia, Hawaii, Idaho, Indiana, Iowa, Kentucky, Maine, Michigan, Mississippi, Montana, Nevada, New Hampshire, North Carolina, Ohio    , Oklahoma, Oregon, Pennsylvania, South Carolina, Tennessee, Texas, Utah, Washington, Wisconsin, and Wyoming.
                      
                      This is based off a significance level of .005."
      return (x)
  
    }
  })
  
})

