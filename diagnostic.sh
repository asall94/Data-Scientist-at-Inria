#!/bin/bash


psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='leroymerlinit-www.leroymerlin.it') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site1_4weeks.csv' (format csv,header);
EOF
echo "done1"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='adidas_china-plp') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site2_4weeks.csv' (format csv,header);
EOF
echo "done2"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='movitex-www.daxon.fr') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site3_4weeks.csv' (format csv,header);
EOF
echo "done3"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='adidas_china-pdp') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site4_4weeks.csv' (format csv,header);
EOF
echo "done4"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,plt from valid_passive where siteid='afibel_rum-www.afibel.com') to '/data/datasets/abdoulaye/scripts/diagnostic/plt/site5_4weeks.csv' (format csv,header);
EOF
echo "done5"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='electrodepot-www.electrodepot.fr') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site6_4weeks.csv' (format csv,header);
EOF
echo "done6"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='ubaldi-www.ubaldi.com') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site7_4weeks.csv' (format csv,header);
EOF
echo "done7"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='adidas_china-homePage') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site8_4weeks.csv' (format csv,header);
EOF
echo "done8"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,tti from valid_passive where siteid='aircaraibe-www.aircaraibes.com') to '/data/datasets/abdoulaye/scripts/diagnostic/tti/site9_4weeks.csv' (format csv,header);
EOF
echo "done9"

psql postgresql://postgres:B3tterNET_IPL@10.16.0.4:5432/postgres << EOF
	\copy (select siteid,starttime,country,date,hour,osname,osversion,browsername,device,provider,day,timezone,plt from valid_passive where siteid='maybellineapac-Home') to '/data/datasets/abdoulaye/scripts/diagnostic/plt/site10_4weeks.csv' (format csv,header);
EOF
echo "done10"


Rscript /data/datasets/abdoulaye/scripts/diagnostic.R tti


