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
library(rmarkdown)
source("load-viz-one.R")
#load data
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

# Define UI for application that draws map for various data
shinyUI(navbarPage(
  # Application title
  "State Level Rent/Poverty Data Project", 
  #INTRO TO PROJECT SECTION
  tabPanel("Introduction",
           h3('	According to our data, rent rates and poverty levels tend to correlate inversely for each state. This means that where rent rates are higher, poverty rates tend to be lower.  We have found that this correlation between Zillow rent rates and poverty levels is statistically significant for most states. This is based off a significance level of .005. '),
           includeHTML("intro.html")
  ),
  
  #ABOUT US SECTION
  navbarMenu("About us!",
             #each subtab will contain some information and a relevant image about team member
             tabPanel("Mimi Du",
                      h1("I'm Mimi Du", align = "center"),
                      p("I'm a senior at UW studying applied math! Specifically scientific computing & numerical analysis.", align = "center"), 
                      p("I have no idea what I'm going to end up doing after graduation...", align = "center"),
                      p("But aside from doing math all day I love to bake and watch SVU marathons on TV!", align = "center"),
                      HTML('<center><img src="https://upload.wikimedia.org/wikipedia/commons/c/cf/SVUopening.jpg" width="300" height="300" alt="SVU titlecard"</img></center>')),
             tabPanel("Robi Lin",
                      h1("I'm Robi Lin", align = "center"),
                      p("Imma sophomore at UW and I'm studying philosophy, informatics, and economics.", align = "center"), 
                      p("I hope to one day work on systematic issues that cause oppression on living things.", align = "center"),
                      p("I enjoy rock climbing and watching movies and just kicking it real talk boy.", align = "center"),
                      HTML('<center><img src="https://outdoordesignbylucas.files.wordpress.com/2011/01/1-10-11-charcter-rocks.jpg" width="300" height="300" alt="This is a rock"</img></center>')),
             tabPanel("Marc Punio",
                      h1("I'm Marc Punio", align = "center"),
                      p("I'm a sophomore, I’m in informatics thinking about minoring in business.", align = "center"), 
                      p("I love technology and having fun and one day I hope to be able to help the world through technology.", align = "center"),
                      p("Some of my hobbies are playing basketball, hanging out with friends, going to the gym, etc.", align = "center"),
                      HTML('<center><img src="http://blogs.nbc12.com/.a/6a016766efbf6d970b01bb0979375a970d-pi" width="300" height="300" alt="This is a rock"</img></center>')),
             tabPanel("Simon Lau",
                      h1("I'm Simon Lau", align = "center"),
                      p("I'm a junior at UW Seattle.", align = "center"), 
                      p("An intesting fact about me is that I'm a geography major.", align = "center"),
                      p("I am also a self-proclaimed caffeine addict with no real hobbies!", align = "center"),
                      HTML('<center><img src="https://jennyyozimmermann.files.wordpress.com/2014/11/coffee-addict-dude-7-to-wake-up.png" width="300" height="300" alt="This is a rock"</img></center>'))),

  #RENT RATE PER STATE VISUALIZATION SECTION
  tabPanel("Rent Rates",
           
           # Sidebar with a select input for rent
           sidebarLayout(
             sidebarPanel(
               #Select Input for rent data to be plotted
               selectInput("slider1", label = h3("By month from 2010 - 2018"), choices = cycle$cycle)

             ),
             
             mainPanel(
               p("The following visualization displays the median Zillow Rent Index score for each state in the United States."),
               p("The lighter the color, the higher the median rent rate!"),
               p("Select a value on the right to change the year of the data."),
               plotOutput("rentPlot")
               
             )
           )
  ),
  
  #POVERTY RATE BY STATE VISUALIZATION SECTION
  tabPanel("Poverty Rates by Year",
           
           # Sidebar with a select input for poverty
           sidebarLayout(
             sidebarPanel(
               #Select Input for povrty data to be plotted
               selectInput("slider2", label = h3("Year of data"), choices = a)

             ),
             
             mainPanel(
               p("The following visualization displays the poverty level for each state in the United States."),
               p("The lighter the color, the higher the poverty rate!"),
               p("Select a value on the right to change the year of the data."),
               plotOutput("povertyPlot")
             )
           )
  ),
  
  #LOOKING AT THE CORRELATIONS BETWEEN POVERTY AND RENT SECTION
  tabPanel("Findings",
           titlePanel("Correlation Between Poverty and Rent Rates"), 
           sidebarLayout(
             sidebarPanel(
               radioButtons("selectData", "Dataset", list("Poverty Estimates", "Rent Rates", "Correlation Dataset") ),
               includeMarkdown("correlation.md")
             ),
             
             mainPanel(
               textOutput("text"),
               tableOutput("dataTable")
               
             )
           )
           
           
           
           )
  
  )
)

