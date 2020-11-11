table <- fread("project/site/site.csv")  
pdf <- fread("project/site/extract.csv")
pdf$date <- as_date(pdf$date)
pdf <- pdf[, year := year(date)]

pdf <- pdf%>%group_by(name, variable, year)%>%
  summarise(name = name[1],
            variable = variable[1],
            year = year[1],
            value = mean(value))


# ggplot
p <- ggplot(data = pdf,
            aes(year, value, color = name))+
  geom_point(size = 1.2, alpha = 0.8)+
  geom_smooth(method = "lm",
              se = FALSE
  )+
  labs(x = "年份", y = "变量值")+
  #scale_x_continuous(breaks = 2013:2020)+
  scale_color_manual(values = rev(brewer.pal(length(levels(factor(pdf$name))), "Set1")),
                     name = NULL)+
  facet_wrap(.~variable, ncol = 1, scales = "free_y")+
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    #legend.background = element_rect(fill = "white", size = 4, colour = "white"),
    legend.justification = c(0, 1),
    #legend.position = c(0, 1),
    axis.ticks = element_line(colour = "grey70", size = 0.2),
    panel.grid.major = element_line(colour = "grey70", size = 0.2),
    panel.grid.minor = element_blank()
  )
print(p)
