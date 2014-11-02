// This class stores the points that define a hand 
// (discriminated between border and center points).

int puppetPicker = 13;
//==========================================================
//====HandPoint Class======================================= 
//==========================================================
class Hand
{
  Hand(int n, float f)
  {
    borderPoints = new Point2D[n];
    for (int i = 0; i < n; i++) borderPoints[i] = new Point2D();         
    centerPoint = new Point2D();
    centerPoint0 = new Point2D();
    direction = new Point2D();
    cornerPoint = new Point2D();
    boundWidth = 0;
    boundHeight = 0;     
    easingConst = f;
    updated = false;
    old = false;
    ageIter = 0;
    bornMillis = millis();
    ageMillis = 0;    
    currX = currY = currA = 0;
    puppetID = int(random(numPuppets + 0.9));
    left2right = 1;
    follow = 6;
  }
  //==========================================================
  Hand(Hand hand)
  {
    int n = hand.borderPoints.length;
    borderPoints = new Point2D[n];
    for (int i = 0; i < n; i++) borderPoints[i] = new Point2D(hand.borderPoints[i]);
    centerPoint = new Point2D(hand.centerPoint);
    centerPoint0 = new Point2D(hand.centerPoint0);
    direction = new Point2D(hand.direction);
    cornerPoint = new Point2D(hand.cornerPoint);
    boundWidth = hand.boundWidth;
    boundHeight = hand.boundHeight;    
    easingConst = hand.easingConst;
    updated = true;
    old = false;
    ageIter = 0;
    bornMillis = millis();
    ageMillis = 0;
    currX = currY = currA = 0;    
    puppetID = int(random(numPuppets + 0.9));
    left2right = hand.left2right;
    follow = hand.follow;
  }    
  //==========================================================
  Hand(Hand hand, int ID)
  {
    int n = hand.borderPoints.length;
    borderPoints = new Point2D[n];
    for (int i = 0; i < n; i++) borderPoints[i] = new Point2D(hand.borderPoints[i]);
    centerPoint = new Point2D(hand.centerPoint);
    centerPoint0 = new Point2D(hand.centerPoint0);
    direction = new Point2D(hand.direction);
    cornerPoint = new Point2D(hand.cornerPoint);
    boundWidth = hand.boundWidth;
    boundHeight = hand.boundHeight;    
    easingConst = hand.easingConst;
    updated = true;
    old = false;
    ageIter = 0;
    bornMillis = millis();
    ageMillis = 0;
    currX = currY = currA = 0;    
    puppetID = ID;
    left2right = hand.left2right;
    follow = hand.follow;
  }      
  //==========================================================
  void update(Hand hand)
  {
    centerPoint0.set(centerPoint);      
    centerPoint.update(hand.centerPoint, easingConst);
    direction.update(centerPoint.x - centerPoint0.x, centerPoint.y - centerPoint0.y, easingConst);
    direction.normalize();

    cornerPoint.update(hand.cornerPoint, easingConst);
    boundWidth += easingConst * (hand.boundWidth - boundWidth);
    boundHeight += easingConst * (hand.boundHeight - boundHeight);

    for (int i = 0; i < borderPoints.length; i++) borderPoints[i].update(hand.borderPoints[i], easingConst);
    updated = true;
    old = true;
    ageIter++;
    ageMillis = millis() - bornMillis;
  }
  //==========================================================
  float distanceAve(Hand hand)
  {
    float d = dist(centerPoint.x, centerPoint.y, hand.centerPoint.x, hand.centerPoint.y);
    for (int i = 0; i < borderPoints.length; i++) d += dist(borderPoints[i].x, borderPoints[i].y, hand.borderPoints[i].x, hand.borderPoints[i].y);
    d /= (borderPoints.length + 1);
    return d;
  }  
  //==========================================================
  float distanceCenter(Hand hand)
  {
    return dist(centerPoint.x, centerPoint.y, hand.centerPoint.x, hand.centerPoint.y);
  }
  //==========================================================
  void setCenterPoint(float x, float y)
  {
    centerPoint0.set(centerPoint);       
    centerPoint.set(x, y);
    direction.update(centerPoint.x - centerPoint0.x, centerPoint.y - centerPoint0.y, easingConst);        
    direction.normalize();    
  }
  //==========================================================  
  void calcOrientation()
  {
      if (centerPoint.x >= width/2) 
      {
        follow = 6;
        left2right = -1;
      }
      else 
      {
        left2right = 1; 
        follow = 8;
      }      
  }
  //==========================================================
  void updateCenterPoint(float x, float y)
  {
    centerPoint0.set(centerPoint);      
    centerPoint.update(x, y, easingConst);
    direction.update(centerPoint.x - centerPoint0.x, centerPoint.y - centerPoint0.y, easingConst);        
    direction.normalize();    
  }
  //==========================================================
  void setBorderPoint(int i, float x, float y)
  {
    if ((0 < i) && (i < borderPoints.length)) borderPoints[i].set(x, y);
  }
  //==========================================================
  void updateBorderPoint(int i, float x, float y)
  {
    if ((0 < i) && (i < borderPoints.length)) borderPoints[i].update(x, y, easingConst);
  }
  //==========================================================
  void displace(float dx, float dy)
  {
    centerPoint0.add(dx, dy);  
    centerPoint.add(dx, dy);
    cornerPoint.add(dx, dy);
    for (int i = 0; i < borderPoints.length; i++) borderPoints[i].add(dx, dy);
  }
  //==========================================================
  // This method tests whether the center point of hand is inside the polygon defined by the border points of this hand.
  // Algorithm taken from http://alienryderflex.com/polygon/. More info about this problem can be found at wikipedia:
  // http://en.wikipedia.org/wiki/Point_in_polygon
  boolean containsPoly(Hand hand)
  {
    boolean oddNodes = false;
    int j = borderPoints.length - 1;
    for (int i = 0; i < borderPoints.length; i++)
    {
      if ((borderPoints[i].y < hand.centerPoint.y && borderPoints[j].y >= hand.centerPoint.y) || 
          (borderPoints[j].y < hand.centerPoint.y && borderPoints[i].y >= hand.centerPoint.y)) 
      {
        if (borderPoints[i].x + (hand.centerPoint.y - borderPoints[i].y) / (borderPoints[j].y - borderPoints[i].y) * (borderPoints[j].x - borderPoints[i].x) < hand.centerPoint.x) 
        {
          oddNodes=!oddNodes; 
        }
      }
      j = i;    
    }
    return oddNodes;
  }
  //==========================================================  
  boolean containsPoly(Point2D p)
  {
    boolean oddNodes = false;
    int j = borderPoints.length - 1;
    for (int i = 0; i < borderPoints.length; i++)
    {
      if ((borderPoints[i].y < p.y && borderPoints[j].y >= p.y) || 
          (borderPoints[j].y < p.y && borderPoints[i].y >= p.y)) 
      {
        if (borderPoints[i].x + (p.y - borderPoints[i].y) / (borderPoints[j].y - borderPoints[i].y) * (borderPoints[j].x - borderPoints[i].x) < p.x) 
        {
          oddNodes=!oddNodes; 
        }
      }
      j = i;    
    }
    return oddNodes;
  }  
  //==========================================================
  // This method evaluates whether or not the center point of hand is inside the bounding box of this hand.
  boolean containsBBox(Hand hand)
  {
    return (cornerPoint.x < hand.centerPoint.x) && (hand.centerPoint.x < cornerPoint.x + boundWidth) &&
           (cornerPoint.y < hand.centerPoint.y) && (hand.centerPoint.y < cornerPoint.y + boundHeight);
  }
  //==========================================================
  boolean containsBBox(Point2D p)
  {
    return (cornerPoint.x < p.x) && (p.x < cornerPoint.x + boundWidth) &&
           (cornerPoint.y < p.y) && (p.y < cornerPoint.y + boundHeight);
  }  
  //==========================================================
  int updateFusedHands(ArrayList hands, int[] idxContainedHands, int numContHands, int[] availablePuppetIDs, int numAvailablePuppetIDs0)
  {  
    Hand hand;
    float xh, yh, x0, y0, x1, y1, avex, avey;
    Hand hand0;
    boolean found, foundX0, foundY0, foundX1, foundY1, collision;
    float d, dmin, dminX0, dminY0, dminX1, dminY1;
    int closestPt;
    boolean[] availablePts;
    Point2D pt = new Point2D();
    int numAvailablePuppetIDs = numAvailablePuppetIDs0;
        
    for (int i = 0; i < numContHands; i++)
    {
      // Updating the i-th contained hand.
      hand = (Hand)hands.get(idxContainedHands[i]);
      
      if (hand.updated) continue;
      
      availablePts = new boolean[borderPoints.length];
      for (int j = 0; j < borderPoints.length; j++) availablePts[j] = true;

      // Build an extended bounding box for hand that encompases the maxiumum area in relation to the other hands. 
      // This is done in order to capture as many border points of the new hand that would correspond to the old hands.
      // Basically, we enlarge (x0, y0, x1, y1) as much as possible to not intersect the extended bounding boxes of the other hands.
      x0 = hand.cornerPoint.x;
      y0 = hand.cornerPoint.y;
      x1 = x0 + hand.boundWidth;
      y1 = y0 + hand.boundHeight;

      foundX0 = foundY0 = foundX1 = foundY1 = false;
      dminX0 = dminX1 = width;
      dminY0 = dminY1 = height;
      for (int i0 = 0; i0 < numContHands; i0++)
        if (i != i0)
        {
          hand0 = (Hand)hands.get(idxContainedHands[i0]);
   
          if (hand0.centerPoint.x + hand0.boundWidth < x0)
          {
            d = x0 - hand0.centerPoint.x + hand0.boundWidth;
            if (d < dminX0) 
            {
              dminX0 = d;
              foundX0 = true;
            }
          }

          if (hand0.centerPoint.y + hand0.boundHeight < y0)
          {
            d = y0 - hand0.centerPoint.y + hand0.boundHeight;
            if (d < dminY0) 
            {
              dminY0 = d;
              foundY0 = true;
            }
          }

          if (x1 < hand0.centerPoint.x)
          {
            d = hand0.centerPoint.x - x1;
            if (d < dminX1) 
            {
              dminX1 = d;
              foundX1 = true;
            }
          }

          if (y1 < hand0.centerPoint.y)
          {
            d = hand0.centerPoint.y - y1;
            if (d < dminY1) 
            {
              dminY1 = d;
              foundY1 = true;
            }
          }
          
        }
        
      if (foundX0) x0 -= 0.5 * dminX0; else x0 = 0;
      if (foundY0) y0 -= 0.5 * dminY0; else y0 = 0;
      if (foundX1) x1 += 0.5 * dminX1; else x1 = width;
      if (foundY1) y1 += 0.5 * dminY1; else y1 = height;

      // We update the border points of hand using the closest border point point inside the extended
      // bounding box of hand.
      for (int j = 0; j < hand.borderPoints.length; j++)
      {
        dmin = 10000.0;  
        found = false;
        closestPt = -1;
        for (int k = 0; k < borderPoints.length; k++)
          if (availablePts[k] && (x0 < borderPoints[k].x) && (borderPoints[k].x < x1) && (y0 < borderPoints[k].y) && (borderPoints[k].y < y1))
          {
              d = dist(borderPoints[k].x, borderPoints[k].y, hand.borderPoints[j].x, hand.borderPoints[j].y);             
              if (d < dmin)
              {
                dmin = d;
                closestPt = k;
                found = true;
              }
          }
           
        if (found)
        {
          hand.borderPoints[j].update(borderPoints[closestPt], hand.easingConst);
          availablePts[closestPt] = false;
        }
      }
      
      // We update the center point, direction point and bounding box of hand.
      avex = avey = 0.0;
      x0 = width;      
      y0 = height;
      x1 = 0;
      y1 = 0;      
      for (int j = 0; j < hand.borderPoints.length; j++)
      {
        xh = hand.borderPoints[j].x;
        yh = hand.borderPoints[j].y;
        
        avex += xh;
        avey += yh;
        
        if (xh < x0) x0 = xh;
        if (yh < y0) y0 = yh;
        if (x1 < xh) x1 = xh;
        if (y1 < yh) y1 = yh;        
      }
      avex /= hand.borderPoints.length;
      avey /= hand.borderPoints.length;
      pt.set(avex, avey); 
            
      hand.centerPoint0.set(hand.centerPoint);
      hand.centerPoint.update(pt, hand.easingConst);      
      hand.direction.update(hand.centerPoint.x - hand.centerPoint0.x, hand.centerPoint.y - hand.centerPoint0.y, hand.easingConst);
      hand.direction.normalize();
      
      hand.setBoundingBox(x0, y0, x1, y1);

      hand.updated = true;
      hand.old = true;
      hand.ageIter++;
      hand.ageMillis = millis() - hand.bornMillis;
    } 
    
    // Collision detection: if two hands are two close together, one of them is deleted.
    for (int i = 0; i < numContHands; i++)
    {
      hand = (Hand)hands.get(idxContainedHands[i]);

      if (!hand.updated) continue;
      
      collision = false;
      hand0 = null;
      for (int i0 = i + 1; i0 < numContHands; i0++)
      {
        hand0 = (Hand)hands.get(idxContainedHands[i0]);
        if (!hand0.updated) continue;
          
        // Comparing center points of hands i and i0:
        d = dist(hand.centerPoint.x, hand.centerPoint.y, hand0.centerPoint.x, hand0.centerPoint.y);
          
        if (d < colissionThreshold)
        { 
          collision = true;
          break;
        }
      }
      
      if (collision) 
      {
        // Marking one of the two hands (hand or hand0) for deletion, this is, setting updated to false.
        // At the end of updateHandPoints(), all the non-updated hands are deleted.
        if (random(1) < 0.5) 
        {
          hand.updated = false;
          availablePuppetIDs[numAvailablePuppetIDs] = hand.puppetID; 
        }
        else
        {
           hand0.updated = false;
           availablePuppetIDs[numAvailablePuppetIDs] = hand0.puppetID; 
        }
        numAvailablePuppetIDs++;
      }
    }
    return numAvailablePuppetIDs;
  }
  //==========================================================
  void setBoundingBox(float x0, float y0, float x1, float y1)
  {
    cornerPoint.set(x0, y0);
    boundWidth = x1 - x0;
    boundHeight = y1 - y0;
  }
  //==========================================================
  void draw()
  {
    // Drawing border points.
    strokeWeight(10);
    for (int i = 0; i < borderPoints.length; i++)   
    {
      if(i==5 || i==12 || i==25){
        stroke(255, 0, 0);
      } 
      else {
        stroke(10,10,255); 
      }
      ellipse(borderPoints[i].x, borderPoints[i].y, 10, 10);
    }

    // Drawing center point.
    stroke(255, 255, 0);
    ellipse(centerPoint.x, centerPoint.y,10,10);

    // Drawing direction vector.
    float n = dist(0, 0, direction.x, direction.y);
    if (n > 0)
    {
      direction.x /= n;
      direction.y /= n;
      strokeWeight(5);
      stroke(0, 255, 255);  
      line(centerPoint.x, centerPoint.y, centerPoint.x + 20.0 * direction.x, centerPoint.y + 20.0 * direction.y);
    }
  }
  //avoid declarations in draw loop functions
  private float diff1, diff2, diff3, o, h, ang;
  //==========================================================
  void renderPuppets()
  {
    //Determining the appropriate orientation for the puppet
    o = borderPoints[follow].x - centerPoint.x;
    h = dist(centerPoint.x,centerPoint.y, borderPoints[follow].x,borderPoints[follow].y);
    ang = asin(o/h);
    //println(degrees(ang));

/*    
    if(centerPoint.x <= width/2)
    {
       follow = 8;
    } else {
       follow = 6;
    }
*/

    //Picking some point differences as references for puppet motion
    diff1 = dist(borderPoints[12].x,borderPoints[12].y, borderPoints[23].x,borderPoints[23].y);// C - shape
    diff2 = dist(borderPoints[2].x,borderPoints[2].y, borderPoints[10].x,borderPoints[10].y);
    diff3 = dist(borderPoints[15].x,borderPoints[15].y, borderPoints[25].x,borderPoints[25].y); 

    //This function calls a random puppet from the Puppets list
    callPuppet(puppetID, centerPoint.x,centerPoint.y, ang, area, diff1,diff2,diff3);

    //A line to demonstrate how the puppet will be oriented
    /*strokeWeight(1);
    stroke(0,0,255);
    line(centerPoint.x,centerPoint.y, borderPoints[follow].x,borderPoints[follow].y);*/
  } 

  //==========================================================

//----------------- ID   x-position  y-position  orientation  direction    knobs 1  ... 2 ... 2
void callPuppet(int num, float xpos, float ypos, float a, float area, float newD1,float newD2,float newD3)
{ 
  fill(0); 

    
  if(num==0){

    //---------------------------------
    //--------Alligator----------------
    //---------------------------------



    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;
    
    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;

    pushMatrix();
    {

      translate(currX, currY);
      rotate( constrain(currA, -PI/4, PI/4  ));
      //if(dir < 0) scale(-1.0,1.0);
      //for determing which way it faces
      // println(area);\
      scale(left2right,1);
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      //render the alligator in the upper corner w/ no positioning
      image(puppets.ali_top, -130,-100);

      //translate(currX, currY);
      // rotate(currA + radians(map(a, 0,d1, 0,30)));

      if(d1 >=300) d1=300; 
      if(d1 <=200) d1=200;
      
      rotate(  map(d1, 200,300, -PI/8,PI/8)  ); //30
      image(puppets.ali_bottom, -130,-15);
    }
    popMatrix();



  } 
  else if(num==1){
    //---------------------------------
    //--------fly----------------
    //---------------------------------
    {
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;


      float easing2 = 0.5;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;


      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(left2right,1);
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
        image(puppets.fly_body, -180,-73);
        pushMatrix();
        {
          translate(-5,-40);
          //-0.40142572,0.4886922
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.50142572,0.6886922));
          image(puppets.fly_wing,-221,-38); 
        }
        popMatrix();

        pushMatrix();
        {    

          translate(48,49);
          //-0.61086524,0.36651915
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.61086524,0.36651915));
          image(puppets.fly_front_leg,-8,-32);
        }   
        popMatrix();  
        pushMatrix();
        { 
          translate(14,62);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, -0.61086524,0.36651915));
          image(puppets.fly_middle_leg,-12,-59);
        }   
        popMatrix();
        pushMatrix();
        {    
          //Translation, relative to the "body"
          translate(-33,50);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.6,0.2));
          image(puppets.fly_back_leg,-78,-40);
        }   
        popMatrix();   
      }
      popMatrix();
    }

    //---------------------------------
    //---------Spider------------------
    //---------------------------------

    /*currX = A * currX + B* xpos;
     currY = A * currY + B* ypos;
     currA = A * currA + B* a;
     
     pushMatrix();
     {
     translate(xpos+40,ypos);
     rotate( constrain(currA, -PI/4, PI/4  ));
     
     //if(dir < 0) scale(-1.0,1.0);
     scale(left2right,1);
     scale(0.7,0.7);
     if(area < 0.2) {
     area = 0.2;
     } 
     scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
     image(puppets.spider_body, -200,-100);
     pushMatrix();
     {
     translate(57,6);
     rotate(map(d1,  100,300,  -0.75837773,0.5754247));
     image(puppets.spider_ll, -53,-242);
     }
     popMatrix();
     
     pushMatrix();
     {    
     translate(86,9);
     rotate(map(d2,  250,450,  0.29670596,-0.9599311));
     //println(d3);
     
     image(puppets.spider_rl, -212,-43);
     }   
     popMatrix();  
     }
     popMatrix();*/
  } 
  else if(num==2) {

    //---------------------------------
    //---------Angler Fish-------------
    //---------------------------------

    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/6, PI/6  ));
      scale(left2right,1); 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.angler_body, -302, -118);

      pushMatrix();
      { 
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        translate(13, 61);
        rotate(map(d1, 200,300, -0.20943952, 0.52831855)); 
        image(puppets.angler_jaw, 0, -103);  
      }
      popMatrix();
      pushMatrix();
      {    
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        translate(26, -64);
        rotate(map(d1, 200,300,  -0.15707964, 0.17453292));
        image(puppets.angler_light, 37, -121);
      }   
      popMatrix();  
    }
    popMatrix();
  } 
  else if(num==3)
  {
    //---------------------------------
    //---------Skeleton Bird-----------
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B*a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(0.7,0.7);
      scale(left2right,1);  
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.bird_body, -262, -103);

      pushMatrix();
      {
        translate(134, -85);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300,   0.61086524,-0.94247776));
        //-0.94247776, 0.61086524
        image(puppets.bird_head, -21, -215); 

      }
      popMatrix();

      pushMatrix();
      {    
        translate(45, -111);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450,  -0.38397244, 0.6632251));
        //-0.38397244, 0.6632251
        image(puppets.bird_wing, -295, -179);


      }   
      popMatrix();  
    }
    popMatrix(); 
  } 
  else if(num==4) {

    //---------------------------------
    //---------Jelly Fish Awesomeness--
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;
    
    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;
    
    
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(1.0+radians(sin(radians(30)*millis()/100)),1.0+radians(sin(radians(30)*millis()/100)));
      scale(left2right,1); 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.jelly_head, -167, -165);
      pushMatrix();
      {
        translate(-89, 87);
        rotate(radians(sin(radians(30)*millis()/100)));
        image(puppets.jelly_left, -208, -106); 
      }
      popMatrix();

      pushMatrix();
      { 
        translate(51, 100);
        rotate(radians(cos(radians(30)*millis()/100)));
        image(puppets.jelly_right, -129, -91);
      }   
      popMatrix();  
    }
    popMatrix(); 
  }
  else if(num==5) {


    pushMatrix();
    {
      //---------------------------------
      //---------Baby--------------------
      //---------------------------------
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;
      
      float easing2 = 0.5;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;
      
      
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(left2right,1); 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   ); 
      image(puppets.baby_body, -133, -123);

      pushMatrix();
      {

        translate(-22,-120);
        //-0.8552113,0.10471976
        if(d3 >=150) d3=150; 
        if(d3 <=400) d3=400;
        rotate(map(d3, 150,400, -0.8552113, 0.10471976));

        image(puppets.baby_head, -35,-93); //Determine these numbers by changing them to mouseX,mouseY positioning them and printing

      }
      popMatrix();

      pushMatrix();
      {
        translate(51,-64);
        //-0.9773844,1.6929693
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -0.9773844, 1.6929693));
        image(puppets.baby_left_arm, -7,-51); 
      }
      popMatrix();

      pushMatrix();
      {    
        translate(9,-94);

        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        //-0.27925268,1.4660766
        rotate(map(d1, 200,300, -0.37925268, 1.4660766));
        image(puppets.baby_right_arm, -10, -41);
      }   
      popMatrix();  
    }
    popMatrix();

  } 
  else if(num==6) {
    //---------------------------------
    //---------Cabaret Dancer----------
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(-left2right,1); // Orientation has to be inverted because of the images. 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.cabaret_dancer_body, -91, -72);

      pushMatrix();
      {
        translate(26, -42);
        //-0.4537856, 0.54105204
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -0.4537856, 0.54105204));
        image(puppets.cabaret_dancer_head, -118,-297); 
      }
      popMatrix();

      pushMatrix();
      {    

        translate(-17, -36);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -1.1519173, 1.2740903));
        image(puppets.cabaret_dancer_left_arm,-117,-92);
        //-1.1519173,1.2740903

      }   
      popMatrix();  
      pushMatrix();
      {    
        translate(60, -25);
        if(d3 >=450) d3=450; 
        if(d3 <=150) d3=150;
        rotate(map(d3, 150,450, -1.0297443, 1.3439035));
        //-1.0297443,1.3439035
        image(puppets.cabaret_dancer_right_arm,-6, -78);
      }   
      popMatrix();  
    }
    popMatrix();
  } 
  else if(num==7){
    //---------------------------------
    //---------Clown-------------------
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;

    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(-left2right,1); // Orientation has to be inverted because of the images. 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.clown_body, -68, -77);

      pushMatrix();
      {
        translate(29, -47);
        if(d3 >=450) d3=450; 
        if(d3 <=150) d3=150;
        rotate(map(d3, 150,450, -0.2443461, 0.54105204));
        //-0.2443461,0.54105204
        image(puppets.clown_head, -90,-104); 
      }
      popMatrix();

      pushMatrix();
      {    

        translate(60, 12);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -1.1519173,1.9896753));
        image(puppets.clown_left_arm,-74,-18);
      }   
      popMatrix();  
      pushMatrix();
      {    
        translate(0, 0);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -1.37881,1.2217305));
        //-1.37881,1.2217305
        image(puppets.clown_right_arm,-200, -41);

      }   
      popMatrix();  
    }
    popMatrix();
  } 
  else if(num==8){
    //---------------------------------
    //---------Reaper-------------------
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(-left2right,1); // Orientation has to be inverted because of the images. 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.death_horse,-243,-73);

      pushMatrix();
      {

        translate(13, -76);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -0.61086524,1.134464));
        //-0.61086524,1.134464
        image(puppets.death_skeleton, -99, -100); //Determine these numbers by changing them to mouseX,mouseY positioning them and printing
        pushMatrix();
        {    
          translate(-19,-66);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450 , 2.2863812, -0.62831855));
          //-0.62831855, 2.2863812
          image(puppets.death_arm, -9,-9);
        }   

        popMatrix();

      }
      popMatrix(); 

    }
    popMatrix();
  } 
  else if(num==9){
    //---------------------------------
    //---------Fighter-----------------
    //---------------------------------
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(-left2right,1);  // Orientation has to be inverted because of the images. 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.fighter_body, -94, -75);

      pushMatrix();
      {
        translate(-4, -64);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -0.40142572,0.2268928));
        //-0.40142572,0.2268928
        image(puppets.fighter_head, -88,-130); 
      }
      popMatrix();

      pushMatrix();
      {    

        translate(44,-22);
        if(d3 >=450) d3=450; 
        if(d3 <=150) d3=150;
        rotate(map(d3, 150,450, -0.80285144, 2.443461));
        //-0.80285144,2.443461
        image(puppets.fighter_arm,-9,-28);
      }   
      popMatrix();  
      pushMatrix();
      {
        translate(-46, -11);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -1.2217305,1.2566371));

        //-1.2217305,1.2566371
        image(puppets.fighter_arm_sword,-195,-120);
      }   
      popMatrix();  
    }
    popMatrix();
  } 
  else if(num==10){
    //---------------------------------
    //---------Hunter------------------
    //---------------------------------   

    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(left2right,1); 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.hunter_body, -74, -90);

      pushMatrix();
      {

        translate(-2, -63);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -0.715585, 0.40142572));
        //-0.715585, 0.40142572
        image(puppets.hunter_head, -24,-114); 
      }
      popMatrix();

      pushMatrix();
      {  
        translate(23,-21);
        if(d3 >=450) d3=450; 
        if(d3 <=150) d3=150;
        rotate(map(d3, 150,450, -0.7853982,1.0646509));
        //-0.7853982,1.0646509
        image(puppets.hunter_arm,-9,-20);
      }   
      popMatrix();  
      pushMatrix();
      { 
        translate(55, -49);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -0.43633232,0.2617994));
        //-0.43633232,0.2617994
        image(puppets.hunter_stick,-219,-67);
      }   
      popMatrix();  
    }
    popMatrix();

  } 
  else if(num==11){
    //---------------------------------
    //---------Manly Man---------------
    //---------------------------------    
    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(left2right,1); 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.man_body, -70, -97);

      pushMatrix();
      {
        translate(-10, -71);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -0.47123888,0.9599311));
        //-0.47123888,0.9599311
        image(puppets.man_head, -77,-169); 
      }
      popMatrix();

      pushMatrix();
      {    
        translate(-38, -23);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -2.984513,0.47123888));
        //-2.984513,0.47123888
        image(puppets.man_left_arm,-129,-11);
      }   
      popMatrix();  
      pushMatrix();
      {    
        translate(32, -4);
        if(d2 >=450) d2=450; 
        if(d2 <=250) d2=250;
        rotate(map(d2, 250,450, -1.0646509,1.8151424));
        //-1.0646509,1.8151424
        image(puppets.man_right_arm,-16, -146);
      }   
      popMatrix();  
    }
    popMatrix();

  } 
  else if(num==12){

    //---------------------------------
    //---------Sea Horse---------------
    //---------------------------------    

    currX = A * currX + B* xpos;
    currY = A * currY + B* ypos;
    currA = A * currA + B* a;

    float easing2 = 0.5;
    float C = easing2;
    float D = 1.0 - C;
    d1 = C * d1 + D * newD1; 
    d2 = C * d2 + D * newD2;
    d3 = C * d3 + D * newD3;


    //Overall position for puppet
    pushMatrix();
    {
      translate(xpos,ypos);
      rotate( constrain(currA, -PI/4, PI/4  ));
      scale(-left2right,1); // Orientation has to be inverted because of the images. 
      if(area < 0.2) {
        area = 0.2;
      } 
      scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
      image(puppets.sea_horse_body, -123, -143);


      pushMatrix();
      {
        translate(62,79);
        if(d1 >=300) d1=300; 
        if(d1 <=200) d1=200;
        rotate(map(d1, 200,300, -0.55850536,0.75049156));
        //-0.55850536,0.75049156
        image(puppets.sea_horse_fin, -17,-30);
      }
      popMatrix();
    }
    popMatrix();


  } 
  else if(num==13){
    //---------------------------------
    //---------Old Man---------------
    //---------------------------------  
    {
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;

      float easing2 = 0.7;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;


      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(-left2right,1); // Orientation has to be inverted because of the images. 
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
        image(puppets.old_man_body, -126, -115);
        pushMatrix();
        {
          translate(-103,-86);

          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -1.2391838,1));
          image(puppets.old_man_head,-129,-111); 
        }
        popMatrix();
        pushMatrix();
        {    
          translate(-110,-42);
          //-0.4886922,1.6231562
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.4886922,1.6231562));
          image(puppets.old_man_left_upper_arm,-51,-18);
          pushMatrix();
          {    
            translate(-29,160);
            if(d1 >=300) d1=300; 
            if(d1 <=200) d1=200;
            rotate(map(d1, 200,300, 0,1.7104226));
            image(puppets.old_man_left_arm,-24,-20);
          }   
          popMatrix();
        }   
        popMatrix();  
        pushMatrix();
        {    
          translate(-50,-54);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, -0.27925268,2));
          //rotate(1.3613569);
          image(puppets.old_man_right_upper_arm,-70,-17);
          pushMatrix();
          {    
            translate(-44,151);
            //rotate(radians(mouseX));
            if(d3 >=450) d3=450; 
            if(d3 <=150) d3=150;
            rotate(map(d3, 150,450, 0,2));
            image(puppets.old_man_right_arm,-48,-17);
          }   
          popMatrix();  
        }   
        popMatrix();  
      }
      popMatrix();
    }
  }
  else if(num==14){
    //---------------------------------
    //---------Pierrot---------------
    //---------------------------------  
    {
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;

      float easing2 = 0.5;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;


      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(-left2right,1); // Orientation has to be inverted because of the images. 
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );

        image(puppets.pierrot_body, -132, -163);
        pushMatrix();
        {
          translate(-35,-81);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.38397244,0.33161256));
          //-0.38397244,0.33161256
          image(puppets.pierrot_head,-85,-217); 
        }
        popMatrix();

        pushMatrix();
        {    
          translate(-16,-24);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.4537856,1.7));
          //-0.4537856,1.0821041
          image(puppets.pierrot_left_arm,-178,-15);
        }   
        popMatrix();  
        pushMatrix();
        {    
          translate(-90,-41);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, -1.4835298,0.87266463));
          image(puppets.pierrot_right_arm,-203, -107);
        }   
        popMatrix();  
      }
      popMatrix();
    }

  }
  else if(num==15){
    //---------------------------------
    //---------Soldier-----------------
    //---------------------------------  
    {

      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;

      float easing2 = 0.5;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;


      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(-left2right,1); // Orientation has to be inverted because of the images. 
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
        image(puppets.soldier_body, -132, -75);

        pushMatrix();
        {

          translate(-93, -60);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.2617994,0.62831855));
          image(puppets.soldier_head, -89, -97); 
        }
        popMatrix();

        pushMatrix();
        {    

          translate(-85,-11);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.40142572,1.5));
          image(puppets.soldier_arm, -177, -23);
        }   
        popMatrix();  
      }
      popMatrix();
    }
  }
  else if(num==16){
    //---------------------------------
    //---------Scorpion-----------------
    //---------------------------------  
    {
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;

      float easing2 = 0.3;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;


      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(0.6,0.6);
        scale(left2right,1); 
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
        image(puppets.scorpion_body, -225,-131);
        pushMatrix();
        {
          translate(-198,-97);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -1.1693705,0.4537856));
          //-1.1693705,0.4537856
          image(puppets.scorpion_tail, -77,-245); 
        }
        popMatrix();

        pushMatrix();
        {    
          translate(141,77);
          /*if(d2 >=450) d2=450; 
           if(d2 <=250) d2=250;
           rotate(-map(d2, 250,450, -1.0,1.0));*/
          //0,0.57595867
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -1.0,1.0));
          image(puppets.scorpion_left_claw,-21,-72);
        }   
        popMatrix();  
        pushMatrix();
        {  
          translate(87,111);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.9,1.0));
          //-0.43633232,0.82030475
          image(puppets.scorpion_right_claw,-89, -24);
        }   
        popMatrix(); 
        pushMatrix();
        {    
          translate(-14,71);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.7,0.7));
          //-0.62831855,0.57595867
          image(puppets.scorpion_left_leg_1,-86, -9);
        }   
        popMatrix(); 
        pushMatrix();
        {    
          translate(-75,56);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.7,0.7));
          //0.7330383,-0.715585
          image(puppets.scorpion_left_leg_2,-91,-16);
        }   
        popMatrix();
        pushMatrix();
        { 
          translate(-155,12);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, -0.7,0.7));
          image(puppets.scorpion_left_leg_3,-117,-45);
        }   
        popMatrix(); 
        pushMatrix();
        {  
          translate(-209,-42);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, 0.7,-0.7));
          image(puppets.scorpion_left_leg_4,-186,-89);
        }   
        popMatrix();  
        pushMatrix();
        { 
          translate(62,12);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, -0.7,0.7));
          image(puppets.scorpion_right_leg_1,-6,-68);
        }   
        popMatrix();  
        pushMatrix();
        { 
          translate(10,-33);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.7,0.7));
          image(puppets.scorpion_right_leg_2,-11,-70);
        }   
        popMatrix(); 
        pushMatrix();
        { 
          translate(-65,-67);
          if(d3 >=450) d3=450; 
          if(d3 <=150) d3=150;
          rotate(map(d3, 150,450, 0.7,-0.7));
          image(puppets.scorpion_right_leg_3,-10,-71);
        }   
        popMatrix(); 
        pushMatrix();
        { 
          translate(-162,-84);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.7,0.7));
          image(puppets.scorpion_right_leg_4,-11,-92);
        }   
        popMatrix();      
      }
      popMatrix();
    }
  }
  else if(num==17){
    //---------------------------------
    //---------venus_flytrap-----------
    //---------------------------------  
    {
      currX = A * currX + B* xpos;
      currY = A * currY + B* ypos;
      currA = A * currA + B* a;
      
      float easing2 = 0.5;
      float C = easing2;
      float D = 1.0 - C;
      d1 = C * d1 + D * newD1; 
      d2 = C * d2 + D * newD2;
      d3 = C * d3 + D * newD3;

      
      pushMatrix();
      {
        translate(xpos,ypos);
        rotate( constrain(currA, -PI/4, PI/4  ));
        scale(left2right,1); 
        if(area < 0.2) {
          area = 0.2;
        } 
        scale(  (map(area, 0.2,0.4, 1.0,2.0)) , (map(area, 0.2,0.4, 1.0,2.0))   );
        image(puppets.venus_flytrap_stem, -98, -94);
        pushMatrix();
        {
          translate(-107,27);
          //-0.7853982,0.715585
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.7853982,0.715585));
          image(puppets.venus_flytrap_side,-78, -80); 
        }
        popMatrix();

        pushMatrix();
        {    
          translate(-45, -109);
          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(map(d1, 200,300, -0.62831855,0));
          //-0.62831855,0
          image(puppets.venus_flytrap_closed_left, -55, -142);
        }   
        popMatrix();  
        pushMatrix();
        {    
          translate(-22,-104);

          if(d1 >=300) d1=300; 
          if(d1 <=200) d1=200;
          rotate(-map(d1, 200,300, -0.62831855,0));
          image(puppets.venus_flytrap_closed_right,-72,-136);

        }   
        popMatrix(); 
        pushMatrix();
        {    

          translate(114,-93);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(map(d2, 250,450, -0.43633232,0.36651915));
          //-0.43633232,0.36651915
          image(puppets.venus_flytrap_open_left, -56,-159);
        }   
        popMatrix(); 
        pushMatrix();
        {    
          translate(107, -88);
          if(d2 >=450) d2=450; 
          if(d2 <=250) d2=250;
          rotate(-map(d2, 250,450, 0,0.5));

          //0,0.5061455
          image(puppets.venus_flytrap_open_right, -9, -148);

        }   
        popMatrix();     
      }
      popMatrix();
    }

  }
}



  // Easing variables for global position and rotation of puppet.
  float easing = 0.3;
  float A = easing;
  float B = 1.0 - A;

  float currX,currY,currA;
  float d1, d2, d3;

  boolean old;
  boolean updated;
  Point2D direction;
  Point2D centerPoint, centerPoint0;
  Point2D cornerPoint;
  Point2D[] borderPoints;
  float easingConst, area;
  float boundWidth, boundHeight;
  int ageIter;
  int ageMillis;
  int bornMillis;  
  int puppetID;
  int follow;
  int left2right;
}
