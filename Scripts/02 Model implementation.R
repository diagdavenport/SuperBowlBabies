

library(boot)

final.data$Quarter <- ceiling(final.data$Month.Code/3)

final.data <- subset(final.data, select = c(City, Year, Quarter, Births)) 

final.data <-aggregate(final.data, by=list(final.data$City, final.data$Year, final.data$Quarter), 
                       FUN=mean, na.rm=TRUE)
#final.data$YQ <- paste(final.data$Year , final.data$Quarter, sep = "-")

final.data$End.of.quarter <- as.Date(paste( final.data$Quarter*3, 1, final.data$Year, sep = "/"), "%m/%d/%Y")

names(final.data)[names(final.data) == 'Group.1'] <- 'City'

#ggplot(data=final.data, aes(x=End.of.quarter, y=Births, color = City)) + geom_line() + facet_wrap(~City, scales="free", ncol = 2) # spectral content

pdf("Year over year differences.pdf")

for ( place in unique(final.data$City)) { 

    # Generate the YoY differences by quarter
      ## Starting with New England
    
    vector.of.Q1to3.changes <- rep("NA", 8)
    vector.of.Q4.changes <- rep("NA", 8)
    
    for (year in 2008:2015){
      
      vector.of.Q1to3.changes[year-2007] <- (sum(subset(final.data, City == place & Group.2 == year & Quarter != 4, select =  Births)) - 
                                            sum(subset(final.data, City == place & Group.2 == year-1 & Quarter != 4, select =  Births)) ) /
                                            sum(subset(final.data, City == place & Group.2 == year-1 & Quarter != 4, select =  Births))
      
    }

    for (year in 2008:2015){
      
      vector.of.Q4.changes[year-2007] <- (subset(final.data, City == place & Group.2 == year & Quarter == 4, select =  Births) - 
                                       subset(final.data, City == place & Group.2 == year-1 & Quarter == 4, select =  Births) ) /
                                       subset(final.data, City == place & Group.2 == year-1 & Quarter == 4, select =  Births)
      
    }

    #plot(c(2008:2015), vector.of.Q1to3.changes, pch = "1", main = place)
    #points(c(2008:2015), vector.of.Q4.changes, pch = "4")
    
    brth.change.gap <- unlist(vector.of.Q4.changes ) - as.numeric(unlist(vector.of.Q1to3.changes))
    
    plot(c(2008:2015), brth.change.gap , main = place)
    
    if (place == "Pittsburgh") abline( v = c(2008.8, 2010.8), col = c("green", "red"), lty = 2)
    else if (place == "Baltimore") abline( v = 2012.8, col = "green", lty = 2)
    else if (place == "NY") abline( v = c(2007.8, 2011.8), col = "green", lty = 2)
    else if (place == "Green Bay") abline( v = c(2010.8), col = c("green"), lty = 2)
    else if (place == "Denver") abline( v = c(2013.8), col = c("red"), lty = 2)
    else if (place == "Seattle") abline( v = c(2013.8, 2014.8), col = c("green", "red"), lty = 2)
    else if (place == "Arizona") abline( v = c(2008.8), col = c("red"), lty = 2)
    else if (place == "Indianapolis") abline( v = c(2009.8), col = c("red"), lty = 2)
    else if (place == "New England") abline( v = c(2007.8, 2011.8, 2014.8), col = c("red", "red", "green"), lty = 2)
    else if (place == "New Orleans") abline( v = c(2009.8), col = c("green"), lty = 2)
    else if (place == "San Francisco") abline( v = c(2012.8), col = c("red"), lty = 2)
}

dev.off()

### now munge into a regression-ready format 

full.reg.data <- data.frame(changes = double(), participated = logical(), won = logical(), row.num = integer()) # initialize for later

econ.act <- read.csv("Raw/Economic activity.csv", header = T, stringsAsFactors = FALSE)
econ.act$GDP..2009.dollars. <- as.numeric(econ.act$GDP..2009.dollars.)
econ.act$row.num <- 1:8

# capture the q4 changes in one vector

for ( place in unique(final.data$City)) { 
  
  # Generate the YoY differences by quarter
  vector.of.Q4.changes <- rep("NA", 8)

  for (year in 2008:2015){
    
    vector.of.Q4.changes[year-2007] <- (subset(final.data, City == place & Group.2 == year & Quarter == 4, select =  Births) - 
                                          subset(final.data, City == place & Group.2 == year-1 & Quarter == 4, select =  Births) ) /
      subset(final.data, City == place & Group.2 == year-1 & Quarter == 4, select =  Births)
    
  }
  
  part.vec <- rep(FALSE, 8)
  w.vec <- rep(FALSE, 8)
  
  if (place == "Pittsburgh") {
    part.vec[c(2009-2007, 2011 - 2007)] <- TRUE
    w.vec[2009-2007] <- TRUE
  }
  else if (place == "Baltimore"){
    part.vec[c(2013-2007)] <- TRUE
    w.vec[2013-2007] <- TRUE
  }
  else if (place == "NY"){
    part.vec[c(2008-2007, 2012 - 2007)] <- TRUE
    w.vec[c(2008-2007, 2012 - 2007)] <- TRUE
  }
  else if (place == "Green Bay") {
    part.vec[c(2011-2007)] <- TRUE
    w.vec[c(2011-2007)] <- TRUE
  }
  else if (place == "Denver") {
    part.vec[c(2014-2007)] <- TRUE
  }
  else if (place == "Seattle") {
    part.vec[c(2014-2007, 2015 - 2007)] <- TRUE
    w.vec[c(2014-2007)] <- TRUE
  }
  else if (place == "Arizona"){
    part.vec[c(2009-2007)] <- TRUE
  }
  else if (place == "Indianapolis"){
    part.vec[c(2010-2007)] <- TRUE
  }
  else if (place == "New England"){
    part.vec[c(2008-2007, 2012 - 2007, 2015 - 2007)] <- TRUE
    w.vec[2015 - 2007] <- TRUE
  }
  else if (place == "New Orleans"){
    part.vec[c(2010-2007)] <- TRUE
    w.vec[c(2010-2007)] <- TRUE
  }
  else if (place == "San Francisco"){ 
    part.vec[c(2013-2007)] <- TRUE
  }
  else BREAK
  
  current.reg.data <- data.frame(row.num = 1:8 , changes = unlist(vector.of.Q4.changes) , participated = part.vec, won = w.vec)
  current.reg.data <- merge(current.reg.data, econ.act, by = "row.num")
  
  # finally, append to full data set
  full.reg.data <- rbind(full.reg.data, current.reg.data)
  
  
}

results.glm1 <- glm(changes ~ participated + won + poly(GDP..2009.dollars. , 1) , data = full.reg.data)
results.glm3 <- glm(changes ~ participated + won + poly(GDP..2009.dollars. , 3) , data = full.reg.data)

summary(results)

#Sensitivity
set.seed(1914)
cv.glm(full.reg.data, glmfit = results.glm3)$delta

#vs.

cv.glm(full.reg.data, glmfit = results.glm1)$delta