options(scipen = 999)

# Librerias:
library(tidyverse)

# Datos:
datos = readr::read_csv("d_agg_2020.csv",
                        locale = locale(encoding = "WINDOWS-1252"))

vol_prod_cultivos <- datos %>%
  group_by(`Nomcultivo Sin Um`) %>%
  summarise(Volumenproduccion = sum(Volumenproduccion, na.rm = T),
            Valor_produccion = sum(Valorproduccion, na.rm = T))

openxlsx::write.xlsx(vol_prod_cultivos,
                     "vol_prod_cultivos.xlsx")

datos_flor <- tibble::tribble(
  ~nom_flor, ~vol_prod, ~is.flor,
        "Crisantemo",        12522963.25,       1L,
           "Gerbera",         1278993.04,       1L,
      "Girasol flor",          258867.02,       1L,
          "Gladiola",         5112392.26,       1L,
  "Lilium (azucena)",           735472.2,       1L,
        "Nochebuena",        18846361.13,       1L,
              "Rosa",         9082620.62,       1L,
        "Terciopelo",          409470.75,       1L,
  "Tulipán holandés",             418800,       1L,
    "Zempoalxochitl",          515634.65,       1L
  )

datos_flor <- vol_prod_cultivos %>%
  filter(`Nomcultivo Sin Um` %in% datos_flor$nom_flor) %>%
  rename(nom_flor = `Nomcultivo Sin Um`)

datos_flor %>%
  mutate(nom_flor = str_c(nom_flor, "\n$", prettyNum(round(Valor_produccion/1e6, 2), big.mark = ","), " MDP")) %>%
  ggplot(aes(x = nom_flor, y = Valor_produccion/1e6)) +
  geom_col(width = 0.5,
           fill = "#E91222") +
  ylim(-900, 2000) +
  coord_polar() +
  theme_bw() +
  labs(x = "", y = "",
       subtitle = "El crisantemo, la rosa y la gladiola son los cultivos con\nmayor valor de producción a nivel nacional en 2020.",
       title = "Valor de producción de cultivos florales en 2020",
       caption = "#30DayChartChallenge - Día 4: Comparaciones & Floral,
       Datos del SIAP de la SADER para 2020
       @JuvenalCamposF") +
  theme(panel.background = element_rect(color = "transparent"),
        panel.border = element_blank(),
        text = element_text(family = "Poppins"),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        plot.caption.position = "plot",
        plot.title = element_text(family = "Poppins",
                                  hjust = 0.5,
                                  face = "bold",
                                  size = 20,
                                  color = "#E91222"),
        plot.subtitle = element_text(family = "Poppins",
                                     hjust = 0.5,
                                     face = "bold",
                                     size = 10,
                                     color = "#345C20"))

ggsave("grafica_flores.png",
       device = "png",
       height = 9,
       width = 7.5)
