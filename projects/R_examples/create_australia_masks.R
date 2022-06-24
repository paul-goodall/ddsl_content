

source("/Volumes/Abyss/rstudio/ddsl_content/projects/ddsl_packages/R/ddsl_r.R")

ddsl_lib('tidyverse')
ddsl_lib("sf")
ddsl_lib("raster")
ddsl_lib("ggplot2")
ddsl_lib("dplyr")

geo_data <- readRDS("data/geo_data.rds")
summary(geo_data)

##  1. Australia coordinate map - coastline
##  2. Bottom-up aggregation via Adaptive Mesh Refinement
##  3. Point-grid smoothing of attributes
##  4. Shiny postcode-level mapview.



com_pattern <- "
wget -O my_dataset_name.zip 'my_data_url';
mkdir -p data/my_dataset_name; 
unzip my_dataset_name.zip -d data/my_dataset_name/; 
rm my_dataset_name.zip
"

## Download Australian boundaries data:
my_data_url     <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_aus_2016_aust_shape.zip&1270.0.55.001&Data%20Cubes&5503B37F8055BFFECA2581640014462C&0&July%202016&24.07.2017&Latest"
my_dataset_name <- "aus_country_boundaries"

com <- com_pattern
com <- gsub("my_data_url", my_data_url, com)
com <- gsub("my_dataset_name", my_dataset_name, com)
cat(com,"\n")
system(com)

## Download Australian state boundaries data:
my_data_url     <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_ste_2016_aust_shape.zip&1270.0.55.001&Data%20Cubes&65819049BE2EB089CA257FED0013E865&0&July%202016&12.07.2016&Latest"
my_dataset_name <- "aus_state_boundaries"

com <- com_pattern
com <- gsub("my_data_url", my_data_url, com)
com <- gsub("my_dataset_name", my_dataset_name, com)
cat(com,"\n")
system(com)

## Download Australian sa1 boundaries data:
my_data_url     <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_sa1_2016_aust_shape.zip&1270.0.55.001&Data%20Cubes&6F308688D810CEF3CA257FED0013C62D&0&July%202016&12.07.2016&Latest"
my_dataset_name <- "aus_sa1_boundaries"

com <- com_pattern
com <- gsub("my_data_url", my_data_url, com)
com <- gsub("my_dataset_name", my_dataset_name, com)
cat(com,"\n")
system(com)


aus_country_boundaries <- read_sf("data/aus_country_boundaries/", "AUS_2016_AUST")
aus_state_boundaries   <- read_sf("data/aus_state_boundaries/", "STE_2016_AUST")
aus_sa1_boundaries     <- read_sf("data/aus_sa1_boundaries/", "SA1_2016_AUST")

head(aus_state_boundaries)
summary(aus_state_boundaries)


ggplot() +
  geom_sf(data=aus_state_boundaries,aes(fill = STE_NAME16))+
  ggtitle("Map: Australian State Boundaries") +
  xlab("Longitude") +
  ylab("Latitude")

ggplot() +
  geom_sf(data=aus_country_boundaries, fill="red")+
  ggtitle("Map: Australian National Boundary") +
  xlab("Longitude") +
  ylab("Latitude")

sf_use_s2(FALSE)
# Remove outline, labels, axes .. basically a picture of Australia:
ggplot() +
  geom_sf(data=aus_country_boundaries, fill="black", lwd=0)+
  ggtitle("Map: Australian National Boundary") +
  xlab("Longitude") +
  ylab("Latitude") +
  coord_sf(xlim = c(110,155), ylim = c(-45,-10), expand = FALSE) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"))


x1 <- 110
x2 <- 155
dx <- (x2-x1)
y1 <- -45
y2 <- -9
dy <- (y2-y1)
dydx <- dy/dx
  
sf_use_s2(FALSE)
# JUST a picture of Australia:
gg <- ggplot() +
  geom_sf(data=aus_country_boundaries, colour="white", fill="white", lwd=0)+
  coord_sf(xlim = c(x1,x2), ylim = c(y1,y2), expand = FALSE) + 
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  labs(x=NULL, y=NULL, title=NULL) +
  theme(
    axis.line=element_blank(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    legend.position="none",
    panel.grid.major=element_blank(),
    panel.grid.minor=element_blank(),
    plot.background=element_rect(fill="black", colour=NA),
    panel.background = element_rect(fill = "black", colour = NA),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    plot.margin = unit(c(0, 0, 0, 0), "null"),
    panel.spacing = unit(c(0, 0, 0, 0), "null"),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks.length = unit(0, "null")
  )
  

# ============================
# Let's get the scaling right - we want to specify a pixel-size in metres:
for(px in c(200, 250,500,1000,2000)){
  
pixel_size_metres <- px
r_earth_metres <- 6731000
one_degree_in_metres <- 2 * pi * r_earth_metres / 360
im_name <- paste0("images/australia_main_pixels-", pixel_size_metres, "m")
im_name_png <- paste0(im_name,".png")
im_name_pdf <- paste0(im_name,".pdf")

im_x <- round(one_degree_in_metres * dx / pixel_size_metres)
im_y <- round(im_x * dydx)

ggsave(
  filename=im_name_png,
  plot = gg,
  device = "png",
  path = NULL,
  scale = 1,
  width = im_x,
  height = im_y,
  units = c("px"),
  dpi = 300,
  limitsize = F,
  bg = NULL
)


ggsave(
  filename=im_name_pdf,
  plot = gg,
  device = "pdf",
  scale = 1,
  width = im_x,
  height = im_y,
  units = c("px"),
  dpi = 300,
  limitsize = F,
  bg = NULL
)

}
# ============================
