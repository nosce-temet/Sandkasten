library(dplyr)

batting <- read.csv("C:/tmp/Batting.csv")

head(batting)

str(batting)

head(batting$AB)

head(batting$X2B)

batting <- batting %>%
  mutate(
    BA = H / ifelse(AB == 0, 1, AB),
    X1B = H - X2B - X3B - HR,
    OBP = (H + BB + HBP) / ifelse(AB + BB + HBP + SF == 0, 1, AB + BB + HBP + SF),
    SLG = (X1B + 2*X2B + 3*X3B + 4*HR) / ifelse(AB == 0, 1, AB)
  )

tail(batting)
str(batting)


sal <- read.csv("C:/tmp/Salaries.csv")

head(sal)


combo <- batting %>%
  inner_join(sal, by = c("playerID", "yearID"))

summary(merged)

lost_players <- combo %>%
  filter(
    playerID %in% c('giambja01', 'damonjo01', 'saenzol01'),
    yearID == 2001
  ) %>%
  select(playerID,H,X2B,X3B,HR,OBP,SLG,BA,AB)

combo_2001 <- combo %>%
  filter(
    !playerID %in% c('giambja01', 'damonjo01', 'saenzol01'),
    yearID == 2001,
    salary < 15000000
  )
