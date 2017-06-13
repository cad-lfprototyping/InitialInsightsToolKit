import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

class Maze {
  //private char[][] mesh;
  private PrintWriter output;
  private int mazeWidth;
  private int mazeHeight;
  private int radius;
  private int baseX;
  private int baseY;
  private char[][]maze;
  private Cell start ;
  private Cell end ;
  //private int defaultCost = 1;
  private HashMap<Cell,Cell> came_from = new HashMap<Cell,Cell>();
  private HashMap<Cell,Float> cost_so_far = new HashMap<Cell,Float>();
  
  Maze(int mazeWidth, int mazeHeight,ArrayList<Wall> walls,int baseX,int baseY,int startX,int startY,int endX,int endY,int radius){
    
    this.mazeWidth = mazeWidth;
    this.mazeHeight =mazeHeight;
    this.baseX = baseX;
    this.baseY = baseY;
    this.radius = radius;
    this.start = new Cell(startX,startY);
    this.end = new Cell(endX,endY);
    
    createMesh(walls);
  }
  private void createMesh(ArrayList<Wall> walls){
    
    maze = new char[mazeHeight][];
    
    for(int i=0;i<mazeHeight;i++){
      maze[i]  =new char[mazeWidth];
      for(int j=0;j<mazeWidth;j++){
        
        if(i==0||i==mazeHeight-1||j==0||j==mazeWidth-1){
          maze[i][j]='#';
        }
        else{
          maze[i][j]=' ';
        }
      }  
    }
    int tempX=0,tempY=0;
    int tempXX=0,tempYY=0;
    for(Wall wall:walls){
        try{
       
        if(tempY==(ceil(wall.getY())-baseY)&&(ceil(wall.getX())-baseX)-tempX<=radius*2){
          
          for(;tempX<=(ceil(wall.getX())-baseX);tempX++){
             maze[ceil(wall.getY())-baseY][tempX] = '#';
          }
        }
        else{
          tempY=(ceil(wall.getY())-baseY);
          tempX = (ceil(wall.getX())-baseX);
        }
        tempXX = 0;
        tempYY=0;
        for(Wall wall2:walls){
          if(tempXX == (ceil(wall2.getX())-baseX)&&(ceil(wall2.getY())-baseY)-tempYY<=radius){
             for(;tempYY<=(ceil(wall2.getY())-baseY);tempYY++){
               maze[tempYY][tempXX] = '#';
             }
          }
          else{
             tempXX = (ceil(wall.getX())-baseX);
             tempYY=(ceil(wall.getY())-baseY);
          }
        }
        }catch(ArrayIndexOutOfBoundsException e){
          continue; 
        }
    }
  }
  public char[][] getMaze(){
    return maze; 
  }
  public void clearMaze(){
    for(int i=0;i<mazeHeight;i++){
      for(int j=0;j<mazeWidth;j++){
       
          maze[i][j]=' ';
        
      }  
    }
  }
  public ArrayList<Cell> solveMaze(){
    Comparator<Cell> comparator = new HeuristicComparator(end);
    PriorityQueue<Cell> frontier = new PriorityQueue<Cell>(comparator);
    
    frontier.add(start);
    came_from.put(start,new Cell(-1,-1));
    cost_so_far.put(start,0.0);
    
    maze[start.getY()][start.getX()]='0';
    
    while(!frontier.isEmpty()){
        Cell current = frontier.remove();
        if(isEnd(current)){
             //came_from.put(end, current);
             break;
        }
           
        HashMap<Cell,Float> neighboursWithCost = findNeighbours(current);
        
        for(Cell next : neighboursWithCost.keySet()){
            Float newCost = cost_so_far.get(current)+neighboursWithCost.get(next);
            if(!cost_so_far.containsKey(next) || newCost < cost_so_far.get(next)){
                cost_so_far.put(next,newCost);
                frontier.add(next);
                came_from.put(next, current);
                
            }
            
        }
    }
    ArrayList<Cell> path = reconsturctPath();
    for(Cell cell : path){
        maze[cell.getY()][cell.getX()]='*';
    }
    setMazeToFile("mazeSolution.txt",maze);
    
    return path;
  }
  private ArrayList<Cell> reconsturctPath(){
      Cell current = end;
      ArrayList<Cell> path = new ArrayList<Cell>();
      while(current != start){
          path.add(current);
          current = came_from.get(current);
          
      }
      path.add(start);
      Collections.reverse(path);
      return path;
  }
  private boolean isEnd(Cell current){
      if(current.getX() == end.getX() && current.getY() == end.getY())
          return true;
      return false;
  }
  private HashMap<Cell,Float> findNeighbours(Cell current){
      HashMap<Cell,Float> neighbours = new HashMap<Cell,Float>();
      
      Cell left = new Cell (current.getX()-1,current.getY());
      Cell right = new Cell (current.getX()+1,current.getY());
      Cell up = new Cell (current.getX(),current.getY()-1);
      Cell down = new Cell (current.getX(),current.getY()+1);
      
      Cell leftUp = new Cell (current.getX()-1,current.getY()-1);
      Cell leftDown = new Cell (current.getX()-1,current.getY()+1);
      Cell rightUp = new Cell (current.getX()+1,current.getY()-1);
      Cell rightDown = new Cell (current.getX()+1,current.getY()+1);
      
      if(isWalkable(left)){
          neighbours.put(left,defaultCost*2.0);
      }
      if(isWalkable(right)){
          neighbours.put(right,defaultCost*2.0);
      }
      if(isWalkable(up)){
          neighbours.put(up,defaultCost*2.0);
      }
      if(isWalkable(down)){
          neighbours.put(down,defaultCost*2.0);
      }
      
      if(isWalkable(leftUp)){
          neighbours.put(leftUp,sqrt(defaultCost*2));
      }
      if(isWalkable(leftDown)){
          neighbours.put(leftDown,sqrt(defaultCost*2));
      }
      if(isWalkable(rightUp)){
          neighbours.put(rightUp,sqrt(defaultCost*2));
      }
      if(isWalkable(rightDown)){
          neighbours.put(rightDown,sqrt(defaultCost*2));
      }
      
      return neighbours;
  }
  private boolean isWalkable(Cell cell){
      int threshold = 3;
      for(int i = cell.getY()-radius-threshold ; i<=cell.getY()+radius+threshold; i++){
          for(int j = cell.getX()-radius-threshold ; j<=cell.getX()+radius+threshold; j++){
              if(maze[i][j]=='#')
                  return false;
          }
      }
      return true;
  }
  public void printMaze(){
      for(char[]row:maze){
          for(char col : row){
              System.out.print(col);
          }
          System.out.println();
      }
  }
  public void setMazeToFile(String name,char[][]mazeArr){
      try
      {
          output = createWriter(name);    
          int i = 0;
          for (char [] row : mazeArr)
          {
             int j =0;
              for(char col : row){
                if(start.getX()==j&&start.getY()==i)
                  output.print("S");
               else if(end.getX()==j&&end.getY()==i)
                  output.print("f");  
               else
               
                  output.print(col);
                 j++;
              }
              output.println();
              i++;
          }
          output.close();
      }
      catch (Exception e)
      {
          e.printStackTrace();
          System.out.println("No such file exists.");
      }
  }
  public void writeTxt(String name){
    output = createWriter(name);
    for(int i=0;i<mazeHeight;i++){
      output.println();
      
      for(int j=0;j<mazeWidth;j++){
        output.print(maze[i][j]);
        
      }  
    }
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
  }
}