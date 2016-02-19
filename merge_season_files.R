library(reshape2)
library(dplyr)
library(lubridate)

file.dir <- "C:/path to downloaded files/"

#------------------------------------------------------------------------------------------------------------
#   Dump season files downloaded from football-data.co.uk into one directory and set the path above   
#
#   Script will create two new csv files in the specified directory
#   1. merged-seasons.csv  -  Untransformed season files merged into one file with data columns aligned properly 
#   2. merged-transformed.csv  -  transforms the merged data so that columns are identical for home and away teams
#------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------
#   Load and merge season files
#----------------------------------------------------------------------------------------

filelist <- list.files(file.dir)

for (i in 1:length(filelist)){
  
    if (grepl("^.*.csv",filelist[i])
        & filelist[i]!="merged-seasons.csv"
        & filelist[i]!="merged-transformed.csv") {
      
      imported.original <- read.csv(paste(file.dir,filelist[i],sep=""), stringsAsFactors = FALSE)
  
      imported.long <- melt(imported.original,id.vars = c("Div","Date","HomeTeam","AwayTeam"))
      
      imported.long$Date <- as.Date(imported.long$Date,"%d/%m/%y")
  
      if (i==1) {
        merged.df <- imported.long      
      } else {
        merged.df <- rbind(merged.df,imported.long)
      }
    }
}

merged.wide <- dcast(merged.df, Div + Date + HomeTeam + AwayTeam ~ variable)

#Create a season variable
merged.wide$season <- ifelse(month(merged.wide$Date) < 8,paste(year(merged.wide$Date)-1,year(merged.wide$Date),sep="/"),paste(year(merged.wide$Date),year(merged.wide$Date)+1,sep="/"))

#Save a merged seasons file
write.csv(merged.wide,paste(file.dir,"merged-seasons.csv",sep=""), row.names = FALSE)

#----------------------------------------------------------------------------------------
#   Split home and away to create team summary data
#----------------------------------------------------------------------------------------

homedata <- merged.wide[,c("Div","Date","season","HomeTeam","AwayTeam","FTR","HTR",
                                   "FTHG","HTHG","HS","HST","HF","HC","HY","HR",
                                   "FTAG","HTAG","AS","AST","AF","AC","AY","AR"
)]

awaydata <- merged.wide[,c("Div","Date","season","AwayTeam","HomeTeam","FTR","HTR",
                                   "FTAG","HTAG","AS","AST","AF","AC","AY","AR",
                                   "FTHG","HTHG","HS","HST","HF","HC","HY","HR"
)]

homedata$Home_Away <- 'H'
awaydata$Home_Away <- 'A'

#----------------------------------------------------------------------------------------
#   Rename home and away variables to generic names ("Home Shots" to "Shots" etc.)
#----------------------------------------------------------------------------------------

homedata <- rename(homedata,
                   Team = HomeTeam,
                   Opposition = AwayTeam,
                   Full_Time_Result=FTR,
                   Half_Time_Result=HTR,
                   Full_Time_Goals_For=FTHG,
                   Half_Time_Goals_For=HTHG,
                   Shots=HS,
                   Shots_On_Target=HST,
                   Fouls_Committed=HF,
                   Corners=HC,
                   Yellow_Cards=HY,
                   Red_Cards=HR,
                   Full_Time_Goals_Against=FTAG,
                   Half_Time_Goals_Against=HTAG,
                   Shots_Against=AS,
                   Shots_On_Target_Against=AST,
                   Fouls_Drawn=AF,
                   Corners_Against=AC,
                   Yellow_Cards_Opposition=AY,
                   Red_Cards_Opposition=AR
)

awaydata <- rename(awaydata,
                   Team = AwayTeam,
                   Opposition = HomeTeam,
                   Full_Time_Result=FTR,
                   Half_Time_Result=HTR,
                   Full_Time_Goals_For=FTAG,
                   Half_Time_Goals_For=HTAG,
                   Shots=AS,
                   Shots_On_Target=AST,
                   Fouls_Committed=AF,
                   Corners=AC,
                   Yellow_Cards=AY,
                   Red_Cards=AR,
                   Full_Time_Goals_Against=FTHG,
                   Half_Time_Goals_Against=HTHG,
                   Shots_Against=HS,
                   Shots_On_Target_Against=HST,
                   Fouls_Drawn=HF,
                   Corners_Against=HC,
                   Yellow_Cards_Opposition=HY,
                   Red_Cards_Opposition=HR
)

#Merge home and away data
merged.home_away <- rbind(homedata, awaydata)

#Create a points variable
merged.home_away$points <- 0
merged.home_away$points <- ifelse(merged.home_away$Home_Away==merged.home_away$Full_Time_Result,3,merged.home_away$points)
merged.home_away$points <- ifelse(merged.home_away$Full_Time_Result=="D",1,merged.home_away$points)

#Save transformed data
write.csv(merged.home_away,paste(file.dir,"merged-transformed.csv",sep=""), row.names = FALSE)
