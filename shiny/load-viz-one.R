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
library('jsonlite')
#prep data for mapping rent
rent <- fread('State_Zri_MultiFamilyResidenceRental.csv', stringsAsFactors = F)
usa <- map_data('usa')
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
# prep sliderInput for rent
cycle <- colnames(mapThis)[8:94]
ind <- seq(1:87)
cycle <- data.frame(ind, cycle)
colors <- mapThis[8:94]

