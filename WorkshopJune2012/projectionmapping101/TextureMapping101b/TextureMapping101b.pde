import processing.opengl.*;


PImage myImage;
// these will represent the boundary of our rectangular
// image on screen
int startX, endX, startY, endY;

void setup()
{
  // set size and renderer
  size(320,240, OPENGL);
  
  // load my image
  myImage = loadImage("7sac9xt9.bmp");
  
  startX  = 0;
  endX    = myImage.width;
  startY  = 0;
  endY    = myImage.height;
  
}

void draw()
{
  // white background
  background(255);
 
  if (keyPressed)
  {
    // key was pressed - see if SHIFT was held
    if (key==CODED && keyCode==SHIFT)
    {
      endX = constrain(mouseX, 5,myImage.width);
      endY = constrain(mouseY, 5, myImage.height);
      fill(255);
      text("SHIFT", mouseX,mouseY);
    }
    else
    {
      startX = constrain(mouseX, 0,endX-5);
      startY = constrain(mouseY, 0,endY-5);;
    }
  }
  
  image(myImage, 0,0);
  
  fill(255,40);
  rectMode(CORNERS);
  rect(startX,startY, endX,endY); 
  
  //  1 *---* 2
  //    |   |
  //  4 *---* 3 
  
  
  beginShape();
  texture( myImage );
  vertex(mouseX, mouseY,       startX,startY);
  vertex(mouseX+40, mouseY,    endX,startY);
  vertex(mouseX+40, mouseY+40, endX,endY);
  vertex(mouseX, mouseY+40,    startX,endY);
  endShape(CLOSE);
}
