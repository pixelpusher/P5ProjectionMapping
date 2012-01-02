import processing.opengl.*;

/*
 * First go at Projection mapping in Processing
 *
 * by Evan Raskob
 * 
 * keys:
 *
 *  d: delete currently selected shape vertex
 *  SPACEBAR: clear current shape
 *  i: toggle drawing source image
 *  m: next display mode ( SHOW_SOURCE, SHOW_MAPPED, SHOW_BOTH)
 *  s: sync vertices to source for current shape
 *  d: sync vertices to destination for current shape
 *
 */
 
 



ProjectedShapeVertex currentVert = null; // reference to the currently selected vert

ProjectedShapeRenderer shapeRenderer = null;

float maxDistToVert = 10;  //max distance between mouse and a vertex for moving

ProjectedShape currentShape = null;

PImage sourceImage;

final int SHOW_SOURCE = 0;
final int SHOW_MAPPED = 1;
final int SHOW_BOTH = 2;

int displayMode = SHOW_BOTH;  

boolean hitSrcShape = false;
boolean hitDestShape = false;

boolean drawImage = true;

final float distance = 15;
final float distanceSquared = distance*distance;  // in pixels, for selecting verts

// 
// setup
//

void setup()
{
  // set size and renderer
  size(640, 480, OPENGL);

  // load my image
  sourceImage = loadImage("7sac9xt9.bmp");

  currentShape = new ProjectedShape( sourceImage );
  shapeRenderer = new ProjectedShapeRenderer(); 
  
  frame.setResizable(true);
  
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
    shapeRenderer.drawSourceShape(currentShape);
    break;


  case SHOW_MAPPED:
    fill(255, 20);
    stroke(255,0,255);
    shapeRenderer.draw(currentShape);
    break;



  case SHOW_BOTH:

    fill(255, 20);
    shapeRenderer.drawSourceShape(currentShape);

    pushMatrix();
    translate(currentShape.srcImage.width, 0);
    
    noStroke();
    shapeRenderer.draw(currentShape);
    
    shapeRenderer.drawDestShape(currentShape);
    popMatrix();


    break;
  }
}



void mousePressed()
{
  hitSrcShape = hitDestShape = false;  
  
  switch( displayMode )
  {
  case SHOW_SOURCE:

    currentVert = currentShape.getClosestVertexToSource(mouseX, mouseY, distanceSquared);

    if (currentVert ==  null)
    {
      println("*****check distance to line\n");

      currentVert = currentShape.addClosestSourcePointToLine( mouseX, mouseY, distance);
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
      currentVert = currentShape.addClosestDestPointToLine( mouseX, mouseY, distance);
    }

    if (currentVert ==  null)
    {
      currentVert = currentShape.addVert( mouseX, mouseY, mouseX, mouseY );
    } 
    break;

  case SHOW_BOTH:

    if (mouseX < currentShape.srcImage.width)
    {
      // SOURCE
      currentVert = currentShape.getClosestVertexToSource(mouseX, mouseY, distanceSquared);

      if (currentVert ==  null)
      {
        currentVert = currentShape.addClosestSourcePointToLine( mouseX, mouseY, distance);
      }

      if (currentVert ==  null)
      {   
   
         if (isInsideShape(currentShape, mouseX, mouseY, true))
         {
           hitSrcShape = true;
           println("inside src shape[" + mouseX +","+mouseY+"]");
         }
         else
          currentVert = currentShape.addVert( mouseX, mouseY, mouseX, mouseY );
      }
    }
    else
    {
      //println("mx" + (mouseX-currentShape.srcImage.width));

      //DEST
      currentVert = currentShape.getClosestVertexToDest(mouseX-currentShape.srcImage.width, mouseY, distanceSquared);

      if (currentVert ==  null)
      {
        currentVert = currentShape.addClosestDestPointToLine( mouseX-currentShape.srcImage.width, mouseY, distance);
      }

      if (currentVert ==  null)
      {
        if (isInsideShape(currentShape, mouseX-currentShape.srcImage.width, mouseY, false))
         {
           hitDestShape = true;
           println("inside dest shape[" + mouseX +","+mouseY+"]");
         }
         else
         {
          currentVert = currentShape.addVert( mouseX-currentShape.srcImage.width, mouseY, 
            mouseX-currentShape.srcImage.width, mouseY );
         }
      }
    }
    break;
  }
}



void mouseReleased()
{
  // Now we know no vertex is pressed, so stop tracking the current one
  currentVert = null;
  
  hitSrcShape = hitDestShape = false;
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

      if (mouseX < currentShape.srcImage.width)
      {
        currentVert.src.x = mouseX;
        currentVert.src.y = mouseY;
      } 
      else 
      {
        println("move dest");
        currentVert.dest.x = mouseX-currentShape.srcImage.width;
        currentVert.dest.y = mouseY;
      }

      break;
    }
  }
  else
  if (hitSrcShape)
  {
      currentShape.move(mouseX-pmouseX, mouseY-pmouseY, true);
  }
  else
  if (hitDestShape)
  {
      currentShape.move(mouseX-pmouseX, mouseY-pmouseY, false);
  }
}



void keyPressed()
{
}

void keyReleased()
{
  if (key == 's' || key =='S' && currentShape != null)
  {
    currentShape.syncVertsToSource();
  }
  else if (key == 'd' || key =='D' && currentShape != null)
  {
     currentShape.syncVertsToDest();
  }
  else if (key == 'd' && currentVert != null)
  {

    currentShape.removeVert(currentVert);
    currentVert = null;
  }
  else if (key == ' ') 
  {
    currentShape.clearVerts();
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

