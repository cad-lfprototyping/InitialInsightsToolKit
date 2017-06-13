class EndPoint {
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
  private int  id;
  private boolean deleted=false;
  private Button button;
  private Selection selection;
  
  private int baseX;
    private int baseY;
    
  private void handleException(Exception ex) {
    println("Disabling onClickEvent because of an error. ");
    ex.printStackTrace();
  }
  EndPoint(float x,float y,int size,color c,Object parent,Selection selection) {
    this.x= x;
    this.y= y;
    this.c = c;
    this.parent=parent;
    this.buttonSize =size;
    this.selection = selection;
    button =new Button(this, "toggle_S", x, y, size*2, 0.5,"",false,1);
    selection.addButtonToExclude(button);
    selection.clear();
  }
  EndPoint(float x,float y,int size,color c,int baseX,int baseY) {
    this.x= x;
    this.y= y;
    this.baseX=baseX;
    this.baseY= baseY;
    this.buttonSize = size;
    this.threshold = int((60*successRate)*s);
    this.c = c;
  }
  public EndPoint getCopy(int cornerX,int cornerY,int baseX,int baseY){
    EndPoint s = new EndPoint(x-cornerX,y-cornerY,buttonSize,c,baseX,baseY);
    return s;
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
  public void onClick_toggle_S(){
    try{
      parent.getClass().getMethod("onClick_toggle_CallFromEndPoint",this.getClass()).invoke(parent,this);
    }catch (Exception ex) { 
      handleException(ex);
    }
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
}