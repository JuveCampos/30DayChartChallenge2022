# Librerias
library(jsonlite)
library(httr)
library(png)
library(magick)
library(tidyverse)
library(ggimage)
library(ggExtra)

# Llamada a la API
no = 2

gen_data_pokemon <- function(no){

  call1 <- paste0("https://pokeapi.co/api/v2/",
                  "pokemon/", no, "/")

  # Realizamos la llamada (Obtenemos la respuesta)
  llamada <- GET(call1)
  llamada # Status 200: Todo ok.
  class(llamada) # Tipo Response

  # De la llamada, obtenemos la respuesta en formato JSON
  # Formato JSON: https://en.wikipedia.org/wiki/JSON
  get_data <- content(llamada, "text")
  get_data
  class(get_data)

  # Del JSON, convertimos este texto en un objeto lista
  get_data_JSON <- fromJSON(get_data, flatten = TRUE)
  class(get_data_JSON)

  # Renombramos el objeto, por comodidad
  a <- get_data_JSON
  a

  # a$height
  # a$weight

  tabla = tibble(numero = a$id,
                 nombre = a$name,
                 altura = a$height,
                 peso = a$weight,
                 sprite = a$sprites$front_default)

  # tabla = a$stats %>%
  #   as_tibble() %>%
  #   filter(stat.name %in% c("attack", "defense")) %>%
  #   select(base_stat, stat.name) %>%
  #   mutate(no = no) %>%
  #   pivot_wider(id_cols = "no",
  #               names_from = stat.name,
  #               values_from = base_stat) %>%
  #   mutate(sprite = a$sprites$front_default,
  #          name = a$name,
  #          main.type = a$types$type.name[1])
  print(a$id)
  return(tabla)
}

# Obtenemos los datos de los 890 pokemones registrados ----
# datos = lapply(1:890, gen_data_pokemon)
datos = lapply(1:898, gen_data_pokemon)
datos_tibble = do.call(rbind, datos)

datos_tibble %>%
  openxlsx::write.xlsx("datos_cualidades_pokemon.xlsx")

# Leemos los datos:
datos_tibble <- readxl::read_xlsx("datos_cualidades_pokemon.xlsx")

# Agrupamos por pesos y alturas:
datos_pokemon <- datos_tibble %>%
  mutate(al_pes = str_c(altura, "-", peso)) %>%
  group_by(al_pes) %>%
  mutate(ranking = rank(al_pes, ties.method = "random")) %>%
  filter(ranking == 1) %>%
  ungroup()


# Grafica ----
plt <- datos_pokemon %>%
# [sample(1:779, 200),]
  ggplot() +
    geom_point(data = datos_tibble) +
    aes(x = log(peso),
        y = log(altura)) +
    labs(title = "\nDistribución de las estadísticas de altura y peso de los Pokemon",
         subtitle = "Distribution of physical height and weight stats of Pokemon",
         x = "log(Peso) en lb", y = "log(Altura) en pies",
         caption = "#30DayChartChallenge2022
         @JuvenalCamposF - IG: juvenalcampos.dataviz
         Día 7: Distribuciones + Físico
         Fuente: Datos provenientes de la PokeAPI:https://pokeapi.co") +
  geom_image(aes(image = sprite)) +
    theme(plot.title = element_text(hjust = 0.5, size = 20,family = "Montserrat", face = "bold", color = "purple"),
          plot.subtitle = element_text(hjust = 0.5, size = 12, family = "Montserrat", face = "bold"),
          text = element_text(family = "Montserrat"),
          panel.background = element_rect(fill = "white"),
          panel.border = element_rect(color = rgb(248, 213, 112, maxColorValue = 255),
                                      fill = NA,
                                      size = 2))

plt

# Show only marginal plot for x - y axis
p3 <- ggMarginal(plt, color = c("purple"),
                 fill = c("#f5d4ff"), size=4)

p3
class(p3)



