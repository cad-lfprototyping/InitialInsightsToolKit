class Cell {
    
    private int x;
    private int y;
    
    Cell(int x, int y){
        
        this.x = x;
        this.y = y;
        
    }
    public int hashCode(){
        int hashcode = 0;
        hashcode = x*10;
        hashcode += y;
        return hashcode;
    }
    @Override
    public boolean equals(Object obj){
        if (obj instanceof Cell) {
            Cell pp = (Cell) obj;
            
            return (pp.x == this.x && pp.y == this.y);
        } else {
            return false;
        }
    }
    public int getX(){
        return x;
    }
    public int getY(){
        return y;
    }
    public String toString(){
        return "x: "+x+" y: "+y;
    }
    
}