#README.R
# 
# Here are two different shiny apps for the R group
# They are built using three packages that may take a while to install,
# so I would recommend running the following code to install them
# if you do not have them already:

list.of.packages <- c("tidyverse", "shiny", "plotly")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# List of contents:
# 
# /simple/ is a folder containing the user interface and server code for a 
# simple covid-19 plotter based on ggplot2 graphics that we will go through 
# in-depth on Monday, (June 8th) to showcase the basic structure and
# capabilities of R-shiny web applications.
# 
# /advanced/ is a more advanced covid-19 plotter that I am not responsible for 
# creating (except tinkering with the plots a little), with advanced features, 
# e.g., automatically updating within 10-mins to the most recent version of the 
# data, allows subsetting of both country and state (where applicable), and 
# updating the fields being plotted using the tick boxes for the three metrics.
# 
# aus_data.RData is a subset of processed data (not up to date) for Aus-only,
# in case you'd like to play around with plotting the data differently and
# need an example of what the data loaded within the reactive will look like.
#
# More info on building shiny web apps:
# https://deanattali.com/blog/building-shiny-apps-tutorial/
# https://spartanideas.msu.edu/2016/11/07/interactive-r-plots-with-ggplot2-and-plotly/
# https://towardsdatascience.com/create-a-coronavirus-app-using-r-shiny-and-plotly-6a6abf66091d
# 
# Happy shining! Kevin Bairos-Novak