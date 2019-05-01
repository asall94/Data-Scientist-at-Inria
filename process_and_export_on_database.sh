#!/bin/bash

argum=$1

if [ -z $argum ]; then
	echo "Give the week on which you will work into argument. Possible answers: week1 or week2 or week3 ..."
else
	echo "Data processing for data from $argum"
	Rscript /data/datasets/abdoulaye/scripts/data_preprocessing.R $argum
	echo "active and passive data of $argum saved"

	echo "cleaning R memory"
	Rscript /data/datasets/abdoulaye/scripts/gc.R
	echo "DONE"

	echo "Exporting passive data"
	python2.7 /data/datasets/abdoulaye/scripts/python/import_passive.py /data/datasets/abdoulaye/scripts/preprocessed\ data/$argum/passive_data.csv > /data/datasets/abdoulaye/scripts/preprocessed\ data/$argum.log
	python2.7 /data/datasets/abdoulaye/scripts/python/count_lines.py /data/datasets/abdoulaye/scripts/preprocessed\ data/$argum/passive_data.csv > /data/datasets/abdoulaye/scripts/preprocessed\ data/error_log$argum.log # Counting lines
	echo "Exporting active data"
	python2.7 /data/datasets/abdoulaye/scripts/python/import_active.py /data/datasets/abdoulaye/scripts/preprocessed\ data/$argum/active_data.csv

fi


#Example to run the code: /data/datasets/abdoulaye/scripts/process_and_export_on_database.sh week1
