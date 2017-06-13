 //<>//
FingerFinder tracker;

MainWindow [] mainWindows = new MainWindow[2] ;
MasterWindow masterWindow;
EmptyWindow emptyWindow;
 
PApplet pApplet = this; 


public void settings() {
    fullScreen(P2D, 2); 
   
}
void setup() 
{ 
  smooth(5); 

  // Reads config file
  ReadConfigurationFile();

  
  
  tracker = new FingerFinder(this);
  
  mainWindows[0] = new MainWindow(baseX, baseY, tableW/2-2, tableH/2-2,false,image,tracker,0);
  mainWindows[1] = new MainWindow(baseX+tableW/2+2, baseY-2, tableW/2, tableH/2,false,image,tracker,1);  
  masterWindow = new MasterWindow(baseX+tableW/2+2, baseY+tableH/2+2, tableW/2, tableH/2,true,tracker);
  emptyWindow = new EmptyWindow(baseX, baseY+tableH/2+2, tableW/2-2, tableH/2,true,image,tracker);
  
  emptyWindow.setCorners(baseX,baseY,baseX+tableW/2+2,baseY-2);
 
  
}

/**
 The program loops this draw function.
 */
void draw() 
{
  // Tracking fingers
  tracker.find();
  background(bg);
  
  stroke(0);
  
  mainWindows[0].drawImage();
  mainWindows[1].drawImage();
  
  
  mainWindows[0].drawSelection();
  mainWindows[1].drawSelection();
  masterWindow.drawSelection();
  

  
  mainWindows[0].drawButtons();
  mainWindows[1].drawButtons();
  masterWindow.drawButtons();
  
  mainWindows[0].action();
  mainWindows[1].action();
  emptyWindow.action();
  
  // taking screenshots      
  if(screenShotR){
    screenShotRName = "R"+frameCount+".png";
    pApplet.saveFrame(screenShotRName);
    if(mainWindows[1].getCurrentMode()==1)
      emptyWindow.addName(screenShotRName,1,mainWindows[1].getCurrentMode(),mainWindows[1].getShowHeatmap());
    else if(mainWindows[1].getCurrentMode()==0){
      emptyWindow.addASE(mainWindows[1].getAgents(),mainWindows[1].getStartPoints(),mainWindows[1].getEndPoints(),mainWindows[1].getWalls(),1);
    }
    screenShotR=false;
    masterWindow.setScreenShot(1+mainWindows[1].getCurrentMode()*2+(mainWindows[1].getCurrentMode()==1?(int(mainWindows[1].getShowHeatmap())*2):0),true);
  }
  if(screenShotL){
    screenShotLName = "L"+frameCount+".png";
    pApplet.saveFrame(screenShotLName);
    if(mainWindows[0].getCurrentMode()==1){
      emptyWindow.addName(screenShotLName,0,mainWindows[0].getCurrentMode(),mainWindows[0].getShowHeatmap());
     
    }
    else if(mainWindows[0].getCurrentMode()==0){
      emptyWindow.addASE(mainWindows[0].getAgents(),mainWindows[0].getStartPoints(),mainWindows[0].getEndPoints(),mainWindows[0].getWalls(),0);
    }
    masterWindow.setScreenShot(0+mainWindows[0].getCurrentMode()*2+(mainWindows[0].getCurrentMode()==1?(int(mainWindows[0].getShowHeatmap())*2):0),true);
    screenShotL=false;
  }
  
}