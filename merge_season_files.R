library(reshape2)

file.dir <- "C:/path to downloaded files/"

filelist <- list.files(file.dir)

for (i in 1:length(filelist)){
  
    if (filelist[i]!="merged.csv"){
      
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

write.csv(merged.wide,paste(file.dir,"merged.csv",sep=""), row.names = FALSE)
