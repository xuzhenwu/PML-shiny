library(sp)
library(raster)
library(rgeos)
library(spatstat)
library(rgdal)     
library(maptools)
library(sf)

dir <- "C:/Users/Administrator/source/repos/xuzhenwu/PML-shiny/sf/river"

fns <- dir(dir, 
           "shp",
           full.names = TRUE)

shp_lst <- lapply(fns, read_sf) 
shp_lst <- lapply(shp_lst, st_transform, 4326)

shp1 <- shp_lst[[1]]
shp2 <- shp_lst[[2]]
shp3 <- shp_lst[[3]]
shp4 <- shp_lst[[4]]


#shp1 <- st_drop_geometry(shp1)

world_df = st_drop_geometry(world)



all <- do.call(rbind, shp_lst)

plot(all)