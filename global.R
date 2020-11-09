# slibrary <- function(fun){
#   fun_name <- as.character(substitute(fun))
#   if(is.element(fun_name, installed.packages()[,1]) == FALSE)
#     install.packages(fun_name)
#   COMMAND <- paste("library(", fun_name, ")", sep = "")
#   eval(parse(text = COMMAND))
# }

# dependences 

library(shiny)
library(raster)
library(rgdal)
library(leaflet)
library(RColorBrewer)
library(reshape2)
library(plotly)
library(gapminder)
library(ggplot2)
library(rsconnect)
library(shinyFiles)
library(shinyWidgets)
library(exactextractr)
library(data.table)
library(sf)
library(ncdf4)
library(stringr)
library(leaflet)
library(DT)
library(lubridate)
library(waiter)
library(shinycssloaders)

# setings
choices_month <- format(seq.Date(from = as.Date("2013-01-01"), by = "month", length.out = 12*7), "%B-%Y")
choices_var <- c("Ec", "Ei", "Es", "ET", 
                 "GPP", "LAI",
                 "LE", "Rainf",
                 "Rn", "SWdown", "Tair", "VPD",
                 "landcover")
file_location <- "data/"
