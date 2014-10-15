# ui.R

shinyUI(fluidPage(
  titlePanel("Distributions Example"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      # allowing mathJax 
      tags$head( tags$script(src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML-full", type = 'text/javascript'),
                 tags$script( "MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});", type='text/x-mathjax-config')
      ),
      
      helpText("App for testing several distributions by changing their parameters"),
      
      selectInput("distr", 
        label = "Choose a distribution to display",
        choices = c("Uniform", "Gaussian", "Poisson"),
        selected = "Uniform"),
      
      sliderInput("theta1", 
                  label = "$\\theta_1$",
                  min = -10, max = 10, value = 0, step = 1),
    
      sliderInput("theta2", 
                  #label = HTML("&theta;<sub>2</sub>"), # optional way to place greek letters
                  label = "$\\theta_2$",
                  min = -10, max = 10, value = 1, step = 1)
    ),
    
    mainPanel(
      uiOutput("help"),
      plotOutput("pdf")
    )
  )
))