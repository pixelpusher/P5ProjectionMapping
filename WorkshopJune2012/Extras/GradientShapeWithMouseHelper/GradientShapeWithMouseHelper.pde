import processing.opengl.*;

//
// Shows how to draw the mouse position (in pixels) in a white box on the screen.
// Useful for drawing shapes.
//
// by Evan Raskob 2012
// In the public domain.


void setup()
{
  size(640, 480, OPENGL);
}



void draw()
{
  background(0);

  beginShape();
  
  fill(57, 152, 188);
  vertex(10, 10);
  
  fill(255,0,0);
  vertex(280, 20);
  
  fill(255,0,255);
  vertex(370, 300);
  vertex(220, 360);
  
  fill(188, 152, 57);
  vertex(63, 222);
  vertex(10, 10);

  endShape();


  if (mousePressed) drawMousePosition();
}





void drawMousePosition()
{
  int h = 26; // height of box in pixels

  textSize(h-4); // leave 4 pixels for padding

  // make a white box
  fill(255, 180);
  stroke(0, 180);
  rect(mouseX, mouseY-h, 100, h); // add 4px of padding to the height

  fill(0); // draw text black
  text(mouseX+","+mouseY, mouseX+4, mouseY-4);

  fill(255, 255, 0);
  noStroke();
  ellipse(mouseX, mouseY, 8, 8);
}

