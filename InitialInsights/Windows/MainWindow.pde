class MainWindow{
  private int cornerX;
  private int cornerY;
  private int widthWindow;
  private int heightWindow;
  private boolean position;
  private int currentMode = 0; //0 p, 1 w , 2 s
  private ArrayList<Button> buttons ; 
  private Button wr=null;//olayi farkli oldugu ic
  private color wrColor = color(255,0,0);
  private boolean wrColorRed=true;
  private boolean wrClicked=false;
  private int wrTime=0;
  private boolean buttonMutex = false;
  private int ss=0;
 
  PGraphics frame = new PGraphics();
  
  
  //private int selectionPadX = 70;
 // private int selectionPadY = 5; 
  private int []selectionX = new int[2];
  private int []selectionY = new int[2];
  private Selection selection;
  private PImage img;
  
  private FingerFinder tracker;
  
  
  private ArrayList<Wall> walls = new ArrayList<Wall>();
  private ArrayList<Finger> wallsFromKinect;
  
  private ArrayList<StartPoint> startPoints = new ArrayList<StartPoint>();
  private ArrayList<EndPoint> endPoints = new ArrayList<EndPoint>();
  private ArrayList<Agent>agents = new ArrayList<Agent>();
  
  private StartPoint clickedStartPoint = null;
  private EndPoint clickedEndPoint = null;
  private int id;
  
  private Windtunnel wt =null;
  private int timeForWind = 0;
  private int timeBreak = 2000;
  private boolean showHeatmap =false;
  
  MainWindow(int cornerX, int cornerY,int widthWindow,int heightWindow,boolean position,String image,FingerFinder tracker,int id){
    this.id=id;
    this.cornerX = cornerX;
    this.cornerY = cornerY;
    this.position = position;
    this.widthWindow = widthWindow;
    this.heightWindow = heightWindow;
    this.tracker = tracker;
    buttons = new ArrayList<Button>();
    
   
    selectionX[0] = cornerX+2;
    selectionY[0] = cornerY;
    selectionX[1] = cornerX+widthWindow-2;
    selectionY[1] = cornerY+heightWindow;
    
    selection = new Selection(0.3,selectionX,selectionY);
    selection.clear();
    selection.setEnable(true);
    
    this.img = loadImage(image);
    frame = createGraphics(widthWindow, heightWindow);
    frame.beginDraw();
    frame.background(0, 0);
    frame.endDraw();
    createButtons();
  }
  public void setImg(PImage img){
     this.img = img;
    
  }
  public Selection getSelection(){
    return selection;
  }
  public boolean getShowHeatmap(){
    return showHeatmap;
  }
  public int getId(){
    return id;
  }
  public int getCurrentMode(){
    return currentMode;
  }
  public ArrayList<Agent> getAgents(){
    return agents;
  }
  public ArrayList<StartPoint> getStartPoints(){
    return (ArrayList<StartPoint>)startPoints.clone();
  }
  public  ArrayList<EndPoint> getEndPoints(){
    return ( ArrayList<EndPoint>)endPoints.clone();
  }
  public ArrayList<Wall> getWalls(){
    return (ArrayList<Wall>)walls.clone();
  }
  private void showImageWithOpacity(PGraphics i){
    tint(255, 127);
    pApplet.image(i,cornerX,cornerY,widthWindow,heightWindow);
    noTint();
  }
  private color randomColorGen(){
    float R = random(20,235);
    float G = random (20,235);
    float B = random (20,235);
    return color(R,G,B);
  }
  public void action(){
     try{
    switch(currentMode){
      case 0:
        selection.setDrawFlag(true);
        if(selection.getVertices()!=null){
          buttons.get(4).setEnable(true);
        }
        else{
          buttons.get(4).setEnable(false);
        }
        drawWalls();
        drawEndPoints();
        drawStartPoints();
        drawAgents();
        if(!buttons.get(3).isEnabled()){
          createWalls();
          if(agents.size()!=0){
            agents.clear();
            for(StartPoint startPoint : startPoints){
              startPoint.clearPaths();
              for(EndPoint endPoint : startPoint.getEndPoints()){
                  createAgent(startPoint,endPoint);
              }
            }
            
          }
          
          buttons.get(3).setEnable(true);
        }
        
        break;
      
      case 1:
        drawWalls();
        selection.setDrawFlag(false);
        if(wt==null){
          selection.clear();
          wt = new Windtunnel(cornerX,cornerY,widthWindow,heightWindow,selection);
          wt.setup(walls);
        }
        if(!buttons.get(3).isEnabled()){
          createWalls();
          buttons.get(3).setEnable(true);
          selection.clear();
          wt.setup(walls);
        }
        if(wt.getHeatmapNeeded()){
          if((millis()-timeForWind>timeBreak)||timeForWind==0){
            timeForWind=millis();
            wt.takeVectors(ss); 
            ss++;
          }
        }
        
        else if(showHeatmap&&wt.getCanShowHeatmap()){
          showImageWithOpacity(wt.getHeatmap());
        }
        
        if(!buttons.get(4).isEnabled()&&wt.getCanShowHeatmap()){
          buttons.get(4).setEnable(true); 
        }
        else if(buttons.get(4).isEnabled()&&!wt.getCanShowHeatmap()){
          buttons.get(4).setEnable(false);
        }
        
        if(!showHeatmap)
          wt.draw();
        break;
      
    }
     }catch(Exception e){println("action ex");}
  }
  private void drawAgents(){
    ArrayList<Agent> temp = new ArrayList<Agent>();
    ArrayList<Agent> deleted = new ArrayList<Agent>();
    for(Agent agent : agents){
      if(!(endPoints.contains(agent.getEndPoint())&&startPoints.contains(agent.getStartPoint()))){
        deleted.add(agent);
        continue;
      }
      int random = int(random(40,agent.getPath().size()));
      if(!agent.getIsCreateBack()&&random<=agent.getPathIndex()){
        StartPoint currentStartPoint = agent.getStartPoint();
        ArrayList<EndPoint> currentEndPoints = currentStartPoint.getEndPoints();
        int r = int(random(0,currentEndPoints.size()));
        Agent newAgent = new Agent(cornerX,cornerY,diameter,agent.getColor(),currentEndPoints.get(r),currentStartPoint);
        newAgent.setPath(currentStartPoint.getPath(r));
        agent.setIsCreateBack(true);
        temp.add(newAgent);
      }
      agent.display(); 
    }
    agents.removeAll(deleted);
    agents.addAll(temp);
  }
  private void drawEndPoints(){
    for(EndPoint endPoint : endPoints){
      endPoint.display(); 
    }
  }
  private void drawStartPoints(){
    for(StartPoint startPoint : startPoints){
      startPoint.display(); 
    }
  }
  private void drawWalls(){
    for(Wall wall: walls){
      wall.display();  
    }
  }
  
  public void drawSelection(){
    selection.draw(); 
  }
  
  public void drawFrame(){
     pApplet.line(cornerX, cornerY, cornerX+widthWindow, cornerY);
     pApplet.line(cornerX+widthWindow, cornerY, cornerX+widthWindow, cornerY+heightWindow);
     pApplet.line(cornerX, cornerY, cornerX, cornerY+heightWindow);
     pApplet.line(cornerX,  cornerY+heightWindow, cornerX+widthWindow, cornerY+heightWindow); 
  }
  public void drawImage(){
    
      frame.beginDraw();
      frame.translate(widthWindow, heightWindow);
      frame.rotate(PI);
      frame.image(img,0,0,widthWindow,heightWindow);
      frame.endDraw();
      pApplet.image(frame,(cornerX),(cornerY),widthWindow,heightWindow);
  }
  
  public void drawButtons(){
    while(buttonMutex);
    buttonMutex=true;
    for(Button button : buttons){
      button.draw(); 
    }
    if(wr != null){
      if(wrClicked&&((millis()-wrTime)/1000)!=0&&((millis()-wrTime)/1000)%2==0){
        wrColor = color(255,255,255);
        wrTime=millis();
        wrColorRed=!wrColorRed;
      }
      else if(wrClicked&&((millis()-wrTime)/1000)!=0&&((millis()-wrTime)/1000)%2!=0){
        wrColor = color(255,0,0);
        wrColorRed=!wrColorRed;
      }
      
      wr.draw(wrColor);
      
    }
    buttonMutex=false;
  }
  private void createButtons(){// ters/duz
    int distanceButton=2;
    buttons.add(new Button(this, "toggle_S", cornerX+buttonSize+buttonSize*buttons.size()*distanceButton, cornerY+heightWindow-buttonSize, buttonSize, 0.5,"S",position,0));
    buttons.add(new Button(this, "toggle_W", cornerX+buttonSize+buttonSize*buttons.size()*distanceButton, cornerY+heightWindow-buttonSize, buttonSize, 0.5,"W",position,0));
    buttons.add(new Button(this, "toggle_P", cornerX+buttonSize+buttonSize*buttons.size()*distanceButton, cornerY+heightWindow-buttonSize, buttonSize, 0.5,"P",position,0));
    buttons.add(new Button(this, "toggle_Find", cornerX+widthWindow-buttonSize, cornerY+buttonSize, buttonSize*4, 0.5,"",position,5));
    
    //for P
    buttons.add(new Button(this, "toggle_Add", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"ADD SRC",position,1));
    buttons.get(buttons.size()-1).setEnable(false);
    buttons.add(new Button(this, "toggle_Clear", cornerX+buttonSize*5, cornerY+buttonSize*1, buttonSize*2, buttonSize*4,0.5,"CLEAR",position,1));
    buttons.get(2).setEnable(false);
    buttons.add(new Button(this, "toggle_TS", cornerX+buttonSize*8, cornerY+buttonSize*1, buttonSize*2, buttonSize*4,0.5,"SCREENSHOT",position,1));
    //selectiona buttonlar eklenıyor...
    for(Button button : buttons){
      selection.addButtonToExclude(button);  
    }
  }
  private boolean inArea(float x2,float y2){
    int i=0;
    for(Button button :buttons){
      float x1=button.getX();
      float y1=button.getY();
      float distx=button.getDistX()/2;
      float disty=(button.getDistY()==0)?distx:button.getDistY()/2;
      if(i==3)
      if(x2>x1-distx&&x2<x1+distx&&y2>y1-disty&&y2<y1+disty){
        return true; 
      }
      i++;
    }
    return false;
    
  }
  private void createWalls(){
    walls.clear();
    tracker.find(selectionX,selectionY);
    wallsFromKinect = (ArrayList<Finger>)(tracker.getFingers().clone());
    color c = randomColorGen();
    for(Finger wall:wallsFromKinect){
      if(!inArea(wall.getX(),wall.getY()))
      walls.add(new Wall(wall.getX(),wall.getY(),c));
    }
    buttons.get(3).setEnable(true);
    selection.clear();
  }
  private void clearAddButtons(){
    while(buttonMutex);
    buttonMutex=!buttonMutex;
    for(int i = buttons.size()-1;i>=4;i--){
      selection.removeButtonToExclude(buttons.get(i));
      buttons.get(i).setDeleted(true);
      buttons.remove(i);
    }
    buttons.add(new Button(this, "toggle_Add", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"ADD SRC",position,1));
      buttons.get(buttons.size()-1).setEnable(false);
      selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
      buttons.add(new Button(this, "toggle_Clear", cornerX+buttonSize*5, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"CLEAR",position,1));
      selection.addButtonToExclude(buttons.get(buttons.size()-1));
      
      buttons.add(new Button(this, "toggle_TS", cornerX+buttonSize*8, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"SCREENSHOT",position,1));
      selection.addButtonToExclude(buttons.get(buttons.size()-1));
    buttonMutex=!buttonMutex; 
    
  }
   private void createAgent(StartPoint startPoint,EndPoint endPoint){ //<>// //<>//
    Maze maze = new Maze(widthWindow,heightWindow,walls,cornerX+5,cornerY+5,round(startPoint.x)-cornerX,round(startPoint.y)-cornerY,round(endPoint.x)-cornerX,round(endPoint.y)-cornerY,diameter/2) ; 
    Agent currentAgent = new Agent(cornerX,cornerY,diameter,endPoint.getColor(),endPoint,startPoint);
    ArrayList<Cell> currentPath = maze.solveMaze();
    startPoint.addPath(currentPath);
    currentAgent.setPath(currentPath);
    agents.add(currentAgent);
  }
  public void onClick_toggle_P()
  {
   
    buttons.get(2).setEnable(false);
    buttons.get(0).setEnable(true);
    buttons.get(1).setEnable(true);
    while(buttonMutex);
    buttonMutex=!buttonMutex;
    if(buttons.size()>4){
     
      if(wr!=null){
        wr.setDeleted(true);
        selection.removeButtonToExclude(wr);
        wr=null;
      }
      for(int i = buttons.size()-1;i>=4;i--){
        selection.removeButtonToExclude(buttons.get(i));
        buttons.get(i).setDeleted(true);
        buttons.remove(i);
      }
    }
    
    
    buttons.add(new Button(this, "toggle_Add", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"ADD SRC",position,1));
    buttons.get(buttons.size()-1).setEnable(false);
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttons.add(new Button(this, "toggle_Clear", cornerX+buttonSize*5, cornerY+buttonSize*1,  buttonSize*2, buttonSize*4,0.5,"CLEAR",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1));
    
    buttons.add(new Button(this, "toggle_TS", cornerX+buttonSize*8, cornerY+buttonSize*1,  buttonSize*2,buttonSize*4,0.5,"SCREENSHOT",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1));
    buttonMutex=!buttonMutex;
    currentMode = 0;
    for(StartPoint startPoint: startPoints){
      startPoint.setButtonEnable(true);
    }
    for(EndPoint endPoint: endPoints){
      endPoint.setButtonEnable(true);
    }
  }
  public void onClick_toggle_W()
  {
   
    selection.clear();
    buttons.get(0).setEnable(true);
    buttons.get(2).setEnable(true);
    buttons.get(1).setEnable(false);
    while(buttonMutex);
    buttonMutex=!buttonMutex;
    if(buttons.size()>4){
      for(int i = buttons.size()-1;i>=4;i--){
        selection.removeButtonToExclude(buttons.get(i));
        buttons.get(i).setDeleted(true);
        buttons.remove(i);
      }
    }
    String shTitle ="BACK";
    if(!showHeatmap){
      shTitle="HEATMAP";
      wr = new Button(this, "toggle_WR", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"RECORD",position,1);
      selection.addButtonToExclude(wr);
    }
    Button sh = new Button(this, "toggle_SH", cornerX+buttonSize*5, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,shTitle,position,1);
    sh.setEnable(false);
    buttons.add(sh);
    selection.addButtonToExclude(sh);
   
    buttons.add(new Button(this, "toggle_TS", cornerX+buttonSize*8, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"SCREENSHOT",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1));
    
    buttonMutex=!buttonMutex;
    currentMode = 1;
    for(StartPoint startPoint: startPoints){
      startPoint.setButtonEnable(false);
    }
    for(EndPoint endPoint: endPoints){
      endPoint.setButtonEnable(false);
    }
  }
  public void onClick_toggle_S(){
    
    buttons.get(2).setEnable(true);
    buttons.get(0).setEnable(false);
    buttons.get(1).setEnable(true);
    if(buttons.size()>4){
      
      while(buttonMutex);
      buttonMutex=!buttonMutex;
      for(int i = buttons.size()-1;i>3;i--){
        selection.removeButtonToExclude(buttons.get(i));
        buttons.get(i).setDeleted(true);
        buttons.remove(i);
      }
      if(wr!=null){
        wr.setDeleted(true);
        selection.removeButtonToExclude(wr);
        wr=null;
      }
      buttonMutex=!buttonMutex;
    }
    for(StartPoint startPoint: startPoints){
      startPoint.setButtonEnable(false);
    }
    for(EndPoint endPoint: endPoints){
      endPoint.setButtonEnable(false);
    }
    currentMode = 2;
  }
  public void onClick_toggle_WR(){
    wrClicked=!wrClicked;
    if(wrClicked){
      
      wrColor =color(255,255,255);
      wrTime=millis();
      
      wt.clearVectors();
      
       ss=0;
      wt.setHeatmapNeeded(true);
      wt.setCanShowHeatmap(false);
    }
    else{
      wrColor =color(255,0,0);
      wrTime=0;
      timeForWind=0;
      wt.calcHeatmap();
      wt.clearVectors();
      wt.setCanShowHeatmap(true);
      wt.setHeatmapNeeded(false);
    }
  }
  public void onClick_toggle_SH(){
    showHeatmap=!showHeatmap;
    if(showHeatmap){
      wr.setDeleted(true);
      selection.removeButtonToExclude(wr);
      wr = null;
      buttons.get(4).setTitle("BACK");
    }
    else{
      wr = new Button(this, "toggle_WR", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"RECORD",position,1);
      
      selection.addButtonToExclude(wr);
      buttons.get(4).setTitle("HEATMAP");
    }
  }
  public void onClick_toggle_Find()
  {
    buttons.get(3).setEnable(false);
    
  }
  public void onClick_toggle_Add()
  {
    if(buttons.get(4).getTitle().equals("ADD SRC")){
      startPoints.add(new StartPoint(selection.getVertices().get(0).x,selection.getVertices().get(0).y,buttonSize,randomColorGen(),this,selection));
      buttons.get(4).setTitle("ADD DST"); 
    }
    else{ //<>// //<>//
      StartPoint currentStartPoint = startPoints.get(startPoints.size()-1);
       EndPoint currentEndPoint = new EndPoint(selection.getVertices().get(0).x,selection.getVertices().get(0).y,buttonSize,startPoints.get(startPoints.size()-1).getColor(),this,selection);
      if((currentStartPoint.getX()!=currentEndPoint.getX())&&
      (currentStartPoint.getY()!=currentEndPoint.getY())){ 
       //<>// //<>//
      currentStartPoint.addEndPoint(currentEndPoint);

       
      endPoints.add(currentEndPoint);
      createAgent(currentStartPoint,currentEndPoint);
      buttons.get(4).setTitle("ADD SRC");
      }
    }
  }
  public void onClick_toggle_TS()
  {
    if(id==1){
      screenShotR=true;
    }
    if(id==0){
      screenShotL=true;
    }
    delay(1000);
  }
  public void onClick_toggle_Clear()
  {
    selection.clear();
    for(EndPoint endpoint: endPoints){
      endpoint.setDeleted(true);
    }
    endPoints.clear();
   
    for(StartPoint startPoint: startPoints){
      startPoint.setDeleted(true);
    }
    startPoints.clear();
    agents.clear();
    buttons.get(4).setTitle("ADD SRC");
    delay(1000);
  }
  public void onClick_toggle_CallFromEndPoint(EndPoint endPoint)
  {
    clickedEndPoint = endPoint;
    clickedStartPoint =null;
    while(buttonMutex);
    buttonMutex=!buttonMutex;
    for(int i = buttons.size()-1;i>=4;i--){
        selection.removeButtonToExclude(buttons.get(i));
        buttons.get(i).setDeleted(true);
        buttons.remove(i);
    }
    buttons.add(new Button(this, "toggle_AddStartPoint", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"ADD SRC",position,1));
    buttons.get(buttons.size()-1).setEnable(false);
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttons.add(new Button(this, "toggle_DeleteEndPoint", cornerX+buttonSize*5, cornerY+buttonSize*1, buttonSize*2, buttonSize*4,0.5,"DELETE",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttons.add(new Button(this, "toggle_BackEndPoint", cornerX+buttonSize*8, cornerY+buttonSize*1, buttonSize*2, buttonSize*4,0.5,"BACK",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttonMutex=!buttonMutex;
    
  }
  public void onClick_toggle_CallFromStartPoint(StartPoint startPoint)
  {
    clickedEndPoint =null;
    clickedStartPoint =startPoint;
    while(buttonMutex);
    buttonMutex=!buttonMutex;
    for(int i = buttons.size()-1;i>=4;i--){
        selection.removeButtonToExclude(buttons.get(i));
        buttons.get(i).setDeleted(true);
        buttons.remove(i);
    }
    buttons.add(new Button(this, "toggle_AddEndPoint", cornerX+buttonSize*2, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"ADD DST",position,1));
    buttons.get(buttons.size()-1).setEnable(false);
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttons.add(new Button(this, "toggle_DeleteStartPoint", cornerX+buttonSize*5, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"DELETE",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttons.add(new Button(this, "toggle_BackStartPoint", cornerX+buttonSize*8, cornerY+buttonSize*1, buttonSize*2,buttonSize*4, 0.5,"BACK",position,1));
    selection.addButtonToExclude(buttons.get(buttons.size()-1)); 
    buttonMutex=!buttonMutex;
  }
  public void onClick_toggle_AddEndPoint()
  {
    
    EndPoint currentEndPoint = new EndPoint(selection.getVertices().get(0).x,selection.getVertices().get(0).y,buttonSize,startPoints.get(startPoints.size()-1).getColor(),this,selection); //<>// //<>//
    StartPoint currentStartPoint = clickedStartPoint;
    currentStartPoint.addEndPoint(currentEndPoint);

     
    endPoints.add(currentEndPoint);
    createAgent(currentStartPoint,currentEndPoint);
  }
  
  public void onClick_toggle_DeleteStartPoint()
  {
    startPoints.remove(clickedStartPoint);
    clickedStartPoint.setDeleted(true);
    for(EndPoint endPoint:clickedStartPoint.getEndPoints()){
      boolean flag = false;
      for(StartPoint startPoint: startPoints){
        if(startPoint.getEndPoints().contains(endPoint)){
          flag=true;
          break;
        }
      }
      if(flag)
        continue;
      endPoint.setDeleted(true);
      endPoints.remove(endPoint);
    }
    onClick_toggle_BackStartPoint();
  }
  
  public void onClick_toggle_BackStartPoint()
  {
    clickedStartPoint=null;
    clearAddButtons();
  }
  
  
  public void onClick_toggle_AddStartPoint()
  {
    StartPoint currentStartPoint = new StartPoint(selection.getVertices().get(0).x,selection.getVertices().get(0).y,buttonSize,startPoints.get(startPoints.size()-1).getColor(),this,selection); //<>// //<>//
    EndPoint currentEndPoint = clickedEndPoint;
    currentStartPoint.addEndPoint(currentEndPoint);
    startPoints.add(currentStartPoint);
    createAgent(currentStartPoint,currentEndPoint);
  }
  public void onClick_toggle_DeleteEndPoint()
  {
    endPoints.remove(clickedEndPoint);
    ArrayList <StartPoint> hasSingleEndPoint = new ArrayList <StartPoint> ();
    for(StartPoint startPoint: startPoints){
      if(startPoint.getEndPoints().contains(clickedEndPoint)){
        startPoint.getPath().remove(startPoint.getEndPoints().indexOf(clickedEndPoint));
        startPoint.getEndPoints().remove(clickedEndPoint);
       
        
      }
      if(startPoint.getEndPoints().size()==0){
        hasSingleEndPoint.add(startPoint);
      }
    }
    for(StartPoint startPoint:hasSingleEndPoint){
       startPoints.remove(startPoint); 
       startPoint.setDeleted(true);
    }
    endPoints.remove(clickedEndPoint);
    clickedEndPoint.setDeleted(true);
    onClick_toggle_BackEndPoint();
    
  }
  public void onClick_toggle_BackEndPoint()
  {
    clickedEndPoint=null;
    clearAddButtons();
  }
  
  public void onClick_toggle_back()
  {
    
  }
  void changeWindowScale(boolean zoom){
   
  }
  
  
  public void onClick_toggle_zoomIn()
  {
  }
  
  // Selection Type Button
  public void onClick_toggle_zoomOut()
  {
  }
  
  public void onClick_toggle_selection()
  {
  }
  public void onClick_toggle_findingObject()
  {
  }
  public void onClick_toggle_startEnd()
  {
  }
  public void onClick_toggle_replay()
  {
  }
  public void onClick_toggle_pushleft()
  {
  }
  public void onClick_toggle_clear()
  {
  }
  
}