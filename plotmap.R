library(raster)
library(leaflet)
library(RColorBrewer)
library(reshape2)
library(plotly)

plotmap <- function(varname){
  
  palette <- c("Spectral", "YlGn")
  
  if(varname == "ET")
    pals <- palette[1]
  if(varname == "GPP")
    pals <- palette[2]
     
  pals <- brewer.pal(9, pals)
  
  fn <- paste("data/", varname, ".tif", sep = "")
  r <- raster(fn)
  
  pal <- colorNumeric(pals, values(r),
                      na.color = "transparent")
  
  p <- leaflet() %>% addTiles() %>%
    addRasterImage(r, colors = pal, opacity = 0.8) %>%
    addLegend(pal = pal, values = values(r),
              title = "Value")
  return(p)
}