options(scipen = 999)

# Librerias:
library(tidyverse)
library(jsonlite)
library(sf)
library(cartogram)
library(leaflet)

# Datos:
covid <- read_csv("https://covid.ourworldindata.org/data/owid-covid-data.csv")
# Descargado de: https://international.ipums.org/international/gis.shtml
mapa <- read_sf("IPUMSI_world_release2020/world_countries_2020.shp")
unique(vacunas$location)[unique(vacunas$location) %in% mapa$CNTRY_NAME]
unique(vacunas$location)[!(unique(vacunas$location) %in% mapa$CNTRY_NAME)]

# Procesamiento:
vacunas <- covid %>%
  select(iso_code,continent, location, date, total_vaccinations) %>%
  filter(!is.na(`total_vaccinations`)) %>%
  group_by(iso_code, location) %>%
  filter(date == max(date)) %>%
  filter(!is.na(continent))

mapa_vacunas <- mapa %>%
  filter(CNTRY_NAME %in% unique(vacunas$location)[unique(vacunas$location) %in% mapa$CNTRY_NAME]) %>%
  left_join(vacunas, by = c("CNTRY_NAME" = "location"))

# Hacemos la proyeccion dorling:
dorling <- cartogram_dorling(st_transform(mapa_vacunas,
                                          2163), "total_vaccinations") %>%
  mutate(X = st_coordinates(st_centroid(.))[,1],
         Y = st_coordinates(st_centroid(.))[,2])

dorling$area <- st_area(dorling)
dorling$pp_area <- 100*dorling$area/sum(dorling$area)
sort(dorling$pp_area)
attributes(dorling$pp_area) <- NULL

dorling <- dorling %>%
  mutate(label = case_when(pp_area > 10 ~ str_c(CNTRY_NAME,
                                                "\n", prettyNum(round(total_vaccinations/1e6, 1), big.mark = ","),
                                                "M"),
                           between(pp_area, 2, 10) ~ str_c(CNTRY_NAME,
                                                           "\n", prettyNum(round(total_vaccinations/1e6, 1), big.mark = ","),
                                                           "M"),
                           between(pp_area, 0.5, 2) ~ iso_code,
                           pp_area < 0.5 ~ "")) %>%
  mutate(label_size = case_when(pp_area > 10 ~ 3,
                                between(pp_area, 0.8, 10) ~ 1.5,
                                pp_area <= 0.8 ~ 1.5))

dorling %>%
  ggplot(aes(fill = continent)) +
  geom_sf() +
  geom_text(aes(x = X, y = Y, label = label),
            color = "white",
            size = dorling$label_size,
            family = "Montserrat") +
  theme_bw() +
  labs(fill = "Continentes", x = NULL, y = NULL,
       title = "¿Cuantas vacunas han sido aplicadas en el mundo,\n hasta el día de hoy? ",
       subtitle = "Cartograma de Dorling de las vacunas aplicadas en el mundo hasta abril del 2022. ",
       caption = "Fuente: Base de datos de COVID-19 de OWID\n@JuvenalCamposF - IG: juvenalcampos.dataviz"
       ) +
  scale_fill_manual(values = c(wesanderson::wes_palettes$Cavalcanti1[-5],
                               wesanderson::wes_palettes$BottleRocket1)) +
  theme(legend.position = "bottom",
        panel.border = element_blank(),
        plot.title = element_text(size= 20, family = "Montserrat", face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size= 10, family = "Montserrat", hjust = 0.5),
        plot.title.position = "plot",
        axis.text = element_blank()) +
  guides(fill = guide_legend(title.position = "top",
                             title.hjust = 0.5,
                             ncol = 6))

# Guardamos gráfica
ggsave("mapa_vacunas.png",
       device = "png",
       height = 8,
       width = 8)
