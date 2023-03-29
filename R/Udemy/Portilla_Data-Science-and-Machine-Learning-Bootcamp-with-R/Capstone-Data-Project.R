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

summary(combo)

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
  ) %>%
  select(
    playerID, salary, AB, OBP
  )

cross1 <- cross_join(combo_2001, combo_2001) %>%
  filter(
    playerID.x < playerID.y,
    salary.x + salary.y < 15000000
  )

cross2 <- cross_join(cross1, combo_2001) %>%
  rename(
    playerID.z = playerID,
    salary.z = salary,
    AB.z = AB,
    OBP.z = OBP
  ) 

filteredCross <- cross2 %>%
  filter(
    playerID.y < playerID.z
  )

filteredCross2 <- filteredCross %>%
  filter(
    salary.x + salary.y + salary.z < 15000000
  )

combAB <- sum(lost_players$AB)
meanOBP <- mean(lost_players$OBP)
rm(lost_players)
rm(filteredCross)

filteredCross3 <- filteredCross2 %>%
  filter(
    AB.x + AB.y + AB.z >= combAB
  )
rm(combAB)
rm(filteredCross2)

filteredCross4 <- filteredCross3 %>%
  filter(
    (OBP.x + OBP.y + OBP.z) / 3 >= meanOBP
  )
rm(meanOBP)
rm(filteredCross3)

filteredCross4 <- filteredCross4 %>%
  mutate(
    sumAB = AB.x + AB.y + AB.z,
    meanOBP = (OBP.x + OBP.y + OBP.z) / 3,
    sumSalary = salary.x + salary.y + salary.z
  )

head(filteredCross4 %>% arrange(desc(meanOBP)))


















