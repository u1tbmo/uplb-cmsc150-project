# ------------------------------------------------------------------------------------------------
# File: modules/simplex.R
# This file contains the functions needed to perform the Simplex Method and generate the diet plan.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# Generates and returns a GT Table of the tableau for a given iteration
GenerateGTTableau <- function(iterations, index, unbounded_column = NULL) {
  # Check if the index is valid
  if (index < 0 || index > length(iterations)) {
    return(NULL)
  }

  # Get the tableau for the given iteration
  tableau <- as.data.frame(iterations[[index]])
  tableau_gt_table <- tableau |>
    gt() |> # Create GT Table
    tab_header( # Create header
      md("**TABLEAU**")
    ) |>
    fmt_scientific( # Format to scientific notation
      columns = everything(),
      drop_trailing_zeros = TRUE,
      decimals = 4
    ) |>
    text_transform( # Make the column labels more readable
      locations = cells_column_labels(),
      fn = SnakeCaseToLabel
    ) |>
    tab_style( # Make serving labels condensed
      style = cell_text(
        stretch = "extra-condensed"
      ),
      locations = cells_column_labels(
        ends_with("SERVINGS")
      )
    ) |>
    tab_options( # Styling
      heading.align = "left",
      heading.title.font.size = "2.027rem",
      column_labels.font.size = "1.125rem",
      heading.title.font.weight = "bold",
      table.background.color = "transparent",
      table.font.names = c("Inconsolata", "monospace"),
      container.height = "100%"
    )

  # Highlight the unbounded column
  if (!is.null(unbounded_column)) {
    tableau_gt_table <- tableau_gt_table |>
      tab_style_body(
        style = cell_fill(color = "pink"),
        columns = matches(unbounded_column),
        fn = function(x) TRUE
      )
  }

  # Return the gt table
  tableau_gt_table
}

GenerateGTSolution <- function(iterations, index) {
  # Check if the index is valid
  if (index < 0 || index > length(iterations)) {
    return(NULL)
  }

  # Get the solution for the given iteration
  solution <- iterations[[index]]
  solution <- as.data.frame(solution)
  solution$variable <- rownames(solution)

  # In the data frame, change the RHS row to the Z row
  solution$variable[nrow(solution)] <- "Z"

  solution_gt_table <- solution |>
    gt( # Create GT Table
      rowname_col = "variable"
    ) |>
    tab_header( # Create header
      md("**SOLUTION**")
    ) |>
    text_transform( # Make the column labels more readable
      locations = list(cells_column_labels(), cells_stub()),
      fn = SnakeCaseToLabel
    ) |>
    fmt_number( # Format numbers to 4 decimal places
      columns = everything(),
      drop_trailing_zeros = TRUE,
      decimals = 4
    ) |>
    tab_style_body(
      style = cell_fill(color = "pink"),
      rows = ends_with("SERVINGS"),
      columns = is.numeric,
      fn = function(x) x < 0 || x > 10
    ) |>
    tab_options( # Styling
      column_labels.hidden = TRUE,
      heading.align = "right",
      heading.title.font.size = "2.027rem",
      heading.title.font.weight = "bold",
      table.background.color = "transparent",
      table.font.names = c("Inconsolata", "monospace"),
      container.height = "100%"
    )

  # Return the gt table
  solution_gt_table
}

CostMinimizer <- function(food_items) {
  # SET UP THE PROBLEM -----------------------------------------------

  # Count the number of food items and nutrients
  n_foods <- length(food_items)
  n_nutrients <- length(nutrients) # Constant, 11

  # Extract the data for the selected food items
  problem_data <- food_data[food_data$food_name %in% food_items, ] # Get the rows that match the food items
  max_servings <- problem_data$max_servings # Constant, 10, defined in food file
  cost <- problem_data$price_per_serving
  food_matrix <- as.matrix(problem_data[, nutrients])

  # Transpose the matrix (to get primal form) since the food data is in rows
  food_matrix <- t(food_matrix)

  # Create the objective vector, which is the cost of each food item
  obj_vec <- cost

  # Create the constraint matrix, which is the food matrix twice (for >= and <= constraints) and the identity matrix (for servings)
  const_mat <- rbind(
    food_matrix,
    food_matrix,
    diag(n_foods)
  )
  dimnames(const_mat) <- list(
    c(nutrients, nutrients, paste0(food_items, " Servings")),
    c(food_items)
  )

  # Create the constraint direction vector
  const_dir <- c(rep(">=", n_nutrients), rep("<=", n_nutrients), rep("<=", n_foods))

  # Create the RHS vector
  rhs <- c(min_nutrients, max_nutrients, max_servings)

  # SOLVE THE PROBLEM -----------------------------------------------

  dual_tableau <- CreateDualTableau(obj_vec, const_mat, const_dir, rhs, food_items)
  simplex_result <- SimplexMinimization(dual_tableau)

  # Log optimal value
  cat(paste0("[LOG] Optimum: ", simplex_result$optimal_value, "\n"))
  cat(paste0("[LOG] Status:  ", simplex_result$status, "\n"))

  # If the problem is unbounded, return NULL for the diet plan
  if (simplex_result$status == "unbounded") {
    return(list(
      simplex_result = simplex_result,
      diet_plan_gt_table = NULL
    ))
  }

  # CREATE THE DIET PLAN -----------------------------------------------

  # The servings of each food item are in the final solution starting at column sn + 1
  # We know that there are 11 nutrients and they are double bounded, so there are 22 slacks for the nutrients
  # There is an additional constraint for each food item, so there are 22 + n_foods slacks in total
  # The solution is in the form [s1, s2, ..., sn, servings1, servings2, ..., servingsN, RHS]
  n_slack_solutions <- 2 * n_nutrients + n_foods
  servings <- simplex_result$final_solution[(n_slack_solutions + 1):(n_slack_solutions + n_foods)]
  food_cost <- cost * servings


  # Create a data frame for the diet plan
  # This is because gt requires a data frame (or a tibble) to create a GT table
  # Only include food items with servings above 0
  diet_plan <- data.frame(
    food = food_items[servings > 0],
    servings = servings[servings > 0],
    cost = food_cost[servings > 0]
  )

  # Create a GT table for the diet plan
  diet_plan_gt_table <- diet_plan |>
    gt( # Create GT Table
      rowname_col = "food"
    ) |>
    tab_header( # Create a header
      title = md("**Solution and Cost Breakdown**"),
      subtitle = paste0("Total Cost: $", sprintf("%.2f", round(simplex_result$optimal_value, digits = 2)))
    ) |>
    tab_stubhead( # Set the stubhead label
      label = "Food"
    ) |>
    fmt_number( # Format servings as floats
      columns = 2,
      decimals = 2
    ) |>
    fmt_currency( # Format cost as currency
      columns = 3,
      currency = "USD"
    ) |>
    text_transform(
      locations = cells_column_labels(),
      fn = function(x) tools::toTitleCase(x)
    ) |>
    tab_options( # Styling
      table.background.color = "transparent",
      table.font.names = c("Inconsolata", "monospace"),
      heading.title.font.size = "2.027rem",
      heading.subtitle.font.size = "1.602rem",
      column_labels.font.size = "1.424rem",
    )

  # Return the simplex result and the diet plan GT table
  list(
    simplex_result = simplex_result,
    diet_plan_gt_table = diet_plan_gt_table
  )
}

# Creates a dual tableau given an objective vector, constraint matrix, constraint directions, and constraint RHS
# Also takes the food list for tableau naming
# This function's formal parameters are heavily inspired by lpSolve's function parameters.
CreateDualTableau <- function(obj_vec, const_mat, const_dir, const_rhs, food_list) {
  # PRIMAL SETUP -----------------------------------------------
  # In the primal when minimizing, all constraints should be in the form >=
  # We need to change the direction of constraints that are in the form <=
  # This can be done by knowing that a <= b is equivalent to  -a >= -b

  # Change the direction of all constraints to >=
  for (i in seq_along(const_dir)) {
    if (const_dir[i] == "<=") {
      const_mat[i, ] <- -const_mat[i, ]
      const_rhs[i] <- -const_rhs[i]
      const_dir[i] <- ">="
    }
  }

  # DUAL SETUP -----------------------------------------------
  # To use the simplex method for minimization, create a dual problem that can be maximized

  # Transpose the constraint matrix
  dual_const_mat <- t(const_mat)

  # Swap the objective vector and the right-hand side vector
  # Since the RHS in the primal is the objective in the dual
  dual_obj_vec <- const_rhs
  dual_rhs <- obj_vec

  # Get dimensions
  n_constraints <- nrow(dual_const_mat)
  n_variables <- ncol(dual_const_mat)

  # Create the tableau with the constraint matrix, slack variables, and RHS
  tableau <- cbind(dual_const_mat, diag(n_constraints), dual_rhs)

  # Add the objective row
  tableau <- rbind(tableau, c(-dual_obj_vec, rep(0, n_constraints + 1))) # Objective row is negated for form -s1 - s2 - ... - sn = -Z


  # Name the columns
  colnames(tableau) <- c(
    paste0("s", 1:n_variables),
    paste0(food_list, " Servings"), # In the dual, the slack variables are the primal variables
    "RHS"
  )

  # Name the rows
  rownames(tableau) <- c(
    paste0(food_list, " Servings"),
    "Objective"
  )

  # Return the tableau
  tableau
}

# Performs simplex method to minimize an objective
# Returns a list of iterations, the final iteration, and the minimized solution
SimplexMinimization <- function(tableau) {
  # Store each iteration and solution
  iterations <- list()
  solutions <- list()

  # The tableau is an m x n matrix
  m <- nrow(tableau)
  n <- ncol(tableau)

  while (TRUE) {
    # Store the current iteration
    iterations[[length(iterations) + 1]] <- tableau

    # Store the current solution
    # The solution of a dual problem is just the bottom row of the tableau + the optimal value Z
    solution <- tableau[m, ]
    solutions[[length(solutions) + 1]] <- solution

    # Get the pivot column
    p_col <- which.min(tableau[m, 1:(n - 1)])

    # The solution is optimal if all values in the pivot column are nonnegative
    # This can be checked by just checking if the minimum in the row is nonnegative
    if (tableau[m, p_col] >= 0) {
      # Solution is found
      break
    }

    # Compute for the test ratios
    ratios <- rep(Inf, m - 1) # Create a vector of size m-1 ratios (all rows excluding objective)
    valid_rows <- which(tableau[1:(m - 1), p_col] > 0) # Create a logical vector of size m-1 which indicates which rows are valid for test ratios
    if (length(valid_rows) > 0) {
      # If there are valid rows, then compute the ratios of those valid rows
      ratios[valid_rows] <- tableau[valid_rows, n] / tableau[valid_rows, p_col]
    } else if (length(valid_rows) == 0) {
      # If there are no valid rows, then the problem is unbounded
      return(
        list(
          iterations = iterations,
          solutions = solutions,
          final_tableau = iterations[[length(iterations)]],
          unbounded_column = colnames(tableau)[p_col],
          final_solution = NA,
          optimal_value = NA,
          status = "unbounded"
        )
      )
    }

    # Get the pivot row
    p_row <- which.min(ratios)

    # Indicate the entering and leaving variables
    # This is usually used when maximizing since the RHS is the basic solution for maximization
    rownames(tableau)[p_row] <- colnames(tableau)[p_col]

    # GAUSS-JORDAN ELIMINATION ------------------------

    # Get the pivot element
    pivot <- tableau[p_row, p_col]

    # Normalize
    tableau[p_row, ] <- tableau[p_row, ] / pivot

    # Eliminate
    for (i in 1:m) {
      if (i != p_row) {
        tableau[i, ] <- tableau[i, ] - tableau[i, p_col] * tableau[p_row, ]
      }
    }
  }

  # Get the final tableau, final basic solution, and optimal value
  final_tableau <- iterations[[length(iterations)]]
  final_solution <- solutions[[length(solutions)]]
  optimal_value <- tableau[m, n]

  # Return the list
  list(
    iterations = iterations,
    solutions = solutions,
    final_tableau = final_tableau,
    unbounded_column = NULL,
    final_solution = final_solution,
    optimal_value = optimal_value,
    status = "optimal"
  )
}
