/**
 * ColorTheme demo showing the following:
 * - construction of TColorthemes via textual descriptions of shades and colors
 * - explicitlystepping through a list of colors over time (frames)
 *
 * @author Evan Raskob <evan@openlabworkshops.org> after Karsten Schmidt <info at postspectacular dot com>
 */


/* 
 * Copyright (c) 2009 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import toxi.color.*;
import toxi.util.datatypes.*;

ColorList clist; //this will hold our list of colors
int numberOfUniqueColors = 60; // these are all the sahdes of colours we will generate from a list


void setup() 
{
  size(1024, 768);

  smooth();  

  // first define our new theme
  ColorTheme t = new ColorTheme("test");
  // add different color options, each with their own weight
  t.addRange("soft ivory", 0.5);
  t.addRange("intense goldenrod", 0.25);
  t.addRange("warm saddlebrown", 0.15);
  t.addRange("fresh teal", 0.05);
  t.addRange("bright yellow", 0.05);

  // now add another random hue which is using only bright shades
  t.addRange(ColorRange.BRIGHT, TColor.newRandom(), random(0.02, 0.05));

  // use the TColortheme to create a list of colors
  clist = t.getColors( numberOfUniqueColors );

  
  frameRate(3); // set the framerate to something slow
}



void draw() {

  background(0);
  
  // use the framecount to get the next color, making sure it never is greater than the size of the list!
  int colorIndex = frameCount % clist.size(); 

  // get the TColor, which is a handy toxiclibs-specific color object 
  TColor tcolor = clist.get( colorIndex );

  color c = tcolor.toARGB(); // convert to a color we can use to set the fill

  fill(c);

  ellipse( width/2, height/2, width/2, height/2);
}

