library(readr)
library(janitor)
library(tidyverse)
library(stringr)

#loading the data
my_data <- read.csv('C:/Users/elias-pc/Desktop/webscraping/my_data.csv')

colnames(my_data)

# Cleaning column names
df <- clean_names(my_data)
colnames(my_data)

# CLEANING PRODUCT COLUMN - move string in product that contains $ to original price and move sizes in product to size

df$original_price[str_detect(df$product, "\\$")] <- df$product[str_detect(df$product, "\\$")]
df$product[str_detect(df$product, "\\$")] <- ""

# Move single uppercase characters not separated by anything from product to size
df$size[grepl("^[A-Z]$", df$product)] <- df$product[grepl("^[A-Z]$", df$product)]
df$product[grepl("^[A-Z]$", df$product)] <- NA

# Move single uppercase characters separated by / from product to size
df$size[grepl("^[A-Z]/[A-Z]$", df$product)] <- df$product[grepl("^[A-Z]/[A-Z]$", df$product)]
df$product[grepl("^[A-Z]/[A-Z]$", df$product)] <- NA 




#CLEANING SALE COLUMN - removing strings that does not contain SALE or SOLD OUT
## Create a logical vector indicating which rows have values that are not "SALE" or "SOLD OUT"
not_sale_or_sold_out <- !(df$sale %in% c("SALE", "SOLD OUT"))

# Move the values from the sale column to the product column
df$product[not_sale_or_sold_out] <- df$sale[not_sale_or_sold_out]
df$sale[not_sale_or_sold_out] <- NA # Set the value in the sale column for that row to NA

# Cleaning original_price and moving strings without $ to size.

# Create a logical vector indicating which rows contain strings without "$" in the original_price column
no_dollar <- !is.na(df$original_price) & !grepl("\\$", df$original_price)

# Move the values from the original_price column to the size column for the selected rows
df$size[no_dollar] <- df$original_price[no_dollar]

# Set the value in the original_price column for that row to NA
df$original_price[no_dollar] <- NA


# CLEANING DISCOUNT COLUMN - moving string with $ sign to original_price
# Identify rows that contain a dollar sign
has_dollar_sign <- grepl("\\$", df$discount) 

# Extract price and add dollar sign to 'original_price'
df$original_price[has_dollar_sign] <- paste0("$", sub("\\$([0-9.]+).*", "\\1", df$discount[has_dollar_sign]))

# Replace 'discount' value with NA for the rows that were moved to 'original_price'
df$discount[has_dollar_sign] <- NA  




# Now we move strings that are NOT NA and that doesnt contain % whch are products to products because we finally can!

# Create a logical vector indicating which rows have values that do not contain "%"
no_discount_percent <- !is.na(df$discount) & !grepl("%", df$discount)


# Move the values from the discount column to the product column
df$product[no_discount_percent] <- df$discount[no_discount_percent]
df$discount[no_discount_percent] <- NA # Set the value in the discount column for that row to NA

# Cleaning discounted_price



# Create a logical vector indicating which rows contain single character or strings without "$" in discounted_price column
no_dollar <- !is.na(df$discounted_price) & !grepl("\\$", df$discounted_price) & (nchar(df$discounted_price) == 1 | grepl("/", df$discounted_price))

# Move the values from the discounted_price column to the size column for the selected rows
df$size[no_dollar] <- paste(df$size[no_dollar], df$discounted_price[no_dollar], sep = ",")

# Set the value in the discounted_price column for that row to NA
df$discounted_price[no_dollar] <- NA

df <- df %>%
  mutate(color = if_else(color == "", NA_character_, color))

df <- df %>%
  mutate(color = if_else(is.na(color), 
                         str_extract(product, "(?<=\\| |- )\\w+"), 
                         color))
unique(df$color)

df <- df %>%
  filter(!color %in% c("Square", "Round"))


write.csv(df, "C:/Users/elias-pc/Desktop/webscraping/cleaned-data.csv", row.names = FALSE)

