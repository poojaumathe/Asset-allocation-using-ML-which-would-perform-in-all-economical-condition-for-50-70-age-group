library(tidyr)
library(dplyr)
library(lubridate)
##############################################################################
setwd("~/Desktop/stocks")
df <- lapply(dir(), read.csv)
setwd("~/Desktop")
df22 <- read.csv('risk_free_rate2.csv')

func <- function(x,y,w){
  df <- w
  df$Date <- as.POSIXct(as.character(df$Date), format =  "%m/%d/%y")
  df22$Date <- as.POSIXct(as.character(df22$Date), format =  "%m/%d/%y")
  df2 <- data.frame(df[c(x:y),])
  df_all <- merge(df2, df22, by = 'Date')
  end_date <- max(df_all$Date)
  start_date <- min(df_all$Date)
  end_price <- tail(df_all$price,1)
  start_price <- head(df_all$price,1)
  high <- max(df_all$price)
  low <- min(df_all$price)
  in_sum <- sum(df_all[, 'CPI_PCH'], na.rm = TRUE)
  nam = (unique(df_all$name))
  mean_rfr <- mean(df_all$FEDFUNDS)
  sd_ret <- sd(df_all$PCH, na.rm = TRUE)
  return_price = ((end_price - start_price)/ start_price) 
  #print(mean_rfr)
  #print(sd_ret)
  #print(return_price)
  sr = ((return_price * 100) - mean_rfr) / (sd_ret * 100)
  df3 <- data.frame(start_date = start_date, end_date = end_date, start_price = start_price, end_price = end_price,
                    Inflation_Change = (in_sum * 100), High = high, Low = low,Sharpe_ratio = sr, name = nam,
                    risk_free_rate = mean_rfr, Standard_Deviation = (sd_ret * 100))
  df3 <- mutate(df3, pct_change = ((end_price - start_price)/ start_price) * 100)
  df3 <- mutate(df3, year = format(df3$end_date, '%Y'))
  df3$start_date <- as.factor(df3$start_date)
  df3$end_date <- as.factor(df3$end_date)
  df44 <- select(df3, start_date, end_date, start_price, end_price,pct_change, everything())
  return(df44)
}

new_func <- function(x){
  rr <- seq(from=1, to=409, by=12)
  re_df <- data.frame()
  for(i in rr){
    w <- i + 12
    ww <- func(i,w,x)
    re_df <- rbind(re_df,ww)
    if(w == 421){
      new_df <- x[421:dim(x)[1],]
      len <- dim(x[421:dim(x)[1],])[1]
      w2 <- func(1,len,new_df)
      re_df <- rbind(re_df,w2)
    }
  }
  return(re_df)
}

data2  <- lapply(df, new_func)
data2[3]
###################
library(xlsx)
write.xlsx(data2[1], file="ga_data.xlsx",
           sheetName="AGG", append=FALSE)
write.xlsx(data2[2], file="ga_data.xlsx",
           sheetName="DJ", append=TRUE)
write.xlsx(data2[3], file="ga_data.xlsx",
           sheetName="FTSE", append=TRUE)
write.xlsx(data2[4], file="ga_data.xlsx",
           sheetName="Gold", append=TRUE)
write.xlsx(data2[5], file="ga_data.xlsx",
           sheetName="HS", append=TRUE)
write.xlsx(data2[6], file="ga_data.xlsx",
           sheetName="sp500", append=TRUE)
#######################
df_all <- do.call("rbind", data2)
write.csv(df_all, file = 'all_together_data.csv')
#df_all <- mutate(df_all, time = format(df_all$end_date, '%Y'))
####################################3
ranked <- df_all %>%
  group_by(time) %>%
  mutate(ranks = order(order(pct_change, name, decreasing=TRUE))) %>%
  arrange(time, ranks)
ranked <- mutate(ranked, pct_change2 = round(pct_change * 100,3))
df2 <- select(ranked, name, time, ranks, pct_change2)
write.csv(df2, 'ranked_stocks.csv')
######################################
setwd("~/Desktop")
df <- read.csv('risk_free_rate2.csv')
df$DATE <- as.POSIXct(as.character(df$DATE), format =  "%m/%d/%y")

rr_func <- function(x,y,w){
  df <- w
  df2 <- data.frame(df[c(x:y),])
  df2$year <- format(df2$DATE, '%Y')
  avg <- round(mean(df2$FEDFUNDS),3)
  df3 <- data.frame(Year = df2$year[1], risk_free_rate = avg)
  return(df3)
}

new_func2 <- function(x){
  rr <- seq(from=1, to=409, by=12)
  re_df <- data.frame()
  for(i in rr){
    w <- i + 12
    ww <- rr_func(i,w,x)
    re_df <- rbind(re_df,ww)
    if(w == 421){
      new_df <- x[421:dim(x)[1],]
      len <- dim(x[421:dim(x)[1],])[1]
      w2 <- rr_func(1,len,new_df)
      re_df <- rbind(re_df,w2)
    }
  }
  return(re_df)
}

rfr <- new_func2(df)
write.csv(rfr,'yearly_risk_free_rate.csv')
##############################################3


