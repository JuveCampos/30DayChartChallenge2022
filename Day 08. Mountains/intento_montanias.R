# Librerias
library(tidyverse)
library(rvest)

url <- "https://peakvisor.com/adm/mexico.html"
code <- read_html(url)

code %>%
  html_nodes(".sidebar") %>%
  html_nodes("a")
  # html_nodes(".hs-card") %>%
  html_text()




