# server.R

shinyServer(function(input, output) {

  dotted <- reactive({
    if( eval(parse(text=input$dotted)) )
      "p"
    else
      "l"
  })
  
  range <- reactive({
    as.numeric(input$range)
  })
  
  color <- reactive({
    switch(input$color,
           "1" = "red",
           "2" = "blue",
           "3" = "green")
    
  })
  
  output$plotfunc <- renderPlot(height = 400, {
    
    x <- 1:10
    f <- as.function(alist(x=, eval(parse(text=input$func))))
    n <- (range()[2] - range()[1])*100
    curve(f, from = range()[1], to=range()[2], n=n, type=dotted(), col=color())
    
  })

  }
)