library(tidyverse)
library(lubridate)
library(fs)
library(wesanderson) 

translate <- function(x) {
  sapply(x, function(chn_name) {
    if (str_detect(chn_name, "澳门")) {
      eng_name <- "Macau"
    } else if (str_detect(chn_name, "台湾")) {
      eng_name <- "Taiwan"
    } else if (str_detect(chn_name, "上海")) {
      eng_name <- "Shanghai"
    } else if (str_detect(chn_name, "云南")) {
      eng_name <- "Yunnan"
    } else if (str_detect(chn_name, "内蒙古")) {
      eng_name <- "Inner Mongolia"
    } else if (str_detect(chn_name, "北京")) {
      eng_name <- "Beijing"
    } else if (str_detect(chn_name, "台湾")) {
      eng_name <- "Taiwan"
    } else if (str_detect(chn_name, "吉林")) {
      eng_name <- "Jilin"
    } else if (str_detect(chn_name, "四川")) {
      eng_name <- "Sichuan"
    } else if (str_detect(chn_name, "天津")) {
      eng_name <- "Tianjin"
    } else if (str_detect(chn_name, "宁夏")) {
      eng_name <- "Ningxia"
    } else if (str_detect(chn_name, "安徽")) {
      eng_name <- "Anhui"
    } else if (str_detect(chn_name, "山东")) {
      eng_name <- "Shandong"
    } else if (str_detect(chn_name, "山西")) {
      eng_name <- "Shanxi"
    } else if (str_detect(chn_name, "广东")) {
      eng_name <- "Guangdong"
    } else if (str_detect(chn_name, "广西")) {
      eng_name <- "Guangxi"
    } else if (str_detect(chn_name, "新疆")) {
      eng_name <- "Xinjiang"
    } else if (str_detect(chn_name, "江苏")) {
      eng_name <- "Jiangsu"
    } else if (str_detect(chn_name, "江西")) {
      eng_name <- "Jiangxi"
    } else if (str_detect(chn_name, "河北")) {
      eng_name <- "Hebei"
    } else if (str_detect(chn_name, "河南")) {
      eng_name <- "Henan"
    } else if (str_detect(chn_name, "浙江")) {
      eng_name <- "Zhejiang"
    } else if (str_detect(chn_name, "海南")) {
      eng_name <- "Hainan"
    } else if (str_detect(chn_name, "湖北")) {
      eng_name <- "Hubei"
    } else if (str_detect(chn_name, "湖南")) {
      eng_name <- "Hunan"
    } else if (str_detect(chn_name, "甘肃")) {
      eng_name <- "Gansu"
    } else if (str_detect(chn_name, "福建")) {
      eng_name <- "Fujian"
    } else if (str_detect(chn_name, "西藏")) {
      eng_name <- "Tibet"
    } else if (str_detect(chn_name, "贵州")) {
      eng_name <- "Guizhou"
    } else if (str_detect(chn_name, "辽宁")) {
      eng_name <- "Liaoning"
    } else if (str_detect(chn_name, "重庆")) {
      eng_name <- "Chongqing"
    } else if (str_detect(chn_name, "陕西")) {
      eng_name <- "Shanxi"
    } else if (str_detect(chn_name, "青海")) {
      eng_name <- "Qinghai"
    } else if (str_detect(chn_name, "香港")) {
      eng_name <- "Hong Kong"
    } else if (str_detect(chn_name, "黑龙江")) {
      eng_name <- "Heilongjiang"
    } else {
      eng_name <- chn_name # don't translate if no correspondence
    }
    return(eng_name)
  })
}


ncov_tbl <- read_csv("ncov_tbl.csv", col_names = T, cols(
  `Province/State` = col_character(),
  `Country/Region` = col_character(),
  Lat = col_double(),
  Long = col_double(),
  Date = col_date(format = "%F"),
  Case = col_character(),
  Count = col_integer())
)

chn_prov <- chn_map %>% 
  count(NAME) %>%
  mutate(NAME_ENG = translate(NAME)) # translate function is vectorized