library(tidyverse)
library(leaflet)
library("plyr")

households <- read.csv('data/data_syntheticPopulation_householdBeats.csv.gz', stringsAsFactors = F)

summary(households$hhSize)
hhSize_3rd <- summary(households$hhSize)[[5]]

households_b1 <- households %>% filter(beatId == 'allBeats_WGS84.1' | 
                                       beatId == 'allBeats_WGS84.2')
households_b1$lon <- as.numeric(households_b1$lon)

landfills <- read.csv('data/disposalFacilities.csv')
landfills <- plyr::rename(landfills, c("Waste.Entering.Disposal.Facilities" = "Landfill"))

pal <- colorNumeric(palette = "YlGn", domain = c(1:max(households_b1$hhSize)))

m <- leaflet() %>% 
  addProviderTiles(provider = 'Esri.WorldImagery', group='Satellite') %>%  
  addProviderTiles(provider = 'OpenStreetMap.BlackAndWhite', group='Plain') %>%  
  addCircleMarkers(data=landfills, 
                   label=~Landfill, 
                   col='red', 
                   radius=2, 
                   opacity=1,
                   group = 'Landfills') %>%
  addCircleMarkers(data=households_b1, 
                   label=~as.factor(hhSize), 
                   col=~pal(hhSize), 
                   radius=0.8, 
                   opacity=1,
                   #stroke=F,
                   group = 'Households') %>%
  addLegend(pal = pal,
            values=c(1:max(households_b1$hhSize)),
            opacity = 0.75,
            title = "Household size",
            position = "topright") %>%
  addLayersControl(baseGroups = c("Satellite", "Plain"), 
                   overlayGroups = c("Landfills", "Households"))

m  # Print the map

