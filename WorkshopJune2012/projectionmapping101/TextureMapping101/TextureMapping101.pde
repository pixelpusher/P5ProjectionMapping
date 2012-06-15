import processing.opengl.*;


PImage myImage;


void setup()
{
  // set size and renderer
  size(320,240, OPENGL);
  
  // load my image
  myImage = loadImage("7sac9xt9.bmp");
}

void draw()
{
  // white background
  background(255);
  
  //  1 *---* 2
  //    |   |
  //  4 *---* 3 
  
  
  beginShape();
  texture( myImage );
  vertex(mouseX, mouseY,       0,0);
  vertex(mouseX+40, mouseY,    myImage.width,0);
  vertex(mouseX+40, mouseY+40, myImage.width,myImage.height);
  vertex(mouseX, mouseY+40,    0,myImage.height);
  endShape(CLOSE);
}
