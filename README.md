# google-analytics-data
R script and R Markdown presentation with a brief summary of Google Analytics data of 2021 using the **Google Analytics API**. Script uses **Google Analytics API** to query various data such as page views, users, session duration per user, and top 5 countries and top 5 cities globally.

## Requirements

**GA_presentation.Rmd** is set to knit to PDF so make sure to install the required **LaTeX** packages. Make sure to have set up Google Analytics for you website and check if you have valid Google Analytics API key credentials.

## Guide

In the script change the ***client.id*** and ***client.secret*** with the credentials from your **Google Analytics API Key**.

```r
token <- Auth(client.id="<ga:client.id>", # Replace <ga:client.id> with actual client.id
              client.secret="<ga:client.secret>") # Replace <ga:client.secret> with actual client.secret
```

Make sure to change the ***table.id*** in the **get_data()** function to the table.id from your website in Google Analytics.

```r
  query <- Init(start.date = start.date,
                end.date = end.date,
                dimensions = dimensions,
                metrics = metrics,
                max.results = 10000,
                sort = paste("-",dimensions,sep=""),
                table.id = "<ga:table.id>" # Replace <ga:table.id> with actual table.id
                )
```
