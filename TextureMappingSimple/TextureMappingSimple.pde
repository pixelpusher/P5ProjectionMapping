import processing.opengl.*;

/*
 * First go at Projection mapping in Processing
 *
 * by Evan Raskob
 * 
 */
 
 



ProjectedShapeVertex currentVert = null; // reference to the currently selected vert

float maxDistToVert = 10;  //max distance between mouse and a vertex for moving

ArrayList<ProjectedShape> shapes = null; // list of points in the image (PVectors)

ProjectedShape currentShape = null;

PImage sourceImage;

final int SHOW_SOURCE = 0;
final int SHOW_MAPPED = 1;
final int SHOW_BOTH = 2;

int displayMode = SHOW_BOTH;  

float distanceSquared = 20*20;  // in pixels, for selecting verts

boolean drawImage = true;


// 
// setup
//

void setup()
{
  // set size and renderer
  size(640, 480, OPENGL);

  // load my image
  sourceImage = loadImage("7sac9xt9.bmp");

  // this will hold out drawing's vertices
  shapes = new ArrayList<ProjectedShape>();

  currentShape = new ProjectedShape( sourceImage );
  shapes.add ( currentShape );
}


// 
// draw
//

void draw()
{
  // white background
  background(255);

  if (drawImage)
    image( sourceImage, 0, 0);

  switch( displayMode )
  {
  case SHOW_SOURCE:
    fill(255, 20);
    currentShape.drawSourceShape();
    break;


  case SHOW_MAPPED:
    fill(255, 20);
    stroke(255,0,255);
    currentShape.draw();
    break;



  case SHOW_BOTH:

    fill(255, 20);
    currentShape.drawSourceShape();

    pushMatrix();
    translate(currentShape.myImage.width, 0);
    
    noStroke();
    currentShape.draw();
    
    currentShape.drawDestShape();
    popMatrix();


    break;
  }
}




void mousePressed()
{

  switch( displayMode )
  {
  case SHOW_SOURCE:

    currentVert = currentShape.getClosestVertexToSource(mouseX, mouseY, distanceSquared);

    if (currentVert ==  null)
    {
      println("*****check distance to line\n");
      
      currentVert = currentShape.addClosestSourcePointToLine( mouseX, mouseY, distanceSquared);
    }
    else
    {
      println("*****got a vert\n\n");
    }

    if (currentVert ==  null)
    {
      println("*****add a vert\n\n");
      currentVert = currentShape.addVert( mouseX, mouseY, mouseX, mouseY );
    } 
    break;

  case SHOW_MAPPED:
    currentVert = currentShape.getClosestVertexToDest(mouseX, mouseY, distanceSquared);

    if (currentVert ==  null)
    {
      currentVert = currentShape.addClosestDestPointToLine( mouseX, mouseY, distanceSquared);
    }

    if (currentVert ==  null)
    {
      currentVert = currentShape.addVert( mouseX, mouseY, mouseX, mouseY );
    } 
    break;

  case SHOW_BOTH:

    if (mouseX < currentShape.myImage.width)
    {
      // SOURCE
      currentVert = currentShape.getClosestVertexToSource(mouseX, mouseY, distanceSquared);

      if (currentVert ==  null)
      {
        currentVert = currentShape.addClosestSourcePointToLine( mouseX, mouseY, distanceSquared);
      }

      if (currentVert ==  null)
      {        
        currentVert = currentShape.addVert( mouseX, mouseY, mouseX, mouseY );
      }
    }
    else
    {
      //println("mx" + (mouseX-currentShape.myImage.width));

      //DEST
      currentVert = currentShape.getClosestVertexToDest(mouseX-currentShape.myImage.width, mouseY, distanceSquared);

      if (currentVert ==  null)
      {
        currentVert = currentShape.addClosestDestPointToLine( mouseX-currentShape.myImage.width, mouseY, distanceSquared);
      }

      if (currentVert ==  null)
      {
        currentVert = currentShape.addVert( mouseX-currentShape.myImage.width, mouseY, 
        mouseX-currentShape.myImage.width, mouseY );
      }
    }
    break;
  }
}



void mouseReleased()
{
  // Now we know no vertex is pressed, so stop tracking the current one
  currentVert = null;
}


void mouseDragged()
{
  // if we have a closest vertex, update it's position

  if (currentVert != null)
  {
    switch( displayMode )
    {
    case SHOW_SOURCE:
      currentVert.src.x = mouseX;
      currentVert.src.y = mouseY;
      break;


    case SHOW_MAPPED:
      currentVert.dest.x = mouseX;
      currentVert.dest.y = mouseY;
      break;


    case SHOW_BOTH:

      if (mouseX < currentShape.myImage.width)
      {
        currentVert.src.x = mouseX;
        currentVert.src.y = mouseY;
      } 
      else 
      {
        println("move dest");
        currentVert.dest.x = mouseX-currentShape.myImage.width;
        currentVert.dest.y = mouseY;
      }

      break;
    }
  }
}




void keyPressed()
{
}

void keyReleased()
{
  if (key == 'p' || key =='P')
  {
  }
  else if (key == 'd' && currentVert != null)
  {

    currentShape.removeVert(currentVert);
    currentVert = null;
  }
  else if (key == ' ') 
  {
    currentShape.clear();
    currentVert = null;
  }
  else if (key == 'i') 
  {
    drawImage = !drawImage;
  }  
  else if (key == 'm') 
  {

    if (displayMode == SHOW_BOTH)
      displayMode = SHOW_SOURCE;
    else
      displayMode++;
  }
}

