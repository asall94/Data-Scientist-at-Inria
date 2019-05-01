args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("Exactly one argument must be given: site1, site2,etc.", call.=FALSE)
} else {
  
  require(withr,lib='~/R/libs',warn.conflicts = FALSE)
  require(ggplot2,lib='~/R/libs',warn.conflicts = FALSE)
  require(StanHeaders,lib='~/R/libs',warn.conflicts = FALSE)
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
  require(MASS,lib='~/R/libs',warn.conflicts = FALSE, quietly=TRUE)
  require(tibble,lib='~/R/libs',warn.conflicts = FALSE)
  require(lattice,lib='~/R/libs',warn.conflicts = FALSE)
  require(foreach,lib='~/R/libs',warn.conflicts = FALSE)
  require(iterators,lib='~/R/libs',warn.conflicts = FALSE)
  require(mvtnorm,lib='~/R/libs',warn.conflicts = FALSE)
  require(modeltools,lib='~/R/libs',warn.conflicts = FALSE)
  require(zoo,lib='~/R/libs',warn.conflicts = FALSE)
  require(httr,lib='~/R/libs',warn.conflicts = FALSE)
  require(curl,lib='~/R/libs',warn.conflicts = FALSE)
  require(rstan,lib='~/R/libs',warn.conflicts = FALSE)
  rstan_options(auto_write = TRUE)
  require(e1071,lib='~/R/libs',warn.conflicts = FALSE)
  require(gplots,lib='~/R/libs',warn.conflicts = FALSE)
  
  
  library(devtools,lib='~/R/libs',warn.conflicts = FALSE)
  library(rethinking,lib='~/R/libs',warn.conflicts = FALSE)
  library(sandwich,lib='~/R/libs',warn.conflicts = FALSE)
  library(strucchange,lib='~/R/libs',warn.conflicts = FALSE)
  library(RSQLite,lib='~/R/libs',warn.conflicts = FALSE)
  library(proto,lib='~/R/libs',warn.conflicts = FALSE)
  library(gsubfn,lib='~/R/libs',warn.conflicts = FALSE)
  library(sqldf,lib='~/R/libs',warn.conflicts = FALSE)
  library(withr,lib='~/R/libs',warn.conflicts = FALSE)
  library(labeling,lib='~/R/libs',warn.conflicts = FALSE)
  library(tidyverse,lib='~/R/libs',warn.conflicts = FALSE)
  library(GGally,lib='~/R/libs',warn.conflicts = FALSE)
  library(data.table,lib='~/R/libs',warn.conflicts = FALSE)
  library(digest,lib='~/R/libs',warn.conflicts = FALSE)
  library(urltools,lib='~/R/libs',warn.conflicts = FALSE)
  library(bindrcpp,lib='~/R/libs',warn.conflicts = FALSE)
  library(pls,lib='~/R/libs',warn.conflicts = FALSE)
  library(robustbase,lib='~/R/libs',warn.conflicts = FALSE)
  library(nadiv,lib='~/R/libs',warn.conflicts = FALSE)
  library(dmm,lib='~/R/libs',warn.conflicts = FALSE)
  library(caret,lib='~/R/libs',warn.conflicts = FALSE)
  library(doParallel,lib='~/R/libs',warn.conflicts = FALSE)
  library(tree,lib='~/R/libs',warn.conflicts = FALSE)
  library(party,lib='~/R/libs',warn.conflicts = FALSE)
  library(ROSE,lib='~/R/libs',warn.conflicts = FALSE)
  library(ROCR,lib='~/R/libs',warn.conflicts = FALSE)
  
  set.seed(123)
  
  #---------------------------------------------------------------------------------------------------------------
  getwd()
  #source('/data/datasets/abdoulaye/scripts/gc.R')
  source('/data/datasets/abdoulaye/scripts/functions&packages.R')
  
  site=args[1] 
  ourfile=paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_merged.csv",sep="")
  our_data = read.csv(ourfile, sep=",", row.names=NULL, stringsAsFactors = FALSE)
  
  our_data$location[our_data$location=="same country than the company"] = "France"
  our_data$location[our_data$location=="different country from the company"] = "Other"
  our_data$browsername[our_data$browsername!="Edge" & our_data$browsername!="Chrome" & our_data$browsername!="Firefox" &
                         our_data$browsername!="Safari"] = "Others"
  our_data$provider[our_data$provider!="Orange" & our_data$provider!="SFR SA" & our_data$provider!="Free SAS" &
                      our_data$provider!="Bouygues Telecom SA"] = "Others"
  our_data = our_data %>% mutate(time = hour, type2 = hour)
  our_data$time[our_data$hour>=0 & our_data$hour<6] = 'night'
  our_data$time[our_data$hour>=6 & our_data$hour<12] = 'morning'
  our_data$time[our_data$hour>=12 & our_data$hour<18] = 'afternoon'
  our_data$time[our_data$hour>=18] = 'evening'
  our_data$type2[our_data$type=="not an outlier"] = 0
  our_data$type2[our_data$type=="outlier"] = 1
  
  our_data=our_data[,c("location","browsername","week","device","osname","time","provider","type")]
  our_data[] <- lapply(our_data, factor)
  our_data = droplevels.data.frame(our_data) #Will remove unnecessary levels
  our_data = na.omit(our_data)
  
  grouped_country=count(our_data, type)
  write_csv(grouped_country,paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_grouped_type.csv",sep=""))  

  #The train set will be the equivalent of 80% of the whole dataset
  n = length(our_data[,1]) 
  ind = createDataPartition(our_data$type, p=0.80, list=FALSE)
  trainSet = our_data[ind,]
  testSet = our_data[-ind,]

  ourfile=paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_train_unbalanced.csv",sep="")
  write.csv(trainSet, ourfile, row.names=F)
  ourfile=paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_validation.csv",sep="")
  write.csv(testSet, ourfile, row.names=F)
  grouped_type=count(trainSet, type)
  write_csv(grouped_type,paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_grouped_type_in_trainSet.csv",sep=""))

  ###Undersampling
  n = min(sum(trainSet$type=="outlier",na.rm=TRUE),sum(trainSet$type=="not an outlier",na.rm=TRUE))
  under = ovun.sample(type~., data=trainSet, method = "under", N = 2*n)$data  #trainSet = trainSet %>% group_by(type) %>% sample_n(size = min(grouped_type$n)) #90590
  ourfile=paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_train.csv",sep="")
  write.csv(under, ourfile, row.names=F)

  gc(reset = TRUE) #Garbage collection before Machine Learning

  ###BUILDING THE MODEL
  ControlParameters = trainControl(method="cv", number=10, 
                                   savePredictions=TRUE,
                                   classProbs=FALSE, 
                                   ctree_control(minsplit = 500L))

  parameterGrid = expand.grid(
    .mincriterion=c(0.6,0.7,0.8,0.9,0.95,0.65,0.99), 
    #All features with p value <0.05 will be taken for 0.95
    .maxdepth=c(2,3,4,5,6)) 
  
  print("The training is launched")
  model = train(type~., data=under, method="ctree2", 
                trControl=ControlParameters,
                tuneGrid=parameterGrid)

  #Saving the tree
  pdf(paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_tree.pdf",sep=""), width = 30, height = 20)
  plot(model$finalModel, type=c("extended","simple"))
  dev.off()
  print("plot_train_done")
  print("Model")
  print(model)
  
  #Accuracy on the training set
  print('Accuracy on the training set')
  tab = table(predict(model),under$type) #TRAINING ON THE BALANCED TRAINSET
  print(tab)
  accuracy = sum(diag(tab))/sum(tab)
  error = 1 - accuracy
  precision = tab[2,2]/sum(tab[2,])
  recall = tab[2,2]/sum(tab[,2])
  print(paste("Accuracy =", accuracy))
  print(paste("Precision =",precision))
  print(paste("Recall =",recall))
  
  
  ###Testing
  testSet = na.omit(testSet)
  n = min(sum(testSet$type=="outlier",na.rm=TRUE),sum(testSet$type=="not an outlier",na.rm=TRUE))
  testSet2 = ovun.sample(type~., data=testSet, method = "under", N = 2*n)$data
  predicted <- predict(model, testSet2, type="prob")
  
  #Saving predictions
  ourfile=paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_predicted.csv",sep="")
  write.csv(predicted, ourfile, row.names=F)
  
  #Accuracy on the validation set
  print('Accuracy on the validation set')
  tab = confusionMatrix(predict(model, testSet2),testSet2$type, positive = 'outlier')
  print(tab)
  
  tab = table(predict(model, testSet2),testSet2$type)
  # print(tab)
  accuracy = sum(diag(tab))/sum(tab)
  error = 1 - accuracy
  precision = tab[2,2]/sum(tab[2,])
  recall = tab[2,2]/sum(tab[,2])
  print(paste("Accuracy =", accuracy))
  print(paste("Precision =",precision))
  print(paste("Recall =",recall)) #Recall or sensitivity

  
  ###ROC Curve creation
  predicted = prediction(predicted[,2], testSet2$type)
  roc = performance(predicted,"tpr", "fpr")
  
  pdf(paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_ROC_Curve.pdf",sep=""))#, width = 30, height = 20)
  plot(roc, main="ROC Curve", color="blue",
       xlab="False positive rate (1- Specificity)",
       ylab = "True positive rate (Sensitivity)")
  abline(a=0, b=1, lty=2) 
  auc = performance(predicted, "auc")    #Area Under Curve
  auc = unlist(slot(auc, "y.values"))
  legend(0.6, 0.2, auc, title="AUC", cex=1)
  dev.off()
  
  print(paste("AUC =",auc))
  
  
  ###Save the model to disk
  ourfile = paste("/data/datasets/abdoulaye/scripts/diagnostic/plt/",site,"_final_model.rds",sep="")
  saveRDS(model$finalModel, ourfile)
  
}