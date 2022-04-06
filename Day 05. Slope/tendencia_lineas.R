# Librerias:
library(tidyverse)
library(readxl)
library(leaflet)
library(broom)

# Datos:
archivos <- str_c("datos/", list.files("datos/"))
datos <- lapply(archivos, read_excel) %>%
  do.call(rbind, .)

datos_grafica <- datos %>%
  janitor::clean_names() %>%
  mutate(pctje_respecto_namo = 100*(almacenamiento_actual_hm3/namo_almacenamiento_hm3))

edos <- unique(datos_grafica$entidad_federativa)

valor_pendiente <- lapply(edos, function(e){
  # e = "Aguascalientes"
  regresion <- datos_grafica %>%
    filter(entidad_federativa == e) %>%
    mutate(ranking = rank(fecha, ties.method = "first")) %>%
    do(lm(formula = pctje_respecto_namo ~ ranking, data = .) %>% tidy()) %>%
    select(term, estimate)

  pendiente = regresion$estimate[2]

  tibble(entidad_federativa = e,
         pendiente = pendiente)

})

color_pendiente <- valor_pendiente %>%
  do.call(rbind,.) %>%
  print(n = Inf)

max(color_pendiente$pendiente)
min(color_pendiente$pendiente)

# pal_pendiente <- colorNumeric(palette = c("red", "gray", "blue"),
#                               )

datos_grafica %>%
  left_join(color_pendiente) %>%
  ggplot(aes(x = fecha,
             y = pctje_respecto_namo)) +
  geom_line(color = "gray50") +
  geom_smooth(aes(color = pendiente),
              method = "lm", se = F) +
  scale_color_gradientn(colors = c("red", "gray", "blue")) +
  scale_y_continuous(labels = scales::comma_format(suffix = "%")) +
  facet_wrap(~entidad_federativa) +
  labs(x = "Fecha", y = "Porcentaje respecto al NAMO",
       color = "Pendiente de regresión: ",
       title = "Tendencia del Porcentaje de almacenamiento de agua\nde las presas por entidad federativa",
       caption = "Datos provenientes del SINA-CONAGUA al primero de marzo del 2022.
       #30DayChartChallenge Día 5 - Pendientes.
       @JuvenalCamposF - IG: juvenalcampos.dataviz") +
  theme_bw() +
  theme(plot.background = element_rect(color = "black"),
        panel.background = element_rect(color = "black"),
        legend.position = "bottom",
        legend.text = element_text(family = "Poppins", size = 10, color = "#083D77"),
        legend.title = element_text(family = "Poppins", size = 10, face = "bold", color = "#083D77"),
        plot.title = element_text(color = "#083D77", size = 15, face = "bold", hjust = 0.5),
        plot.title.position = "plot",
        axis.title = element_text(family = "Poppins", size = 10, face = "bold", color = "#083D77"),
        strip.background = element_rect(fill = "#083D77"),
        strip.text = element_text(family = "Poppins", size = 10, face = "bold", color = "white"),
        panel.grid.minor = element_blank()) +
  guides(color = guide_colorbar(barwidth = 10,
                                barheight = 0.5,
                                title.position = "top",
                                title.hjust = 0.5))

ggsave("grafica_pendientes.png",
       device = "png",
       height = 10,
       width = 8)

