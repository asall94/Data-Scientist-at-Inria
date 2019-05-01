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
  #source('/data/datasets/abdoulaye/scripts/gc.R')
  source('/data/datasets/abdoulaye/scripts/functions&packages.R')
  
  site=args[1]
  input_file = paste("/data/datasets/abdoulaye/scripts/detection_active/",site,".csv",sep="")
  data_site=read.csv(input_file, sep=",", dec=".")#[,1:59]# quote="\"",
  
  #Put date and time into timestamp
  data_site$timestamp = as.numeric(as.POSIXct(data_site$starttime))
  print("done0")
  
  data_site=data_site %>% filter(timestamp >= 1526860800 & timestamp<=1534204799)# Ensure that all data points are taken from 21/05/2018 00:00:00 to 13/08/2018 23:59:59 (12 weeks)
  data_site=data_site %>% filter(plt<=300000)# Ensure that all plt are less than 5mn
  
  print(length(unique(data_site$timestamp)))
  print(length(data_site$timestamp))
  
  # Create the graphs
  xmin=min(data_site$timestamp)
  xmax=max(data_site$timestamp)
  ymin=min(data_site$plt)
  ymax=max(data_site$plt)
  
  png(paste('/data/datasets/abdoulaye/scripts/detection_active/',site,'_timeseries.png',sep=""))
  print(ggplot(data_site, aes(x=timestamp, y=plt/1000)) + coord_cartesian(xlim=c(xmin,xmax),ylim = c(ymin/1000,ymax/1000)) + 
          geom_point(size=0.25) + ggtitle(paste("Timeseries of",data_site$siteid[5])) + xlab("Timestamp in seconds (s)") + 
          ylab("plt values in seconds (s)"))
  #zm(type = "Xlib", rp = NULL)
  dev.off()
  print("done1")
  
  kept_data_site = data_site
  
  #21600 = 6 hours into ms
  for(i in seq(xmin, xmax, by = 21600)){ 
    
    data_site=kept_data_site %>% filter(timestamp >= i & timestamp<=i+21600)
    
    print(paste("Total length of the page:", data_site$siteid[5], sep=""))
    length(data_site[,1])
    
    q25=quantile(data_site$plt, c(.25, .50, .75))[1]
    q75=quantile(data_site$plt, c(.25, .50, .75))[3]
    distance = 1.5 * (q75 - q25)
    lower = q25 - distance
    upper = q75 + distance
    
    print("quantiles")
    quantile(data_site$plt, c(.25, .50, .75))
    print("--------------------------")
    print("lower and upper")
    c(lower,upper)
    
    data_low=filter(data_site,data_site$plt < lower)
    print("taille totale data_low")
    print(length(data_low[,1])) #IS ALWAYS EQUAL TO ZERO
    
    data_high=filter(data_site,data_site$plt >  upper)
    print("taille totale data_high")
    print(length(data_high[,1]))
    
    #save with append
    output_file = paste("/data/datasets/abdoulaye/scripts/detection_active/",site,"_outliers.csv",sep="")
    write.table(data_low, output_file, quote=T, dec=".", sep=",", row.names=F, col.names=F, append=TRUE) #NO OBSERVATIONS WILL BE INSERTED
    write.table(data_high, output_file, quote=T, dec=".", sep=",", row.names=F, col.names=F, append=TRUE)
  }
  
  output_file = paste("/data/datasets/abdoulaye/scripts/detection_active/",site,"_outliers.csv",sep="")
  outliers_site=read.csv(output_file, sep=",", quote="\"", dec=".", row.names=NULL)
  print(length(outliers_site[,1]))
  
  diff = sqldf("select * from kept_data_site except select * from outliers_site")
  print(length(diff[,1]))
  
  diff$type="not an outlier"
  outliers_site$type="outlier"
  result=rbind(diff,outliers_site)
  print(length(result[,1]))
  
  resultfile=paste("/data/datasets/abdoulaye/scripts/detection_active/",site,"_with_labels.csv",sep="")
  write.table(result, resultfile, quote=T, dec=".", sep=",", row.names=F)
  print("done4")
  
  png(paste('/data/datasets/abdoulaye/scripts/detection_active/',site,'_timeseries_colored.png',sep=""))
  print(ggplot(result, aes(x=timestamp, y=plt/1000, colour=type)) + coord_cartesian(xlim=c(xmin,xmax),ylim = c(ymin/1000,ymax/1000)) +
          geom_point(size=0.25) + ggtitle(paste("Timeseries of",result$siteid[5],"\n  from 21/05/2018 to 13/08/2018")) + 
          xlab("Timestamp in seconds (s)") + ylab("plt values in seconds (s)"))
  dev.off()
  
}