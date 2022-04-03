# Librerias:
library(tidyverse)
library(waffle)

# Datos:
datos <- tibble(variable = c("Total Alumnos",
                             # "Alumnos que votaron",
                             "Alumnos apoyo",
                             "Alumnos no apoyo",
                             "Votos Nulos"),
       numeros = c(12221 - (524+361+150+13),
                   # 524,
                   361, 150, 13)
       ) %>%
  mutate(variable = factor(variable, c("Total Alumnos",
                                       # "Alumnos que votaron",
                                       "Alumnos apoyo",
                                       "Alumnos no apoyo",
                                       "Votos Nulos")))
# %>%
#   mutate(numeros = numeros/10)

# Raíz cuadrada de 12,221 (para que el waffle salga cuadrado)
sqrt(12221)

# Colores:
# colores <- wesanderson::wes_palettes$Zissou1[-2]
colores <- c("#3B9AB2","#F21A00", "#EBCC2A","gray50")
scales::show_col(colores)

# Gráfica:
datos %>%
  ggplot(aes(label = variable,
             values = numeros,
             color = variable)) +
  geom_pictogram(n_rows = 80,
                 make_proportional = F,
                 size = 1.5,
                 family = "Font Awesome 5 Free Solid") +
  scale_label_pictogram(
    name = NULL,
    values = c("user"),
    labels = c("Total Alumnos",
              "Alumnos que votaron",
              "Alumnos apoyo",
              "Alumnos no apoyo",
              "Votos Nulos"))  +
  scale_color_manual(values = colores) +
  scale_y_continuous(expand = expansion(c(0.01,0.01), 0)) +
  scale_x_continuous(expand = expansion(c(0.01,0.01), 0)) +
  labs(x = "", y = "",
       title = "¿Cómo estuvo la participación en el ejercicio de revocación\nde la FCPyS de la UNAM?",
       subtitle = "De un total de 12,221 estudiantes...",
       caption = "#30DayChartChallenge Día 2.
       Comparaciones - Pictograma.
       @JuvenalCamposF - IG: juvenalcampos.dataviz
       Fuente: 12,221 alumnos fueron los registrados en Población Total de Licenciatura de la Facultad de Ciencias Políticas de la UNAM en 2019-2020. ") +
  theme_bw() +
  theme_enhance_waffle() +
  theme(panel.border = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0.5,
                                  family = "Poppins",
                                  size = 15,
                                  face = "bold",
                                  color = colores),
        plot.subtitle = element_text(hjust= 0.5,
                                     family = "Poppins",
                                     size = 10),
        legend.position = "none")

ggsave("grafica_1.png",
       device = "png",
       height = 8,
       width = 8)


# Grafica de resultados:
colores = colores[-1]
datos %>%
  filter(variable != "Total Alumnos") %>%
  ggplot(aes(label = variable,
             values = numeros,
             color = variable)) +
  geom_pictogram(n_rows = 10,
                 make_proportional = F,
                 size = 4,
                 family = "Font Awesome 5 Free Solid") +
  scale_label_pictogram(
    name = NULL,
    values = c("user"),
    labels = c("Total Alumnos",
               "Alumnos que votaron",
               "Alumnos apoyo",
               "Alumnos no apoyo",
               "Votos Nulos"))  +
  scale_color_manual(values = colores) +
  scale_y_continuous(expand = expansion(c(0.05,0.05), 0)) +
  scale_x_continuous(expand = expansion(c(0.05,0.05), 0)) +
  #' labs(x = "", y = "",
  #'      title = "¿Cómo estuvo la participación en el ejercicio de revocación\nde la FCPyS de la UNAM?",
  #'      subtitle = "De un total de 12,221 estudiantes...",
  #'      caption = "#30DayChartChallenge Día 2.
  #'      Comparaciones - Pictograma.
  #'      @JuvenalCamposF - IG: juvenalcampos.dataviz
  #'      Fuente: 12,221 alumnos fueron los registrados en Población Total de Licenciatura de la Facultad de Ciencias Políticas de la UNAM en 2019-2020. ") +
  theme_bw() +
  theme_enhance_waffle() +
  theme(panel.border = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0.5,
                                  family = "Poppins",
                                  size = 15,
                                  face = "bold",
                                  color = colores),
        plot.subtitle = element_text(hjust= 0.5,
                                     family = "Poppins",
                                     size = 10),
        legend.position = "none")

ggsave("grafica_2.png",
       device = "png",
       height = 3,
       width = 12)
