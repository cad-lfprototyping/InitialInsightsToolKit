class EmptyWindow{
  private int cornerX;
  private int cornerY;
  private int widthWindow;
  private int heightWindow;
  private int buttonX;
  private int buttonY;
  private boolean position;
  private PImage img=null;
  private boolean imgP=false;
  private PImage imgWH=null;
  private PImage imgOthers=null;
  PGraphics frame = new PGraphics();
  private ArrayList<Button> buttons ; 
  
  private FingerFinder tracker;
  
  private int []selectionX = new int[2];
  private int []selectionY = new int[2];
  private Selection selection;
  private ArrayList<String> namesL = new ArrayList<String>();
  private ArrayList<String> namesR = new ArrayList<String>();
  private String []hs= new String[] {"",""};
  private String []ws= new String[] {"",""};
  private String []ps= new String[] {"",""};
  private ArrayList<EndPoint> endPointsL=new ArrayList<EndPoint>();
  private ArrayList<StartPoint> startPointsL=new ArrayList<StartPoint>();
  private ArrayList<Agent> agentsL=new ArrayList<Agent>();
  private ArrayList<Wall> wallsL=new ArrayList<Wall>();
  private ArrayList<EndPoint> endPointsR=new ArrayList<EndPoint>();
  private ArrayList<StartPoint> startPointsR=new ArrayList<StartPoint>();
  private ArrayList<Agent> agentsR=new ArrayList<Agent>();
  private ArrayList<Wall> wallsR=new ArrayList<Wall>();
  
  private boolean actionable =false;
  private int id;
  //private int index;
  private int cornersL[] = new int[2];
  private int cornersR[] = new int[2];
  EmptyWindow(int cornerX, int cornerY,int widthWindow,int heightWindow,boolean position,String image, FingerFinder tracker){
    
    this.cornerX = cornerX;
    this.cornerY = cornerY;
    this.position = position;
    this.widthWindow = widthWindow;
    this.heightWindow = heightWindow;
    this.tracker = tracker;
    buttons = new ArrayList<Button>();
    
    selectionX[0] = cornerX;
    selectionY[0] = cornerY;
    selectionX[1] = cornerX+widthWindow;
    selectionY[1] = cornerY+heightWindow;
    
    selection = new Selection(0.3,selectionX,selectionY);
    selection.clear();
    selection.setEnable(true);
    this.img = loadImage(image);
    frame = createGraphics(widthWindow, heightWindow);
    frame.beginDraw();
    frame.background(0, 0);
    frame.endDraw();
    
  }
  public void setCorners(int xl,int yl,int xr,int yr){
    cornersL[0]=xl;
    cornersL[1]=yl;
    cornersR[0]=xr;
    cornersR[1]=yr;
  }
  public void clearASE(int id){
    if(id==0){
      agentsL.clear();
      startPointsL.clear();
      endPointsL.clear();
      wallsL.clear();
    }
    if(id==1){
      agentsR.clear();
      startPointsR.clear();
      endPointsR.clear();
      wallsR.clear();
    }
  }
  public void clearH(int id){
    hs[id]="";
    imgWH=null;
  }
  public void clearW(int id){
    ws[id]="";
    imgWH=null;
  }
  public void addASE(ArrayList<Agent> agents,ArrayList<StartPoint> startPoints,ArrayList<EndPoint> endPoints,ArrayList<Wall> walls,int id){
    if(id==0){
      clearASE(id);
      for(Agent agent:agents){
        
        agentsL.add(agent.getCopy(cornerX,cornerY));
      }
      for(StartPoint startPoint:startPoints){
        startPointsL.add(startPoint.getCopy(cornersL[0],cornersL[1],cornerX,cornerY));
      }
      for(EndPoint endPoint:endPoints){
        endPointsL.add(endPoint.getCopy(cornersL[0],cornersL[1],cornerX,cornerY));
      }
      for(Wall wall:walls){
        wallsL.add(wall.getCopy(cornersL[0],cornersL[1],cornerX,cornerY));
      }
    }
    else{
      clearASE(id);
      for(Agent agent:agents){
        agentsR.add(agent.getCopy(cornerX,cornerY));
      }
      for(StartPoint startPoint:startPoints){
        startPointsR.add(startPoint.getCopy(cornersR[0],cornersR[1],cornerX,cornerY));
      }
      for(EndPoint endPoint:endPoints){
        endPointsR.add(endPoint.getCopy(cornersR[0],cornersR[1],cornerX,cornerY));
      }
      for(Wall wall:walls){
        wallsR.add(wall.getCopy(cornersL[0],cornersL[1],cornerX,cornerY));
      }
    }
  }
  public void addName(String name,int id,int currentMode,boolean isHeatMap){
    if(currentMode==1&&isHeatMap){
      if(hs[id]!=""){
        if(id==0)
           namesL.add(0,hs[id]);
        else if(id==1)
           namesR.add(0,hs[id]);
      }
      hs[id] = name;  
    }
    else if(currentMode==1){
      if(ws[id]!=""){
        if(id==0)
           namesL.add(0,ws[id]);
        else if(id==1)
           namesR.add(0,ws[id]);
      }
      ws[id] = name;  
    }
    else if(currentMode==0){
      if(ps[id]!=""){
        if(id==0)
           namesL.add(0,ps[id]);
        else if(id==1)
           namesR.add(0,ps[id]);
      }
      ps[id] = name;  
    }
  }
  public void action(){
    if(!imgP&&imgWH==null&&imgOthers==null){
      
      drawImage();
    }
    else{
      if(id==0)
        show(cornersL);
      else{
        show(cornersR);
      } 
    }
  }
  private void show(int[]corners){
        
        if(imgWH!=null){
          PImage temp = imgWH.get(corners[0],corners[1],widthWindow,heightWindow);
          PGraphics frame2 = createGraphics(widthWindow, heightWindow);
          frame2.beginDraw();
          frame2.background(0, 0);
          frame2.translate(widthWindow, heightWindow);
          frame2.rotate(PI);
          frame2.image(temp,0,0,widthWindow,heightWindow);
          frame2.endDraw();
          pApplet.image(frame2,(cornerX),(cornerY),widthWindow,heightWindow);
        }
        if(imgP){
          if(imgWH==null)
            drawImage();
          drawAgent();
          drawStartPoint();
          drawEndPoint();
          drawWall();
        }
  }
  public void drawAgent(){
    if(id==0)
    {
      for(Agent agent:agentsL){
        agent.display2();  
      }
    }
    else if(id==1)
    {
      for(Agent agent:agentsR){
        agent.display2();  
      }
    }
  }
  public void drawStartPoint(){
    if(id==0)
    {
      for(StartPoint startPoint:startPointsL){
        startPoint.display2();  
      }
    }
    else if(id==1)
    {
      for(StartPoint startPoint:startPointsR){
        startPoint.display2();  
      }
    }
  }
  public void drawWall(){
    if(id==0)
    {
      for(Wall wall:wallsL){
        wall.display2(id);  
      }
    }
    else if(id==1)
    {
      for(Wall wall:wallsR){
        wall.display2(id);  
      }
    }
  }
  public void drawEndPoint(){
    if(id==0)
    {
      for(EndPoint endPoint:endPointsL){
        endPoint.display2();  
      }
    }
    else if(id==1)
    {
      for(EndPoint endPoint:endPointsR){
        endPoint.display2();  
      }
    }
  }
  public void drawImage(){
    
      frame.beginDraw();
      frame.image(img,0,0,widthWindow,heightWindow);
      pApplet.image(frame,(cornerX),(cornerY),widthWindow,heightWindow);
  }
  
  public void drawFrame(){
     pApplet.line(cornerX, cornerY, cornerX+widthWindow, cornerY);
     pApplet.line(cornerX+widthWindow, cornerY, cornerX+widthWindow, cornerY+heightWindow);
     pApplet.line(cornerX, cornerY, cornerX, cornerY+heightWindow);
     pApplet.line(cornerX,  cornerY+heightWindow, cornerX+widthWindow, cornerY+heightWindow); 
  }
  public void deleteImg2(){
    imgP=false;
  }
  public void deleteImg3(){
    imgWH=null;
  }
  public void deleteImgOthers(){
    imgOthers=null;
  }
  public void setActionable(boolean b){
    this.actionable=b;
  }
  public void setIdIndex(int id, int index){
    this.id = id;
   if(index<0){
     switch(index){
        case -1:
          this.imgP = true;
          actionable=true;
          break;
        case -2:
          if(ws[id]!=""){
            this.imgWH = loadImage(ws[id]);
            
            actionable=true;
          }
          else{
            this.imgWH=null;
            actionable=false;
          }
          break;
        case -3:
          if(hs[id]!=""){
            this.imgWH = loadImage(hs[id]);
            actionable=true;
          }
          else{
            this.imgWH=null;
            actionable=false;
          }
          break;
        case -4:break;
        default:
          actionable = false;
          break;
     }
     
   }else{
      if(id==0)
        if(index<namesL.size()){
          this.imgOthers = loadImage(namesL.get(index));
          actionable=true;
        }
        else
           actionable=false;
      else{
         if(index<namesR.size()){
           this.imgOthers = loadImage(namesR.get(index));
           actionable=true;
         }
         else
           actionable=false;
      }
   }
  }
}