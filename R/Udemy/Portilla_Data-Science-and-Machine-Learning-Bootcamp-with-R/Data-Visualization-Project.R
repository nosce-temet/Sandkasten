library(ggplot2)
library(data.table)

df <- fread(
  file = 'C:/tmp/Economist_Assignment_Data.csv'
)

head(df)

pointsToLabel <- c("Russia", "Venezuela", "Iraq", "Myanmar", "Sudan",
                   "Afghanistan", "Congo", "Greece", "Argentina", "Brazil",
                   "India", "Italy", "China", "South Africa", "Spane",
                   "Botswana", "Cape Verde", "Bhutan", "Rwanda", "France",
                   "United States", "Germany", "Britain", "Barbados", "Norway", "Japan",
                   "New Zealand", "Singapore")

pl <- ggplot(df, aes(x = CPI, y = HDI)) +
  geom_point(
    aes(color = Region),
    shape = 1,
    size = 4
  ) +
  geom_smooth(
    aes(group = 1),
    method = 'lm',
    formula = y ~ log(x),
    se = FALSE,
    color = 'red'
  ) +
  geom_text(
    aes(label = Country), 
    color = "gray20", 
    data = subset(df, Country %in% pointsToLabel),
    check_overlap = TRUE
  ) +
  theme_bw() +
  scale_x_continuous(
    name = 'Corruption Perceptions Index, 2011 (10=least corrupt)',
    limits = c(1,10),
    breaks = 1:10
  ) +
  scale_y_continuous(
    name = 'Human Development Index, 2011 (1=Best)',
    limits = c(.2,1),
    breaks = 1:5*2/10
  ) +
  ggtitle(
    label = 'Corruption and Human development'
  )

library(plotly)

ggplotly(pl)
