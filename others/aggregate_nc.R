aggregate_nc <- function(i, infns){
  
  t  <- system.time({
    
    library(raster)
    library(ncdf4)
    library(stringr)
    
    fn <- infns[i]
    
    new_resolution <- 1500
    origin_resolution <- 10
    fact <- new_resolution / origin_resolution
    
    r <- brick(fn, readunlim = TRUE)
    r <- readAll(r)
    rout <- aggregate(r, fact, fun = mean)
    
    ofn <- gsub(origin_resolution, new_resolution, fn)
    
    writeRaster(rout, ofn, "CDF")
    
    nc2 <- nc_open(ofn, write = TRUE)
    
    var_name <- basename(ofn) %>% str_sub(1, str_locate(., "_")[1] - 1)
    
    nc2 <- ncvar_rename(nc2, "variable", var_name)
    
    nc_close(nc2)
  })
  
  print(t)
  
}

library(parallel)
infns <- dir("F:/pml_data/",
             "10m", 
             full.names =  TRUE)

# 1 original: 10 sec
# parallel: 16 sec
# total costs almost 40 mins
ncores <- detectCores(logical=F) # physical cores
ncores <- 2
cl <- makeCluster(ncores)
t  <- system.time({
  clusterApply(cl, seq_along(infns), infns, fun = aggregate_nc)
})
stopCluster(cl)
print(t)








