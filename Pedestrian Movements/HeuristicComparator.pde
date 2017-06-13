import java.util.Comparator;

class HeuristicComparator implements Comparator<Cell>
{
    private Cell endCell;
    public HeuristicComparator(Cell endCell) {
        this.endCell = endCell;
    }
    
    @Override
    public int compare(Cell x, Cell y)
    {
        //compare remaining distance 
        if (calcHeuristic(x) < calcHeuristic(y))
        {
            return -1;
        }
        if (calcHeuristic(x) > calcHeuristic(y))
        {
            return 1;
        }
        return 0;
    }
    public int calcHeuristic(Cell currentCell){
        
         return Math.abs(currentCell.getX() - endCell.getX()) + Math.abs(currentCell.getY() - endCell.getY());
    }
}