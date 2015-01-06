#
# Install if needed and load required Packages
#
if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RGoogleAnalytics")) {
  install.packages("RGoogleAnalytics", dependencies = TRUE)
  library(RGoogleAnalytics)
}

#
# Assign the following 5 variables with your values.
# Use dates of range N*7 (7, 14, 21...). First and last day are included
#
client.id <- '123456789.apps.googleusercontent.com'
client.secret <- 'abcdefghijklmno'
view.id <- "ga:123456789"
start.date <- "2014-01-25"
end.date <- "2014-01-31"

# Authorize Google Analytics account
# Save the token object for future sessions if file "token" does not exist
# If token exists load it 
if (!file.exists("./token")) {
  token <- Auth(client.id,client.secret)
  save(token,file="./token")
} else {
  load("./token")  
}

#Validate acquired token
ValidateToken(token)

# Create a list of parameteres needed for the query to GA API
query.list <- Init(start.date = start.date,
                   end.date = end.date,
                   dimensions = "ga:hour,ga:dayOfWeek",
                   metrics = "ga:sessions",
                   table.id = view.id)

# Construct a query Builder object
ga.query <- QueryBuilder(query.list)

# Get data using the query builder object and acquired token
ga.data <- GetReportData(ga.query, token)

# Transform the data to be a (7x24) matrix (for the heatmap)
heatmapData <-  t(matrix(as.numeric(ga.data$sessions), nrow = 7))
# Rename columns from 0-6, to Sun-Sat
colnames(heatmapData) <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
# Rename rows from 00, 01, 02... to 0, 1, 2...
rownames(heatmapData) <- 0:23
# Draw the heatmap
# To see what each parameter does type "?heatmap.2" in your R console
heatmap.2(heatmapData, dendrogram="none", Rowv = NA, Colv=NA, col=cm.colors(20), margins=c(5,10), scale="none", trace="none", denscol="red", key.title="", key.xlab = "Sessions")