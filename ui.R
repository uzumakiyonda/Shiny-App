#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # Application title
    titlePanel(em("Book Analysis from Goodreads")),
    h4("This app is constituted by two tabs. The first one (\"Query\") 
       provides a table with multiple information about a given book.
       The second tab (\"Book characteristics\") shows a plot where each 
       point represents a book, allowing for the user to compare multiple
       works visually."),
    h4("To get started, you can insert a title and/or an author. It is 
       not necessary to insert the complete name, partial matching is 
       also viable. Then, click the \"Search!\" button and the data 
       will show up."),
    h4("It you want to see the whole list, leave the spaces empty and 
       click the button."),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput('title','Insert title of interest (if any).'),
            textInput('author','Insert author of interest (if any).'),
            actionButton("search", "Search!")
        #    sliderInput("bins",
        #                "Number of bins:",
        #                min = 1,
        #                max = 50,
        #                value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Query", tableOutput("table")), 
                tabPanel("Book characteristics", plotlyOutput("distPlot",  width = "100%",height="150%"))
            )
        ),
        
    )
))
