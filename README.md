# Classifying-land-use-gee-rf-mf-example

## Overview

This repository provides a methodology for **Sentinel-2 acquisition and preprocessing**, a **Random Forest (RF) model** and a **Majority Filter (MF) procedure**.
Please note that the TanDEM-X Global Digital Elevation Model Change Maps (DCM) must be accessed separately from: **https://geoservice.dlr.de/web/datasets/tdm30_dcm**.
The workflow involves three main scripts:

1. **gee_example_code.js** - Sentinel-2 acquisition and preprocessing.
2. **rf_example_code.R** - Random Forest (RF) model for classifying land use and land cover.
3. **mf_example_code.R** - Majority Filter (MF) procedure for smoothing the RF results.

## Data

Due to the large volume of data (more than 80,000 mining sites), only example datasets (**example_data_gee**, **example_data_rf.csv**, and **example_data_mf.zip**) are provided to ensure reproducibility. The full generated dataset (Cheng et al., 2025)  is openly accessible and archived under the DOI: **https://doi.org/10.5281/zenodo.15726306**.

- **example_data_gee** - Example data for Sentinel-2 acquisition and preprocessing via GEE (available in the GEE JS code).
- **example_data_rf.csv** - Training and prediction/classification data for the RF model.
- **example_data_mf.zip** - Example shapefile data for MF procedure.

## Workflow and Scripts

### 1. Sentinel-2 Acquisition and Preprocessing (gee_example_code.js)

- Uses **Sentinel-2 imagery from 2017-2022**.
- Applies **pre-processing functions** to prepare imagery.
- Outputs **Sentinel-2 data for the region of interest (ROI) at 10 m resolution**. 

### 2. RF model (rf_example_code.R)

- Uses **ten bands of Sentinel-2 imagery combined with elevation change data from the DCM**.
- Produces **land-use and land-cover classification results**.

### 3. MF procedure (mf_example_code.R)

- Applies a **MF procedure** to smooth the classification results from the RF model.
- Produces **smoothed land-use and land-cover classification results**

## Requirements

### **Software & Dependencies**
- Google Earth Engine (Tested in GEE Code Editor, Aug 2025)
- R version 4.4.0 (Tested on RStudio)
  
### **Google Earth Engine (GEE)**
- **Required** for running `gee_example_code.js`.
- **Data is stored in an EE FeatureCollection**.
  
### **R Environment**
- **Required** for `rf_example_code.R`, and `mf_example_code.R`.
- Install the following **R packages**:
  ```r
  install.packages("randomForest")
  install.packages("caret")
  install.packages("dplyr")
  install.packages("ggplot2")
  install.packages("terra")
  install.packages("sf")
  install.packages("FNN")

## Outputs
- Sentinel-2 data for the region of interest (ROI) at 10 m resolution.
- Land-use and land-cover classification results.
- Smoothed land-use and land-cover classification results.

## Notes
  Ensure that Google Earth Engine (GEE) assets are correctly linked.
  Modify folder paths before exporting results to Google Drive.
  This repository provides an example methodology; adjustments may be required for different datasets and study areas.
  
## Licenses:
- The code in this repository is licensed under **CC BY-NC 4.0**.
