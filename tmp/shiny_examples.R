dir <- "c:/Users/Administrator/source/repos/xuzhenwu/shiny-examples/"
i <- 9

#for(i in 1:100){
  if(i < 10){
    i <- paste0('00', i)
  }else{
    if(i < 100)
      i <- paste0('0', i)
  }
  
  fl <- dir(dir, as.character(i), full.names = TRUE)
  
  runApp(fl)
  
  Sys.sleep(20)
  
#} 