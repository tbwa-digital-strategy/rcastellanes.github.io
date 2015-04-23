library(readr)
library(plyr)
library(dplyr)

age_calc <- function(dob, enddate=Sys.Date()){
  # assumes born on current day, given no other information about birthday
  dob <- as.Date(dob, "%Y")
  start <- as.POSIXlt(dob)
  end <- as.POSIXlt(enddate)
  years <- end$year - start$year
  result <- ifelse((end$mon < start$mon) | ((end$mon == start$mon) & (end$mday < start$mday)),
                   years - 1, years)    
  return(result)
}

setwd("~/github/usingCrosslet/data/raw")
lookupfile <- "~/github/usingCrosslet/data/neighborhoodlookup.csv"

#file_list <- list.files(pattern="*.csv")
#for (file in file_list){
#  # if the merged dataset doesn't exist, create it
#  if (!exists("dataset")){
#    dataset <- read_csv(file, col_names=TRUE, na="NA", col_types="iccicddicdd__cc")
#  }
# if the merged dataset does exist, append to it
#  if (exists("dataset")){
#    temp_dataset <-read_csv(file, col_names=TRUE, na="NA", col_types="iccicddicdd__cc")
#    dataset<-rbind(dataset, temp_dataset)
#   rm(temp_dataset)
#  }
#}

#temp = list.files(pattern="*.csv")
#for (i in 1:length(temp)) assign(temp[i], read_csv(temp[i], col_names=TRUE, na="NA", escape_backslash=TRUE, col_types="icc_cdd_cdd__cc"))


dataset <- read_csv("c201307_citibike_tripdata.csv", col_names=TRUE, na="NA", col_types="icc_cdd_cdd__cc")

lookup.table <- read_csv(lookupfile, col_names=TRUE)

#df2 <- as.data.frame(sapply(dataset,gsub,pattern="\\\\N",replacement=NA))
final.filtered <- dataset
# remove all rows with missing info 
#row.has.na <- apply(df2, 1, function(x){any(is.na(x))})
#sum(row.has.na)
#final.filtered <- dataset[!row.has.na,]

names <- gsub(names(final.filtered),pattern=" ",replacement = "")
names(final.filtered) <- names

# Add stop/start station neighborhood names 
names(lookup.table) <- c("startstationname","neighborhood.start")
final.filtered <- join(final.filtered, lookup.table, by='startstationname')

names(lookup.table) <- c("endstationname","neighborhood.end")
final.filtered <- join(final.filtered, lookup.table, by='endstationname')


# Group by gender (Zero=unknown; 1=male; 2=female)
final.filtered$gender <- gsub(final.filtered$gender, pattern="0", replacement = NA)
final.filtered$gender <- gsub(final.filtered$gender, pattern="1", replacement = "m")
final.filtered$gender <- gsub(final.filtered$gender, pattern="2", replacement = "f")

# To group by multiple columns, use these steps: 
# Columns you want to group by
grp_cols <- c("neighborhood.start","gender")
dots <- lapply(grp_cols, as.symbol)
gender.count <- final.filtered %>%
  group_by_(.dots=dots) %>%
  summarise(n = n()) 

row.has.na <- apply(gender.count, 1, function(x){any(is.na(x))})
#sum(row.has.na)
gender.count <- gender.count[!row.has.na,]

neighborhood <- unique(gender.count$neighborhood.start)
female <- gender.count$n[gender.count$gender == "f"]
male <- gender.count$n[gender.count$gender == "m"]
ratio <- male/female
newdf <- data.frame(neighborhood, ratio, stringsAsFactors=FALSE)




# Weekend vs Weekday
final.filtered <- transform(final.filtered, day=ifelse(as.POSIXlt(starttime)$wday > 1 & as.POSIXlt(starttime)$wday < 6, "weekday", "weekend"))
#final.filtered <- transform(final.filtered, day.drop.off=ifelse(as.POSIXlt(stoptime)$wday > 1 & as.POSIXlt(starttime)$wday < 6, "weekday", "weekend"))

grp_cols <- c("neighborhood.start","day")
dots <- lapply(grp_cols, as.symbol)
zSTART <- final.filtered %>%
  group_by_(.dots=dots) %>%
  summarise(nleave = n()) 

neighborhood <- unique(zSTART$neighborhood.start)
weekday.start <- zSTART$nleave[zSTART$day == "weekday"]
weekend.start <- zSTART$nleave[zSTART$day == "weekend"]
start <- data.frame(neighborhood, weekday.start, weekend.start, stringsAsFactors=FALSE)

grp_cols <- c("neighborhood.end","day")
dots <- lapply(grp_cols, as.symbol)
zEND <- final.filtered %>%
  group_by_(.dots=dots) %>%
  summarise(narrive = n())  
neighborhood <- unique(zEND$neighborhood.end)
weekday.end <- zEND$narrive[zEND$day == "weekday"]
weekend.end <- zEND$narrive[zEND$day == "weekend"]
end <- data.frame(neighborhood, weekday.end, weekend.end, stringsAsFactors=FALSE)

joined <- join(start, end, by="neighborhood")
joined$weekdayflow <- joined$weekday.end - joined$weekday.start
joined$weekendflow <- joined$weekend.end - joined$weekend.start

row.has.na <- apply(joined, 1, function(x){any(is.na(x))})
joined <- joined[!row.has.na,]
newdf2 <- select(joined, neighborhood, weekdayflow, weekendflow)


# Finding morning, afternoon, night
timeofday <- function(time) {
  time <- as.POSIXlt(time)
  hour <- time$h
  if(hour <= 11) {
    result <- "morning"
  }
  if(hour > 11 & hour <= 19) {
    result <- "afternoon"
  }
  if(hour > 19) {
    result <- "evening"
  }  
  return(result)
}

final.filtered$timeStart <- sapply(final.filtered$starttime, timeofday)
final.filtered$timeEnd <- sapply(final.filtered$stoptime, timeofday)

grp_cols <- c("neighborhood.start","timeStart")
dots <- lapply(grp_cols, as.symbol)
timeStart <- final.filtered %>%
  group_by_(.dots=dots) %>%
  summarise(nleave = n())

neighborhood <- unique(timeStart$neighborhood.start)
morning.start <- timeStart$nleave[timeStart$time == "morning"]
afternoon.start <- timeStart$nleave[timeStart$time == "afternoon"]
evening.start <- timeStart$nleave[timeStart$time == "evening"]
start <- data.frame(neighborhood, morning.start, afternoon.start, evening.start, stringsAsFactors=FALSE)

grp_cols <- c("neighborhood.end","timeEnd")
dots <- lapply(grp_cols, as.symbol)
timeEnd <- final.filtered %>%
  group_by_(.dots=dots) %>%
  summarise(narrive = n())  

neighborhood <- unique(timeEnd$neighborhood.end)
morning.end <- timeEnd$narrive[timeEnd$time == "morning"]
afternoon.end <- timeEnd$narrive[timeEnd$time == "afternoon"]
evening.end <- timeEnd$narrive[timeEnd$time == "evening"]
end <- data.frame(neighborhood, morning.end, afternoon.end, evening.end, stringsAsFactors=FALSE)

joined <- join(start, end, by="neighborhood")
joined$morning <- joined$morning.end - joined$morning.start
joined$evening <- joined$evening.end - joined$evening.start
joined$afternoon <- joined$afternoon.end - joined$afternoon.start


row.has.na <- apply(joined, 1, function(x){any(is.na(x))})
joined <- joined[!row.has.na,]
newdf3 <- select(joined, neighborhood, morning, afternoon, evening)


# Ages
# final.filtered$usr_age <- sapply(final.filtered$birthyear, age_calc)




finaldf <- join(newdf, newdf2, by="neighborhood")
finaldf <- join(finaldf, newdf3, by="neighborhood")
names(finaldf) <- c("neighborhood", "gender_ratio", "weekday", "weekend" , "morning", "afternoon", "evening")

write.csv(finaldf, file = "../data.csv",row.names=FALSE,quote=FALSE)


