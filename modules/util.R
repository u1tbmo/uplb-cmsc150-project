# ------------------------------------------------------------------------------------------------
# File: modules/util.R
# This file contains utility functions used in the application.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# Utility function that converts a snake case string to an uppercase label
SnakeCaseToLabel <- function(str) {
  # Convert snake case to label
  str |>
    str_replace_all("_", " ") |>
    str_to_upper()
}