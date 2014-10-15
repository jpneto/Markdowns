# ui.R

shinyUI(fluidPage(
  titlePanel("Draw Function Example"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      # allowing mathJax 
      tags$head( tags$script(src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML-full", type = 'text/javascript'),
                 tags$script( "MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});", type='text/x-mathjax-config')
      ),
      
      helpText("App for drawing a user-defined function"),
      
      textInput("func", 
                label = "Define function expression", 
                value = "x^2*sin(x^2)"),
    
      radioButtons("color", 
                   label = "Choose Line Color",
                   choices = list("red" = 1, 
                                  "blue" = 2,
                                  "green" = 3),
                   selected = 1),
  
      checkboxInput("dotted", label = "Dotted?", value = FALSE),
  
      sliderInput("range", 
                  label="Define Range",
                  min = -50, max = 50, 
                  value = c(0, 10))
      
    ),
    
    mainPanel(
      plotOutput("plotfunc")
    )
  )
))