
// CONVERTS SCREEN COORDINATES TO GEOCOORDINATES
public PVector ScreenToGeoCoordinates(float screenX, float screenY)
{
  PVector geo = new PVector();

  geo.x = map(screenX, xoff, scale*2+xoff, extent_lon_min, extent_lon_max);
  geo.y = map(screenY, yoff, yoff-scale*1.5, extent_lat_min, extent_lat_max);

  return geo;
}

// CONVERTS GEOCOORDINATES TO SCREEN COORDINATES
public PVector GeoToScreenCoordinates(float geoX, float geoY)
{
  PVector screen = new PVector();

  screen.x = map(geoX, extent_lon_min, extent_lon_max, xoff, scale*2+xoff);
  screen.y = map(geoY, extent_lat_min, extent_lat_max, yoff, yoff-scale*1.5);
  return screen;
}

// CALCULATE DISTANCE BETWEEN TWO GEOCOORDINATES IN METERS
public float CalculateGeoDistance(float lon1, float lat1, float lon2, float lat2) 
{
  float R = 6371000; // earth's radius in metres
  float theta1 = radians(lat1);
  float theta2 = radians(lat2);
  float delta_theta = radians(max(lat2, lat1)-min(lat2, lat1));
  float delta_lambda = radians(max(lon2, lon1)-min(lon2, lon1));

  float a = sin(delta_theta/2) * sin(delta_theta/2) +
    cos(theta1) * cos(theta2) *
    sin(delta_lambda/2) * sin(delta_lambda/2);
  float c = 2 * atan2(sqrt(a), sqrt(1-a));

  float d = R * c;

  return d;
}

// CALCULATE OTHER GEOCOORDINATE GIVEN A COORDINATE AND BEARING AND DISTANCE
public PVector CalculateEndPoint(float lon, float lat, float brng, float d)
{
  float R = 6371000; // earth's radius in metres
  float theta = radians(lat);
  float lambda = radians(lon);
  brng = radians(brng);

  float theta2 = asin(sin(theta)*cos(d/R) + cos(theta)*sin(d/R)*cos(brng));
  float lambda2 = lambda + atan2(sin(brng)*sin(d/R)*cos(theta), cos(d/R)-sin(theta)*sin(theta2));

  lambda2 = (lambda2+540)%360-180;

  return new PVector(degrees(lambda2), degrees(theta2));
}

// CONVERTS PIXELS TO METERS FOR TANGY -- WORLD CURVATURE IS IGNORED 
//                                        SINCE TANGY PRINTED BY IGNORING IT
public float PixelsToMeters(float pixelvalue)
{
  // width of the Tangy in meters and in pixels
  float extent_lat_average = (extent_lat_max+extent_lat_min)/2.0;
  float meter = CalculateGeoDistance(extent_lon_min, extent_lat_average, extent_lon_max, extent_lat_average);
  float pixel = GeoToScreenCoordinates(extent_lon_max, extent_lat_average).x - 
    GeoToScreenCoordinates(extent_lon_min, extent_lat_average).x;
  return pixelvalue*meter/pixel;
}

// CONVERTS METERS TO PIXELS FOR TANGY -- WORLD CURVATURE IS IGNORED 
//                                        SINCE TANGY PRINTED BY IGNORING IT
public float MetersToPixels(float metervalue)
{
  // width of the Tangy in meters and in pixels
  float extent_lat_average = (extent_lat_max+extent_lat_min)/2.0;
  float meter = CalculateGeoDistance(extent_lon_min, extent_lat_average, extent_lon_max, extent_lat_average);
  float pixel = GeoToScreenCoordinates(extent_lon_max, extent_lat_average).x - 
    GeoToScreenCoordinates(extent_lon_min, extent_lat_average).x;
  return pixel*metervalue/meter;
}

// COMPLEX POLYGON-POINT INTERSECTION FUNCTION
boolean pointInPolygon(List<PVector> v, PVector p) 
{
  int i, j = v.size()-1;
  boolean oddNodes = false;

  for (i=0; i < v.size(); i++) {
    if ((v.get(i).y < p.y && v.get(j).y >= p.y
      || v.get(j).y < p.y && v.get(i).y >= p.y)
      && (v.get(i).x <=p.x || v.get(j).x <= p.x)) 
    {
      oddNodes^=(v.get(i).x+(p.y-v.get(i).y)/
        (v.get(j).y-v.get(i).y)*
        (v.get(j).x-v.get(i).x) < p.x);
    }
    j=i;
  }

  return oddNodes;
}

// DRAWS THE DEBUG LINE THAT CAN BE USED FOR CALIBRATION
void drawDebugLine() {
  PVector ul = GeoToScreenCoordinates(extent_lon_min, extent_lat_max); //upper-left corner
  PVector lr = GeoToScreenCoordinates(extent_lon_max, extent_lat_min); //lower-right corner   
  fill(255);
  ellipse(ul.x, lr.y, 12, 12);
  ellipse(lr.x, lr.y, 12, 12);
  fill(0);
  ellipse(ul.x, lr.y, 8, 8);
  ellipse(lr.x, lr.y, 8, 8);
  fill(255);
  ellipse(ul.x, lr.y, 4, 4);
  ellipse(lr.x, lr.y, 4, 4);
  strokeWeight(3);
  stroke(255);
  line(ul.x, lr.y, lr.x, lr.y);
  strokeWeight(1);
  stroke(0);
  line(ul.x, lr.y, lr.x, lr.y);
}