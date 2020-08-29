# setings
command <- c("cdo gridboxmean,150,150")


infl <- "F:/pml_data/"
outfl <- "F:/pml_data/sample/"
win_to_linux <- c("F:", "/mnt/f")


# scripts
inlist <- dir(infl, "*.nc$", full.names = TRUE)
if(dir.exists(outfl) != TRUE)
  dir.create(outfl)

commands <- NULL
for(i in seq_along(command)){
  
  outlist <- gsub("10mx10m", "1500mx1500m", inlist)
  outlist <- gsub(infl, outfl, outlist)
  
  
  outlist <- paste(command[i], 
                   " ",
                   inlist,
                   " ",
                   outlist,
                   "&&",
                   sep = ""
  )
  
  outlist <- gsub(win_to_linux[1], win_to_linux[2], outlist)
  
  if(i == 0)
    commands <- outlist
  else 
    commands <- c(commands, outlist)
  
}

commands <- as.matrix(commands, ncol = 1)

# then copy the scripts to execute in linux 
write.table(commands,
            file = paste(outfl, "aggregate.sh", sep = ""),
            col.names = FALSE,
            row.names = FALSE,
            quote = FALSE
)