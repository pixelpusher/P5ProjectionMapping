/**
 * MultiColorGradientToxiclists demonstrates how to create a changing fill color using a ColorGradient
 * class from the toxi.color package.
 *
 * by Evan Raskob 2012 <evan@openlabworkshops.org>
 */
 

import toxi.math.*;
import toxi.color.*;


ColorList clist;          // this variable holds the ordered list of colors we'll use
int numberOfShades = 80;  // this the the number of shades of color we want (the more, the smoother the transitions)
int currentColorIndex = 0; // current index of the TColor in the ColorList 


void setup() 
{
  size(640, 480);

  // setup color gradients and lists  
  ColorGradient grad=new ColorGradient();

  // add some color points to the gradient
  grad.addColorAt(0, TColor.BLACK);
  grad.addColorAt(numberOfShades/4, TColor.BLUE);
  grad.addColorAt(2*numberOfShades/4, TColor.RED);
  grad.addColorAt(3*numberOfShades/4, TColor.YELLOW);
  grad.addColorAt(numberOfShades-1, TColor.BLACK); // back to black
  
  // now, convert the gradient into a simple list of colors:
  clist = grad.calcGradient(0, numberOfShades);
}


void draw() 
{
  background(0);
  currentColorIndex++;

  if (currentColorIndex >= clist.size())
  {
    currentColorIndex = 0;
  }
  
  noStroke();
  
  TColor c = clist.get(currentColorIndex); // get the color at the current index
  
  fill(c.toARGB());  // set fill color to currnt gradient
  
  rectMode(CENTER); // draw rectangle from centre point
  rect(width/2, height/2, width/2, height/2);
}

