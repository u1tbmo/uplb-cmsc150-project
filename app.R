# ------------------------------------------------------------------------------------------------
# File: app.R
# This file is the entry point of the application.
# ------------------------------------------------------------------------------------------------
# Tabamo, Euan Jed S. AB-3L
# Project in CMSC 150: Numerical and Symbolic Computing
# Date Created: 06 November 2024
# Date Modified: 05 December 2024
# ------------------------------------------------------------------------------------------------

# Load R Packages
library(shiny) # Shiny Web Framework
library(bslib) # Bootstrap Elements
library(gt) # GT Tables
library(stringr) # String Operations
library(shinycssloaders) # CSS Loaders

# Source R scripts
source(file = "./modules/util.R", encoding = "UTF-8")
source(file = "./modules/simplex.R", encoding = "UTF-8")
source(file = "./data/food.R", encoding = "UTF-8")
source(file = "./app/ui.R", encoding = "UTF-8")
source(file = "./app/server.R", encoding = "UTF-8")

# Run the app --------------------------------------------------------------
shinyApp(ui = ui, server = server)
