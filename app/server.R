# ------------------------------------------------------------------------------------------------
# File: app/server.R
# This file contains the server logic of the application.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# DEFINE THE SERVER ---------------------------------------------------------

server <- function(input, output) {
  # APP STARTUP -------------------------------------------------------------
  observe({
    # Set initial text outputs
    output$diet_plan_selected_foods_text_output <- renderText("Please select food items to generate a diet plan!")
    output$home_status_text_output <- renderText("")
    output$logs_status_text_output <- renderText("")
    output$current_iteration_text_output <- renderText("No iterations to display!")

    # Set tables
    output$diet_plan_table <- render_gt(NULL)
    output$iteration_table <- render_gt(NULL)
    output$solution_table <- render_gt(NULL)
  }) |> bindEvent("session")

  # HOME & OPTIMIZATION LOGS ------------------------------------------------

  # NOTE TO SELF:
  # reactiveVal Get: variable_name()
  # reactiveVal Assignment: variable_name(value)

  # Store the current result of the optimization
  result <- reactiveVal(NULL)
  selected_food_items <- reactiveVal(NULL)

  # Store the current iteration and the maximum number of iterations
  # Initialize both to 0, which means no table is displayed
  current_iteration <- reactiveVal(0)
  max_iterations <- reactiveVal(0)

  # Previous iteration button
  observe({
    if (current_iteration() != 0) {
      # Decrement current iteration unless it is already at 1
      if (current_iteration() > 1) {
        current_iteration(current_iteration() - 1)

        # Change the iteration and solution table to the new current iteration
        output$current_iteration_text_output <- renderText(paste("Iteration ", current_iteration(), " of ", max_iterations(), sep = ""))
        output$iteration_table <- render_gt(
          GenerateGTTableau(
            result()$simplex_result$iterations,
            current_iteration(),
            NULL
          )
        )
        output$solution_table <- render_gt(
          GenerateGTSolution(
            result()$simplex_result$solutions, current_iteration()
          )
        )
      }
    }
  }) |> bindEvent(input$previous_iteration)

  # Next iteration button
  observe({
    if (current_iteration() != 0) {
      unbounded_column <- NULL

      # Increment current iteration unless it is already at the maximum
      if (current_iteration() < max_iterations()) {
        current_iteration(current_iteration() + 1)

        if (current_iteration() == max_iterations() && result()$simplex_result$status == "unbounded") {
          unbounded_column <- result()$simplex_result$unbounded_column
        }

        # Change the iteration and solution table to the new current iteration
        output$current_iteration_text_output <- renderText(paste("Iteration ", current_iteration(), " of ", max_iterations(), sep = ""))
        output$iteration_table <- render_gt(
          GenerateGTTableau(
            result()$simplex_result$iterations,
            current_iteration(),
            unbounded_column
          )
        )
        output$solution_table <- render_gt(
          GenerateGTSolution(
            result()$simplex_result$solutions, current_iteration()
          )
        )
      }
    }
  }) |> bindEvent(input$next_iteration)


  # Obtain the food list from the selectizeInput
  selected_food_items_selectize <- reactive({
    food_data[food_data$food_name %in% input$selected_food_items_selectize, ]$food_name
  })

  # Select all food items button
  observe({
    updateSelectizeInput(
      inputId = "selected_food_items_selectize",
      selected = food_data$food_name
    )
  }) |> bindEvent(input$select_all_food_items)

  # Deselect all food items button
  observe({
    updateSelectizeInput(
      inputId = "selected_food_items_selectize",
      selected = character(0) # empty character vector
    )
  }) |> bindEvent(input$deselect_all_food_items)


  # Generate diet plan button
  observe({
    # Obtain currently selected food items from the selectizeInput
    selected_food_items(selected_food_items_selectize())
    # If there are selected food items
    if (length(selected_food_items()) > 0) {
      # Call the CostMinimizer function to generate the diet plan and store the result
      result(CostMinimizer(selected_food_items_selectize()))

      # Display selected food items
      output$diet_plan_selected_foods_text_output <- renderText(paste(
        "You selected:",
        paste(selected_food_items(), collapse = ", ")
      ))
      if (result()$simplex_result$status == "optimal") {
        # If there is an optimal solution, display the cost of the diet plan and the diet plan table
        output$home_status_text_output <- renderText(paste0(
          "The cost of this optimal diet is $",
          round(result()$simplex_result$optimal_value, digits = 2)
        ))
        output$logs_status_text_output <- renderText("Optimal solution found!")
        output$diet_plan_table <- render_gt(result()$diet_plan_gt_table)
      } else {
        # If the problem is unbounded, display a message
        output$home_status_text_output <- renderText(
          "The problem is infeasible!
          It is not possible to generate a diet plan with the selected food items.
          Please check the optimization logs for more details."
        )
        output$logs_status_text_output <- renderText("The problem is infeasible!")
        output$diet_plan_table <- render_gt(NULL)
      }

      # Get and display the latest iteration and solution tables
      output$iteration_table <- render_gt(
        GenerateGTTableau(
          result()$simplex_result$iterations,
          length(result()$simplex_result$iterations),
          result()$simplex_result$unbounded_column
        )
      )
      output$solution_table <- render_gt(
        GenerateGTSolution(
          result()$simplex_result$solutions,
          length(result()$simplex_result$solutions)
        )
      )

      # Set current and maximum iterations
      current_iteration(length(result()$simplex_result$iterations))
      max_iterations(length(result()$simplex_result$iterations))
      output$current_iteration_text_output <- renderText(paste("Iteration ", current_iteration(), " of ", max_iterations(), sep = ""))
    } else {
      # If there are no selected food items, display text outputs
      output$diet_plan_selected_foods_text_output <- renderText("Please select food items to generate a diet plan!")
      output$home_status_text_output <- renderText("")
      output$logs_status_text_output <- renderText("")
      output$current_iteration_text_output <- renderText("No iterations to display!")
      output$diet_plan_table <- render_gt(NULL)

      # Remove optimization logs
      output$iteration_table <- render_gt(NULL)
      output$solution_table <- render_gt(NULL)

      # Remove stored result
      result(NULL)

      # Reset current and maximum iterations
      current_iteration(0)
      max_iterations(0)
    }
  }) |> bindEvent(input$generate_diet_plan)

  # DATA --------------------------------------------------------------------

  # Render tables
  output$food_gt_table <- render_gt(food_gt_table)
  output$nutritional_requirements_gt_table <- render_gt(nutritional_reqs_gt_table)

  # ABOUT -------------------------------------------------------------------

  # Render the image
  output$about_image <- renderImage(
    {
      list(src = "./resources/images/about-image.jpg", alt = "Photo of Euan")
    },
    deleteFile = FALSE
  )
}
