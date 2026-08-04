# Load the dataset
retail_data <- read.csv(
  "data/Copy of Online Retail.csv",
  sep = "'",
  header = TRUE
)

# View the first 6 rows
head(retail_data)
str(retail_data)
dim(retail_data)
names(retail_data)

# Check missing values
(colSums(is.na(retail_data)))

# Remove rows with missing Customer IDs
retail_clean <- retail_data[!is.na(retail_data$CustomerID), ]

# Check the new dataset size
print(dim(retail_clean))

# Confirm there are no missing Customer IDs
print(sum(is.na(retail_clean$CustomerID)))

# Remove cancelled and invalid transactions
retail_clean <- retail_clean[
    retail_clean$Quantity > 0 &
    retail_clean$UnitPrice > 0 &
  !grepl("^C", retail_clean$InvoiceNo),
]

# Check the new dataset size
(dim(retail_clean))

# Calculate the total value of each transaction
retail_clean$TotalPrice <- 
  retail_clean$Quantity * retail_clean$UnitPrice

# View the first few rows
(head(retail_clean))

# Convert InvoiceDate to date-time format
retail_clean$InvoiceDate <- as.POSIXct(
  retail_clean$InvoiceDate,
  format = "%d %m %Y %H:%M"
)

# Check the result
str(retail_clean$InvoiceDate)

# Find the latest transaction date
max(retail_clean$InvoiceDate)
(max(retail_clean$InvoiceDate))

# Creating the reference date
reference_date <- max(retail_clean$InvoiceDate) + 1

# Creating the RFM values
recency <- aggregate(
  InvoiceDate ~ CustomerID,
  data = retail_clean,
  FUN = function(x) floor(as.numeric(
    difftime(reference_date, max(x), units = "days")
))
)

frequency <- aggregate(
  InvoiceNo ~ CustomerID,
  data = retail_clean,
  FUN = function(x) length(unique(x))
)

monetary <- aggregate(
  TotalPrice ~ CustomerID,
  data = retail_clean,
  FUN = sum
)

# Renaming the columns
names(recency)[2] <- "Recency"
names(frequency)[2] <- "Frequency"
names(monetary)[2] <- "Monetary"

# Combining the RFM values
rfm_data <- merge(recency, frequency, by = "CustomerID")
rfm_data <- merge(rfm_data, monetary, by = "CustomerID")

# Viewing the first rows
print(head(rfm_data))

# Checking the RFM values
print(summary(rfm_data[, c("Recency", "Frequency", "Monetary")]))
# Creating the values for clustering
rfm_values <- rfm_data[, c("Recency", "Frequency", "Monetary")]

# Applying log transformation
rfm_log <- log1p(rfm_values)

# Scaling the values
rfm_scaled <- scale(rfm_log)

# Checking the scaled values
print(summary(rfm_scaled))

# Finding the best number of clusters

set.seed(123)

wss <- numeric(10)

for (k in 1:10) {
  kmeans_result <- kmeans(
    rfm_scaled,
    centers = k,
    nstart = 25
  )

  wss[k] <- kmeans_result$tot.withinss
}

# Creating the elbow plot

plot(
  1:10,
  wss,
  type = "b",
  xlab = "Number of Clusters",
  ylab = "Within-Cluster Sum of Squares",
  main = "Elbow Method"
)
# Creating 4 customer clusters

set.seed(123)

kmeans_model <- kmeans(
  rfm_scaled,
  centers = 4,
  nstart = 25
)

# Creating 4 customer clusters

set.seed(123)

kmeans_model <- kmeans(
  rfm_scaled,
  centers = 4,
  nstart = 25
)

# Adding the clusters to the data

rfm_data$Cluster <- kmeans_model$cluster

# Checking the number of customers in each cluster

print(table(rfm_data$Cluster))
# Looking at the customer clusters

cluster_summary <- aggregate(
  cbind(Recency, Frequency, Monetary) ~ Cluster,
  data = rfm_data,
  FUN = mean
)

print(cluster_summary)

# Naming the customer groups

rfm_data$CustomerGroup <- ifelse(
  rfm_data$Cluster == 1,
  "Inactive Customers",
  ifelse(
    rfm_data$Cluster == 2,
    "Occasional Customers",
    ifelse(
      rfm_data$Cluster == 3,
      "High-Value Customers",
      "Regular Customers"
    )
  )
)

# Checking the customer groups

print(table(rfm_data$CustomerGroup))

# Saving the customer group chart

png(
  "visuals/customer_groups.png",
  width = 1000,
  height = 700
)

customer_counts <- table(rfm_data$CustomerGroup)

barplot(
  customer_counts,
  main = "Customer Groups",
  xlab = "Customer Group",
  ylab = "Number of Customers"
)

dev.off()
# Creating the customer comparison chart

png(
  "visuals/recency_vs_monetary.png",
  width = 1000,
  height = 700
)

plot(
  rfm_data$Recency,
  rfm_data$Monetary,
  main = "Customer Spending and Recency",
  xlab = "Recency (Days)",
  ylab = "Total Spending"
)

dev.off()
# Saving the customer results

write.csv(
  rfm_data,
  "data/customer_segments.csv",
  row.names = FALSE
)