// Example shapefile provided with 1 polygon/feature for demonstration.
// The code processes features in batch mode and can be run on the full dataset 
// (~80,000 polygons/features) by replacing the example file with the complete dataset.
var roi_data = ee.FeatureCollection("projects/ee-chengyu-tongb2/assets/Sentinel-2_acquisition_and_preprocessing_example/example_data_gee");

// Cloud Masking using QA60 band; https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED#bands
function maskS2clouds(image) {
  var qa = image.select('QA60');
  // Bits 10 and 11 are clouds and cirrus, respectively.
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;
  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));
  return image.updateMask(mask); // Apply the mask
}

// Apply cloud mask
function applyMasks(image) {
  var cloudMasked = maskS2clouds(image); // Apply cloud mask
  return cloudMasked;
}

// Load Sentinel-2 Collection
// Set the time period you need
var startDate = '2017-01-01';
var endDate = '2022-12-31';
var dataset = ee.ImageCollection('COPERNICUS/S2_HARMONIZED')
  .filterDate(startDate, endDate) // Filter by date
  .filterBounds(roi_data) // Filter by ROI
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)) // Pre-filter for cloud cover
  .map(applyMasks); // Apply both masks
// Calculate the median composite
var Final_sample = dataset.median()
  .reproject({
    crs: 'EPSG:4326', // Define a standard CRS for the Sentinel-2 data
    scale: 10 // Match Sentinel-2 resolution
  });
print('Final_sample projection:', Final_sample.projection());

var bands = [
    'B11',
    'B12',
    'B2',
    'B3',
    'B4',
    'B5',
    'B6',
    'B7',
    'B8',
    'B8A'
];

// Sort roi data by "index_no" to ensure non-overlapping batches
var sortedroi_data = roi_data.sort('index_n');

// Extract sorted unique "index_no" values
var indexList = sortedroi_data.aggregate_array('index_n');

// Set batch size (n features per batch)
var batchSize = 1;
var startBatch = 0;  // Start at batch n
var maxBatches = 1;  // End at batch n

// Process batches automatically
indexList.evaluate(function(indexArray) {
  var totalFeatures = indexArray.length;
  var totalBatches = Math.ceil(totalFeatures / batchSize); // Calculate total number of batches
  var batchesToProcess = Math.min(maxBatches, totalBatches); // Ensure we don't exceed total available batches

  print("Total Features:", totalFeatures);
  print("Total Batches in Dataset:", totalBatches);
  print("Batches to Export:", batchesToProcess);

  // Loop over batches
  for (var i = startBatch; i < Math.min(maxBatches, totalBatches); i++) {
    var batchStart = i * batchSize;
    var batchEnd = Math.min(batchStart + batchSize, totalFeatures); // Ensure it doesn't exceed max index
    var limitedIndexArray = indexArray.slice(batchStart, batchEnd); // Extract current batch of n

    // Filter collection for current batch
    var filteredCollection = sortedroi_data.filter(ee.Filter.inList('index_n', limitedIndexArray));

    var sample = Final_sample.select(bands).sampleRegions({
      collection: filteredCollection,
      properties: ['index_no'],
      scale: 10,
      tileScale: 4,
      geometries: true
    });

    // Export each batch separately (only batch number in filename)
    Export.table.toDrive({
      collection: sample,
      description: 'Batch_' + i,  // **Only batch number in filename**
      folder: 'your_folder',
      fileFormat: 'GeoJSON'
    });
  }
});