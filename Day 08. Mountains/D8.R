# Librerias:
library(tidyverse)
library(osmdata)
library(ggtext)
library(sf)
library(glue)
library(ggExtra)

# Funciones propias:
get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

# Guardamos el shape de México:
shape_mx <- getbb("Mexico",
                  featuretype = "country",
                  format_out = "sf_polygon")$multipolygon
st_crs(shape_mx) <- "EPSG:4326"

osm_filepath <- "osm_features_{Sys.Date()}.rds"

mountain_feature_values <- c("peak", "hill", "ridge", "volcano", "mountain")
feature_query <- glue("\"natural\"=\"{mountain_feature_values}\"" )

# if(FALSE){
osm_features <- opq(bbox = st_bbox(shape_mx), timeout = 1200) %>%
  add_osm_features(features = feature_query) %>%
  osmdata_sf()
write_rds(osm_features, osm_filepath)
# }

# if(T){
#   osm_features <- readRDS("osm_features_2022-04-08.rds")
# }

# Make sure there are only features within MX in the dataset
osm_features_intersect <- st_intersection(osm_features$osm_points, shape_mx)
write_rds(osm_features_intersect, glue("osm_features_intersect_{Sys.Date()}.rds"))

osm_features_intersect %>%
  transmute(elevation = as.numeric(ele)) %>%
  ggplot() +
  geom_sf(aes(col = elevation), size = 0.05, alpha = 0.8) +
  scale_color_continuous(trans = "pseudo_log") +
  coord_sf(crs = 4326) +
  theme_void()

coordenadas_montañas <- osm_features_intersect %>%
  st_coordinates() %>%
  as_tibble() %>%
  mutate(densidad = get_density(X, Y, n = 100))

# coordenadas_montañas$densidad <- get_density()
# get_density(tacos_mpio$X, tacos_mpio$Y, n = 100)

mapa_mexico <- st_read("https://raw.githubusercontent.com/JuveCampos/Shapes_Resiliencia_CDMX_CIDE/master/geojsons/Division%20Politica/DivisionEstatal.geojson")

plt <- mapa_mexico %>%
  ggplot() +
  geom_sf(fill = "#DFDCDB", color = "gray40") +
  labs(x = "Longitud", y = "Latitud"
       # ,
       # title = "\nUbicación (y densidad) de las montañas, colinas y elevaciones de México",
       # subtitle = "Registradas para México en la base de datos de OpenStreetMap"
       ) +
  geom_point(data = coordenadas_montañas,
             aes(x = X, y = Y, color = densidad),
             # pch = 21,
             size = 0.5) +
  viridis::scale_color_viridis(option = "magma") +
  theme(panel.background = element_rect(fill = "#b3cde4"),
        plot.background = element_rect(fill = "#b3cde4"),
        plot.title =element_text(family = "Montserrat", face = "bold",
                                 size = 20, color = "black"),
        plot.subtitle =element_text(family = "Montserrat", face = "bold",
                                 size = 15, color = "black"),
        plot.title.position = "plot",
        legend.position = "none",
        axis.text = element_text(family = "Montserrat",
                                 size = 12, color = "black"),
        axis.title = element_text(family = "Poppins", face = "bold",
                                 size = 12, color = "black"),
        panel.grid = element_line(size = 0.5, color = "white")
        )

plt

p3 <- ggMarginal(plt,
                 color = c("gray20"),
                 fill = c("gray50"),
                 size=5)
p3

