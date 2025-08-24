# secciones

library(tidyverse)

bd <- read_csv("bd_secciones_20220406.csv") %>%
  select(cve_edo, nom_ent, cve_distrito, nom_mun_ine, cve_seccion, lista_nominal_casilla) %>%
  filter(cve_edo == 17)

saveRDS(bd, "secciones_morelos.rds")

# Morelos tiene 914 secciones
