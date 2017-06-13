class Wall {
  private float x;
  private float y;
  private color c;
  private int baseX;
    private int baseY;
  
  Wall(float x,float y,color c) {
    this.x= x;
    this.y= y;
    this.c = c;
  }
  Wall(float x,float y,color c,int baseX,int baseY) {
    this.x= x;
    this.y= y;
    this.c = c;
    this.baseX=baseX;
    this.baseY= baseY;
  }
  public Wall getCopy(int cornerX,int cornerY,int baseX,int baseY){
    Wall s = new Wall(x-cornerX,y-cornerY,c,baseX,baseY);
    return s;
  }
  public void display(){
    strokeWeight(1);
    stroke(0);
    fill(c);
    rectMode(CENTER);
    rect(x, y, 2, 2);
  }
  void display2(int id){
    noStroke();
    fill(c);
    rectMode(CENTER);
    if(id==0)
      rect(((tableW/2-2-x)+baseX+2),((tableH/2-2-y)+baseY+2), 3, 3);
    else
    rect(((tableW-x)+baseX+2),(tableH/2-2-y+baseY+2), 3, 3);
    
  }
  public color getColor(){
    return c;
  }
  public float getX(){
    
    return x;
  }
  public float getY(){
    
    return y;
  }
}