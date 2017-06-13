import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.fluid.DwFluidStreamLines2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;


class Windtunnel/* extends PApplet*/{
  
   


   class MyFluidData implements DwFluid2D.FluidData{
    private float prevpx=0,prevpy=0;
    private int counter=0;
    private int threshold=20;
    @Override
    // this is called during the fluid-simulation update step.
    public void update(DwFluid2D fluid) {
    
      float px, py, vx, vy, radius, vscale;
     
      boolean mouse_input = selection.getVertices()==null ? false: selection.getVertices().size()>1 && !obstacle_painter.isDrawing();
      if(mouse_input ){
        
        vscale = 15;
        px     = selection.getVertices().get(0).x-viewport_x;
        py     = viewport_h - selection.getVertices().get(0).y+viewport_y;
        if(px == prevpx &&py == prevpy){
          counter++;
        }
        else
          counter =0;
        if(threshold>counter){
          
          prevpx=px;
          prevpy=py;
          vx     = (selection.getVertices().get(0).x - selection.getVertices().get(1).x) * +vscale;
          vy     = (selection.getVertices().get(0).y - selection.getVertices().get(1).y) * -vscale;
         
          //if(mouseButton == LEFT){
            radius = 20;
            fluid.addVelocity(px, py, radius, vx, vy);
            fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1);
          //}
        }

      }
      else if(!selection.isEnabled())
      {
        selection.setEnable(true);
      }
        // use the text as input for density
      float mix_density  = fluid.simulation_step == 0 ? 1.0f : 0.05f;
      float mix_velocity = fluid.simulation_step == 0 ? 1.0f : 0.5f;
      
      addDensityTexture (fluid, pg_density , mix_density);
      addVelocityTexture(fluid, pg_velocity, mix_velocity);
    }
    
    
    // custom shader, to add velocity from a texture (PGraphics2D) to the fluid.
    public void addVelocityTexture(DwFluid2D fluid, PGraphics2D pg, float mix){
      int[] pg_tex_handle = new int[1]; 
//      pg_tex_handle[0] = pg.getTexture().glName
      context.begin();
      context.getGLTextureHandle(pg, pg_tex_handle);
      context.beginDraw(fluid.tex_velocity.dst);
      DwGLSLProgram shader = context.createShader("C:/Users/VisDemo/Desktop/yasin findik/withmesh2/Tangy/data/addVelocity.frag");
      shader.begin();
      shader.uniform2f     ("wh"        , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode", 6);   
      shader.uniform1f     ("mix_value" , mix);     
      shader.uniform1f     ("multiplier", 1);     
      shader.uniformTexture("tex_ext"   , pg_tex_handle[0]);
      shader.uniformTexture("tex_src"   , fluid.tex_velocity.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end();
      fluid.tex_velocity.swap();
    }
    
    // custom shader, to add density from a texture (PGraphics2D) to the fluid.
    public void addDensityTexture(DwFluid2D fluid, PGraphics2D pg, float mix){
      int[] pg_tex_handle = new int[1]; 
//      pg_tex_handle[0] = pg.getTexture().glName
      context.begin();
      context.getGLTextureHandle(pg, pg_tex_handle);
      context.beginDraw(fluid.tex_density.dst);
      DwGLSLProgram shader = context.createShader("C:/Users/VisDemo/Desktop/yasin findik/withmesh2/Tangy/data/addDensity.frag");
      shader.begin();
      shader.uniform2f     ("wh"        , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode", 2);   
      shader.uniform1f     ("mix_value" , mix);     
      shader.uniform1f     ("multiplier", 1);     
      shader.uniformTexture("tex_ext"   , pg_tex_handle[0]);
      shader.uniformTexture("tex_src"   , fluid.tex_density.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end();
      fluid.tex_density.swap();
    }
 
  }

  
  int viewport_w;// = 1280;
  int viewport_h;// = 720;
  int viewport_x;// = 230;
  int viewport_y;// = 0;
  Selection selection=null;
  
  /*int gui_w = 200;
  int gui_x = viewport_w-gui_w;
  int gui_y = 0;*/
      
  int fluidgrid_scale = 1;

  PFont font;
  
  DwPixelFlow context;
  DwFluid2D fluid;
  DwFluidStreamLines2D streamlines;
  MyFluidData cb_fluid_data;

  PGraphics2D pg_fluid;             // render target
  PGraphics2D pg_density;           // texture-buffer, for adding fluid data
  PGraphics2D pg_velocity;          // texture-buffer, for adding fluid data
  PGraphics2D pg_obstacles;         // texture-buffer, for adding fluid data
  PGraphics2D pg_obstacles_drawing; // texture-buffer, for adding fluid data
  
  ObstaclePainter obstacle_painter;
  
  //MorphShape morph; // animated morph shape, used as dynamic obstacle
  
  // some state variables for the GUI/display
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = true;
  boolean DISPLAY_FLUID_VECTORS      = false;
  int     DISPLAY_fluid_texture_mode = 0;
  boolean DISPLAY_STREAMLINES        = false;
  int     STREAMLINE_DENSITY         = 10;
  
  int offy = 5;//padding top
  int num_segs = 35;
  float [][]heatmapData;
  int threadID;
  int inc =5;
  Float []vectors;
  private boolean heatmapNeeded=false;
  private boolean canShowHeatmap=false;
  int gridSize=25;
  float max=0.0;
  float min = MAX_FLOAT;
  float[]px_velocity;
  PrintWriter output;
  int numberOfThread = 250;
  boolean []doneThreads = new boolean[numberOfThread];
  PGraphics heatmap ;
  
  Windtunnel(int viewport_x,int viewport_y,int viewport_w,int viewport_h, Selection selection){
    this.viewport_w = viewport_w;
    this.viewport_h = viewport_h;
    this.viewport_x = viewport_x;
    this.viewport_y = viewport_y;
    this.selection = selection;
    
    selection.setDrawFlag(false);
    heatmapData = new float[viewport_h][];
    for(int i=0;i<viewport_h;i++){
      heatmapData[i]  =new float[viewport_w];
      for(int j=0;j<viewport_w;j++){
        heatmapData[i][j]=0.0;
      }  
    }
    
  }
  public PGraphics getHeatmap()
  {
     return heatmap; 
  }
  public void calcHeatmap(){
    heatmap = createGraphics(fluid.fluid_w, fluid.fluid_h);
    PrintWriter output = createWriter("d3.txt");
    
    
    Float v[] = (Float[])vectors.clone();
     for(int i =0 ; i<fluid.fluid_h-gridSize;i+=gridSize){
      for(int j =0 ; j<fluid.fluid_w-gridSize;j+=gridSize){
        
          float sum = 0.0;
          for(int ii=i;ii<i+gridSize;ii++){
            for(int jj=j;jj<j+gridSize;jj++){
              sum+=vectors[ii*fluid.fluid_w+jj];
            }  
          }
          for(int ii=i;ii<i+gridSize;ii++){
            for(int jj=j;jj<j+gridSize;jj++){
              if(ii==i+gridSize-1||ii==i){
                 v[ii*fluid.fluid_w+jj]=0.0;
              }
              else if(jj==j+gridSize-1||jj==j){
                 v[ii*fluid.fluid_w+jj]=0.0;
              }
              else
                v[ii*fluid.fluid_w+jj]=sum/(gridSize*gridSize);
            }  
          }
      }
    }
     output.close();
    max = Collections.max(Arrays.asList(v));
    min = Collections.min(Arrays.asList(v));
    
    heatmap.beginDraw();
    heatmap.loadPixels();
   
    for(int i=0;i<fluid.fluid_h*fluid.fluid_w;i++){
      
        int n = int((v[i]-min)/(max-min)*100);
        if(n>100){
          /*println(n);
          println(v[i]);
          println(max);
          println(min);*/
        }
        
        int R = (255 * n) / 100;
        int G = 0;
        int B = 0;
        color c = color(R,G,B);
        int xx = i%fluid.fluid_w;
        int yy = i/fluid.fluid_w;
        heatmap.pixels[fluid.fluid_w*(fluid.fluid_h-yy-1)+xx]=c;
      
    }
    heatmap.updatePixels();
    //heatmap.rotate(PI/2);
    heatmap.endDraw();
    heatmap.save("test.png");
  }
  public void clearVectors(){
    vectors=new Float[fluid.fluid_h*fluid.fluid_w];
    for(int i=0;i<viewport_h*viewport_w;i++){
        vectors[i]=0.0;
    }
    
  }
  public boolean AllThreadDone(){
    for(int i = 0 ; i< numberOfThread;i++){
      if(!doneThreads[i])
        return false;
    }
    return true;
  }
  public void setHeatmapNeeded(boolean b){
    heatmapNeeded = b; 
  }
  public boolean getHeatmapNeeded(){
    
    return heatmapNeeded;
  }
  public void setCanShowHeatmap(boolean b){
    canShowHeatmap = b; 
  }
  public boolean getCanShowHeatmap(){
    
    return canShowHeatmap;
  }
  public void takeVectors(int ii){
    try{
      px_velocity = fluid.getVelocity(null);
     
      output = createWriter("debug5.txt");
      int start = 0;
      int end = px_velocity.length;
      for(int i=start;i<end;i++){
        int j = i/2;
        vectors[j] += abs(px_velocity[i++]);
      
      }
      
      output.close(); 
    }catch(Exception e){println("takeVectors ex");}
    
  }

  public void settings() {
    size(viewport_w, viewport_h, P2D);
    smooth(4);
  }
  
  
  public void setup(ArrayList<Wall> walls) {
  
    surface.setLocation(viewport_x, viewport_y);
    
    // main library context
    context = new DwPixelFlow(pApplet);
    context.print();
    context.printGL();
    
    streamlines = new DwFluidStreamLines2D(context);
    
    // fluid simulation
    fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);

    // some fluid params
    fluid.param.dissipation_density     = 0.99999f;
    fluid.param.dissipation_velocity    = 0.99999f;
    fluid.param.dissipation_temperature = 0.70f;
    fluid.param.vorticity               = 0.00f;
    
    // interface for adding data to the fluid simulation
    cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);

    // processing font
    //font = createFont("C:/Users/VisDemo/Desktop/yasin findik/withmesh2/Tangy/SourceCodePro-Regular.ttf", 48);

    // fluid render target
    pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_fluid.smooth(4);

    // main obstacle texture
    pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
//    pg_obstacles.noSmooth();
    pg_obstacles.smooth(4);
    pg_obstacles.beginDraw();
    pg_obstacles.clear();
    pg_obstacles.endDraw();
    
    
    // second obstacle texture, used for interactive mouse-driven painting
    pg_obstacles_drawing = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  //  pg_obstacles_drawing.noSmooth();
    pg_obstacles_drawing.smooth(4);
    pg_obstacles_drawing.beginDraw();
    pg_obstacles_drawing.clear();
    pg_obstacles_drawing.blendMode(REPLACE);
   
    // place some initial obstacles
    randomSeed(6);
    if(walls!=null)
    for(Wall wall:walls){
      float px = wall.getX()-viewport_x;
      float py = wall.getY()-viewport_y;
      pg_obstacles_drawing.rectMode(CENTER);
      pg_obstacles_drawing.noStroke();
      pg_obstacles_drawing.fill(64);
      pg_obstacles_drawing.rect(px, py, 4, 4);
    }
   
    pg_obstacles_drawing.endDraw();
    
    
    // init the obstacle painter, for mouse interaction
    obstacle_painter = new ObstaclePainter(pg_obstacles_drawing);
    
    // image/buffer that will be used as density input
    pg_density = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_density.noSmooth();
    pg_density.beginDraw();
    pg_density.clear();
    pg_density.endDraw();
    
    // image/buffer that will be used as velocity input
    pg_velocity = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_velocity.noSmooth();
    pg_velocity.beginDraw();
    pg_velocity.clear();
    pg_velocity.endDraw();
    
    
    // animated morph shape
    //morph = new MorphShape(120);

    //createGUI();

    frameRate(60);
  }
  

  
  
  public void drawObstacles(){
  
    pg_obstacles.beginDraw();
    pg_obstacles.blendMode(BLEND);
    pg_obstacles.clear();
    
    // add painted obstacles on top of it
    pg_obstacles.image(pg_obstacles_drawing, 0, 0);
    pg_obstacles.endDraw();
  }
  
  
  
  

  
  public void drawVelocity(PGraphics pg, int texture_type){
    
    float vx = 30; // velocity in x direction
    float vy =  0; // velocity in y direction
    
    int argb = Velocity.Polar.encode_vX_vY(vx, vy);
    float[] vam = Velocity.Polar.getArc(vx, vy);
    
//    float vA = vam[0]; // velocity direction (angle)
    float vM = vam[1]; // velocity magnitude
    
    if(vM == 0){
      // no velocity, so just return
      return;
    }
    
    pg.beginDraw();
    pg.blendMode(REPLACE); // important
    pg.clear();
    pg.noStroke();
    
    if(vM > 0){
      
      
  
      // add density
      if(texture_type == 1){
        float size_h = viewport_h-2*offy;
        pg.noStroke();
        
        
        float seg_len = size_h / num_segs;
        for(int i = 0; i < num_segs; i++){
          float py = offy + i * seg_len;
          if(i%2 == 0){
            if(frameCount % 50 == 0){
              pg.fill(255,150,50);
              pg.rect(5, py, seg_len*2, seg_len);
            }
          } else {
            pg.fill(50, 155, 255);
            pg.noStroke();
            pg.rect(5, py, seg_len, seg_len);
          }

        }
      }
      
      // add encoded velocity
      if(texture_type == 0){
        // if the the M bits are zero (no magnitude), then processings fill() method 
        // builds a different color than zero: 0x00000000 becomes 0xFF000000
        // this fucks up the encoding/decoding process in the shader.
        // (argb & 0xFFFF0000) == 0
        // pg.fill(argb); // this fails if argb == 0
        
        // so, a workaround is, to pass 4 components separately
        int a = (argb >> 24) & 0xFF;
        int r = (argb >> 16) & 0xFF;
        int g = (argb >>  8) & 0xFF;
        int b = (argb >>  0) & 0xFF;
        pg.fill  (r,g,b,a);   
        pg.stroke(r,g,b,a);
        
        pg.noStroke();
        pg.rect(0, offy, 10, viewport_h-2*offy);
      }
    }
    pg.endDraw();
  }
  
  
  

  public void draw() {
   

    if(UPDATE_FLUID){
      
      drawVelocity(pg_velocity, 0);
      drawVelocity(pg_density , 1);
      
      drawObstacles();
      try{
      fluid.addObstacles(pg_obstacles);
      fluid.update();
      }catch(Exception e){
        println("err winddraw");
      }
    }

    
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    
    if(DISPLAY_FLUID_TEXTURES){
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      fluid.renderFluidVectors(pg_fluid, 10);
    }
    
    if(DISPLAY_STREAMLINES){
      streamlines.render(pg_fluid, fluid, STREAMLINE_DENSITY);
    }
    
    // display
    tint(255, 127);
    image(pg_fluid    , viewport_x, viewport_y);
    //image(pg_obstacles, viewport_x, viewport_y);
    noTint();

    
    // draw the brush, when obstacles get removed
    obstacle_painter.displayBrush(pApplet.g);

    // info
    String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    surface.setTitle(txt_fps);
    
  }
   public void mousePressed(){
    if(mouseButton == CENTER ) obstacle_painter.beginDraw(1); // add obstacles
    if(mouseButton == RIGHT  ) obstacle_painter.beginDraw(2); // remove obstacles
  }
  
  public void mouseDragged(){
    obstacle_painter.draw();
  }
  
  public void mouseReleased(){
    obstacle_painter.endDraw();
  }
  
  
  public void fluid_resizeUp(){
    fluid.resize(viewport_w, viewport_h, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(viewport_w, viewport_h, ++fluidgrid_scale);
  }
  public void fluid_reset(){
    fluid.reset();
  }
  public void fluid_togglePause(){
    UPDATE_FLUID = !UPDATE_FLUID;
  }
  public void fluid_displayMode(int val){
    DISPLAY_fluid_texture_mode = val;
    DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
  }
  public void fluid_displayVelocityVectors(int val){
    DISPLAY_FLUID_VECTORS = val != -1;
  }

  public void streamlines_displayStreamlines(int val){
    DISPLAY_STREAMLINES = val != -1;
  }
  public void set_texture_mode(int val){
    DISPLAY_fluid_texture_mode = val;
  }
  public void change_textures_visibility(){
    DISPLAY_FLUID_TEXTURES = !DISPLAY_FLUID_TEXTURES;
  }
  public void change_vectors_visibility(){
    DISPLAY_FLUID_VECTORS = !DISPLAY_FLUID_VECTORS;
  }
  public void keyReleased(){
    if(key == 'p') fluid_togglePause(); // pause / unpause simulation
    if(key == '+') fluid_resizeUp();    // increase fluid-grid resolution
    if(key == '-') fluid_resizeDown();  // decrease fluid-grid resolution
    if(key == 'r') fluid_reset();       // restart simulation
    
    if(key == '1') DISPLAY_fluid_texture_mode = 0; // density
    if(key == '2') DISPLAY_fluid_texture_mode = 1; // temperature
    if(key == '3') DISPLAY_fluid_texture_mode = 2; // pressure
    if(key == '4') DISPLAY_fluid_texture_mode = 3; // velocity
    
    if(key == 'q') DISPLAY_FLUID_TEXTURES = !DISPLAY_FLUID_TEXTURES;
    if(key == 'w') DISPLAY_FLUID_VECTORS  = !DISPLAY_FLUID_VECTORS;
  }
 
  
  
  
  
  
}