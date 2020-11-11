pdf <- fread("extract.csv")

pdf$date <- as_date(pdf$date)

for(i in seq_along(vars_trend)){
  if(i == 1)
    units_trend <- dt_varunit[variables == vars_trend[i],]$units[1]
  else
    units_trend <- c(units_trend, dt_varunit[variables == vars_trend[i],]$units[1])
}
str_labels <- paste0(vars_trend, "(", units_trend, ")")
pdf$variable <- factor(pdf$variable, labels = str_labels)
pdf$variable[1:4]



p <- ggplot(data = pdf,
            aes(date, value, color = name))+
  geom_point(size = 1.2, alpha = 0.8)+
  # geom_smooth(method = "lm",
  #             se = FALSE
  # )+
  labs(x = "日期", y = "变量值")+
  scale_x_continuous(breaks = as_date(paste0(2013:2020, "-01-01"))
  )+
  scale_color_manual(values = rev(brewer.pal(length(levels(factor(pdf$name))), "Set1")),
                     name = NULL)+
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    #legend.background = element_rect(fill = "white", size = 4, colour = "white"),
    legend.justification = c(0, 1),
    legend.position = c(0, 1),
    axis.ticks = element_line(colour = "grey70", size = 0.2),
    panel.grid.major = element_line(colour = "grey70", size = 0.2),
    panel.grid.minor = element_blank()
  )+
  facet_grid(. ~ variable,  scales = "free_y", labeller = label_parsed)

p


p <- ggplotly(p)%>%
  layout(
    legend = list(orientation = "h",
                  x = 0,
                  y = 1),
    height = 1000
  )

p

p <- ggplot(data = pdf,
            aes(date, value, color = name))+
  geom_point(size = 1.2, alpha = 0.8)+
  # geom_smooth(method = "lm",
  #             se = FALSE
  # )+
  labs(x = "日期", y = "变量值")+
  scale_x_continuous(breaks = as_date(paste0(2013:2020, "-01-01"))
  )+
  scale_color_manual(values = rev(brewer.pal(length(levels(factor(pdf$name))), "Set1")),
                     name = NULL)+
  facet_wrap(.~variable, ncol = 1, scales = "free_y", labeller = labeller(str_labels))+
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    #legend.background = element_rect(fill = "white", size = 4, colour = "white"),
    legend.justification = c(0, 1),
    legend.position = c(0, 1),
    axis.ticks = element_line(colour = "grey70", size = 0.2),
    panel.grid.major = element_line(colour = "grey70", size = 0.2),
    panel.grid.minor = element_blank()
  )

p

