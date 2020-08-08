library(parallel)

# setting
fl_path <- "F:/dataset_pml/"
ncores <- 6
fl <- list.files(fl_path, "*.nc", full.names = TRUE)
vars <- c("ET", "GPP", "LAI", "VPD", "Es", "Ei", "Eca", "landcover")
resolution <- 300 #m
i <- 1


library(raster)
library(tidyverse)
fn <- fl[i]
original_resolution <- 10
aggregate_inx <- resolution / original_resolution
for(j in seq_along(vars)){
  
  raster_var <- raster(fn, varname = vars[j]) 
  raster_var <- aggregate(raster_var, fact = aggregate_inx, fun = mean)
  if(j == 1)
    raster_all <- raster_var
  else 
    raster_all <- stack(raster_all, raster_var)
}
ofn <- gsub("*.nc", 
            paste("_", resolution, "m.nc", sep = ""),
            fn)
writeRaster(raster_all, filename = ofn, varname = "variable", format="CDF", overwrite = TRUE) 
setZ(raster_all, vars)
writeRaster(raster_all, filename = ofn, datatype='INT2S', force_v4=TRUE, compression=7,overwrite = TRUE) 

library(ncdf4)
fl <- list.files(fl_path, "*300m.nc", full.names = TRUE)
nc <- nc_open(fl[1], write = TRUE)
zvals <- vars
ncvar_put(nc, 'var', zvals)

nc_close(nc)


ncb = brick(fn)
zvals = ncvar_get(nc, 'Time')








# function
education_aggregate <- function(i, fl, resolution, vars){
  
  library(raster)
  library(tidyverse)
  fn <- fl[i]
  original_resolution <- 10
  aggregate_inx <- resolution / original_resolution
  for(j in seq_along(vars)){
    raster_var <- raster(fn, varname = vars[j]) %>%
      aggregate(fact = aggregate_inx, fun = mean)
    if(j == 1)
      raster_all <- raster_var
    else 
      raster_all <- stack(raster_all, raster_var)
  }
  ofn <- gsub("*.nc", 
              paste("_", resolution, "m.nc", sep = ""),
              fn)
  writeRaster(raster_all, filename = ofn, bylayer = TRUE, format="CDF", overwrite = TRUE) 
  
}

education_aggregate(1, fl, resolution, vars)


# parallel computing
# cl <- makeCluster(ncores)
# system.time({
#   parLapply(cl, 1:1, education_aggregate, fl, resolution, vars)
#   #parLapply(cl, seq_along(fl), education_aggregate, fl, resolution, vars)
# })
# stopCluster(cl)

library(ncdf4)
fl <- list.files(fl_path, "*300m.nc", full.names = TRUE)
ncf <- nc_open(fl[1])
nc_close(ncf)


fl <- list.files(fl_path, "*10m.nc", full.names = TRUE)
ncf1 <- nc_open(fl[1])

