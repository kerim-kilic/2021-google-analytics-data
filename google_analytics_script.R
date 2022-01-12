##
##  Author:     Kerim Kiliç
##  Created:    January 2022
## 
##
## 

install.packages("RGoogleAnalytics")
install.packages("tidyverse")
install.packages("scales")
install.packages("gridExtra")

library(RGoogleAnalytics)
library(tidyverse)
library(scales)
library(gridExtra)

# Create token
token <- Auth(client.id = "<ga:client.id>",
              client.secret = "<ga:client.secret>")

# Save the token object for future sessions
save(token,file="./token_file")

# In future sessions it can be loaded by running load("./token_file")
ValidateToken(token)

# Function to query data
get_data <- function(start.date,end.date,dimensions,metrics)
{
  query <- Init(start.date = start.date,
                end.date = end.date,
                dimensions = dimensions,
                metrics = metrics,
                max.results = 10000,
                sort = paste("-",dimensions,sep=""),
                table.id = "ga:<table.id>"
  )
  ga.query <- QueryBuilder(query)
  return(GetReportData(ga.query, token))
}

# Geographic data
# Query the countries
df2 <- get_data("2021-01-01",
                "2021-12-25",
                "ga:year,ga:country",
                "ga:sessions,ga:pageviews,ga:users,ga:avgSessionDuration"
                )
df3 <- df2[with(df2,order(-sessions)),]%>%slice(1:5)

#Plot with top 5 countries based on number of sessions
p1 <- ggplot(df3, aes(x = reorder(country, sessions), y=sessions)) + 
  geom_bar(position="dodge",stat="identity", alpha=.9, width=.5,fill="#a40000") +
  scale_y_continuous(limits = c(0,300), breaks=seq(0,300,50)) + 
  labs(x = "Country",y="Sessions", title ="Top 5 countries") + 
  coord_flip() +
  theme(
    axis.line.x = element_line(colour = "grey50"),
    axis.line.y = element_line(colour = "grey50"),
  ) +
  theme_light()

#Query the cities
df5 <- get_data("2021-01-01",
                "2021-12-25",
                "ga:year,ga:city",
                "ga:sessions,ga:pageviews,ga:users,ga:avgSessionDuration"
)
df6 <- df5[with(df5,order(-sessions)),]%>%filter(city != "(not set)")%>%slice(1:5)

# Plot with top 5 cities based on number of sessions
p2 <- ggplot(df6, aes(x = reorder(city, sessions), y=sessions)) + 
  geom_bar(position="dodge",stat="identity", alpha=.9, width=.5,fill="#a40000") +
  scale_y_continuous(limits = c(0,125), breaks=seq(0,125,25)) + 
  labs(x = "City",y="Sessions", title ="Top 5 cities") + 
  coord_flip() +
  theme(
    axis.line.x = element_line(colour = "grey50"),
    axis.line.y = element_line(colour = "grey50"),
  ) +
  theme_light()

# Show plots next to each other
grid.arrange(p1,p2,ncol=2)

# Query the channel data
df4 <- get_data("2021-01-01",
                "2021-12-25",
                "ga:year,ga:channelGrouping",
                "ga:sessions,ga:pageviews,ga:users,ga:avgSessionDuration"
)
# Plot the channels and their respective number of sessions
ggplot(df4, aes(x = reorder(channelGrouping, sessions), y=sessions)) + 
  geom_bar(position="dodge",stat="identity", alpha=.9, width=.5,fill="#a40000") +
  scale_y_continuous(limits = c(0,300), breaks=seq(0,300,50)) + 
  labs(x = "Channel type",y="Sessions", title ="Sessions per channel type") + 
  coord_flip() +
  theme(
    axis.line.x = element_line(colour = "grey50"),
    axis.line.y = element_line(colour = "grey50"),
  ) +
  theme_light()

# Plot page views over time
ggplot(df1, aes(x = month, y=pageviews)) +
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


# 2021 website statistics summed up 
# Page views and users
sum(df1$pageviews)
sum(df1$users)
# Average session duration
seconds <- round(mean(df1$avgSessionDuration)%%60)
time <- mean(df1$avgSessionDuration)-mean(df1$avgSessionDuration)%%60
minutes <- time/60
paste(minutes,"minutes and",seconds,"seconds"," ")
# Total countries and cities
nrow(df2) # Countries
nrow(df5%>%filter(city != "(not set)")) # Cities
# Average pages per session
round(mean(df1$pageviewsPerSession),2)