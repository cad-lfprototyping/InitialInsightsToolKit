boolean debugGuideEnabled = false;

// extent
float extent_lon_min, extent_lon_max;     // Tangy extent longitude {lon-min, lon-max}
float extent_lat_min, extent_lat_max;     // Tangy extent latitude {lat-min, lat-max}

// geo to screen conversion
float xoff, yoff, scale;                  // GeoToScreen conversion parameters {x-offset, y-offset, scale}

// Map Styles
int sea_fill;
int neigborhood_fill, neigborhood_stroke;
int motorway_stroke;
int primary_stroke;
int trunk_stroke;
float link_stroke_weight, other_stroke_weight;

// Heatmap Styles
int level_7,level_6,level_5,level_4,level_3,level_2,level_1,level_none;
int level_stroke_color, legend_stroke_color;
float legend_stroke_weight;

// Kinect parameters
int roi_origin_x, roi_origin_y;
int roi_width, roi_height;
float margin_ignore;
int blur_coeff;
float contrast_coeff, pixel_diff_threshold;

// Data parameters
String websocketURL;
float singlePointRadius;

//agent parameters
int buttonSize;
int selectionPadX;
int selectionPadY;
int defaultCost;
int diameter;
int baseX;
int baseY;
int tableW;
int tableH;
float border;
int numAnt;
String image;
color bg;
boolean screenShotL=false;
String screenShotLName = "";
boolean screenShotR=false;
String screenShotRName = "";

void ReadConfigurationFile()
{
  try
  {
    JSONObject config = loadJSONObject("config.json");

    JSONObject extent = config.getJSONObject("calibration").getJSONObject("extent");
    extent_lat_max = extent.getFloat("lat-max");
    extent_lat_min = extent.getFloat("lat-min");
    extent_lon_max = extent.getFloat("lon-max");
    extent_lon_min = extent.getFloat("lon-min");

    JSONObject fitting = config.getJSONObject("calibration").getJSONObject("fitting");
    xoff = fitting.getFloat("x-offset");
    yoff = fitting.getFloat("y-offset");
    scale = fitting.getFloat("scale");

    JSONObject map_style = config.getJSONObject("style").getJSONObject("map");
    sea_fill = unhex(map_style.getString("sea-fill-color"));
    neigborhood_fill = unhex(map_style.getString("neigborhood-fill-color"));
    neigborhood_stroke = unhex(map_style.getString("neigborhood-stroke-color"));
    motorway_stroke = unhex(map_style.getString("motorway-stroke-color"));
    primary_stroke = unhex(map_style.getString("primary-stroke-color"));
    trunk_stroke = unhex(map_style.getString("trunk-stroke-color"));
    link_stroke_weight = map_style.getFloat("link-stroke-weight");
    other_stroke_weight = map_style.getFloat("other-stroke-weight");

    JSONObject heatmap_style = config.getJSONObject("style").getJSONObject("heatmap");
    level_7 = unhex(heatmap_style.getString("level-7-fill-color"));
    level_6 = unhex(heatmap_style.getString("level-6-fill-color"));
    level_5 = unhex(heatmap_style.getString("level-5-fill-color"));
    level_4 = unhex(heatmap_style.getString("level-4-fill-color"));
    level_3 = unhex(heatmap_style.getString("level-3-fill-color"));
    level_2 = unhex(heatmap_style.getString("level-2-fill-color"));
    level_1 = unhex(heatmap_style.getString("level-1-fill-color"));
    level_none = unhex(heatmap_style.getString("level-none-fill-color"));
    level_stroke_color = unhex(heatmap_style.getString("levels-stroke-color"));
    legend_stroke_color = unhex(heatmap_style.getString("legend-stroke-color"));
    legend_stroke_weight = heatmap_style.getFloat("legend-stroke-weight");

    JSONObject kinect_par = config.getJSONObject("calibration").getJSONObject("kinect"); 
    roi_origin_x = kinect_par.getInt("roi-origin-x"); 
    roi_origin_y = kinect_par.getInt("roi-origin-y");
    roi_width = kinect_par.getInt("roi-width");
    roi_height = kinect_par.getInt("roi-height");
    blur_coeff = kinect_par.getInt("blur-coefficient");
    contrast_coeff = kinect_par.getFloat("contrast-increase-coefficient");
    pixel_diff_threshold = kinect_par.getFloat("pixel-difference-threshold");
    margin_ignore = kinect_par.getFloat("margin-ignore");
    if (margin_ignore < .01 || margin_ignore > .49) margin_ignore = .06;

    

    JSONObject agent_par = config.getJSONObject("style").getJSONObject("agent"); 
    buttonSize = agent_par.getInt("buttonSize"); 
    selectionPadX = agent_par.getInt("selectionPadX");
    selectionPadY = agent_par.getInt("selectionPadY");
    diameter = agent_par.getInt("diameter");
    defaultCost = agent_par.getInt("defaultCost");
    baseX = agent_par.getInt("baseX");
    baseY = agent_par.getInt("baseY");
    tableW = agent_par.getInt("tableW");
    tableH = agent_par.getInt("tableH");
    border = agent_par.getInt("border");
    numAnt = agent_par.getInt("numAnt");
    image = agent_par.getString("imageName");
    bg = unhex(agent_par.getString("backgroundColor"));//= color(238,250,201)
    
    JSONObject data_par = config.getJSONObject("data");
    websocketURL = data_par.getString("heatmap-url");
    singlePointRadius = MetersToPixels(data_par.getFloat("single-point-selection-radius"));
  }
  catch(Exception e) 
  {
    println("ERROR: Could not read \"config.json\" as configuration file, exiting!");
    exit();
  }
}

void SaveConfigurationFile()
{
  JSONObject config = loadJSONObject("config.json");
  
  JSONObject fitting = config.getJSONObject("calibration").getJSONObject("fitting");
  fitting.setFloat("x-offset", xoff);
  fitting.setFloat("y-offset", yoff);
  fitting.setFloat("scale", scale);
  
  saveJSONObject(config, "config.json");
  println("Configuration file (config.json) is updated.");
}