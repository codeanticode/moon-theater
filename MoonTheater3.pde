/*
MOON THEATER
 MICHAEL KONTOPOULOS AND NOVA JIANG
 PROGRAMMING ANDRES COLUBRI
 VERSION: 3 (SUNDANCE, 1 WAS GLOW, 2 ARIZONA)
 JANUARY 2009
 */

// Sillouethe detection and tracking algorithm: 
// It works by first running a background substraction algorithm, and then a blob detection on
// the difference image from the background substraction. 
// Each sillouethe is characterized by two types of points: border and center. The border points
// are chosen to be uniformly spaced along the edges of the sillouethe, while the center point
// is calculated as the geometric average of all the border points.

//import processing.video.*;
import codeanticode.gsvideo.*;
import blobDetection.*;
import processing.opengl.*;

boolean DEBUGMODE = true;

// Camera resolution.
int camWidth = 320;
int camHeight = 240;

// Size of the image used to do the motion tracking calculations.
int diffWidth = 320;
int diffHeight = 240;
// Threshold for the differencing algorithm: the larger 
// this value is, the more insensitive the tracking becomes
// (that is, it would only detect big changes in the image).
float diffThreshold = 100.0;
// Frame when the tracking detection starts.
int diffFirstFrame = 30;
// If a region in the image has less than diffFreeFraction of different pixels
// (different with respect to the background image), then it is not regarded 
// as contain a motion. wallResX and wallResY are used to determine the number
// of regions in the image.
float diffFreeFraction = 0.1;
// Resolution of the grid used by the differencing algorithm to group pixels.
int diffResX = diffWidth;
int diffResY = diffHeight;

// These parameters discriminate against too small/large blobs
float minBlobArea = 0.04;
float maxBlobArea = 0.65;
// Number of border points per hand.
int numBorderPoints = 30;
// Easing factor used to smooth out the movement of the hand points.
float easingConstant = 0.5;
// Threshold to identify two hands as the same.
float distThreshold = 280.0;
// Minimum distance between non-colliding puppets.
float colissionThreshold = 50.0;

// Maximum number of hands.
int maxNumHands = 10;
// Number of different puppets.
int numPuppets = 17;
int maskThresh = 120;

float blobThreshold = 0.96;

// Minimum age in milliseconds for a puppet to be shown on the screen.
int minAgeMillis = 100;

// Restart interval (0 for not automatic restart). In seconds.
int maskImageRestartInterval = 1800;

boolean drawImgDiff = false;
boolean drawBlobEdges = false;
boolean drawHandCtrlPoints = false;
boolean drawThePuppets = true;
boolean showMoon = true;
boolean showFPS = false;

GSCapture cam;
BlobDetection bDet;

boolean newFrame,showMask;
PImage camImg;

PImage moon;
PImage moonmask;
PImage imageMask;

PuppetImages puppets;

Hand tmpHand;
ArrayList hands;

//==========================================================
//==========================================================

void setup()
{
  size(1024, 768, OPENGL);

  noCursor();
  cam = new GSCapture(this, camWidth, camHeight);

  moon = loadImage("moon_pic.jpg");
  moonmask = loadImage("moon_inverted.jpg");
  moon.mask(moonmask);

  camImg = new PImage(diffWidth, diffHeight); 
  //camImg = new PImage(diffWidth, diffHeight); 
  imageMask = new PImage(diffWidth, diffHeight);

  //Load all of the .png files for the puppets
  puppets = new PuppetImages();
  puppets.loadImages();

  bDet = new BlobDetection(diffWidth, diffHeight);
  bDet.setPosDiscrimination(true);
  //this was .2 when doing MotionDetection differencing
  bDet.setThreshold(blobThreshold);

  hands = new ArrayList(maxNumHands);
  tmpHand = new Hand(numBorderPoints, easingConstant);

  newFrame = false;

  generateMaskImage();
}

int i;
//==========================================================
int maskpixel;
int newpixel;
void draw()
{
  if (0 < maskImageRestartInterval)
  {
    if (millis() % (maskImageRestartInterval * 1000) == 0) generateMaskImage();
  }
  
  //if (DEBUGMODE) println(frameRate);
  if (newFrame)
  {
    background(220);

    newFrame = false;

    //we can only do the following if cam and camImg are the same size
    //i.e. if we're not resizing the capture image
    camImg.loadPixels();
    imageMask.loadPixels();
    cam.loadPixels(); 
    for (i = 0; i < cam.pixels.length; i++) {
      if(imageMask.pixels[i] >= maskThresh)
      {  
        /*maskpixel = imageMask.pixels[i] & 0xff;
        newpixel = maskpixel<<16 | maskpixel<<8 | maskpixel;*/
        
        camImg.pixels[i] = (255<<16 | 255<<8 | 255);//imageMask.pixels[i];
      }
      else{
        camImg.pixels[i] = cam.pixels[i];
      }
    }
    
    cam.updatePixels();
    imageMask.updatePixels();
    camImg.updatePixels();
    //this is what we do if camImg dims are != to cam dims:
    //camImg.copy(cam, 0, 0, cam.width, cam.height, 
    //0, 0, camImg.width, camImg.height);

    fastBlur(camImg);

    // Motion detection by background substracting.
    //mDet.run(camImg);
    //if (drawImgDiff) mDet.renderImgDiff();

    // Blob detection.
    //turning off use of differencing, in the hopes it's not gaining us much due to controlled lighting and white background
    //bDet.computeBlobs(mDet.imgDiff.pixels);
    //just running blob detect straight on camera image. plan B is to copy cam to camImg again (above) and run fast blur on camImg.
    bDet.computeBlobs(camImg.pixels);
    if (drawBlobEdges) drawBlobEdges();

    updateHandPoints();
    if (drawHandCtrlPoints) drawHandPoints();
    if (drawThePuppets) drawPuppets();

    if(showMoon) {
      image(moon,0,0);
    }
    if(showMask){
      image(imageMask,0,0); 
      image(camImg,0,diffHeight);
    }
  }
  
  if (showFPS) println(frameRate);
}
//==========================================================
void captureEvent(GSCapture cam)
{
  cam.read();
  newFrame = true;
}
//==========================================================
void drawBlobEdges()
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n = 0; n < bDet.getBlobNb(); n++)
  {
    b = bDet.getBlob(n);

    if ((b != null) && (b.w * b.h > minBlobArea))
    {
      fill(0, 200, 200);
      strokeWeight(3);
      stroke(0, 255, 0);
      for (int m = 0; m < b.getEdgeNb(); m++)
      {
        eA = b.getEdgeVertexA(m);
        eB = b.getEdgeVertexB(m);
        if (eA != null && eB != null) line(eA.x * width, eA.y * height, eB.x * width, eB.y * height);
      }
    }
  }
}


//==========================================================
void updateHandPoints()
{
  Blob b;
  EdgeVertex evA, evB;
  float avex, avey, x, y, x0, y0, x1, y1;
  int distBtwPoint=0;
  int nValidBlobs = 0;
  int nBlobs = bDet.getBlobNb();
  int nHands0 = hands.size();
  float[] blobArea = new float[nBlobs];
  boolean[] blobValid = new boolean[nBlobs];
  int[] idxContainedHands = new int[nHands0];
  int[] availablePuppetIDs = new int[nHands0];
  int numAvailablePuppetIDs = 0;

  // Reseting updated field in all hands.
  for (int i = 0; i < nHands0; i++)
  {
    ((Hand)hands.get(i)).old = true;
    ((Hand)hands.get(i)).updated = false;  
  }

  for (int n = 0; n < nBlobs; n++)
  {
    b = bDet.getBlob(n);
    if (b != null)
    {
      blobArea[n] = b.w * b.h;
      if ((blobArea[n] > minBlobArea) && (blobArea[n] < maxBlobArea)) 
      {
        blobValid[n] = true; 
        nValidBlobs++;
      }
      else blobValid[n] = false; 
    }
    else blobValid[n] = false;     
  }
  
  for (int n = 0; n < bDet.getBlobNb(); n++)
  {
    b = bDet.getBlob(n);
    if (blobValid[n])
    {       
      // Initializing average for current blob.
      avex = avey = 0.0;
      
      // In the idxContainedHands array the indeces of the hands contained by the current blob are stored.
      for (int i = 0; i < nHands0; i++) idxContainedHands[i] = -1;

      // Intitializing bounding box points.
      x0 = width;      
      y0 = height;
      x1 = 0;
      y1 = 0;

      // Getting border points.
      distBtwPoint = int(b.getEdgeNb() / numBorderPoints);
      int k = 0;
      for (int m = 0; m < b.getEdgeNb(); m++)
      {                
        evA = b.getEdgeVertexA(m);

        // Updating average.
        avex += evA.x * width;
        avey += evA.y * height;

        if ((evA != null) && (m % abs(distBtwPoint) == 0))
        {
          k++;
          x = evA.x * width;
          y = evA.y * height;

          // Updating bounding box points.           
          if (x < x0) x0 = x;
          if (y < y0) y0 = y;
          if (x1 < x) x1 = x;
          if (y1 < y) y1 = y;
          
          tmpHand.setBorderPoint(k, x, y);
        }
      }
      
      // Geometric average of the blob/hand contour. Should correspond, more or less, to the center of the palm.
      avex /= b.getEdgeNb();
      avey /= b.getEdgeNb();


      tmpHand.setCenterPoint(avex, avey); 
      tmpHand.setBoundingBox(x0, y0, x1, y1);
      tmpHand.calcOrientation();
      
      // Checking what hands in the list are contained in the current blob.
      int numContHands = 0;
      for (int i = 0; i < hands.size(); i++)
        if (((Hand)hands.get(i)).old && tmpHand.containsBBox((Hand)hands.get(i)))
        {
          idxContainedHands[numContHands] = i;
          numContHands++;
        }
      
      if (numContHands > 1) 
      {
        // This blob contains more than one hand... so it means that hands have fused by virtue of being too close to each other.
        // The updateFusedHands() updates the positions of each individual hand according to the points of the blob that can be assigned to
        // each hand.
        // When some of the hands are too close to each other (their center points are closed than colissionThreshold), then one of them is
        // marked for deletion (update for that hand is set as false), and its puppet ID is stored in availablePuppetIDs, so new hands in this
        // iteration can recapture this puppet. This trick was implemented to fix the problem of one hand grabbing more than one puppet.
        numAvailablePuppetIDs = tmpHand.updateFusedHands(hands, idxContainedHands, numContHands, availablePuppetIDs, numAvailablePuppetIDs);
      }
      else if (numContHands == 1)
      {
          // The current blob is identified with hand j-th.
          int j = idxContainedHands[0];
          ((Hand)hands.get(j)).update(tmpHand);
          ((Hand)hands.get(j)).area = blobArea[n];        
      }
      else
      {
          // The current blob represents a new hand
          if (numAvailablePuppetIDs == 0)
          {
              hands.add(new Hand(tmpHand));
          }
          else
          {
              // For the new hand, using the puppet ID of a collided hand...
              hands.add(new Hand(tmpHand, availablePuppetIDs[numAvailablePuppetIDs - 1]));
              numAvailablePuppetIDs--;
          }
      }
    }
  }

  // Deleting non-updated hands (if they weren't updated means that they dissapeared from the image).
  for (int i = hands.size() - 1; 0 <= i; i--)
    if (!((Hand)hands.get(i)).updated || (distBtwPoint <= 2) ) 
    {
      hands.remove(i);
    }
}
//==========================================================
int myPixel;
void generateMaskImage()
{
  cam.loadPixels();
  imageMask.loadPixels();
  for (i = 0; i < cam.pixels.length; i++) {
    myPixel = cam.pixels[i] & 0xff;
    myPixel = 255-myPixel;
    imageMask.pixels[i] = ((myPixel<<16) | (myPixel<<8) | (myPixel));
  }
  cam.updatePixels();
  imageMask.updatePixels();
 println("Mask Image Initialized");
}

//==========================================================
void drawHandPoints()
{
  for (int i = 0; i < hands.size(); i++)
  {
    //if (DEBUGMODE) println("HAND " + i);
    ((Hand)hands.get(i)).draw();
    //((HandPoints)hands.get(i)).renderPuppets(); 
    /*
    if (((HandPoints)hands.get(i)).age == 0)
     println("  This hand is new");
     else
     println("  This hand is old");
     if (((HandPoints)hands.get(i)).direction.x > 0)           
     println("  It is going from left to right.");
     else
     println("  It is going from right to left.");*/
  } 
}
//==========================================================
void drawPuppets()
{
  Hand hand;
  for (int i = 0; i < hands.size(); i++)
  {
    hand = (Hand)hands.get(i);
    if (minAgeMillis < hand.ageMillis)
    {
      hand.renderPuppets();
    }
  } 
}
//==========================================================
private void fastBlur(PImage img)
{
  int radius = 2;
  int w = img.width;
  int h = img.height;
  int wm = w - 1;
  int hm = h - 1;
  int wh = w * h;
  int div = radius + radius + 1;
  int r[] = new int[wh];
  int g[] = new int[wh];
  int b[] = new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix = img.pixels;
  int dv[] = new int[256*div];

  for (i = 0; i < 256 * div; i++)
  {
    dv[i] = (i / div);
  }

  yw = yi = 0;

  for (y = 0; y < h; y++)
  {
    rsum = gsum = bsum = 0;

    for (i = -radius; i<=radius; i++)
    {
      p = pix[yi + min(wm, max(i,0))];
      rsum += (p & 0xff0000) >> 16;
      gsum += (p & 0x00ff00) >> 8;
      bsum += p & 0x0000ff;
    }

    for (x = 0; x < w; x++)
    {
      r[yi] = dv[rsum];
      g[yi] = dv[gsum];
      b[yi] = dv[bsum];

      if (y == 0)
      {
        vmin[x] = min(x + radius + 1, wm);
        vmax[x] = max(x - radius, 0);
      }
      p1 = pix[yw + vmin[x]];
      p2 = pix[yw + vmax[x]];

      rsum += ((p1 & 0xff0000) - (p2 & 0xff0000)) >> 16;
      gsum += ((p1 & 0x00ff00) - (p2 & 0x00ff00)) >> 8;
      bsum += (p1 & 0x0000ff) - (p2 & 0x0000ff);
      yi++;
    }
    yw += w;
  }

  for (x = 0; x < w; x++)
  {
    rsum = gsum = bsum = 0;
    yp =- radius * w;
    for (i = -radius; i <= radius; i++)
    {
      yi = max(0, yp) + x;
      rsum += r[yi];
      gsum += g[yi];
      bsum += b[yi];
      yp += w;
    }

    yi = x;
    for (y = 0; y < h; y++)
    {
      pix[yi] = 0xff000000 | (dv[rsum] << 16) | (dv[gsum] << 8) | dv[bsum];
      if (x == 0)
      {
        vmin[y] = min(y + radius + 1, hm) * w;
        vmax[y] = max(y - radius, 0) * w;
      }

      p1 = x + vmin[y];
      p2 = x + vmax[y];

      rsum += r[p1] - r[p2];
      gsum += g[p1] - g[p2];
      bsum += b[p1] - b[p2];

      yi += w;
    }
  }
}
