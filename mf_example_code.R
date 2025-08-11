# Install and load necessary libraries
#install.packages("terra")
#install.packages("sf")
#install.packages("dplyr")
#install.packages("FNN")
library(terra)
library(sf)
library(dplyr)
library(FNN)

# As this study processes shapefiles in batch, please place the example shapefile (example_data_mf.xxx) in your own folder
# Input and output folders
input_dir <- "your_folder"
output_dir <- file.path(input_dir, "smooth_done")

# Create output folder if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# List all .shp files in the input folder
shapefiles <- list.files(input_dir, pattern = "\\.shp$", full.names = TRUE)

# Get appropriate UTM EPSG code based on centroid
get_utm_epsg <- function(sf_object) {
  centroid <- st_coordinates(st_centroid(st_union(sf_object)))
  lon <- centroid[1]
  lat <- centroid[2]
  zone <- floor((lon + 180) / 6) + 1
  if (lat >= 0) {
    return(32600 + zone)  # Northern Hemisphere
  } else {
    return(32700 + zone)  # Southern Hemisphere
  }
}

# Function to get majority class
get_majority <- function(values) {
  values <- values[!is.na(values)]
  if (length(values) == 0) return(NA)
  majority_class <- names(sort(table(values), decreasing = TRUE))[1]
  return(as.numeric(majority_class))
}

# Loop through shapefiles
for (shp_file in shapefiles) {
  cat("Processing:", basename(shp_file), "\n")
  
  point_data <- vect(shp_file)
  point_sf <- st_as_sf(point_data)
  
  if (!all(c("Prdct_C") %in% names(point_sf))) {
    cat("Skipping (missing required fields):", basename(shp_file), "\n")
    next
  }
  
  if (st_crs(point_sf)$IsGeographic) {
    utm_epsg <- get_utm_epsg(point_sf)
    point_sf <- st_transform(point_sf, crs = utm_epsg)
  }
  
  point_sf <- point_sf[complete.cases(st_coordinates(point_sf)), ]
  coords <- st_coordinates(point_sf)
  
  if (nrow(coords) < 2) {
    cat("Skipping (not enough points):", basename(shp_file), "\n")
    next
  }
  
  max_neighbours <- min(48, nrow(coords))
  neighbours_list <- get.knnx(data = coords, query = coords, k = max_neighbours)
  neighbour_indices <- neighbours_list$nn.index
  
  target_classes <- c("1", "2", "3", "4", "5", "6", "7")
  
  point_sf$majority_class <- sapply(1:nrow(point_sf), function(i) {
    current_class <- as.character(point_sf$Prdct_C[i])
    if (current_class %in% target_classes) {
      neighbours <- neighbour_indices[i, ]
      neighbours <- neighbours[neighbours > 0]
      neighbour_classes <- point_sf$Prdct_C[neighbours]
      return(get_majority(neighbour_classes))
    } else {
      return(current_class)
    }
  })
  
  # Export smoothed shapefile in WGS84
  point_sf_wgs84 <- st_transform(point_sf, crs = 4326)
  output_name <- paste0(tools::file_path_sans_ext(basename(shp_file)), "_smoothed.shp")
  output_path <- file.path(output_dir, output_name)
  st_write(point_sf_wgs84, output_path, delete_dsn = TRUE)
  
  # Cleanup memory
  rm(point_data, point_sf, coords, neighbours_list, neighbour_indices, point_sf_wgs84)
  gc()
}

cat("====================================\n")
cat("All shapefiles smoothed and saved to:\n", output_dir, "\n")
