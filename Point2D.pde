// 2d point class.
class Point2D
{
    Point2D() 
    { 
        x = y = 0.0; 
    }

    Point2D(float x, float y) 
    { 
        this.x = x;
        this.y = y;
    }
   
    Point2D(Point2D p) 
    { 
        this.x = p.x;
        this.y = p.y;
    }   
   
    void update(Point2D p, float e)
    {
        this.x += e * (p.x - this.x);
        this.y += e * (p.y - this.y);  
    }     
   
    void update(float x, float y, float e)
    {
        this.x += e * (x - this.x);
        this.y += e * (y - this.y);      
    }
    
    void add(float dx, float dy)
    {
      this.x += dx;  
      this.y += dy;      
    }
    
    void set(Point2D p)
    {
        this.x = p.x;
        this.y = p.y;
    }    
    
    void set(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
    
    void normalize()
    {
       float n = dist(0, 0, x, y);
       x /= n;  
       y /= n;       
    }
    
    float x, y;  
}
