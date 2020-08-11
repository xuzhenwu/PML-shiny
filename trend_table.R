trend_table <- function(dir){
  fn <- paste(dir, "trend_info.csv", sep = "")
  trendinfo <- read.csv(fn)
  names(trendinfo)[1:4] <- c("变量", "多年平均值", "逐年趋势值", "p值")
  trendinfo
}