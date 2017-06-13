import java.lang.reflect.Method;

class Button {
  private void handleException(Exception ex) {
    println("Disabling onClickEvent because of an error. Disabling button(id="+id+").");
    ex.printStackTrace();
    onClickEvent = null;
    enabled = false;
  }

  private Thread check = new Thread() {
    public void run() {
      while (!deleted) {
        if (evaluate()) {
          if (onClickEvent != null) {
            try {
              onClickEvent.invoke(parent);
               sleep(50);
            } 
            catch (Exception ex) { 
              handleException(ex);
            }
          }
        }

        try {
          sleep(10);
        } 
        catch(Exception e) {
          print("ex");
        }
      }
    };
  };
  private Method onClickEvent;
  private Object parent;
  private String id;

  private boolean enabled = true;
  private boolean deleted = false;
  private float successRate = 0.7;
  private String name;

  private int threshold;
  private int confidence = 0;
  private int timeoutMillis;
  private int startMillis;
  private boolean isWorking = false;

  // origin locations for display
  private float x;
  private float y;
  private float r;
  private float r2=0;
  private boolean position;
  private int type;
  public Button(Object parent, String id, float x, float y, float r, float s, String name,boolean position,int type) { //0for cycle, 1 for rect, 2for wind,3for p,4for heat
    this.x=x;
    this.y=y;
    this.r=r;
    this.position = position;
    this.timeoutMillis = (int)(s*1000);
    this.name = name;
    this.enabled = true;
    this.type = type;
    this.threshold = int((60*successRate)*s);

    try {
      this.id = id;
      this.parent = parent;
      this.onClickEvent = parent.getClass().getMethod("onClick_"+id);
    } 
    catch (Exception ex) { 
      handleException(ex);
    }

    this.check.start();
  }
  public Button(Object parent, String id, float x, float y, float r1,float r2, float s, String name,boolean position,int type) { //0for cycle, 1 for rect, 2for wind,3for p,4for heat
    this.x=x;
    this.y=y;
    this.r=r1;
    this.r2=r2;
    this.position = position;
    this.timeoutMillis = (int)(s*1000);
    this.name = name;
    this.enabled = true;
    this.type = type;
    this.threshold = int((60*successRate)*s);

    try {
      this.id = id;
      this.parent = parent;
      this.onClickEvent = parent.getClass().getMethod("onClick_"+id);
    } 
    catch (Exception ex) { 
      handleException(ex);
    }

    this.check.start();
  }

  public float getX() {
    return this.x;
  }
  public float getDistX() {
    return this.r;
  }
  public float getDistY() {
    return this.r2;
  }
  public void setX(float x) {
    this.x = x;
  }
  public float getY() {
    return this.y;
  }
  public void setY(float y) {
    this.y = y;
  }
  public float getRadius() {
    return this.r;
  }
  public void setRadius(float r) {
    this.r = r;
  }
  public int getTimeout() {
    return this.timeoutMillis;
  }
  public void setTimeout(float s) {
    this.timeoutMillis = (int)(s*1000);
    threshold = int((60*successRate)*s);
  }
  public String getTitle() {
    return this.name;
  }
  public int getType() {
    return this.type;
  }
  public void setTitle(String s) {
    this.name = s;
  }

  public boolean isEnabled() {
    return this.enabled;
  }
  public void setEnable(boolean b) {
    this.enabled = b;
  }
  
  public void setDeleted(boolean b) {
    this.deleted = b;
  }

  private synchronized boolean evaluate() 
  {
    
    if (enabled) 
    { 
      try {
        ArrayList<Finger> arr = tracker.getFingers();
        for (int i = 0; i < arr.size(); i++) {
          Finger f = arr.get(i);
          float xPos = f.getX();
          float yPos = f.getY();
          
          if (sqrt(pow(yPos-y, 2)+pow(xPos-x, 2)) <= r*0.5)
          {
            if (!isWorking) {
              startMillis = millis();
              isWorking = true;
            }
            if (f.isTouching()) 
              confidence++;
          }
        }
      }
      catch(Exception e) {
      }
    }

    if (isDown()) {
      return true;
    }
    return false;
  }

  private boolean isDown() {
    if (isWorking && confidence > threshold && millis() - startMillis >= timeoutMillis)
    {
      this.confidence = 0;
      this.isWorking = false;
      return true;
    } else if (isWorking && millis() - startMillis > timeoutMillis) {
      this.confidence = 0;
      this.isWorking = false;
      return false;
    }
    return false;
  }

  public void draw() {
    float alpha = 125.0;  //Button enabled opacity
    if (!enabled)
      alpha = 80;        //Button disabled opacity

    if (isWorking)
    {
      if(type ==0)
      {
      // Draw outer ring
        strokeWeight(3);
        float num = map(confidence, 0, threshold, 50, 255);
        noFill();
        fill(50, num, 50, alpha);
        noStroke();
        ellipse(x, y, r, r);
      }
      else if(type == 1)
      {
         // Draw outer ring
        strokeWeight(3);
        float num = map(confidence, 0, threshold, 50, 255);
        noFill();
  
        // Draw inner circle
        fill(50, num, 50, alpha);
        noStroke();
        rectMode(CENTER);
        if(r2!=0)
          rect(x, y, r2/2, r/2); 
        else
          rect(x, y, r/2, r/2); 
      }
      else if(type ==5){
         strokeWeight(3);
        float num = map(confidence, 0, threshold, 50, 255);
        noFill();
  
        // Draw inner circle
        fill(50, num, 50, alpha);
        noStroke();
        rectMode(CENTER);
        rect(x, y, r/2, r/2); 
        //noFill();
        stroke(1);
        noFill();
        //fill(30, 30, 30, alpha);
        ellipse(x-5, y+5, r/5, r/5);
        ellipse(x-5, y+5, r/7, r/7);
        line(x-5+r/14,y+5-r/14,x+r/10+10,y-32+r/10);
        noStroke();
      }
    } else
    {
      if(type ==0){
        noFill();
        fill(50, 50, 50, alpha);
        noStroke();
        ellipse(x, y, r, r);
      }
      else if(type == 1)
      {
        noFill();
        fill(50, 50, 50, alpha);
        noStroke();
        rectMode(CENTER);
        if(r2!=0)
          rect(x, y, r2/2, r/2); 
        else
          rect(x, y, r/2, r/2); 
      }
      else if(type ==5){
        noFill();
        fill(50, 50, 50, alpha);
        noStroke();
        rectMode(CENTER);
        rect(x, y, r/2, r/2); 
        //noFill();
        stroke(1);
        noFill();
        //fill(30, 30, 30, alpha);
        ellipse(x-5, y+5, r/5, r/5);
        ellipse(x-5, y+5, r/7, r/7);
        line(x-5+r/14,y+5-r/14,x+r/10+10,y-32+r/10);
        noStroke();
      }
    }
  
    // Write title below
    float textSize = map(r, 10, 50, 5, 14);
    fill(0, alpha);
    textAlign(CENTER);
    if(r2==0)
      textSize(textSize);
    else
      textSize(8);
    textLeading(round(textSize));
    if(!position){
      pushMatrix();
      translate(x, y-textSize/2);
      rotate(PI);
      text(name,0, 0);
      translate(-x, -y+textSize/2);
      popMatrix();
    }
    else{
      //textSize(r/2);
      text(name,x, y+3);
    }
    //text(name,x, y);
    textSize(12);
    textAlign(LEFT);
    strokeWeight(1);
  }
  public void draw(color c) {
    float alpha = 125.0;  //Button enabled opacity
    if (!enabled)
      alpha = 80;        //Button disabled opacity

    if (isWorking)
    {
      if(type ==0)
      {
        noFill();
      // Draw outer ring
      strokeWeight(3);
      // Draw inner circle
      fill(c,alpha);
      noStroke();
      ellipse(x, y, r, r);
      }
      else if(type == 1)
      {
        noFill();
         // Draw outer ring
        strokeWeight(3);
        fill(c, alpha);
        noStroke();
        rectMode(CENTER);
        if(r2!=0)
          rect(x, y, r2/2, r/2); 
        else
          rect(x, y, r/2, r/2); 
      }
    } else
    {
      if(type ==0){
        noFill();
        fill(50, 50, 50, alpha);
        noStroke();
        ellipse(x, y, r, r);
      }
      else if(type == 1)
      {
        noFill();
        fill(c, alpha);
        noStroke();
        rectMode(CENTER);
        if(r2!=0)
          rect(x, y, r2/2, r/2); 
        else
          rect(x, y, r/2, r/2); 
      }
    }
    
    if(type==3){
      noFill();
      fill(c, alpha);
        
      triangle(x-r/4,y-r/4,x,y-r/2,x+r/4,y-r/4);
      noStroke();
      rectMode(CENTER);
      rect(x, y, r/2, r/2);
    }
    else if(type==4){
      noFill();
      fill(255,255,255, alpha);
      rectMode(CENTER);
      rect(x-(r/4), y-(r/4), r/2, r/2);
      
      
      fill(c, alpha);
      rectMode(CENTER);
      rect(x+(r/4), y-(r/4), r/2, r/2);
      
      
      fill(c, alpha);
      rectMode(CENTER);
      rect(x-(r/4), y+(r/4), r/2, r/2);
      
      
      fill(255,255,255, alpha);
      rectMode(CENTER);
      rect(x+(r/4), y+(r/4), r/2, r/2);
      noStroke();
    }
    else if(type==2){
     //noFill();
      fill(c, alpha);
      rect(x,y,r,r);
      noStroke();
    }
    
  
    // Write title below
    float textSize = map(r, 10, 50, 5, 14);
    fill(0, alpha);
    textAlign(CENTER);
    if(r2==0)
      textSize(textSize);
    else
      textSize(8);
    textLeading(round(textSize));
    if(!position){
      pushMatrix();
      translate(x, y-textSize/2);
      rotate(PI);
      text(name,0, 0);
      translate(-x, -y+textSize/2);
      popMatrix();
    }
    else{
      text(name,x, y);
    }
    textSize(12);
    textAlign(LEFT);
    strokeWeight(1);
  }
}