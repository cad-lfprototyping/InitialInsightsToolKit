import fingertracker.*;
import KinectPV2.*;
import gab.opencv.*;

class FingerFinder {
  // main objects
  
  private FingerTracker finder;
  private KinectPV2 kinect;
  private OpenCV opencv;

  // base images, 5 is arbitrary
  private PImage baseDepth = new PImage(5, 5);
  private PImage baseIR = new PImage(5, 5);

  // live images
  private PImage liveDepth, liveIR;

  // variable that stops base image retrieval
  private boolean firstCapture = true;

  // margin that excludes the tracking finger
  // x->left,right; y->top,bottom
  private PVector margin;

  // set a default threshold distance.
  // Since the depth is made up from constructed ...
  // binary arms image, we can do this safely.
  private int threshold = 2280;
  private int meltfactor = 10;
  
  // Found finger array
  private ArrayList<Finger> fingers = new ArrayList<Finger>();
  private ArrayList<Finger> walls = new ArrayList<Finger>();
  public FingerFinder(PApplet parent) {
    kinect = new KinectPV2(parent);
    kinect.enableDepthImg(true);
    kinect.enableInfraredImg(true);
    kinect.init();
    
    roi_origin_y -= roi_height;

    opencv = new OpenCV(parent, roi_width*2, roi_height*2);
    finder = new FingerTracker(parent, roi_width*2, roi_height*2);
    
  }

  public ArrayList<Finger> getFingers(){
    return fingers;
  }

  public void find() 
  {
    // get the base depth and ir images
    if (firstCapture && averageImagePixels(baseIR) == 0.0) 
    {
      baseDepth = kinect.getDepthImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      baseIR = kinect.getInfraredImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      baseDepth.resize(baseDepth.width*2, baseDepth.height*2); 
      baseIR.resize(baseIR.width*2, baseIR.height*2);
    } else //know we have the background shapes x2
    {
      if (firstCapture) {
        opencv.loadImage(baseIR);
        opencv.flip(1);
        opencv.contrast(contrast_coeff);
        opencv.blur(blur_coeff);
        baseIR = opencv.getSnapshot();

        opencv.loadImage(baseDepth);
        opencv.flip(1);
        baseDepth = opencv.getSnapshot();
      }
      firstCapture = false;

      // DEPTH IMAGE
      liveDepth = kinect.getDepthImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      liveDepth.resize(liveDepth.width*2, liveDepth.height*2);
      opencv.loadImage(liveDepth);
      opencv.flip(1);
      liveDepth = opencv.getSnapshot();

      // INFRARED IMAGE
      liveIR = kinect.getInfraredImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      liveIR.resize(liveIR.width*2, liveIR.height*2);
      opencv.loadImage(liveIR);
      opencv.flip(1);
      opencv.contrast(contrast_coeff);
      opencv.blur(blur_coeff);
      liveIR = opencv.getSnapshot();

      int w = liveIR.width;
      int h = liveIR.height;

      // the margin value in which finger candidates are ignored
      margin = new PVector(w*margin_ignore, h*margin_ignore);
      
      PImage diff = new PImage(w, h);
      PImage diff1 = diffImages(liveDepth, baseDepth, 0.05);
      PImage diff2 = diffImages(liveIR, baseIR, 0.05);
      
      for (int i = 0; i < h; i++) {
        
        for (int j = 0; j < w; j++) {
          
          // if the pixel is selected on either ir or depth frames, mark it as hand
          try{
            if (int(red(diff1.pixels[i*w+j])) != 0 || int(red(diff2.pixels[i*w+j])) != 0) {
              // discard noise at the edges ('offset' px)
              int offset = 10;
              
              if (i > offset && i < h-offset && j > offset && j < w-offset){
                diff.pixels[i*w+j] = color(255, 255, 255);
               
              }
            }
          }catch(Exception e){
            println("find()"); 
            return;
          }
            
            
        }
      }
      // update the depth threshold beyond which we'll look for fingers
      finder.setMeltFactor(meltfactor);
      finder.setThreshold(threshold); // depth threshold

      // raw Data int valeus from [0 - 4500] assigning depth values for finger tracker
      int[] irMap = new int[roi_width*2 * roi_height*2];
      for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
          float diff_pix = red(diff.pixels[i*w+j]);

          if (diff_pix > 100)
            irMap[i*w+j] = 2000;
          else
            irMap[i*w+j] = 2500;
        }
      }
      finder.update(irMap);
      finder.contours.computeBoundingBoxes();
        
      fingers.clear();
      
      // iterate over all the contours found
      for (int k = 0; k < finder.getNumContours(); k++) 
      {
        // eliminate small defected contours
        if (finder.contours.getContourLength(k) >= 5)
        { 
          // iterate over all the fingers found
          for (int i = 0; i < finder.getNumFingers(); i++) {
            // position of finger in image plane
            PVector position = finder.getFinger(i);
            if (position.x > margin.x && position.x < w-margin.x &&
                position.y > margin.y && position.y < h-margin.y)
            {
              if (finder.contours.contains(k, position.x, position.y)) {
                float baseDepthColor = averageImageRegion(baseDepth, 11, int(position.y), int(position.x));
                float liveDepthColor = averageImageRegion(liveDepth, 11, int(position.y), int(position.x));

                float fingerPosX = map(position.x, 0, w, GeoToScreenCoordinates(extent_lon_min,extent_lat_min).x, GeoToScreenCoordinates(extent_lon_max,extent_lat_min).x);
                float fingerPosY = map(position.y, 0, h, GeoToScreenCoordinates(extent_lon_min,extent_lat_max).y, GeoToScreenCoordinates(extent_lon_min,extent_lat_min).y);
                
                if(walls.isEmpty()||(!walls.isEmpty()&&!isExist(walls,fingerPosX,fingerPosY,10,i))){
                  Finger fin = new Finger(fingerPosX, fingerPosY, baseDepthColor-liveDepthColor);
                  
                  fingers.add(fin);
                }
              }
            }
          }
        }
      }
    }
  }
  private boolean isExist(ArrayList<Finger> temp,float x,float y,int threshold, int i){
    for(Finger finger : temp){
      
      if(x<finger.x+threshold&&x>finger.x-threshold&&y<finger.y+threshold&&y>finger.y-threshold) 
        return true;
       
    }
   
    return false;
  }
  public void find(int[] acceptableX,int[] acceptableY) 
  {
    // get the base depth and ir images
    if (firstCapture && averageImagePixels(baseIR) == 0.0) 
    {
      baseDepth = kinect.getDepthImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      baseIR = kinect.getInfraredImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      baseDepth.resize(baseDepth.width*2, baseDepth.height*2); 
      baseIR.resize(baseIR.width*2, baseIR.height*2);
    } else //know we have the background shapes x2
    {
      if (firstCapture) {
        opencv.loadImage(baseIR);
        opencv.flip(1);
        opencv.contrast(contrast_coeff);
        opencv.blur(blur_coeff);
        baseIR = opencv.getSnapshot();

        opencv.loadImage(baseDepth);
        opencv.flip(1);
        baseDepth = opencv.getSnapshot();
      }
      firstCapture = false;

      // DEPTH IMAGE
      liveDepth = kinect.getDepthImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      liveDepth.resize(liveDepth.width*2, liveDepth.height*2);
      opencv.loadImage(liveDepth);
      opencv.flip(1);
      liveDepth = opencv.getSnapshot();

      // INFRARED IMAGE
      liveIR = kinect.getInfraredImage().get(roi_origin_x, roi_origin_y, roi_width, roi_height);
      liveIR.resize(liveIR.width*2, liveIR.height*2);
      opencv.loadImage(liveIR);
      opencv.flip(1);
      opencv.contrast(contrast_coeff);
      opencv.blur(blur_coeff);
      liveIR = opencv.getSnapshot();

      int w = liveIR.width;
      int h = liveIR.height;

      // the margin value in which finger candidates are ignored
      margin = new PVector(w*margin_ignore, h*margin_ignore);
      ArrayList<ArrayList<ArrayList<Integer>>> temp = new ArrayList<ArrayList<ArrayList<Integer>>>();
      ArrayList<ArrayList<Integer>> a  = new ArrayList<ArrayList<Integer>>();
      boolean flag = true;
      PImage diff = new PImage(w, h);
      PImage diff1 = diffImages(liveDepth, baseDepth, 0.05);
      PImage diff2 = diffImages(liveIR, baseIR, 0.05);
      for (int i = 0; i < h; i++) {
        if(flag&&!a.isEmpty()){
          temp.add(a);
          a = new ArrayList<ArrayList<Integer>>();
        }
        flag = true ;
        for (int j = 0; j < w; j++) {
          
          // if the pixel is selected on either ir or depth frames, mark it as hand
          if (int(red(diff1.pixels[i*w+j])) != 0 || int(red(diff2.pixels[i*w+j])) != 0) {
            // discard noise at the edges ('offset' px)
            int offset = 10;
            
            if (i > offset && i < h-offset && j > offset && j < w-offset){
              diff.pixels[i*w+j] = color(255, 255, 255);
              ArrayList<Integer> b = new ArrayList<Integer>();
              b.add(j);
              b.add(i);
              a.add(b);
              flag = false;   
            }
          }
        }
      }
      fingers.clear();
      
      if(!temp.isEmpty()){
        for(ArrayList<ArrayList<Integer>> corners : temp){
          
          int counter = 0;
          for(ArrayList<Integer> j:corners) {
             float baseDepthColor = averageImageRegion(baseDepth, 11, j.get(1), j.get(0));
             float liveDepthColor = averageImageRegion(liveDepth, 11, j.get(1), j.get(0));
             float fingerPosX = map(j.get(0), 0, w, GeoToScreenCoordinates(extent_lon_min,extent_lat_min).x, GeoToScreenCoordinates(extent_lon_max,extent_lat_min).x);
             float fingerPosY = map(j.get(1), 0, h, GeoToScreenCoordinates(extent_lon_min,extent_lat_max).y, GeoToScreenCoordinates(extent_lon_min,extent_lat_min).y);
             if(!(fingerPosX>=acceptableX[0]&&fingerPosX<=acceptableX[1]&&fingerPosY>=acceptableY[0]&&fingerPosY<=acceptableY[1])&&!fingers.isEmpty()){
               /*if(fingers.size()<=counter)
                 fingers.clear();
               else{
                 //println("size "+fingers.size()+"  "+counter);
                 for(int k = 0; k<counter;k++)
                   fingers.remove(fingers.size()-1);
                 counter=0;
               }*/
             }
             else{
               Finger fin = new Finger(fingerPosX, fingerPosY, baseDepthColor-liveDepthColor);
                    
               fingers.add(fin);
               counter++;
             }
          }
        }
      }
      walls=(ArrayList<Finger>)fingers.clone();
      
      
     // diff.save("C:\\Users\\VisDemo\\Desktop\\yasin findik\\New folder\\test\\Tangy\\ya.jpg");
      // update the depth threshold beyond which we'll look for fingers
      
      
      
    }
  }

  // SUBSTRACTS TWO IMAGE'S ("i" and "j") PIXELS BY ALLOWING "_r" DIFFERENCE
  private PImage diffImages(PImage i, PImage j, float _r) {
    PImage diff = new PImage(i.width, i.height);

    for (int ii = 0; ii < diff.height; ii++) {
      for (int jj = 0; jj < diff.width; jj++) {
        float i_red = map(red(i.pixels[ii*i.width+jj]), 0, 255, 0, 1);
        float j_red = map(red(j.pixels[ii*j.width+jj]), 0, 255, 0, 1);
        float r = abs(i_red-j_red);
        if (r > _r) {
          diff.pixels[ii*i.width+jj] = color(255, 255, 255);
        }
      }
    }
    return diff;
  }

  // CONVERTS GLOBAL DEPTH IMAGE COORDINATES TO ROI COORDINATES
  private int mapOriginalIndexToROI(int row, int col) 
  {
    return int((row+roi_origin_y)*(kinect.WIDTHDepth)+(col+roi_origin_x)+(roi_width-1-2*col));
  }

  // AVERAGES IMAGE PIXELS CENTERED AROUND ("row","col") WITH A KERNEL WHOSE SIZE IS "size"
  private float averageImageRegion(PImage p, int size, int row, int col) 
  {
    if (size % 2 != 1) {
      println("ERROR: Size should be an odd number!!");
      exit();
      return 0;
    }

    float sum = 0;
    for (int i = -size/2; i <= size/2; i++) {
      for (int j = -size/2; j <= size/2; j++) {
        sum += red(p.pixels[(row+i)*p.width+(col+j)]);
      }
    }

    return sum/(size*size);
  }

  // AVERAGE EACH PIXEL OF THE IMAGE
  private float averageImagePixels(PImage p) 
  {
    float sum=0;
    for (int i = 0; i < p.width*p.height; i++) {
      sum+=p.pixels[i];
    }
    return sum/(p.width*p.height);
  }
};

class Finger
{
  // Position's are normalized between 0 and 100
  private float x; 
  private float y;

  // Whether finger is touching or not
  private float touchParam;

  // Constructor
  public Finger(float x, float y, float t) {
    this.x = x;
    this.y = y;
    this.touchParam = t;
  }

  // if touchParam is smaller than 0.1, it means touch
  public boolean isTouching(float k) {
    return touchParam < k;
  }
   public boolean isTouching() {
    return abs(touchParam) < 0.05||touchParam<=0;
    
  }

  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public float getTouchParam() {
    return touchParam;
  }
};