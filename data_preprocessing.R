require(tibble,lib='~/R/libs',warn.conflicts = FALSE)
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

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be given", call.=FALSE)
} else {
  
  week=args[1] #week = the current week of data acquisition
  zone = read_csv("/data/datasets/abdoulaye/scripts/timezone.csv", quote="\"")
  zone = zone[!duplicated(zone$AD), ]
  
  ##  Active measurements---------------------------------------------------------------------------------------------------------------
  dir_path = paste("/data/datasets/abdoulaye/datasets/active/",week,sep="")
  files = list.files(path = dir_path, pattern="bottlenet_export_mesures_*", full.names = T)

  print(length(files))
  acti = do.call(rbind, lapply(files, read.csv, stringsAsFactors = FALSE, sep=";"))
  
  names(acti)[1] <- "OBS_IDTRACKER" #OBS_IDTRACKER = IDCONTRAT
  names(acti)[3] <- "OBS_IDMISSION" #OBS_ID = IDMISSION
  names(acti)[6] <- "OBS_MEASURETYPE"
  names(acti)[7] <- "OBS_MEASUREVALUE"
  
  active_data = separate(data = acti, col = NOMCONTRAT, into = c("OBS_URL", "OBS_BROWSERNAME","OBS_PROVIDER"), sep = "_")
  
  active_data$OBS_PROVIDER[active_data$OBS_URL=='Fake Bottlenet Website'] = active_data$OBS_BROWSERNAME[active_data$OBS_URL=='Fake Bottlenet Website']
  active_data$OBS_BROWSERNAME[active_data$OBS_URL=='Fake Bottlenet Website'] = NA
  
  active_data$OBS_MEASUREMENT = 'Active'  #Adding a column
  active_data$OBS_OSNAME = 'Windows'
  active_data$OBS_OSVERSION = 'Nt 8.0'
  active_data$OBS_DEVICE = 'Pc'
  active_data$OBS_COUNTRY = 'FR'
  
  active_data = active_data %>% mutate(OBS_STARTTIME_0=DATEESSAI)
  
  active_data = separate(data = active_data, col = DATEESSAI, into = c("OBS_DATE", "OBS_TIME"), sep = " ")
  active_data = separate(data = active_data, col = OBS_TIME, into = c("OBS_HOUR", "OBS_MIN", "OBS_SEC"), sep = ":")
  
  a = strptime(as.character(active_data$OBS_DATE), "%d/%m/%Y")  #From 2018/05/07 to 2018-05-07
  active_data$OBS_DAY = weekdays.Date(a)  #Adding a column = the day corresponding to the date
  
  active_data=merge(active_data,zone[,2:3], by.x = "OBS_COUNTRY", by.y = "AD")
  
  active_data$OBS_PAGE = domain(active_data$OBS_URL)
  
  names(active_data) <- gsub(x = names(active_data),
                             pattern = "\\.",
                             replacement = "_")
  names(active_data) <- gsub(x = names(active_data),
                             pattern = "/",
                             replacement = "_")
  
  refcols = c("OBS_IDTRACKER", "OBS_URL", "OBS_IDMISSION", "OBS_STARTTIME_0","OBS_MEASURETYPE","OBS_MEASUREVALUE")
  active_data = active_data[, c("OBS_IDTRACKER", "OBS_IDMISSION", "OBS_URL", "OBS_STARTTIME_0",
                                setdiff(names(active_data), refcols), "OBS_MEASURETYPE","OBS_MEASUREVALUE")]
  
  print(paste("max=",max(active_data$OBS_MEASUREVALUE),sep=""))
  
  file_path = paste("/data/datasets/abdoulaye/scripts/preprocessed\ data/",week,"/active_data.csv",sep="")
  write.table(active_data, file_path ,quote=F, dec=".", sep="\t", row.names = F)
  rm(acti,active_data)
  print("active data saved")
  
  
  ## Passive measurements---------------------------------------------------------------------------------------------------------------
  # Get the files names
  dir_path = paste("/data/datasets/abdoulaye/datasets/passive/",week,sep="")
  files = list.files(path = dir_path, pattern="*.csv$", full.names = T)
  print(length(files))
  p = do.call(rbind, lapply(files, read.csv, stringsAsFactors = FALSE,sep=","))
  print ("p loaded")
  
  print(is.data.table(p))

  p$OBS_OSNAME[p$OBS_OSNAME=='linux'] = 'Linux'
  p$OBS_BROWSERNAME[p$OBS_BROWSERNAME=='Spartan'] = 'Edge'
  
  for(i in 1:length(p)){
    p[[names(p)[i]]] <- gsub("  ","-",p[[names(p)[i]]]) #Will remove tabs present in the values of all features
  }
  print("done1")
  
  p = p %>% mutate(OBS_COUNTRY = LOCALISATION..country_code.., OBS_PROVIDER = OBS_ISP.1., OBS_STARTTIME_0=OBS_STARTTIME)
  print("done2")
  
  p=p %>% filter(OBS_OSNAME != "na" & OBS_BROWSERNAME != "na" & OBS_OSNAME != "Na" & OBS_BROWSERNAME != "Na")
  print("done3")
  
  p$OBS_OSNAME[p$OBS_OSNAME=='Mac'] = 'Mac os x'
  p$OBS_OSNAME[p$OBS_OSNAME=='Mac os x' & p$OBS_DEVICE=='Phone'] = 'iPhone Os'
  print("done4")
  
  p=merge(p,zone[,2:3], by.x = "OBS_COUNTRY", by.y = "AD")
  print("merging done")
  
  p$OBS_STARTTIME_0=gsub("cest",'',as.POSIXct(p$OBS_STARTTIME_0))
  print("done5")
  
  p = separate(data = p, col = OBS_STARTTIME, into = c("OBS_DATE", "OBS_TIME"), sep = " ")
  p = separate(data = p, col = OBS_TIME, into = c("OBS_HOUR", "OBS_MIN", "OBS_SEC"), sep = ":")
  print("done6")
  
  #Adding a column = the day corresponding to the date
  p$OBS_DAY = weekdays.Date(as.Date(p$OBS_DATE,'%Y-%m-%d'))
  print("done7")
  
  p$OBS_URL[p$OBS_URL=='Home'] = 'homepage'
  p$OBS_URL[p$OBS_URL=='Homepage'] = 'homepage'
  p$OBS_URL[p$OBS_URL=='homePage'] = 'homepage'
  p$OBS_URL[p$OBS_URL=='pdp'] = 'productdetails'
  p$OBS_URL[p$OBS_URL=='Category'] = 'categorysearchresult'
  p$OBS_URL[p$OBS_URL=='Others_M'] = 'Others'
  
  p$OBS_PAGE = domain(p$OBS_URL)
  p$OBS_MEASUREMENT = 'Passive'  #Adding a column
  p$OBS_STATE[(p$OBS_MEASURETYPE==2032 | p$OBS_MEASURETYPE==2034) & p$OBS_MEASUREVALUE<=300000] = 'valid'
  p$OBS_STATE[(p$OBS_MEASURETYPE!=2032 & p$OBS_MEASURETYPE!=2034) | p$OBS_MEASUREVALUE>300000] = 'non valid'
  
  gc(reset = TRUE)
  
  names(p) <- gsub(x = names(p),
                   pattern = "\\.",
                   replacement = "_")
  names(p) <- gsub(x = names(p),
                   pattern = "/",
                   replacement = "_")
  
  refcols = c("OBS_IDTRACKER", "OBS_SESSION", "OBS_STARTTIME_0", "OBS_URL","OBS_MEASURETYPE","OBS_MEASUREVALUE")
  p = p[, c("OBS_IDTRACKER", "OBS_SESSION", "OBS_STARTTIME_0", "OBS_URL",
            setdiff(names(p), refcols), "OBS_MEASURETYPE","OBS_MEASUREVALUE")]
  
  file_path = paste("/data/datasets/abdoulaye/scripts/preprocessed\ data/",week,"/passive_data.csv",sep="")
  write.table(p, file_path ,quote=T, dec=".", sep="\t", row.names = F, fileEncoding="UTF-8")
  print("passive data saved")
  
}