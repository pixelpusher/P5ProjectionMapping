/*
 * First go at Projection mapping in Processing
 * Uses a list of projection-mapped shapes.
 * Only really works in Processing 2.0a4 or newer. 
 * by Evan Raskob
 * 
 * keys:
 *
 *  a: add a new shape
 *  x: delete current shape
 *  <: prev shape
 *  >: next shape
 *  d: delete currently selected shape vertex
 *  s: sync vertices to source for current shape
 *  t: sync vertices to destination for current shape
 *  SPACEBAR: clear current shape
 *  i: add 4 vertices around perimeter of shape
 *  I: same as 'i' but scale to mapped view 
 *
 *  m: next display mode ( SHOW_SOURCE, SHOW_MAPPED, SHOW_BOTH)
 *
 *  `: save XML config to file (data/config.xml)
 *  !: read XML config from file (data/config.xml)
 *  ~: change default file name
 *
 *
 * TODO: reordering of shape layers
 */


import processing.video.*;
import processing.opengl.*;
import controlP5.*;


LinkedList<ProjectedShape> shapes = null; // list of points in the image (PVectors)

ProjectedShapeVertex currentVert = null; // reference to the currently selected vert

ProjectedShapeRenderer shapeRenderer = null;

float maxDistToVert = 10;  //max distance between mouse and a vertex for moving

ProjectedShape currentShape = null;

HashMap<String, PImage> sourceImages;  // list of images, keyed by file name
HashMap<ProjectedShape, Movie> sourceMovies;  // list of movies, keyed by associated object that is using them
HashMap<String, DynamicGraphic> sourceDynamic;  // list of dynamic images (subclass of PGraphics), keyed by name

HashMap<PImage, String> imageFiles;
HashMap<Movie, String> movieFiles;

PImage blankImage;  // default image for shapes

final int SHOW_SOURCE = 0;
final int SHOW_MAPPED = 1;
final int EDIT_MAPPED = 2;
final int SHOW_IMAGES = 3;

int fakeTime = 0; // replacement for millis() for rendering
int renderedFrames = 0;

boolean hitSrcShape = false;
boolean hitDestShape = false;
boolean showFPS = false;
boolean deleteShape = false;

boolean rendering = false;

int displayMode = SHOW_MAPPED;  

final float distance = 15;
final float distanceSquared = distance*distance;  // in pixels, for selecting verts

PGraphicsOpenGL editingShapesView, mappedView; // destination output 


boolean drawImage = true;
PFont calibri;

// 
// setup
//

void setup()
{
  // set size and renderer
  size(1024, 768, P3D);
  frameRate(60);

  // set up controlP5 gui
  //initGUI();
  

  blankImage = createImage(32, 32, RGB);
  blankImage.loadPixels();
  for (int x = 0; x < blankImage.width; x++)
    for (int y = 0; y < blankImage.width; y++) {
      blankImage.pixels[y*blankImage.width+x] = ( (x % (blankImage.width/4)) == 0 || (y % (blankImage.width/4)) == 0) ? 
      color(0) : color(255) ;
    }
  blankImage.updatePixels();

  mappedView = (PGraphicsOpenGL)createGraphics(width, height, P3D);
  editingShapesView = (PGraphicsOpenGL)createGraphics(512, 512, P3D);

  {
    // clear mapped view screen
   //GL gl = mappedView.beginGL();
    mappedView.pgl.glClearColor(0f, 0f, 0f, 1f);
    mappedView.pgl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    //mappedView.endGL();
  }

  {
    // clear editingShapesView screen
    //GL gl = editingShapesView.beginGL();
    editingShapesView.pgl.glClearColor(0f, 0f, 0f, 1f);
editingShapesView.pgl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    //editingShapesView.endGL();
  }

  //calibri = loadFont("Calibri-14.vlw");

  String[] fonts = PFont.list();
  PFont font = createFont(fonts[0], 11);
  textFont(font, 16);

  //textFont(calibri,12);

  //shapeRenderer = new ProjectedShapeRenderer((PGraphicsOpenGL)g);

  // use offscreen renderer
  shapeRenderer = new ProjectedShapeRenderer(mappedView);

  shapes = new LinkedList<ProjectedShape>();
  sourceImages = new HashMap<String, PImage>(); 
  sourceMovies = new HashMap<ProjectedShape,Movie>();
  sourceDynamic = new HashMap<String, DynamicGraphic>();

  imageFiles = new HashMap<PImage, String>();
  movieFiles = new HashMap<Movie, String>();

  // load my image
  // PImage sourceImage = loadImageIfNecessary("7sac9xt9.bmp");

  // to do - check for bad image data!
  addNewShape(blankImage);

  // dynamic graphics
  setupDynamicImages();

  hint(DISABLE_DEPTH_TEST);
}


// cleanup

void resetAllData()
{
  // clear all shape refs
  for (ProjectedShape projShape : shapes)
  {
    projShape.clear();
  }
  shapes.clear();
  sourceImages.clear();

  shapes = new LinkedList<ProjectedShape>();

  // TODO: better way to unload these?
  sourceImages = new HashMap<String, PImage>(); 
  sourceMovies = new HashMap<ProjectedShape, Movie>();

  // probably don't want to reset dynamic images because there is no way to recreate them!
  //sourceDynamic = new HashMap<String, PGraphics>();
  // TODO: then re-add them to list of sourceImages

  for (String k : sourceDynamic.keySet())
  {
    PGraphics pg = sourceDynamic.get(k);
    sourceImages.put(k, pg);
  }
}



ProjectedShape addNewShape(PImage sourceImage)
{
  println("ADDING SHAPE " + sourceImage);

  // this will hold out drawing's vertices
  currentShape = new ProjectedShape( sourceImage );
  shapes.add ( currentShape );

  return currentShape;
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
  PImage img = sourceImages.remove( location );

  imageFiles.remove(img);
  movieFiles.remove(img);

  // look through shapes and null out image...
  for (ProjectedShape ps : shapes)
  {
    if (ps.srcImage == img)
    {
      ps.srcImage = blankImage;
    }
  }
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
    loadedImage = loadImage( location );
    sourceImages.put( _location, loadedImage );
    DropdownList dl = (DropdownList)gui.getGroup("AvailableImages");
    dl.addItem(_location, sourceImages.size());
  }

  // map image to file location
  imageFiles.put(loadedImage, location);

  return loadedImage;
}


// 
// draw
//

void draw()
{
  // delete shape here to avoid accessing linked list during middle of draw()
  if (deleteShape)
  {
    deleteShape = false;
    shapes.remove(currentShape);
    currentShape.clear();
    try
    {
      currentShape = shapes.getFirst();
    }
    catch (java.util.NoSuchElementException nse)
    {
      addNewShape(blankImage);
    }
  }

  background(0);

  if (displayMode == SHOW_IMAGES)
  {
    int numImages = sourceImages.size();
    int imgsPerRow = 4;
    int imgW = width/8; // (width/2) / 4)
    int count = 0;
    
   for (PImage srcimg : sourceImages.values())
   {
      image(srcimg, (count % imgsPerRow)*imgW, floor(count/imgsPerRow)*imgW, imgW, imgW); 
      ++count;
   } 
  }
  else
  {


    shapeRenderer.beginRender(mappedView);

    for (ProjectedShape projShape : shapes)
    {
      //if ( projShape != currentShape)
      //{
      //  mappedView.pushMatrix();
      //  mappedView.translate(projShape.srcImage.width, 0);
      shapeRenderer.draw(projShape);
      //  mappedView.popMatrix();
      //}
    }

    if (displayMode == SHOW_SOURCE || displayMode == EDIT_MAPPED)
      shapeRenderer.drawDestShape(currentShape);

    shapeRenderer.endRender();
    // done with drawing mapped shapes


    if (displayMode == SHOW_SOURCE)
    {
      // start drawing source shapes
      shapeRenderer.beginRender(editingShapesView);

      // draw shape we're editing currently
      shapeRenderer.drawSourceShape(currentShape, drawImage);

      shapeRenderer.endRender();

      noTint();
      image(editingShapesView, 0, 0, editingShapesView.height, editingShapesView.width);
      image(mappedView, width/2, 0, mappedView.width/2, mappedView.height/2);
      strokeWeight(3);
      stroke(255);
      line(width/2-1, 0, width/2-1, height);
    }
    else
    {
      image(mappedView, 0, 0);
    }


    if (showFPS)
    {
      fill(255);
      text("fps: " + nfs(frameRate, 3, 2), 4, height-18);
    }
    switch( displayMode )
    {
    case SHOW_MAPPED:
      break;
    case EDIT_MAPPED:
      break;
    case SHOW_SOURCE:
      fill(255);
      strokeWeight(1);
      line(0, height-36, width, height-36);
      text("SOURCE IMAGE", 4, height-38);
      text("MAPPED IMAGE", width/2+5, height-38);
      break;
    }
  }
  // end draw
}



void mousePressed()
{

  hitSrcShape = false;  

  switch( displayMode )
  {
  case SHOW_MAPPED:
  case EDIT_MAPPED:
    {
      int nmx = mouseX;
      int nmy = mouseY;
      int nmpx = pmouseX;
      int nmpy = pmouseY;

      currentVert = currentShape.getClosestVertexToDest(nmx, nmy, distanceSquared);

      if (currentVert ==  null)
      {
        currentVert = currentShape.addClosestDestPointToLine( nmx, nmy, distance);
      }

      if (currentVert ==  null)
      {
        if (isInsideShape(currentShape, nmx, nmy, false))
        {
          hitDestShape = true;
          println("inside dest shape[" + nmx +","+nmy+"]");
        }
        else
          currentVert = currentShape.addVert( nmx, nmy, nmx, nmy );
      }
    }
    break;

  case SHOW_SOURCE:
    {
      int nmx = int(mouseX*float(mappedView.width)/(width*0.5));
      int nmy = int(mouseY*float(mappedView.height)/(height*0.5));
      int nmpx = int(pmouseX*float(mappedView.width)/(width*0.5));
      int nmpy = int(pmouseY*float(mappedView.height)/(height*0.5));

      int boundaryX = width/2;
      //int boundaryX = currentShape.srcImage.width;

      if (mouseX < boundaryX)
      {

        nmx = mouseX*2;
        nmy = mouseY*2;
        nmpx = pmouseX*2;
        nmpy = pmouseY*2;

        // SOURCE
        currentVert = currentShape.getClosestVertexToSource(nmx, nmy, distanceSquared);

        if (currentVert ==  null)
        {
          currentVert = currentShape.addClosestSourcePointToLine( nmx, nmy, distance);
        }

        if (currentVert ==  null)
        {   

          if (isInsideShape(currentShape, nmx, nmy, true))
          {
            hitSrcShape = true;
            println("inside src shape[" + nmx +","+nmy+"]");
          }
          else
            currentVert = currentShape.addVert( nmx, nmy, nmx, nmy );
        }
      }
      else
      {
        //println("mx" + (mouseX-currentShape.srcImage.width));

        //DEST
        nmx = int((mouseX-boundaryX)*mappedView.width/(width*0.5));

        currentVert = currentShape.getClosestVertexToDest(nmx, nmy, distanceSquared);

        if (currentVert ==  null)
        {
          currentVert = currentShape.addClosestDestPointToLine( nmx, nmy, distance);
        }

        if (currentVert ==  null)
        {
          if (isInsideShape(currentShape, nmx, nmy, false))
          {
            hitDestShape = true;
            println("inside dest shape[" + nmx +","+nmy+"]");
          }
          else
          {
            currentVert = currentShape.addVert( nmx, nmy, 
            nmx, nmy );
          }
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

  int nmx = mouseX;
  int nmy = mouseY;
  int nmpx = pmouseX;
  int nmpy = pmouseY;

  if (displayMode == SHOW_SOURCE)
  {
    nmx  = int(mouseX*float(mappedView.width)/(width*0.5));
    nmy  = int(mouseY*float(mappedView.height)/(height*0.5));
    nmpx = int(pmouseX*float(mappedView.width)/(width*0.5));
    nmpy = int(pmouseY*float(mappedView.height)/(height*0.5));
  }

  if (currentVert != null)
  {
    switch( displayMode )
    {
    case SHOW_MAPPED:
    case EDIT_MAPPED:
      {
        currentVert.dest.x = nmx;
        currentVert.dest.y = nmy;
      }
      break;


    case SHOW_SOURCE:
      {

        int boundaryX = width/2;
        //int boundaryX = currentShape.srcImage.width;

        if (mouseX < boundaryX)
        {
          currentVert.src.x = nmx;
          currentVert.src.y = nmy;
        } 
        else 
        {
          nmx = int((mouseX-boundaryX)*mappedView.width/(width*0.5));
          //println("move dest");
          currentVert.dest.x = nmx;
          currentVert.dest.y = nmy;
        }

        break;
      }
    }
  }
  else
    if (hitSrcShape)
    {
      currentShape.move(nmx-nmpx, nmy-nmpy, true);
    }
    else
      if (hitDestShape)
      {
        currentShape.move(nmx-nmpx, nmy-nmpy, false);
      }
}



void movieEvent(Movie movie) 
{
  movie.read();
}


// for rendering... to replace millis() with a standard time per frame
// uncomment when rendering to disk
//int millis()
//{
//  fakeTime += 25; // 33 ms/frame
//  println("ooot" + fakeTime);
//  renderedFrames++;
//  return fakeTime;
//}


