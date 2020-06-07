#server.R
#
# Simple COVID-19 shiny app (ggplot2)
# NOTE: app has a bug in it that makes it not publishable online
# 
# COVID-19 plotter using the Johns Hopkins UCSSE database
# 
# Code from Meinhard Ploner: 
# https://towardsdatascience.com/create-a-coronavirus-app-using-r-shiny-and-plotly-6a6abf66091d
# Adapted by Kevin Bairos-Novak
# 
# Data from:
# Johns Hopkins University Center for System Science and Engineering (JHU CCSE)

library(tidyverse)
library(plotly)
library(shiny)

# root data link for github repo from: https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data
baseURL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series"

# Function to load the individual datasets for cases confirmed, deaths, recoveries
loadData = function(fileName, columnName) {
	
	if(!file.exists(fileName)) { # looks if file exists, if not, continue...
		
		# Use the base URL and the data file's name to read in the .csv file
		data = read.csv(file.path(baseURL, fileName), check.names=FALSE, stringsAsFactors=FALSE) %>%
			select(-Lat, -Long) %>%  # delete Lat, Long (not needed)
			pivot_longer(-(1:2), names_to="date", values_to=columnName) %>% # change to a long-format dataset
			mutate(
				date=as.Date(date, format="%d/%m/%y"), # format the dates
				`Country/Region`=if_else(`Country/Region` == "", "?", `Country/Region`) # set country/region to '?' if no user input
			)
		save(data, file=fileName)  
		
	} else { # If the dataset does already exist...
		load(file=fileName)
	}
	return(data)
}

# Load confirmed, death, recovered case data sources, 
# combine together using inner_joins:
allData = 
	loadData(
		"time_series_covid19_confirmed_global.csv", "CumConfirmed") %>%
	inner_join(loadData(
		"time_series_covid19_deaths_global.csv", "CumDeaths")) %>%
	inner_join(loadData(
		"time_series_covid19_recovered_global.csv","CumRecovered"))

## Begin defining the main server function 

function(input, output, session) {
	# Server takes inputs such as the country/region we want in a list object 
	# called 'input', and returns our final plots in a list object called 'output'
	
	# Since this is the server.R file, we don't define any name for this function
	
	# Create a list of all countries:
	countries = sort(unique(allData$`Country/Region`))
	
	# Update the selection input in the UI to the list of all countries, 
	# default set to Australia:
	updateSelectInput(session, "country", choices=countries, selected="Australia")
	
	# Use a reactive to re-define data to be plotted each time the country 
	# selection is changed:
	data = reactive({
		d = allData %>%
			filter(`Country/Region` == input$country)
		d2 = d %>%
			group_by(date) %>% 
			summarise_if(is.numeric, sum, na.rm=TRUE) %>%
			mutate(
				dateStr = format(date, format="%b %d, %Y"),    # Jan 20, 2020
				
				## Calculate new cases using lag() function within mutate():
				NewConfirmed = CumConfirmed - lag(CumConfirmed, default=0),
				NewRecovered = CumRecovered - lag(CumRecovered, default=0),
				NewDeaths    = CumDeaths -    lag(CumDeaths, default=0)  )
		d2 # return final object to be saved as 'data'
	})
	## Note: reactives produce functions, not objects, so when we want 
	## the subset data, we just have to call it as 'data()' with the parentheses
	
	# Create more reactives for the titles of each plot, with the country name:
	cumulative_plot_title = reactive({paste("Cumulative cases for",input$country)})
	new_plot_title = reactive({paste("New cases for",input$country)})
	
	# Define the first plot output object, for new cases through time:
	output$dailyMetrics =
		# use renderPlotly with previous reactive arguments 
		# to have updated data, plot titles:
		renderPlotly({ 
			
			# Load in our previously-defined reactives:
			data = data() # load up the attached aus_data.RData file to test out this part, if you like!
			plot_title = new_plot_title() # to test, set plot_title="New cases for Australia"
			
			## Subset, elongate the data for 'New' cases:
			data2 <- data %>%
				select(date, dateStr, starts_with("New")) %>%
				pivot_longer(starts_with("New"), names_to="type", values_to="n") %>%
				mutate(type = str_remove(type, "New")) %>%
				filter(n>0)
			
			## Define a plot using ggplot2:
			ggplt <- data2 %>%
				ggplot(aes(x=date, y=n, group=type, color = type)) +
				theme_light() +
				# Include dashed-line smoothers (personal preference):
				geom_smooth(color="black", method="loess", formula="y~x",
							size=0.5, alpha=0.8, linetype="dashed", se=FALSE) +
				geom_line(size=1) +
				# scale_y_log10() +
				scale_color_discrete(name="") +
				labs(x="Month", y = "New number of cases", 
					 title = plot_title)
			
			## Convert the plot to a plot_ly R plot,
			# designate number of cases, date as hover-over options
			pltly = ggplotly(ggplt, tooltip = c("n", "date"))
			
			pltly # return final object to save
		})
	
	# Now, do same thing but for cumulative cases 
	# (also use log10 scale on y):
	output$cumulatedMetrics =
		# use renderPlotly with previous reactive arguments 
		# to have updated data, plot titles:
		renderPlotly({ 
			
			# Load in our previously-defined reactives:
			data = data() # load up the attached aus_data.RData file to test out this part, if you like!
			plot_title = cumulative_plot_title() # to test, set plot_title="New cases for Australia"
			
			## Subset, elongate the data for 'Cumulative' cases:
			data2 <- data %>%
				select(date, dateStr, starts_with("Cum")) %>%
				pivot_longer(starts_with("Cum"), names_to="type", values_to="n") %>%
				mutate(type = str_remove(type, "Cum")) %>%
				filter(n>0)
			
			## Define a plot using ggplot2:
			ggplt <- data2 %>%
				ggplot(aes(x=date, y=n, group=type, color = type)) +
				theme_light() +
				# Include dashed-line smoothers (personal preference):
				geom_smooth(color="black", method="loess", formula="y~x",
							size=0.5, alpha=0.8, linetype="dashed", se=FALSE) +
				geom_line(size=1) +
				scale_y_log10() + # uncommented from above for log10 scale!
				scale_color_discrete(name="") +
				labs(x="Month", y = "Cumulative number of cases", 
					 title = plot_title)
			
			## Convert the plot to a plot_ly R plot
			pltly = ggplotly(ggplt, tooltip = c("n", "date"))
			
			pltly # return final object to save
		})
	
	
	# output$dailyMetrics = New_cases_plot()
	# output$cumulatedMetrics = renderPlot({plot(x=seq(1:10), y=seq(1:10))})
}
