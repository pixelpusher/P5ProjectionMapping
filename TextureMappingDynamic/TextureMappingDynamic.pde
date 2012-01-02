/*
 * This shows how to use a dynamic animation to draw into 
 * a projection-mapped shape.
 *
 * by Evan Raskob
 * 
 * keys:
 *
 *  d: delete currently selected shape vertex
 *  a: add a new shape
 *  x: delete current shape
 *  <: prev shape
 *  >: next shape
 *  SPACEBAR: clear current shape
 *  i: toggle drawing source image
 *  m: next display mode ( SHOW_SOURCE, SHOW_MAPPED, SHOW_BOTH)
 *  s: sync vertices to source for current shape
 *  t: sync vertices to destination for current shape
 *
 */



LinkedList<ProjectedShape> shapes = null; // list of points in the image (PVectors)

ProjectedShapeVertex currentVert = null; // reference to the currently selected vert

ProjectedShapeRenderer shapeRenderer = null;

float maxDistToVert = 10;  //max distance between mouse and a vertex for moving

ProjectedShape currentShape = null;

HashMap<String, PImage> sourceImages;  // list of images, keyed by file name

final int SHOW_SOURCE = 0;
final int SHOW_MAPPED = 1;
final int SHOW_BOTH = 2;

boolean hitSrcShape = false;
boolean hitDestShape = false;

int displayMode = SHOW_BOTH;  

final float distance = 15;
final float distanceSquared = distance*distance;  // in pixels, for selecting verts

PGraphics dynamicImage;

boolean drawImage = true;


// 
// setup
//

void setup()
{
  // set size and renderer
  size(640, 480, OPENGL);

  shapeRenderer = new ProjectedShapeRenderer(); 
  shapes = new LinkedList<ProjectedShape>();
  sourceImages = new HashMap<String, PImage>(); 

  // load my image
  PImage sourceImage = loadImageIfNecessary("7sac9xt9.bmp");
  dynamicImage = createGraphics(256,256,OPENGL); 
  setupDynamicImage(dynamicImage);
  sourceImages.put( "whitneydynamic", dynamicImage );

  // to do - check for bad image data!
  addNewShape(dynamicImage);
}



void addNewShape(PImage sourceImage)
{
  // this will hold out drawing's vertices
  currentShape = new ProjectedShape( sourceImage );
  shapes.add ( currentShape );
}

void deleteShape( ProjectedShape s)
{
  if (currentShape == s) currentShape = null;
  shapes.remove( s );
}



void printLoadedFiles()
{
  println("Printing loaded images:");
  println();

  Set<String> keys = sourceImages.keySet();
  for (String k : keys)
  {
    println(k);
  }
}


// 
// this is dangerous because it doesn't check if it's still in use.
// but doing so would require wrapping the PImage object in a subclass
// that counts usage, and that adds too much complexity (for now)
//
void unloadImage( String location )
{
  sourceImages.remove( location );
}


PImage loadImageIfNecessary(String location)
{
  String _location = "";

  File f = new File(location);
  _location = f.getName();

  PImage loadedImage = null;

  if ( sourceImages.containsKey( _location ) )
  {
    loadedImage = sourceImages.get( _location );
  }
  else
  {
    loadedImage = loadImage( _location );
    sourceImages.put( _location, loadedImage );
  }

  return loadedImage;
}


// 
// draw
//

void draw()
{
  drawDynamicImage(dynamicImage);
  
  
  // white background
  background(255);


  fill(255, 20);
  stroke(255, 0, 255);

  for (ProjectedShape projShape : shapes)
  {
    if ( projShape != currentShape)
    {
      pushMatrix();
      translate(projShape.srcImage.width, 0);

      noStroke();
      shapeRenderer.draw(projShape);
      popMatrix();
    }
  }

 // draw shape we're editing currently
 //
  if (drawImage)
    image( currentShape.srcImage, 0, 0);

    fill(255, 20);
    shapeRenderer.drawSourceShape(currentShape);

    pushMatrix();
    translate(currentShape.srcImage.width, 0);

    noStroke();
    shapeRenderer.draw(currentShape);

    shapeRenderer.drawDestShape(currentShape);
    popMatrix();
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
  else if (key == 't' || key =='T' && currentShape != null)
  {
    currentShape.syncVertsToDest();
  }
  else if (key=='a')
  {
    addNewShape(loadImageIfNecessary("7sac9xt9.bmp"));
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

