#ui.R
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
#
## COVID-19 shiny app user interface
# 
# Code from Meinhard Ploner: 
# https://towardsdatascience.com/create-a-coronavirus-app-using-r-shiny-and-plotly-6a6abf66091d
# Adapted by Kevin Bairos-Novak

library(shiny)
library(plotly)
library(tidyverse)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    titlePanel("Case History of the Coronavirus (COVID-19)"),
    fluidRow(
        column(
            4, 
            selectizeInput("country", label=h5("Country"), choices=NULL, width="100%")
        ),
        column(
            4, 
            selectizeInput("state", label=h5("State / Province"), choices=NULL, width="100%")
        ),
        column(
            4, 
            checkboxGroupInput(
                "metrics", label=h5("Selected Metrics"), 
                choices=c("Confirmed", "Deaths", "Recovered"), 
                selected=c("Confirmed", "Deaths", "Recovered"), width="100%")
        )
    ),
    fluidRow(
        plotlyOutput("dailyMetrics")
    ),
    fluidRow(
        plotlyOutput("cumulatedMetrics")
    )
))

