library(plyr)
library(ggplot2)

# Read in the raw data
raw.data <- read.table("Raw/Births by county and month with man edits.txt"
           , header = TRUE)

# Subset to the vars of interest AND Subset to the counties that participated in the Super Bowl
  ## First need to recode some counties that are within the range for the home team
  
  edit.data <- raw.data
  
  edit.data$County <- revalue(edit.data$County, c("Marion County, IN" = "Indianapolis")) # Colts
  
  edit.data$County <- revalue(edit.data$County, c("Bronx County, NY" = "NY"
                                          ,"Kings County, NY" = "NY"
                                          ,"New York County, NY" = "NY"
                                          ,"Queens County, NY" = "NY"
                                          ,"Richmond County, NY" = "NY")) # Giants
  
  edit.data$County <- revalue(edit.data$County, c("Allegheny County, PA" = "Pittsburgh")) # Steelers
  
  edit.data$County <- revalue(edit.data$County, c("Orleans Parish, LA" = "New Orleans")) # Saints
  
  edit.data$County <- revalue(edit.data$County, c("Brown County, WI" = "Green Bay")) # Packers
  
  edit.data$County <- revalue(edit.data$County, c("Baltimore city, MD" = "Baltimore"
                                          ,"Baltimore County, MD" = "Baltimore" )) # Ravens
  
  edit.data$County <- revalue(edit.data$County, c("King County, WA" = "Seattle")) # Seahawks
  
  edit.data$County <- revalue(edit.data$County, c("Suffolk County, MA" = "New England"
                                                  ,"Norfolk County, MA" = "New England")) # Patriots
  
  edit.data$County <- revalue(edit.data$County, c("Maricopa County, AZ" = "Arizona")) # Cardinals
  
  edit.data$County <- revalue(edit.data$County, c("San Francisco County, CA" = "San Francisco")) # 49ers
  
  edit.data$County <- revalue(edit.data$County, c("Denver County, CO" = "Denver")) # Broncos
  
  edit.data$recoded <- regexpr(',', edit.data$County) == -1
  
  final.data <- subset(edit.data, recoded == TRUE , select = c(County, Year, Month.Code, Births)) 
  
  ## Aggregate the data with the recoding
  
  final.data <-aggregate(final.data, by=list(final.data$County, final.data$Year, final.data$Month.Code), 
                         FUN=mean, na.rm=TRUE)
  
  final.data$Date <- as.Date(paste( final.data$Month.Code, 1, final.data$Year, sep = "/"), "%m/%d/%Y")
  
  names(final.data)[names(final.data) == 'Group.1'] <- 'City'
  
  #final.data <- subset(final.data, select = c(City, Births, Date))
  
  # Flag the time period when the counties participated in the Super Bowl
  
  # Flag the time period 9 months after the counties participated in the Super Bowl
  
  # Quick visualization
  ggplot(data=final.data, aes(x=Date, y=Births, color = City)) + geom_line() + facet_wrap(~City, scales="free", ncol = 2) # spectral content
  ggplot(data=final.data, aes(x=Month.Code, y=Births, color = City, group = Year)) + geom_line() + facet_wrap(~City, scales="free", ncol = 2) # change in spectral content
  
  # Normalize data for differences in days
  final.data$NormBirths <- 1
  final.data$NormBirths[final.data$Month.Code %in% c(9, 4, 6, 11)] <- final.data$Births[final.data$Month.Code %in% c(9, 4, 6, 11)]/30
  final.data$NormBirths[final.data$Month.Code %in% c(1,3,5, 7, 8, 10, 12)] <- final.data$Births[final.data$Month.Code %in% c(1,3,5, 7, 8, 10, 12)]/31
  final.data$NormBirths[final.data$Month.Code == 2] <- final.data$Births[final.data$Month.Code== 2]/28
  
ggplot(data=final.data, aes(x=Date, y=NormBirths, color = City)) + geom_line() + facet_wrap(~City, scales="free", ncol = 2) # spectral content
