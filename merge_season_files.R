library(reshape2)
library(dplyr)

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
  
    if (grepl("\\d\\d\\d\\d\\D\\d.csv",filelist[i])) {
      
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

#Save a merged seasons file
write.csv(merged.wide,paste(file.dir,"merged-seasons.csv",sep=""), row.names = FALSE)

#----------------------------------------------------------------------------------------
#   Split home and away to create team summary data
#----------------------------------------------------------------------------------------

homedata <- merged.wide[,c("Div","Date","HomeTeam","AwayTeam","FTR","HTR",
                                   "FTHG","HTHG","HS","HST","HF","HC","HY","HR",
                                   "FTAG","HTAG","AS","AST","AF","AC","AY","AR"
)]

awaydata <- merged.wide[,c("Div","Date","AwayTeam","HomeTeam","FTR","HTR",
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

#Save transformed data
write.csv(merged.home_away,paste(file.dir,"merged-transformed.csv",sep=""), row.names = FALSE)
