class StartPoint {
    private int confidence = 0;
    private int timeoutMillis;
    private int startMillis;
    private boolean isWorking = false;
    public float x;
    public float y;
    private int buttonSize;
    private color c;
    private boolean touched=false;
    private boolean avaliable=false;
    private Method onClickEvent;
    private Object parent;
    private float successRate = 0.7;
    private int threshold;
    private float s = 0.5;
    private ArrayList<EndPoint> endPoints;
    private ArrayList<ArrayList<Cell>>paths;
    private boolean deleted=false;
    private Selection selection;
    private Button button;
    private int baseX;
    private int baseY;
    
  private void handleException(Exception ex) {
    println("Disabling onClickEvent because of an error. ");
    ex.printStackTrace();
  }
 
  
  StartPoint(float x,float y,int size,color c,Object parent,Selection selection) {
    this.x= x;
    this.y= y;
    this.buttonSize = size;
    this.threshold = int((60*successRate)*s);
    this.c = c;
    this.touched = false;
    this.parent=parent;
    this.selection = selection;
    endPoints = new ArrayList<EndPoint>();
    paths = new ArrayList<ArrayList<Cell>>();
    button =new Button(this, "toggle_S", x, y, size*2, 0.5,"",false,1);
    button.setEnable(false);
    selection.addButtonToExclude(button);
    selection.clear();    
  }
  StartPoint(float x,float y,int size,color c,int baseX,int baseY) {
    this.x= x;
    this.y= y;
    this.baseX=baseX;
    this.baseY= baseY;
    this.buttonSize = size;
    this.threshold = int((60*successRate)*s);
    this.c = c;
  }
  public StartPoint getCopy(int cornerX,int cornerY,int baseX,int baseY){
    StartPoint s = new StartPoint(x-cornerX,y-cornerY,buttonSize,c,baseX,baseY);
    return s;
  }
  public ArrayList<EndPoint>getEndPoints(){ 
    return endPoints;
  }
  public void addEndPoint(EndPoint endPoint){
   
    if(!button.isEnabled())button.setEnable(true);
    endPoints.add(endPoint); 
  }
  public void addPath(ArrayList<Cell> path){
    
    paths.add(path); 
  }
  public void clearPaths(){
    paths = new ArrayList<ArrayList<Cell>>();
  }
  public ArrayList<Cell> getPath(int i){
    return paths.get(i);
  }
  public ArrayList<ArrayList<Cell>> getPath(){
    return paths;
  }
  public boolean getTouched(){
    return touched; 
  }
  public float getX(){
    return x; 
  }
  public float getY(){
    return y; 
  }
  public void setTouched(boolean touched){
    this.touched = touched; 
  }
  public void setAvaliable(boolean avaliable){
    this.avaliable = avaliable; 
  }
  public void setDeleted(boolean b){
    button.setDeleted(b);
    selection.removeButtonToExclude(button);
    this.deleted = b; 
  }
  public void setButtonEnable(boolean b){
    
    button.setEnable(b); 
    if(b)
      selection.addButtonToExclude(button);
    else
      selection.removeButtonToExclude(button);
  }
  public color getColor(){
    return c;
  }
  void display(){
    button.draw(c);
  }
  void display2(){
    strokeWeight(1);
    stroke(0);
    fill(c);
    rectMode(CENTER);
    rect((tableW/2-5-x)+baseX+5,(tableH/2-5-y)+baseY+5, buttonSize, buttonSize);
    
  }
  public void onClick_toggle_S(){
    try{
      parent.getClass().getMethod("onClick_toggle_CallFromStartPoint",this.getClass()).invoke(parent,this);
    }catch (Exception ex) { 
      handleException(ex);
    }
  }
  
  
}