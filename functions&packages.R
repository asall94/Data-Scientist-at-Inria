#install.packages('tidyverse', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('ggplot2', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('GGally', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('sqldf', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('dplyr', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('data.table', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('feather', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('urltools', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('bit64', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('bit', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('dmm', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('nadiv', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('pls', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('robustbase', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('zoom', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('devtools', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('Matrix', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('rattle', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('RPostgreSQL', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('caret', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('doParallel', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('tree', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('party', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('sp', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('ROSE', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")
#install.packages('ROCR', lib='~/R/libs', dependencies=TRUE, repos="http://cran.rstudio.org")

#---------------------------------------------------------------------------------------------------------------

filtering2 <- function(main_data, column) {
  main_data$OBS_RATE=-1 #Adding a column to main_data
  listing = unique(na.omit(column)) #List the elements of the column without repeating them
  n = NROW(column)
  for(i in 1:length(listing)) {  #To compute the rate of the count of each component in the column
    temp_data_frame = filter(main_data, column == listing[i])       #data_tti$OBS_BROWSERNAME = data_tti[["OBS_BROWSERNAME"]]
    m = NROW(temp_data_frame)
    rate = m/n
    main_data$OBS_RATE[column==listing[i]] = rate
  }
  main_data = filter(main_data, main_data$OBS_RATE >= 0.03)
  print("This column has been filtered")
  print(nrow(main_data))
  return(main_data)
}

filtering <- function(main_data, column) {
  main_data$OBS_RATE=-1 
  listing = unique(na.omit(column)) 
  n = length(column)
  for(i in 1:length(listing)) {  
    temp_data_frame = filter(main_data, column == listing[i])
    m = NROW(temp_data_frame)
    rate = m/n
    main_data$OBS_RATE[column==listing[i]] = rate
  }
  main_data = filter(main_data, main_data$OBS_RATE >= 0.03) #Will only consider lines where OBS_RATE>=0.03
  print("This column has been filtered")
  print(nrow(main_data))
  return(main_data)
}

local = function (main_data, column) {
  n = length(column)
  for(i in 1:n) {
    b=as.POSIXct(column[i], tz="Europe/Paris") #TZ here points to server TZ of time zone
    attr(b, "tzone") <- main_data$`Europe/Andorra`[i]
    main_data$OBS_LOCALSTARTTIME[i]=format(b,format = "%d-%m-%Y %H:%M:%S")
  }
  return(main_data)
}

local2 = function (main_data, column) {
  n = length(column)
  main_data$column2="Europe/Paris"
  b=as.POSIXct(column, tz=main_data$column2)
  attr(b, "tzone") <- main_data$`Europe/Andorra`
  main_data$OBS_LOCALSTARTTIME=format(b,format = "%d-%m-%Y %H:%M:%S")
  return(main_data)
}