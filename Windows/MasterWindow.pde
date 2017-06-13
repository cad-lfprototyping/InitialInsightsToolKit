class MasterWindow{
  private int cornerX;
  private int cornerY;
  private int widthWindow;
  private int heightWindow;
  private int buttonX;
  private int buttonY;
  private boolean position;
  private color c3 = color(0,255,0);
  private color c2 = color(255,0,0);
  private color c1= color(0,0,0);
  private color co2 = color(50, 255, 50);
  private color co1 = color(0,0,0);
  
  private boolean screenshots[]=new boolean[]{false,false,false,false,false,false};
  private boolean clicked[]=new boolean[]{false,false,false,false,false,false};
  
  
  private boolean clickedOthers[]=new boolean[]{false,false,false,false,false,false};
  
  private Button buttonPR=null;
  private Button buttonPL=null;
  private Button buttonHL =null;
  private Button buttonHR =null;
  private Button buttonWL =null;
  private Button buttonWR =null;
  private ArrayList<Button> buttons ; 
  
  private FingerFinder tracker;
  
  private int []selectionX = new int[2];
  private int []selectionY = new int[2];
  private Selection selection;
  MasterWindow(int cornerX, int cornerY,int widthWindow,int heightWindow,boolean position,FingerFinder tracker){
    
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
    createButtons();
  }
  
  public void drawFrame(){
     pApplet.line(cornerX, cornerY, cornerX+widthWindow, cornerY);
     pApplet.line(cornerX+widthWindow, cornerY, cornerX+widthWindow, cornerY+heightWindow);
     pApplet.line(cornerX, cornerY, cornerX, cornerY+heightWindow);
     pApplet.line(cornerX,  cornerY+heightWindow, cornerX+widthWindow, cornerY+heightWindow); 
     
    pApplet.line(cornerX,cornerY+buttonSize*3,cornerX+widthWindow,cornerY+buttonSize*3); 
    
    
    pApplet.line(cornerX,cornerY+buttonSize*8,cornerX+widthWindow,cornerY+buttonSize*8); 
  }
  public void drawSelection(){
  }
  public void setScreenShot(int i,boolean value){
    
    screenshots[i]=value;
    if(i>1)
      clicked[i]=false;
  }
  public void drawButtons(){
    if(clicked[0]||clicked[2]||clicked[4])
      change(false,false);
    else if(clicked[1]||clicked[3]||clicked[5])
      change(true,false);
    else{
      change(true,true);
      change(false,true);
    }
    if(clicked[0]){
      buttonPL.draw(c2);
    }
    else{
      if(screenshots[0])
        buttonPL.draw(c3);
      else
        buttonPL.draw(c1);
    }
    if(clicked[1]){
      buttonPR.draw(c2);
    }
    else{
      if(screenshots[1])
        buttonPR.draw(c3);
      else
        buttonPR.draw(c1);
    }
    if(clicked[2]){
      buttonWL.draw(c2);
    }
    else{
      if(screenshots[2])
        buttonWL.draw(c3);
      else
      buttonWL.draw(c1);
    }
    if(clicked[3]){
      buttonWR.draw(c2);
    }
    else{
      if(screenshots[3])
        buttonWR.draw(c3);
      else
      buttonWR.draw(c1);
    }
    if(clicked[4]){
      buttonHL.draw(c2);
    }
    else{
      if(screenshots[4])
        buttonHL.draw(c3);
      else
        buttonHL.draw(c1);
    }
    if(clicked[5]){
      buttonHR.draw(c2);
    }
    else{
      if(screenshots[5])
        buttonHR.draw(c3);
      else
        buttonHR.draw(c1);
    }
    int index=0;
    for(Button button : buttons){
      if(clickedOthers[index])
        button.draw(co2); 
      else
        button.draw(co1);
      index++;
    }
    pApplet.strokeWeight(1);
    pApplet.stroke(0);
    float a = 0.0;
    float inc = TWO_PI/20.0 /3;
    float tempx=(cornerX+buttonSize+5);
    float tempy1=cornerY+buttonSize*4+sin(a)*10.0;
    float tempy2=cornerY+buttonSize*3.5+sin(a)*10.0;
    float tempy3=cornerY+buttonSize*4.5+sin(a)*10.0;
    a = a + inc;
    for (float i = (cornerX+buttonSize+6); i <=(cornerX+buttonSize*3-5); i++) {
      
      pApplet.line(tempx, tempy1, i, cornerY+buttonSize*4+sin(a)*10.0);
      pApplet.line(tempx, tempy2, i, cornerY+buttonSize*3.5+sin(a)*10.0);
      pApplet.line(tempx, tempy3, i, cornerY+buttonSize*4.5+sin(a)*10.0);
      tempx=i;
      tempy1=cornerY+buttonSize*4+sin(a)*10.0;
      tempy2=cornerY+buttonSize*3.5+sin(a)*10.0;
      tempy3=cornerY+buttonSize*4.5+sin(a)*10.0;
      a = a + inc;
    }
    a = 0.0;
    inc = TWO_PI/20.0 /3;
    tempx=cornerX+buttonSize*4+2+5;
    tempy1=cornerY+buttonSize*4+sin(a)*10.0;
    tempy2=cornerY+buttonSize*3.5+sin(a)*10.0;
    tempy3=cornerY+buttonSize*4.5+sin(a)*10.0;
    a = a + inc;
    for (float i = cornerX+buttonSize*4+2+6; i <=(cornerX+buttonSize*6-5); i++) {
      
      pApplet.line(tempx, tempy1, i, cornerY+buttonSize*4+sin(a)*10.0);
      pApplet.line(tempx, tempy2, i, cornerY+buttonSize*3.5+sin(a)*10.0);
      pApplet.line(tempx, tempy3, i, cornerY+buttonSize*4.5+sin(a)*10.0);
      tempx=i;
      tempy1=cornerY+buttonSize*4+sin(a)*10.0;
      tempy2=cornerY+buttonSize*3.5+sin(a)*10.0;
      tempy3=cornerY+buttonSize*4.5+sin(a)*10.0;
      a = a + inc;
    }
    pApplet.noStroke();
    
  }
  
  public void createButtons(){// ters/duz
    int distanceButton=2;
    buttonPL = new Button(this, "toggle_L", cornerX+buttonSize*2, cornerY+buttonSize*1.5, buttonSize*2, 0.5,"L",position,3);
    buttonPR = new Button(this, "toggle_R", cornerX+buttonSize*5+distanceButton, cornerY+buttonSize*1.5, buttonSize*2, 0.5,"R",position,3);
    selection.addButtonToExclude(buttonPL);  
    selection.addButtonToExclude(buttonPR);  
    
    
    buttonWL=new Button(this, "toggle_WL", cornerX+buttonSize*2, cornerY+buttonSize*4, buttonSize*2, 0.5,"",position,2);
    selection.addButtonToExclude(buttonHL);  
    buttonWR=new Button(this, "toggle_WR", cornerX+buttonSize*5+distanceButton, cornerY+buttonSize*4, buttonSize*2, 0.5,"",position,2);
    selection.addButtonToExclude(buttonHR);
    
    buttonHL=new Button(this, "toggle_HL", cornerX+buttonSize*2, cornerY+buttonSize*7, buttonSize*2, 0.5,"",position,4);
    selection.addButtonToExclude(buttonHL);  
    buttonHR=new Button(this, "toggle_HR", cornerX+buttonSize*5+distanceButton, cornerY+buttonSize*7, buttonSize*2, 0.5,"",position,4);
    selection.addButtonToExclude(buttonHR);
    
    
    
    //selectiona buttonlar eklenıyor...
    for(Button button : buttons){
      selection.addButtonToExclude(button);  
    }
    
  }
  public void change(boolean pos,boolean value){
    if(pos){
        buttonPL.setEnable(value);
        buttonWL.setEnable(value);
        buttonHL.setEnable(value);
    }
    else{
        buttonPR.setEnable(value);
        buttonWR.setEnable(value);
        buttonHR.setEnable(value);
    }
  }
  
  public void onClick_toggle_L()
  {
    clicked[0] = !clicked[0];
    if( clicked[0]){
      emptyWindow.setIdIndex(0,-1);
    }
    else{
      emptyWindow.deleteImg2();
    }
  }
  public void onClick_toggle_R()
  {
     clicked[1] = ! clicked[1];
    if(clicked[1]){
      
      emptyWindow.setIdIndex(1,-1);
    }
    else{
      emptyWindow.deleteImg2();
    }
  }
  public void onClick_toggle_WL(){
    clicked[2] = !clicked[2];
    if(clicked[2]){
       clicked[4]=false;
       emptyWindow.setIdIndex(0,-2);
    }
     else{
       emptyWindow.deleteImg3();
     }
  }
  public void onClick_toggle_WR(){
    clicked[3] = ! clicked[3];
    if( clicked[3]){
       clicked[5]=false;
       emptyWindow.setIdIndex(1,-2);
    }
     else{
       emptyWindow.deleteImg3();
     }
  }
  public void onClick_toggle_HL(){
     clicked[4] = !clicked[4];
    if(clicked[4]){
       clicked[2]=false;
       emptyWindow.setIdIndex(0,-3);
    }
     else{
       emptyWindow.deleteImg3();
     }
  }
  public void onClick_toggle_HR()
  {
     clicked[5] = ! clicked[5];
     if( clicked[5]){
       clicked[3]=false;
       emptyWindow.setIdIndex(1,-3);
     }
     else{
       emptyWindow.deleteImg3();
     }
  }
  public void onClick_toggle_1L()
  {
    clickedOthers[0]=!clickedOthers[0];
     if(clickedOthers[0]){
       emptyWindow.setIdIndex(0,0);
     }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  public void onClick_toggle_1R()
  {
    clickedOthers[1]=!clickedOthers[1];
    if(clickedOthers[1]){
       emptyWindow.setIdIndex(1,0);
    }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  public void onClick_toggle_2L()
  {
    clickedOthers[2]=!clickedOthers[2];
    if(clickedOthers[2]){
       emptyWindow.setIdIndex(0,1);
    }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  public void onClick_toggle_2R(){
    clickedOthers[3]=!clickedOthers[3];
    if(clickedOthers[3]){
       emptyWindow.setIdIndex(1,1);
    }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  public void onClick_toggle_3L(){
    clickedOthers[4]=!clickedOthers[4];
    if(clickedOthers[4]){
       emptyWindow.setIdIndex(0,2);
    }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  public void onClick_toggle_3R(){
    clickedOthers[5]=!clickedOthers[5];
    if(clickedOthers[5]){
       emptyWindow.setIdIndex(1,2);
    }
     else{
       emptyWindow.deleteImgOthers();
     }
  }
  
  
}