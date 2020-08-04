library(gapminder)
library(ggplot2)

plottrend <- function(){
  
  # start of TrendPlot
  annual_aggregate <- read.csv("data/annual_aggregate.csv")
  pdf <- melt(annual_aggregate, id.vars = "Year")
  lm1 <- lm(ET ~ Year, annual_aggregate)
  lm2 <- lm(GPP ~ Year, annual_aggregate)
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