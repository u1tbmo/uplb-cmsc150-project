# ------------------------------------------------------------------------------------------------
# File: app/ui.R
# This file contains the UI of the application.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# DEFINE THE HOME PAGE -----------------------------------------------------

home_page <- nav_panel(
  title = h2("Home"),
  # Layout Columns with Two Cards
  layout_columns(
    # Food Items Card with SelectizeInput and Action Button
    class = "home-layout",
    col_widths = c(6, 6),
    card(
      class = "food-items-card",
      h1("Food Items"),
      p("Select some food items below to generate a diet plan."),
      div(
        class = "food-items-buttons",
        actionButton(inputId = "select_all_food_items", label = h6("Select All")),
        actionButton(inputId = "deselect_all_food_items", label = h6("Deselect All"))
      ),
      actionButton(inputId = "generate_diet_plan", label = h4("Generate Diet Plan")),
      selectizeInput(
        inputId = "selected_food_items_selectize",
        label = NULL,
        choices = foods_with_calories,
        multiple = TRUE,
        options = list(placeholder = "Type/select food items..."),
        width = "100%"
      )
    ),
    # Diet Plan Card with Text Output and Table
    card(
      class = "diet-plan-card",
      h1("Diet Plan"),
      textOutput("diet_plan_selected_foods_text_output"),
      textOutput("home_status_text_output"),
      gt_output("diet_plan_table")
    )
  )
)

# DEFINE THE OPTIMIZATION LOGS PAGE ----------------------------------------

optimization_logs_page <- nav_panel(
  title = h2("Optimization Logs"),
  # Optimization Logs Page
  div(
    class = "optimization-logs-buttons",
    actionButton(inputId = "previous_iteration", label = h4("Previous Iteration")),
    actionButton(inputId = "next_iteration", label = h4("Next Iteration")),
  ),
  div(
    class = "optimization-logs-text",
    textOutput("current_iteration_text_output"),
    textOutput("logs_status_text_output"),
  ),
  layout_columns(
    class = "optimization-logs-tables",
    col_widths = c(10, 2),
    gt_output("iteration_table") |> withSpinner(
      color = "#B3C8CF",
      color.background = "#F1F0E8",
      type = 2,
      hide.ui = FALSE
    ),
    gt_output("solution_table")
  )
)

# DEFINE DATA PAGE ---------------------------------------------------------

data_page <- nav_panel(
  title = h2("Data"), # Navigation Bar with Two Tabs for Each Table
  navset_pill( # Food Items Tab
    nav_panel(
      h3("Food and Nutritional Information"),
      p(
        class = "text-centered",
        "This table shows the nutrient information of each food listed along with the price per serving."
      ),
      gt_output("food_gt_table")
    ), # Nutritional Requirements Tab
    nav_panel(
      h3("Nutritional Requirements"),
      p(
        class = "text-centered",
        "This table shows the minimum and maximum constraints for each nutrient from the diet plan."
      ),
      gt_output("nutritional_requirements_gt_table")
    )
  )
)

# DEFINE THE ABOUT PAGE ----------------------------------------------------

about_page <- nav_panel(
  title = h2("About"),
  # App Details
  div(
    class = "about-app",
    h1("About the Application"),
    p(
      "This app aims to solve your diet problems by generating the cheapest
      but most nutritious diet plan for you given a selection of foods."
    ),
    p(
      "It accomplishes this using the Simplex Method by minimizing cost
      and ensuring that the diet plan meets the nutritional requirements."
    ),
    p(
      "You can see each food item's nutritional data and the nutritional requirements
      needed to be met while minimizing cost in the Data tab."
    ),
    p(
      "After the app generates (or fails to generate) a diet plan,
      you can view each iteration of the Simplex algorithm in the Optimization Logs tab."
    )
  ),
  # Developer Details
  div(
    class = "about-dev",
    div(class = "about-image", imageOutput("about_image", height = "auto")),
    div(
      class = "about-dev-details",
      h1("Developed by Euan Jed Tabamo"),
      h2("Project in CMSC 150: Numerical and Symbolic Computing"),
      p(
        "Hi there! I am Euan. I am currently a computer science student of the University of the Philippines Los Baños.
        I have a passion for games and programming!
        I hope that I am able to use this passion to become a game developer and or software developer in the future."
      )
    )
  )
)

# DEFINE THE UI ------------------------------------------------------------

ui <- page_fillable(
  includeCSS("resources/styles.css"),
  div(h1(class = "app-title", "Euan's Diet Optimizer"), ),
  navset_card_pill(home_page, optimization_logs_page, data_page, about_page)
)
