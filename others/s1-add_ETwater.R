library(parallel)

# setting
fl_path <- "F:/dataset_pml/"
ncores <- 6
fl <- list.files(fl_path, "*.nc", full.names = TRUE)

# function
add_ETwater <- function(i, fl){
  
  library(ncdf4)
  fn <- fl[i]
  ncf <- nc_open(fn, write = TRUE)
  ncvar_put(nc = ncf,
            varid = "ET",
            ncvar_get(nc = ncf, varid = "ET") +
              ncvar_get(nc = ncf, varid = "ET_water")
  )
  nc_close(ncf)
}

# parallel computing
cl <- makeCluster(ncores)
system.time({
  parLapply(cl, seq_along(fl), add_ETwater, fl)
})
stopCluster(cl)