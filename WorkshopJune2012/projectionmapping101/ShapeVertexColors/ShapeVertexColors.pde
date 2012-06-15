import processing.opengl.*;

/*
 * Shows how to draw a shape using a number of vertices (points)
 * and give each a color, resulting in a gradient fade.
 * requires either OPENGL or P3D renderers.
 *
 * by Evan Raskob 2012
 */


void setup()
{
  // set size and renderer
  size(640, 480, OPENGL);
}

void draw()
{
  // black background
  background(0);

  // Note:
  // Shapes are drawn point-by-point (vertex-by-vertex) in a clockwise direction, like:
  //
  //  1 *---* 2
  //    |   |
  //  4 *---* 3 
  //


  beginShape();

  fill(255, 0, 0);
  vertex(10, 10);

  fill(255, 0, 255);  
  vertex(280, 20);

  fill(255, 255, 0);
  vertex(370, 300);

  fill(0, 255, 0);
  vertex(220, 360);
  
  endShape();


  drawMousePosition();
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



