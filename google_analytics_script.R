install.packages("RGoogleAnalytics")
install.packages("tidyverse")

library(RGoogleAnalytics)
library(tidyverse)

# Create token
token <- Auth(client.id = "<ga:client.id>",
              client.secret = "<ga:client.secret>")

# Save the token object for future sessions
save(token,file="./token_file")

# In future sessions it can be loaded by running load("./token_file")
ValidateToken(token)

# Create two queries with list of parameters
query1 <- Init(start.date = "2021-01-01",
                   end.date = "2021-12-25",
                   dimensions = "ga:month",
                   metrics = "ga:sessions,ga:pageviews,ga:users,ga:newUsers,ga:avgSessionDuration,ga:sessionDuration",
                   max.results = 10000,
                   sort = "-ga:month",
                   table.id = "ga:<table.id>")

query2 <- Init(start.date = "2021-01-01",
                   end.date = "2021-12-25",
                   dimensions = "ga:month",
                   metrics = "ga:pageviewsPerSession,ga:timeOnPage,ga:avgTimeOnPage,ga:sessionsPerUser",
                   max.results = 10000,
                   sort = "-ga:month",
                   table.id = "ga:<table.id>")


# Create the Query Builder object so that the query parameters are validated
ga.query1 <- QueryBuilder(query1)
ga.query2 <- QueryBuilder(query2)

# Extract the data and store it in a data frame
df1 <- GetReportData(ga.query1, token)
df2 <- GetReportData(ga.query2, token)

# Merge and filter data
df<- cbind(df1,df2)
df[,8] <- NULL
filtered <- df%>%filter(sessions != 0 & pageviews != 0 & users != 0 & newUsers != 0)
filtered$month <- as.Date(paste(filtered$month,"-01-2021",sep=""),"%m-%d-%y")

# Total pageviews
sum(filtered$pageviews)
# Total users
sum(filtered$users)
# Average session duration
seconds <- round(mean(filtered$avgSessionDuration)%%60)
time <- mean(filtered$avgSessionDuration)-mean(filtered$avgSessionDuration)%%60
minutes <- time/60
paste(minutes,"minutes and",seconds,"seconds.",sep=" ")

# Plot page views over time
ggplot(filtered, aes(x = month, y=pageviews)) +
  geom_line(size=.75,color="#a40000") + 
  labs(x = "Month",y="Pageviews",title="Page views over time in 2021") + 
  scale_y_continuous(limits = c(0,600), breaks=seq(0,600,100)) + 
  scale_x_date(labels = date_format("%b"), date_minor_breaks = "month",date_breaks = "1 month") +
  geom_point(size=2,color="#a40000") +
  theme(
    axis.line.x = element_line(colour = "grey50"),
    axis.line.y = element_line(colour = "grey50"),
  ) +
  theme_light()

# Plot sessions over time
ggplot(filtered, aes(x = month, y=sessions)) +
  geom_line(size=.75,color="#a40000") + 
  labs(x = "Month",y="Sessions",title="Sessions over time in 2021") + 
  scale_y_continuous(limits = c(0,140), breaks=seq(0,140,20)) + 
  scale_x_date(labels = date_format("%b"), date_minor_breaks = "month",date_breaks = "1 month") +
  geom_point(size=2,color="#a40000") +
  theme(
    axis.line.x = element_line(colour = "grey50"),
    axis.line.y = element_line(colour = "grey50"),
  ) +
  theme_light()