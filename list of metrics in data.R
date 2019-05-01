require(ggplot2,lib='~/R/libs',warn.conflicts = FALSE)
require(tibble,lib='~/R/libs',warn.conflicts = FALSE)
require(tidyr,lib='~/R/libs',warn.conflicts = FALSE)
require(readr,lib='~/R/libs',warn.conflicts = FALSE)
require(purrr,lib='~/R/libs',warn.conflicts = FALSE)
require(dplyr,lib='~/R/libs',warn.conflicts = FALSE)
require(crayon,lib='~/R/libs',warn.conflicts = FALSE)
require(rstudioapi,lib='~/R/libs',warn.conflicts = FALSE)
require(cli,lib='~/R/libs',warn.conflicts = FALSE)
require(stringr,lib='~/R/libs',warn.conflicts = FALSE)
require(forcats,lib='~/R/libs',warn.conflicts = FALSE)

library(labeling,lib='~/R/libs',warn.conflicts = FALSE)
library(tidyverse,lib='~/R/libs',warn.conflicts = FALSE)
library(GGally,lib='~/R/libs',warn.conflicts = FALSE)
library(data.table,lib='~/R/libs',warn.conflicts = FALSE)
library(feather,lib='~/R/libs',warn.conflicts = FALSE)
library(digest,lib='~/R/libs',warn.conflicts = FALSE)

#---------------------------------------------------------------------------------------------------------------
source('/data/datasets/abdoulaye/scripts/functions&packages.R')

data = read.csv("/data/datasets/abdoulaye/datasets/RumDataRef.csv", sep=",")
passive=fread("/data/datasets/abdoulaye/scripts/preprocessed\ data/passive_data.csv")

pass1 = subset(passive, select=c("OBS_MEASURETYPE"))
rm(passive)
pass1=filtering(pass1, pass1$OBS_MEASURETYPE) #See functions&packages.R

metrics = unique(pass1$OBS_MEASURETYPE)
present_metrics = filter(data, is.element(data$OBS_MEASURETYPE, metrics))

write.csv(present_metrics,"/data/datasets/abdoulaye/scripts/present_metrics.csv")

pdf('/data/datasets/abdoulaye/scripts/present_metrics.pdf')
ggplot(present_metrics, aes(x = OBS_MEASURETYPE)) + geom_bar()
dev.off()