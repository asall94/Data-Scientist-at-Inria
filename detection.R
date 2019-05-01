args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("Exactly one argument must be given: site1, site2,etc.", call.=FALSE)
} else {

  require(tidyr,lib='~/R/libs',warn.conflicts = FALSE)
  require(readr,lib='~/R/libs',warn.conflicts = FALSE)
  require(purrr,lib='~/R/libs',warn.conflicts = FALSE)
  require(dplyr,lib='~/R/libs',warn.conflicts = FALSE)
  require(crayon,lib='~/R/libs',warn.conflicts = FALSE)
  require(rstudioapi,lib='~/R/libs',warn.conflicts = FALSE)
  require(cli,lib='~/R/libs',warn.conflicts = FALSE)
  require(Matrix,lib='~/R/libs',warn.conflicts = FALSE)
  require(stringr,lib='~/R/libs',warn.conflicts = FALSE)
  require(forcats,lib='~/R/libs',warn.conflicts = FALSE)
  require(MASS,lib='~/R/libs',warn.conflicts = FALSE)
  require(tibble,lib='~/R/libs',warn.conflicts = FALSE)
  
  library(RSQLite,lib='~/R/libs',warn.conflicts = FALSE)
  library(proto,lib='~/R/libs',warn.conflicts = FALSE)
  library(gsubfn,lib='~/R/libs',warn.conflicts = FALSE)
  library(sqldf,lib='~/R/libs',warn.conflicts = FALSE)
  library(withr,lib='~/R/libs',warn.conflicts = FALSE)
  library(ggplot2,lib='~/R/libs',warn.conflicts = FALSE)
  library(labeling,lib='~/R/libs',warn.conflicts = FALSE)
  library(tidyverse,lib='~/R/libs',warn.conflicts = FALSE)
  library(GGally,lib='~/R/libs',warn.conflicts = FALSE)
  library(data.table,lib='~/R/libs',warn.conflicts = FALSE)
  library(feather,lib='~/R/libs',warn.conflicts = FALSE)
  library(digest,lib='~/R/libs',warn.conflicts = FALSE)
  library(urltools,lib='~/R/libs',warn.conflicts = FALSE)
  library(bindrcpp,lib='~/R/libs',warn.conflicts = FALSE)
  library(pls,lib='~/R/libs',warn.conflicts = FALSE)
  library(robustbase,lib='~/R/libs',warn.conflicts = FALSE)
  library(nadiv,lib='~/R/libs',warn.conflicts = FALSE)
  library(dmm,lib='~/R/libs',warn.conflicts = FALSE)
  
  #---------------------------------------------------------------------------------------------------------------
  getwd()
  source('/data/datasets/abdoulaye/scripts/functions&packages.R')
  
  site=args[1]
  input_file = paste("/data/datasets/abdoulaye/scripts/detection/",site,".csv",sep="")
  data_site=read.csv(input_file, sep=",", quote="\"", dec=".")#[,1:59]
  
  #Put date and time into timestamp
  data_site$timestamp = as.numeric(as.POSIXct(data_site$starttime))
  print("done0")
  
  data_site=data_site %>% filter(timestamp >= 1527033600 & timestamp<=1528844399)# Ensure that all data points are taken from 23/05/2018 00:00:00 to 12/06/2018 23:59:59
  data_site=data_site %>% filter(tti<=300000)# Ensure that all tti are less than 5mn
  
  print(length(unique(data_site$timestamp)))
  print(length(data_site$timestamp))
  
  # Create the graphs
  xmin=min(data_site$timestamp)
  xmax=max(data_site$timestamp)
  ymin=min(data_site$tti)
  ymax=max(data_site$tti)
  
  png(paste('/data/datasets/abdoulaye/scripts/detection/',site,'_timeseries.png',sep=""))
  print(ggplot(data_site, aes(x=timestamp, y=tti/60000)) + coord_cartesian(xlim=c(xmin,xmax),ylim = c(ymin/60000,ymax/60000)) + 
          geom_point(size=0.25) + ggtitle(paste("Timeseries of",data_site$siteid[5])) + xlab("Timestamp in seconds (s)") + 
          ylab("tti values in minutes (mn)"))
  dev.off()
  print("done1")
  

  kept_data_site = data_site
  #21600 = 6 hours into seconds

  xmin=min(data_site$timestamp)
  xmax=max(data_site$timestamp)
  ymin=min(data_site$tti)
  ymax=max(data_site$tti)
  
  #21600 = 6 hours into seconds
  for(i in seq(xmin, xmax, by = 21600)){ 

    data_site=kept_data_site %>% filter(timestamp >= i & timestamp<=i+21600)

    print(paste("Total length of the page:", data_site$siteid[5], sep=""))
    length(data_site[,1])

    q25=quantile(data_site$tti, c(.25, .50, .75))[1]
    q75=quantile(data_site$tti, c(.25, .50, .75))[3]
    distance = 1.5 * (q75 - q25)
    lower = q25 - distance
    upper = q75 + distance

    print("quantiles")
    quantile(data_site$tti, c(.25, .50, .75))
    print("--------------------------")
    print("lower and upper")
    c(lower,upper)

    data_low=filter(data_site,data_site$tti < lower)
    print("taille totale data_low")
    print(length(data_low[,1])) #IS ALWAYS EQUAL TO ZERO

    data_high=filter(data_site,data_site$tti >  upper)
    print("taille totale data_high")
    print(length(data_high[,1]))

    #save with append
    output_file = paste("/data/datasets/abdoulaye/scripts/detection/",site,"_outliers.csv",sep="")
    #write.table(data_low, output_file, quote=T, dec=".", sep=",", row.names=F, col.names=F, append=TRUE) #NO OBSERVATIONS WILL BE INSERTED
    write.table(data_high, output_file, quote=T, dec=".", sep=",", row.names=F, col.names=F, append=TRUE)
  }

  output_file = paste("/data/datasets/abdoulaye/scripts/detection/",site,"_outliers.csv",sep="")
  outliers_site=read.csv(output_file, sep=",", quote="\"", dec=".", row.names=NULL)
  print(length(outliers_site[,1]))
  
  diff = sqldf("select * from kept_data_site except select * from outliers_site")
  print(length(diff[,1]))
  
  diff$type="not an outlier"
  outliers_site$type="outlier"
  result=rbind(diff,outliers_site)
  print(length(result[,1]))
  
  resultfile=paste("/data/datasets/abdoulaye/scripts/detection/",site,"_with_labels.csv",sep="")
  write.table(result, resultfile, quote=T, dec=".", sep=",", row.names=F)

  png(paste('/data/datasets/abdoulaye/scripts/detection/',site,'_timeseries_colored.png',sep=""))
    print(ggplot(result, aes(x=timestamp, y=tti/1000, colour=type)) + coord_cartesian(xlim=c(xmin,xmax),ylim = c(ymin/1000,ymax/1000)) +
            geom_point(size=0.25) + ggtitle(paste("Timeseries of",result$siteid[5],"\n  from 23/05/2018 to 12/06/2018")) + xlab("Timestamp in seconds (s)") +
            ylab("tti values log scaled and in seconds (s)") + scale_y_log10())
  dev.off()
  
}