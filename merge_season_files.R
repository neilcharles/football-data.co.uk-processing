library(reshape2)

file.dir <- "C:/Users/Neil/Documents/Football Stats/football-data.co.uk/Downloaded/"

filelist <- list.files(file.dir)

for (i in 1:length(filelist)){
    imported.original <- read.csv(paste(file.dir,filelist[i],sep=""), stringsAsFactors = FALSE)

    imported.long <- melt(imported.original,id.vars = c("Div","Date","HomeTeam","AwayTeam"))
    
    imported.long$Date <- as.Date(imported.long$Date,"%d/%m/%y")

    if (i==1) {
      merged.df <- imported.long      
    } else {
      merged.df <- rbind(merged.df,imported.long)
  }
}

imported.wide <- dcast(merged.df, Div + Date + HomeTeam + AwayTeam ~ variable)

write.csv(imported.wide,paste(file.dir,"merged.csv",sep=""), row.names = FALSE)
