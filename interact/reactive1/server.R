# server.R

shinyServer(function(input, output) {

     output$text1 <- renderText({ 
          "You have selected this"
     })

  }
)