# server.R

shinyServer(function(input, output) {

  theta1 <- reactive({
    as.double(input$theta1)
  })
  
  theta2 <- reactive({
    as.double(input$theta2)
  })
  
  xs <- reactive({
    switch(input$distr,
           Gaussian = seq(theta1() - 3*theta2(), theta1() + 3*theta2(), len=101),
           Uniform  = seq(theta1(), theta2(), len=2),
           Poisson  = seq(1, 5*theta1()))
    
  })
  
  # choose selected distribution 
  ys <- reactive({
    switch(input$distr,
           Gaussian = dnorm(xs(), theta1(), theta2()),
           Uniform  = dunif(xs(), theta1(), theta2()),
           Poisson  = dpois(xs(), theta1()))
  })
  
  output$pdf <- renderPlot(height = 400, {
     
    plot(xs(), ys(), col="red", lwd=2, type="l", ylim=c(0,max(ys())))
     

  })
  
  output$help <- renderUI({
    withMathJax(
      switch(input$distr,
           Gaussian = "$\\theta_1$ is the center parameter and $\\theta_2 > 0$ is the standard deviation parameter",
           Uniform  = "$\\theta_1$ is the left limit and $\\theta_2>\\theta_1$ the right limit",
           Poisson  = "$\\theta_1>0$ is the $\\lambda$ parameter")
    )
  })

  }
)