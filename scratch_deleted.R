# quad plot - didn't like output
#Calculate x and y midpoints

x_mid <- mean(c(max(counties_fire_sf_simplified$RISK_NATIONAL_RANK, na.rm = TRUE), 
                min(counties_fire_sf_simplified$RISK_NATIONAL_RANK, na.rm = TRUE) ))
y_mid <- mean(c(max(counties_fire_sf_simplified$sf_count, na.rm = TRUE), 
                (min(counties_fire_sf_simplified$sf_count, na.rm = TRUE))))

x_mid_1 <- mean(counties_fire_sf_simplified$RISK_NATIONAL_RANK, na.rm = TRUE) 
y_mid_1 <- mean(counties_fire_sf_simplified$sf_count, na.rm = TRUE)


x_mid_2 <- median(counties_fire_sf_simplified$RISK_NATIONAL_RANK, na.rm = TRUE)
y_mid_2 <- median(counties_fire_sf_simplified$sf_count, na.rm = TRUE)

print(x_mid)
print(y_mid)
print(x_mid_1)
print(y_mid_1)
print(x_mid_2)
print(y_mid_2)

#Creating quadrant columns
counties_fire_sf_simplified_quad <- counties_fire_sf_simplified %>%
  mutate(quadrant = case_when(RISK_NATIONAL_RANK > x_mid_1 & sf_count > y_mid_1 ~"Q1",
                              RISK_NATIONAL_RANK <= x_mid_1 & sf_count > y_mid_1 ~"Q1",
                              RISK_NATIONAL_RANK <= x_mid_1 & sf_count <= y_mid_1 ~"Q1",
                              TRUE ~ "Q4" ))

view(counties_fire_sf_simplified_quad)

#Checking quad counts
counties_fire_sf_simplified_quad_sum <-counties_fire_sf_simplified_quad %>%
  group_by(Region, quadrant) %>%
  summarise(County = n()) %>%
  ungroup()


counties_fire_sf_simplified_quad_sum2 <-counties_fire_sf_simplified_quad %>%
  group_by(Region, quadrant) %>%
  summarise(sf_count = n()) %>%
  ungroup()

view(counties_fire_sf_simplified_quad_sum)
view(counties_fire_sf_simplified_quad_sum2)


#Plotting quad
counties_quad <-counties_fire_sf_simplified_quad %>%
  count(quadrant) %>%
  mutate(x = if_else(quadrant %in% c("Q1", "Q4"), Inf, -Inf),
         hjust = if_else(quadrant %in% c("Q1", "Q4"), 1, 0),
         y = if_else(quadrant %in% c("Q1", "Q2"), Inf, -Inf),
         vjust = if_else(quadrant %in% c("Q1", "Q2"), 1, 0))
head(counties_quad)

view(counties_fire_sf_simplified_quad)

ggplot(counties_fire_sf_simplified_quad, aes(x = RISK_NATIONAL_RANK, y = sf_count, color = State )) +
  geom_vline(xintercept = x_mid_1) +
  geom_hline(yintercept = y_mid_1) +
  geom_point()

