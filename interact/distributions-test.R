library(shiny)
# runApp("distributions")
runApp("drawfunc")


# 1. include this library
# library(shinyapps)

# 2. authorize to deploy applications to your ShinyApps.io account
# shinyapps::setAccountInfo( name='jpneto', 
#                            token='DCD87535310E1757A8D2EF64FDC33642', 
#                            secret='yrXFwtrML0Q5YkcGSxguTJswSZWmTJvLxfbhiqpw')

# 3. To deploy your application, go to the folder where the app is, open ui.R and then 
# use the deployApp command from the shinyapps packages.
# check https://github.com/rstudio/shinyapps/blob/master/guide/guide.md
#   > shinyapps::deployApp()
# 
# 4. To terminate an application use 
#   > shinyapps::terminateApp("app-name")