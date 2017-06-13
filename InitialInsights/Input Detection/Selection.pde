import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;

class Selection 
{
  private void reset()
  {
    confidence = 0;
    startMillis = -1;
    acceptPosition = null;
  }
  private void evaluate() 
  {
    if (enabled) 
    {
      ArrayList<Finger> fingers = tracker.getFingers();
      for (int i = 0; i < fingers.size(); i++) 
      {
        Finger item = fingers.get(i);

        float xPos = item.getX();
        float yPos = item.getY();

        // First touch
        if (item.isTouching() && acceptPosition == null && startMillis == -1)
        {
          acceptPosition = new PVector(xPos, yPos);
          startMillis = millis();
          confidence = 1;
        }

        // On touch
        if (item.isTouching() 
          && millis() - startMillis < timeoutMillis
          && acceptPosition.dist(new PVector(xPos, yPos)) < acceptRadius)
        {
          confidence++;
        }

        // Touch succesfull
        if (confidence >= threshold && millis()-startMillis >= timeoutMillis) // OK
        {
          ////// ON SUCCESSFULL TOUCH //////
          if (isAccept(acceptPosition)&&(acceptPosition.x>=acceptableX[0]&&acceptPosition.x<=acceptableX[1]&&acceptPosition.y>=acceptableY[0]&&acceptPosition.y<=acceptableY[1])) {
            
            PVector prevPos=null;
            if(!vertices.isEmpty())
              prevPos = vertices.get(0);
            else
              prevPos = acceptPosition;
            if (singlePointSelection)
              vertices.clear();
            vertices.add(acceptPosition);
            vertices.add(prevPos);
          } 
          //////////////////////////////////
          reset();
        } else if (millis()-startMillis >= timeoutMillis)  // threshold criterian failed
        {
          reset();
        }
      }
    }
  }
  // Whether the touch is made on an excluded area or not. 
  private boolean isAccept(PVector p) {
    for (Iterator<Button> it = excludedAreas.iterator(); it.hasNext(); ) {
      Button b = it.next();
      if (dist(p.x, p.y, b.getX(), b.getY()) <= b.getRadius()) {
        return false;
      }
    }
    return true;
  }
  private Thread check = new Thread() {
    public void run() {
      while (true) {
        try {
          evaluate();

          sleep(10);
        } 
        catch(Exception e) {
          println("THREAD ERROR ON SELECTION EVAL:");
          e.printStackTrace();
        }
      }
    };
  };

  private boolean enabled = false;
  private boolean drawFlag = true;
  private boolean singlePointSelection = true;

  private float successRate = 0.7;

  private int threshold;
  private int confidence = 0;
  private int timeoutMillis;
  private int startMillis = -1;
  private int acceptRadius = 50;
  private PVector acceptPosition = null;
  private int acceptableX[];
  private int acceptableY[];
  // origin locations for display
  private List<PVector> vertices; 

  // the parts of the selection area where selection is ignored
  private Set<Button> excludedAreas = new HashSet<Button>(); 

  public Selection(float s,int[] acceptableX,int[] acceptableY) {
    this.acceptableX = acceptableX;
    this.acceptableY = acceptableY;
    
    this.timeoutMillis = (int)(s*1000);
    this.threshold = int((60*successRate)*s);
    this.vertices = Collections.synchronizedList(new ArrayList<PVector>());
    this.check.start();
  }

  public int getTimeout() {
    return this.timeoutMillis;
  }
  public void setTimeout(float s) {
    this.timeoutMillis = (int)(s*1000);
    threshold = int((60*successRate)*s);
  }
  public boolean isEnabled() {
    return this.enabled;
  }
  public void setEnable(boolean b) {
    this.enabled = b;
  }
  public void setDrawFlag(boolean b) {
    this.drawFlag = b;
  }
  public boolean isSinglePointSelection() {
    return this.singlePointSelection;
  }
  public void setSinglePointSelection(boolean b) {
    this.singlePointSelection = b;
  }
  public void addButtonToExclude(Button b) {
    excludedAreas.add(b);
  }
  public void removeButtonToExclude(Button b) {
    excludedAreas.remove(b);
  }
  
  public void draw()
  {
    try {
      if (vertices.size() > 0) {
        // If vertex selection is enabled
        if (singlePointSelection == false) 
        {
          stroke(240, 240, 240, 150);
          fill(150, 150, 50, 60);
          beginShape();
          for (int i = 0; i < vertices.size(); i++) {
            PVector p = vertices.get(i);
            vertex(p.x, p.y);
          }
          endShape(CLOSE);
          for (int i = 0; i < vertices.size(); i++) {
            PVector p = vertices.get(i);
            noStroke();
            fill(240, 240, 240, 150);
            ellipse(p.x, p.y, 8, 8);
          }
        } 
        // If one point selection is enabled
        else if (singlePointSelection == true&&drawFlag)
        {
          if (vertices.size() != 0) 
          {
              // Outer ring
            strokeWeight(3);
            stroke(255, 150);
            noFill();
            ellipse(vertices.get(0).x, vertices.get(0).y, singlePointRadius*2.0+7, singlePointRadius*2.0+7);

            // Inner circle
            strokeWeight(1);
            stroke(255, 100);
            fill(150, 150, 50, 60);
            ellipse(vertices.get(0).x, vertices.get(0).y, singlePointRadius*2.0, singlePointRadius*2.0);
          }
        }
      }
    }
    catch(Exception e) {
      println("VERTICES ACCESS ERROR:");
      e.printStackTrace();
    }
  }

  public void clear() {
    try {
      vertices.clear();
    }
    catch(Exception e) {
      println("VERTICES CLEAR ERROR:");
      e.printStackTrace();
    }
  }

  public List<PVector> getVertices() {
    if (vertices.size() > 0)
    {
      return vertices;
    }
    return null;
  }


  private void drawOnSelect(PVector currentFinger) {
    float xPos = currentFinger.x;
    float yPos = currentFinger.y;

    // Draw legit touch area vaguely
    noStroke();
    fill(255, 255, 0, 20);
    ellipse(acceptPosition.x, acceptPosition.y, acceptRadius*2, acceptRadius*2);

    // If threshold condition is met, display it using color change
    if (confidence >= threshold)
      fill(0, 255, 0);
    else
      fill(255, 255, 0);
    // Progress bar on top of the finger
    rect(xPos+99, yPos - 40, 1, 5); // Right edge of bar
    float interpolatedWidth = map(millis(), startMillis, startMillis+timeoutMillis, 0, 100);
    rect(xPos, yPos - 40, interpolatedWidth, 5);       // The bar
    text(int(interpolatedWidth)+"%", xPos, yPos - 20); // Percent text
    noFill();
  }
}