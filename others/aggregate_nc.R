aggregate_nc <- function(i, infns, fun = mean){
  
  t  <- system.time({
    
    library(raster)
    library(ncdf4)
    library(stringr)
    
    fn <- infns[i]
    
    new_resolution <- 1000
    origin_resolution <- 10
    fact <- new_resolution / origin_resolution
    
    # get inf in nc1
    nc1 <- nc_open(fn)
    
    if(nc1$var[[1]]$ndims > 2){
      r <- brick(fn, readunlim = TRUE)
      r <- readAll(r)
    }else{
      r <- raster(fn)
    }
    rout <- aggregate(r, fact, fun = fun)
    
    ofn <- gsub(origin_resolution, new_resolution, fn)
    
    writeRaster(rout, ofn, "CDF", 
                overwrite = TRUE,
                varname = nc1$var[[1]]$name, 
                longname = nc1$var[[1]]$longname)
    
    
    nc2 <- nc_open(ofn, write = TRUE)
    
    # var_name <- basename(ofn) %>% str_sub(1, str_locate(., "_")[1] - 1)
    # 
    # nc2 <- ncvar_rename(nc2, "variable", var_name)
    nc_close(nc1)
    nc_close(nc2)
    
  })
  print(infns[i])
  print(t)
  
}

library(parallel)
infns <- dir("F:/pml_data/",
             "10m", 
             full.names =  TRUE)

# lapply(43:length(infns), aggregate_nc, infns)
# 
# 
# 
# 
# # 1 original: 10 sec
# # parallel: 16 sec
# # total costs almost 40 mins
# ncores <- detectCores(logical=F) # physical cores
# ncores <- 2
# cl <- makeCluster(ncores)
# t  <- system.time({
#   clusterApply(cl, seq_along(infns), infns, fun = aggregate_nc)
# })
# stopCluster(cl)
# print(t)








# for land cover 
infns <- dir("F:/pml_data/",
             "landcover", 
             full.names =  TRUE)
lapply(1:length(infns), aggregate_nc, infns, max)