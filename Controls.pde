void keyPressed()
{
  switch (key){
  case '[':
     blobThreshold -=0.05;
   // maxBlobArea-=0.1;
    // bDet.setThreshold(blobThreshold);
    if (DEBUGMODE) println(blobThreshold);
    break;
  case ']':
     blobThreshold +=0.05;
   // maxBlobArea+=0.1;
    // bDet.setThreshold(blobThreshold);
    if (DEBUGMODE) println(blobThreshold);
    break;
  case '-':
    // threshold--;
    // easingFactor-=0.1;
    minBlobArea-=0.01;
    if (DEBUGMODE) println(minBlobArea);
    break;
  case '=':
    // threshold++;
    // easingFactor+=0.1;
    minBlobArea+=0.01;
    if (DEBUGMODE) println(minBlobArea);
    break;
  case 'd':
    drawHandCtrlPoints = !drawHandCtrlPoints;
    break;
  case 'i':
    drawImgDiff = !drawImgDiff;
    break;
  case 'm':
    showMoon = !showMoon;
    break;
  case 's':
    showMask = !showMask;
    break;
  case 'o':
    drawBlobEdges = !drawBlobEdges;
    break;
  case 'p':
    drawThePuppets = !drawThePuppets;
    break; 
  case 'f':
    showFPS = !showFPS;
    break; 
  case 'r':
    println("Restarting detector...");
    generateMaskImage();
    break;
  case ENTER:
    println("Restarting detector...");
    generateMaskImage();
    break;
  case ';':
    /*distThreshold--;
    if (DEBUGMODE) println(distThreshold);*/
    maskThresh--;
    //puppetPicker--;
    if (DEBUGMODE) println(maskThresh);
    break;
  case '\'':
    /*distThreshold++;
    if (DEBUGMODE) println(distThreshold); */
     maskThresh++;
    //puppetPicker++;
    if (DEBUGMODE) println(maskThresh);
    break;


  default:
    break;
  }
}
