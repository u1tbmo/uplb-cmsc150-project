# Euan’s Diet Optimizer

This is an application designed to generate diet plans based on the user’s selected foods. The application generates the plans while minimizing the cost of the diet plan but also ensuring that all the diet plan also meets nutrient requirements.

# Usage

The following subsections explain how to use the app in detail. The app has four main pages: Home, Optimization Logs, Data, and About. You can navigate each page by clicking the respective tab at the top of the app.

## Home

The app opens in the home page by default. Here you can select food items and generate diet plans based on the food items.

To select food items, simply press on the prompt and type or select from the available options.

Once you press "Generate Diet Plan"  the diet plan will be displayed in a table along with your selected foods and the total cost of the plan.

If the problem is feasible, great! The app will display your selected foods, the diet plan, and the total cost of the plan. If the problem is infeasible, the app will display a message indicating that the problem is infeasible. 

You can check the Optimization Logs to see each iteration of the Simplex Method and the solution at each iteration.

## Optimization Logs

The Optimization Logs page displays the logs of the optimization process. You will mainly see two tables: the Simplex Tableau and the Solution Table.

Each iteration can be navigated using the Previous Iteration and Next Iteration buttons. The iteration number is also displayed so you can easily navigate to a specific iteration.

If the problem is infeasible, you will see the column that caused the infeasibility in the tableau. This indicates that the problem is unbounded. The solution will also highlight the variables that violate the servings constraint (specifically that servings cannot exceed ten and also not be negative).

## Data

The Data page displays a table depending on the selected tab. The Food and Nutritional Information tab displays the food items and their nutritional information. The Nutrient Requirements tab displays the nutrient requirements for the diet plan.

## About

The About page displays information about the app and the developer.

## Dependencies

Ensure that R version 4.4.2 is installed on your system. Compatibility with versions below or above this version is not guaranteed.

While RStudio is recommended for running the application, R Console and thus other programs like Visual Studio Code with radian are still able to run this application.

Ensure that the necessary packages are installed by running the commands below in your R Console or in RStudio.

```r
install.packages("shiny")
install.packages("bslib")
install.packages("gt")
install.packages("stringr")
install.packages("shinycssloaders")
```

## Running the App

Set your working directory to the root folder of this project.

You can run the app by running the following command in the R Console:

```r
shiny::runApp()
```

In RStudio, you can open `app.R` and press "Run App" on the top right of the Source pane. I recommend setting the app to open in your system’s preferred browser instead of RStudio’s built in browser by selecting Run External in the "Run App" dropdown menu.

## Terminating the App

You can terminate the process by entering the key combination “Ctrl + C” in the R Console.

In RStudio, simply press “Stop” button at the top right corner of the Console pane to stop the app.