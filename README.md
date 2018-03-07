# info201_finalproject_wi18

## TEAM BOUNDLESSS

### Project Description

For our final project, we will be working data from **The United States Census Bureau API** and the **Zillow Research** website. Our goal is to map levels poverty rates in the United States and rental rates in the United States at the state level and see if there is a correlation between those two observations. We think that there may be a correlation of there being higher poverty rates as rental rates increase in the United States due to people not being able to afford the housing. Our target audience is anyone trying to gain insight into 3 things: 1) poverty rates in the United Sates at the state level, 2) rental rates in the United States at state level, 3) those curious to see how the two variables correlate with one another. Our audience would be looking to compare this data between states and across years. Three specific questions that our project will answer are 1) Which states have the highest and lowest relative poverty rates in the United States? 2) Which states have the highest and lowest relative property rates in the United States? and 3) Is there a correlation between these two observations?

### Technical Description 

The format we will be delivering in will be a series of pages compiled through a shiny application. We will be reading in our data using static CSV files to read in our **Zillow Research** data along with using an API to get the data from **The United States Census Bureau API**. We will need to reformat certain information so that we can generate orrelation. In order to map relative values across state levels we will need to use the mapproj, ggplot2,fiftystater,and data.table libraries. Along with that we will need to use the dplyr library for data wrangling to access the level of observations we need. It will be interesting to use some statistical analysis to determine the correlation between poverty and rental rates in the United States. Removing lurking variables will be nearly impossible. This however is not our purpose as were are merely looking for correlation between two pre-established indexes. Visualizations for correlations will be difficult since there are two independent variables, multiple years, and many states.

### Links to Datasets

-[Zillow Research](https://www.zillow.com/research/data/)

-[The United States Census Bureau API](https://www.census.gov/data/developers/data-sets/Poverty-Statistics.html)