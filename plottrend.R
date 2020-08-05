

plottrend <- function(dir,
                      lon,
                      lat){
  
  
  # start of TrendPlot
  annual_aggregate <- read.csv(paste(dir, "annual_aggregate.csv", sep = ""))
  pdf <- melt(annual_aggregate, id.vars = "Year")
  lm1 <- lm(ET ~ Year, annual_aggregate)
  lm2 <- lm(GPP ~ Year, annual_aggregate)
  
  # extract(x, y, fun=NULL, na.rm=FALSE, cellnumbers=FALSE, df=FALSE, layer,
  #         nl, factors=FALSE, along=FALSE, sp=FALSE, ...)
  
  p <- ggplot(data = pdf,
              aes(Year, value))+
    geom_point(color = "blue")+
    geom_smooth(method = "lm",
                color = "red",
                se = FALSE
    )+
    labs(x = "Year", y = "Value")+
    scale_color_brewer(palette='Set1',
                       name = "Variables")+
    facet_wrap(.~variable, scales = "free_y")
  
  ggplotly(p)
  
  #end of trendplot
}