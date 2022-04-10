options(scipen = 999)
# Librerias:
library(tidyverse)
library(pdftools)
library(rebus)

# Procesamos los datos del PDF:
url = "https://portal.ine.mx/wp-content/uploads/2022/03/RM_MOR_21032022_1720.pdf"
t <- pdftools::pdf_text(url)
data <-lapply(1:length(t), function(y){
  # y = 1
  texto <- tibble(a = t[y] %>%
                    str_split("\n") %>%
                    unlist()) %>%
    slice(-c(1:8)) %>%
    mutate(a = str_squish(a)) %>%
    filter(str_detect(a, pattern = "^MORELOS")) %>%
    mutate(nums = str_extract_all(a, pattern = " [[,\\d]?]+")) %>%
    unique()

  vector_secciones <- lapply(1:length(texto$nums), function(x){
    pluck(texto$nums, x,  5) %>% str_squish()
  }) %>% unlist() %>% unique()

  return(vector_secciones)

})

secciones_consulta_morelos <- tibble(secciones_agrupadas = data %>%
                                       unlist()) %>%
  mutate(no_comas = str_detect())

secciones_consulta_morelos$secciones_agrupadas

# Info de las secciones morelos:
secciones_morelos <- readRDS("secciones_morelos.rds")


datos_morelos <- lapply(seq_along(secciones_consulta_morelos$secciones_agrupadas),
       function(S){
         secciones_i <- secciones_consulta_morelos$secciones_agrupadas[S] %>%
           str_split(",") %>%
           unlist()
         secciones_morelos %>%
           filter(cve_seccion %in% secciones_i) %>%
           mutate(cve_seccion_consulta = str_c(secciones_i, collapse = "_")) %>%
           group_by(cve_seccion_consulta, nom_mun_ine) %>%
           summarise(ln = sum(as.numeric(lista_nominal_casilla, na.rm = T)))
       })

datos_morelos_2 <- do.call(rbind, datos_morelos) %>%
  ungroup() %>%
  mutate(consecutivo = 1:nrow(.)) %>%
  filter(!is.na(ln))


datos_densidad <- rbind(datos_morelos_2 %>%
  select(cve_seccion = cve_seccion_consulta, ln) %>%
  mutate(tipo = "Revocación de mandato 2022"),
secciones_morelos %>%
  select(cve_seccion, ln = lista_nominal_casilla) %>%
  mutate(tipo = "Elecciones a diputación 2021"))

promedio_consulta <- mean(datos_densidad %>% filter(tipo == "Revocación de mandato 2022") %>% pull(ln) %>% as.numeric())
promedio_elecciones <- mean(datos_densidad %>% filter(tipo == "Elecciones a diputación 2021") %>% pull(ln) %>% as.numeric() %>% na.omit())



ggplot() +
  geom_density(data = datos_densidad %>%
                 mutate(ln = as.numeric(ln)),
               aes(x = ln, fill = tipo, color = tipo),
               alpha = 0.5) +
  geom_vline(xintercept = c(promedio_consulta,
                            promedio_elecciones),
             linetype = 2,
             color = c("brown", "skyblue"),
             size = 0.5) +
  geom_text(aes(x = c(promedio_consulta,
                      promedio_elecciones) + 150,
                y = 0.0005,
                label = str_c("Promedio: ",
                              c(promedio_consulta,
                                promedio_elecciones) %>% round(2) %>%
                                prettyNum(big.mark = ","))),
            angle = 270,
            family = "Montserrat"
            # fontface = "bold",
            # color = c("brown", "skyblue")
            )  +
  scale_fill_manual(values = c("skyblue", "brown")) +
  scale_color_manual(values = c("skyblue", "brown"), guide = "none") +
  ggthemes::theme_clean() +
  labs(title = "Densidad de votantes por sección",
       subtitle = "Datos para el estado de Morelos",
       caption = "#30DayMapChallenge - Día 09 - Distribución + Estadística
       Datos: portal.ine.mx/wp-content/uploads/2022/03/RM_MOR_21032022_1720.pdf para la consulta
       y Datos del PREP 2021 para las características de las secciones en el 2021 - INE",
       fill = "Evento: ",
       y = NULL,
       x = "Lista Nominal por sección") +
  scale_x_continuous(labels = scales::comma_format()) +
  scale_y_continuous(expand = expansion(c(0,0.1), 0)) +
  theme(legend.position = "bottom",
        axis.text.y = element_blank(),
        axis.ticks =  element_blank(),
        plot.title = element_text(family = "Montserrat", size = 20),
        plot.subtitle = element_text(family = "Montserrat", size = 15)) +
  guides(fill = guide_legend(title.position = "top",
                             title.hjust = 0.5,
                             ncol = 2))
