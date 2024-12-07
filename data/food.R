# ------------------------------------------------------------------------------------------------
# File: data/food.R
# This file contains the food data used in the application.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# Libaries
library(xlsx) # Allows reading of Excel .xlsx files
library(gt) # GT Tables

# CONSTANTS

# 2000 <= Calories <= 2250
min_calories <- 2000
max_calories <- 2250

# Cholestorol <= 300
max_cholesterol <- 300

# Total Fat <= 65
max_total_fat <- 65

# Sodium <= 2400
max_sodium <- 2400

# Carbohydrates <= 300
max_carbohydrates <- 300

# 25 <= Dietary Fiber <= 100
min_dietary_fiber <- 25
max_dietary_fiber <- 100

# 50 <= Protein <= 100
min_protein <- 50
max_protein <- 100

# 5000 <= Vitamin A <= 50000
min_vitamin_a <- 5000
max_vitamin_a <- 50000

# 50 <= Vitamin C <= 20000
min_vitamin_c <- 50
max_vitamin_c <- 20000

# 800 <= Calcium <= 1600
min_calcium <- 800
max_calcium <- 1600

# 10 <= Iron <= 30
min_iron <- 10
max_iron <- 30

# Food servings <= 10
max_servings <- 10

# Minimum constraints
min_nutrients <- c(
  min_calories, 0, 0, 0, 0, min_dietary_fiber,
  min_protein, min_vitamin_a, min_vitamin_c, min_calcium, min_iron
)

# Maximum constraints
max_nutrients <- c(
  max_calories, max_cholesterol, max_total_fat, max_sodium, max_carbohydrates, max_dietary_fiber,
  max_protein, max_vitamin_a, max_vitamin_c, max_calcium, max_iron
)

# Variables to consider
nutrients <- c(
  "calories", "cholesterol_mg", "total_fat_g", "sodium_mg", "carbohydrates_g", "dietary_fiber_g",
  "protein_g", "vitamin_A_IU", "vitamin_C_IU", "calcium_mg", "iron_mg"
)

# Obtain a data frame of food items and their nutritional values
food_data <- read.xlsx("./data/food.xlsx", sheetIndex = 1, encoding = "UTF-8")
rownames(food_data) <- food_data$food_name

# Food list with calories (for easy viewing of calories when choosing)
foods_with_calories <- setNames(
  object = as.list(food_data$food_name),
  sprintf("%s (%.f Cal)", food_data$food_name, food_data$calories)
)

# Log the number of food items loaded
cat(paste("[INFO] Loaded", nrow(food_data), "food items\n"))

# Create a GT Table for the Food and Nutritional Data
food_temp <- food_data
food_temp$max_servings <- NULL # Remove max_servings column

food_gt_table <- food_temp |>
  gt( # Create GT Table with Food Name as Row Name
    rowname_col = "food_name",
  ) |>
  tab_header( # Set the Header Title
    title = md("**FOOD AND NUTRITIONAL DATA**"),
  ) |>
  tab_stubhead( # Set the Stubhead Label
    label = "FOOD NAME"
  ) |>
  fmt_number( # Format numbers to 2 decimal places
    columns = 2:ncol(food_temp),
    decimals = 2
  ) |>
  text_transform( # Make the column labels more readable
    locations = cells_column_labels(),
    fn = SnakeCaseToLabel
  ) |>
  tab_options(
    table.background.color = "transparent",
    table.font.names = c("Inconsolata", "monospace"),
    heading.title.font.size = "2.027rem",
    column_labels.font.size = "1.424rem",
  )

# Load the nutritional requirements
nutritional_requirements <- data.frame(
  Nutrient = c(
    "Calories", "Cholesterol", "Total Fat", "Sodium", "Carbohydrates", "Dietary Fiber",
    "Protein", "Vitamin A", "Vitamin C", "Calcium", "Iron"
  ),
  Minimum = min_nutrients,
  Maximum = max_nutrients
)

# Create a GT Table for the Nutritional Requirements
nutritional_reqs_gt_table <- nutritional_requirements |>
  gt() |> # Create GT Table
  tab_header( # Set the Header Title
    title = md("**NUTRITIONAL REQUIREMENTS**"),
  ) |>
  tab_stubhead( # Set the Stubhead Label
    label = "NUTRIENT"
  ) |>
  fmt_number( # Format numbers to 2 decimal places
    columns = 2:ncol(nutritional_requirements),
    decimals = 2
  ) |>
  text_transform( # Make the column labels more readable
    locations = cells_column_labels(),
    fn = SnakeCaseToLabel
  ) |>
  tab_options(
    table.background.color = "transparent",
    table.font.names = c("Inconsolata", "monospace"),
    heading.title.font.size = "2.027rem",
    column_labels.font.size = "1.424rem",
  )



# Sample Inputs
project_sample1 <- c(
  "Frozen Broccoli",
  "Carrots, Raw",
  "Celery, Raw",
  "Frozen Corn",
  "Lettuce, Iceberg, Raw",
  "Peppers, Sweet, Raw",
  "Potatoes, Baked",
  "Tofu",
  "Roasted Chicken",
  "Spaghetti with Sauce",
  "Tomato, Red, Ripe, Raw",
  "Apple, Raw, with Skin",
  "Banana",
  "Grapes",
  "Kiwifruit, Raw, Fresh",
  "Oranges",
  "Bagels",
  "Wheat Bread",
  "White Bread",
  "Oatmeal Cookies"
)

project_sample2 <- c(
  "Frozen Broccoli",
  "Carrots, Raw",
  "Celery, Raw",
  "Frozen Corn",
  "Lettuce, Iceberg, Raw",
  "Peppers, Sweet, Raw"
)
