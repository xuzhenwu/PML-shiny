

plotmap <- function(dir,
                    varname,
                    resolution){
  
  palette <- c("Spectral", "YlGn")
  
  if(varname == "ET")
    pals <- palette[1]
  if(varname == "GPP")
    pals <- palette[2]
     
  pals <- brewer.pal(9, pals)
  
  fn <- paste(dir, varname, ".tif", sep = "")
  r <- raster(fn)
  
  aggregate_inx <- ceiling(as.numeric(resolution) / 10)
  r <- aggregate(r, fact = aggregate_inx, fun = mean)
  
  pal <- colorNumeric(pals, values(r),
                      na.color = "transparent")
  
  p <- leaflet() %>% addTiles() %>%
    addRasterImage(r, colors = pal, opacity = 0.8) %>%
    addLegend(pal = pal, values = values(r),
              title = "Value")
  return(p)
}