
extract_poin_info <- function(){
  
  
  
  
  
}


nc_path <- "F:/dataset_pml/2013/output_of_PMLV2.0_GLDAS_NOAH_15D_A201301a_BJ_10mx10m.nc"
r <- raster(nc_path, varname = "ET")
r <- aggregate(r, fact = 15, fun = mean)


palette <- c("Spectral", "YlGn")
pals <- palette[1]
pals <- brewer.pal(9, pals)
pal <- colorNumeric(pals, values(r),
                    na.color = "transparent")





p <- st_point(c(lon, lat))%>%
  st_sfc(crs = 4326)
p1 <- p%>% 
  st_sfc(crs = 4326)%>%
  st_transform(crs = 2436) %>% 
  st_transform(crs = 4326)


ofn<- gsub(".nc", ".csv", basename(nc_path)) %>% paste0("LAI_", .)

#nc <- nc_open(nc_path)

d  <- exact_extract(raster(nc_path, varname = "ET"), 
                    c(lat, lon))

colnames(d) %<>% gsub("^mean.X", "", .)
out <- cbind(I = 1:nrow(st_point), basin = basins$name, d)
fwrite(out, outfile)

print(t)





# Buffer circles by 100m
dat_circles <- st_buffer(dat_sf, dist = 100)

# Intersect the circles with the polygons
ticino_int_circles <- st_intersection(dat_ticino_sf, dat_circles)