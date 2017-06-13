class Agent {
  private ArrayList<Cell> path;
  private int pathIndex;
  private int x;
  private int y;
  private int baseX;
  private int baseY;
  private int diameter;
  private boolean isCreateBack;
  private color c;
  private EndPoint endPoint;
  private StartPoint startPoint;
  
  Agent(int baseX,int baseY,int diameter,color c,EndPoint endPoint,StartPoint startPoint){
    this.baseX = baseX;
    this.baseY = baseY;
    this.diameter = diameter;
    this.isCreateBack=false;
    this.endPoint = endPoint;
    this.startPoint=startPoint;
    this.c = c ;
  }
  Agent(int baseX,int baseY,int diameter,color c,int x,int y){
    this.baseX = baseX;
    this.baseY = baseY;
    this.x=x;
    this.y=y;
    this.diameter = diameter;
    this.isCreateBack=false;
    this.endPoint = endPoint;
    this.startPoint=startPoint;
    this.c = c ;
  }
  public Agent getCopy(int nBaseX,int nBaseY){
    Agent a = new Agent(nBaseX,nBaseY,diameter,c,x,y);
    return a;
  }
  public void setBaseX(int baseX){
    this.baseX = baseX;
  }
  public void setBaseY(int baseY){
    this.baseY = baseY;
  }
  public void setPathIndex(int pathIndex){
    this.pathIndex = pathIndex;
  }
  public EndPoint getEndPoint(){
    return endPoint; 
  }
  public StartPoint getStartPoint(){
    return startPoint; 
  }
  public color getColor(){
    return c;
  }
  public void setPath(ArrayList<Cell> path){
    this.path = path;
    pathIndex = 1;
  }
  public void setLoc(int baseX,int baseY){
    this.baseX = baseX;
    this.baseY = baseY;
  }
  public ArrayList<Cell> getPath(){
    return path;
  }
  public void setIsCreateBack(boolean b){
    this.isCreateBack=b;
  }
  public boolean getIsCreateBack(){
    return isCreateBack;
  }
  public void run(){
    if(pathIndex<path.size()){
      x = path.get(pathIndex).getX();  
      y = path.get(pathIndex).getY();  
      pathIndex ++;
    }
  }
  public boolean isDone(){
    if(pathIndex<path.size()){
      return false;
    }
    return true;
  }
  public int getPathIndex(){
    
    return pathIndex;
  }
  public void replay(){
    pathIndex = 0;
    x = path.get(pathIndex).getX();  
    y = path.get(pathIndex).getY();  
    pathIndex ++;
  }
  void display() {
    run();
    ellipse(x+baseX+5, y+baseY+5, diameter, diameter);
  }
  void display2() {
    ellipse((tableW/2-x-10)+baseX+5,(tableH/2-y-10)+baseY+5, diameter, diameter);
  }
  
}

 