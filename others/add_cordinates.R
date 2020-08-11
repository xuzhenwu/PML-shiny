library(ncdf4)

dir <- "F:/pml_data/"
fn_proto <- "F:/pml_dataset/output_of_PMLV2.0_GLDAS_NOAH_15D_A201301a_BJ_10mx10m.nc"


fl <- dir(dir, "*.nc", full.names = TRUE)

nc_proto <- nc_open(fn_proto, write = T)

nc$dim$lat$vals <- nc_proto$dim$lat$vals
nc$dim$lon <- nc_proto$dim$lon


for(i in seq_along(fl)){
  fn <- fl[i]
  nc <- nc_open(fn, write = T)
  
  nc$dim$lat <- nc_proto$dim$lat
  nc$dim$lon <- nc_proto$dim$lon
  nc$var[[1]]$dim$lat <- nc_proto$dim$lat
  nc$var[[1]]$dim$lon <- nc_proto$dim$lon
  nc_sync(nc)
  nc_close(nc)
}
nc_close(nc_proto)

ncvar_def("")