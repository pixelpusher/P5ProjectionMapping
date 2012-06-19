/*
 * First go at Projection mapping in Processing
 * Uses a list of projection-mapped shapes.
 * Uses Processing 1.5 and GLGraphics.
 * Defaults to loading data/config.xml and some dynamic drawings  
 *
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
 *  l: duplicate the selected shape
 *  SPACEBAR: clear current shape
 *  i: add 4 vertices around perimeter of shape
 *  I: same as 'i' but scale to mapped view 
 *  [: hide mouse
 *  ]: show mouse
 *  .: toggle FPS display on/off
 *  /: pause rendering
 *  m: next display mode ( SHOW_SOURCE, SHOW_MAPPED, SHOW_BOTH)
 *
 *  `: save XML config to file (data/config.xml)
 *  !: read XML config from file (data/config.xml)
 *  ~: save new XML config file (using file chooser)
 *  @: load config file (using file chooser)
 *
 *
 * TODO: 
 * 1. reordering of shape layers
 * 2. undo - could just duplicate LinkedList<ProjectedShape> shapes, it's a pretty lightweight way to save/restore states 
 
 */


import processing.video.*;
import controlP5.*;
import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;


LinkedList<ProjectedShape> shapes = null; // Here are all the ProjectedShapes that comtain the geometry for mapping images onto them

ProjectedShapeVertex currentVert = null; // reference to the currently selected vert

ProjectedShapeRenderer shapeRenderer = null; // this renders (draws) the shapes to the screen 

float maxDistToVert = 10;  //max distance between mouse and a vertex for moving

ProjectedShape currentShape = null;

HashMap<String, PImage> sourceImages;  // list of all available images for mapping, keyed by file name
HashMap<ProjectedShape, Movie> sourceMovies;  // list of movies, keyed by associated ProjectedShape object that is using them
HashMap<String, DynamicGraphic> sourceDynamic;  // list of dynamic images (subclass of PGraphics), keyed by name

HashMap<PImage, String> imageFiles;
HashMap<Movie, String> movieFiles;

PImage blankImage;  // default checkered image for shapes

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

int displayMode = SHOW_SOURCE;  

final float distance = 15;
final float distanceSquared = distance*distance;  // in pixels, for selecting verts

GLGraphicsOffScreen editingShapesView, mappedView; // destination output 


boolean drawImage = true;
PFont calibri;


ArrayList<DrawableNode> loadedImagesNodes;


// overriding PApplet.init() to remove title bar, etc
// uncomment it out for 2nd monitor viewing (recommended)

void init() {
 
 // trick to make it possible to change the frame properties
 frame.removeNotify(); 
 
 // comment this out to turn OS chrome back on
 frame.setUndecorated(true); 
 
 // comment this out to not have the window "float"
 frame.setAlwaysOnTop(true); 
 
 //  frame.setResizable(true);  
 frame.addNotify(); 
 
 // making sure to call PApplet.init() so that things 
 // get  properly set up.
 super.init();
 }


// 
// setup
//

void setup()
{
  // set size and renderer
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
  frameRate(60);
  noCursor();

  // uncomment this for 2nd monitor viewing
   frame.setLocation(0,32);


  // this sets up a post-rendering glow effect. See the GLGLowStuff.pde tab and draw() for more details.
  // setupGLGlow();

  // set up controlP5 gui
  initGUI();

  {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
    GL gl = pgl.beginGL();  // always use the GL object returned by beginGL
    gl.glClearColor(0.0, 0.0, 0.0, 1); 
    gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
    pgl.endGL();
  }


  mappedView = new GLGraphicsOffScreen(this, width, height, true, 4);  

  editingShapesView = new GLGraphicsOffScreen(this, width/2, height/2);  

  {
    // clear mapped view screen
    GL gl = mappedView.beginGL();
    gl.glClearColor(0f, 0f, 0f, 1f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    mappedView.endGL();
  }

  {
    // clear editingShapesView screen
    GL gl = editingShapesView.beginGL();
    gl.glClearColor(0f, 0f, 0f, 1f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    editingShapesView.endGL();
  }

  //calibri = loadFont("Calibri-14.vlw");

  String[] fonts = PFont.list();
  PFont font = createFont(fonts[0], 11);
  textFont(font, 16);

  //textFont(calibri,12);

  // use offscreen renderer
  shapeRenderer = new ProjectedShapeRenderer(mappedView);

  shapes = new LinkedList<ProjectedShape>();
  sourceImages = new HashMap<String, PImage>(); 
  //sourceMovies = new HashMap<ProjectedShape,Movie>();
  sourceDynamic = new HashMap<String, DynamicGraphic>();

  imageFiles = new HashMap<PImage, String>();
  movieFiles = new HashMap<Movie, String>();


  blankImage = createImage(32, 32, RGB);
  blankImage.loadPixels();
  for (int x = 0; x < blankImage.width; x++)
    for (int y = 0; y < blankImage.width; y++) {
      blankImage.pixels[y*blankImage.width+x] = ( (x % (blankImage.width/4)) == 0 || (y % (blankImage.width/4)) == 0) ? 
      color(0) : color(255) ;
    }
  blankImage.updatePixels();

  sourceImages.put("blank", blankImage);

  // load my image as a test
  // PImage sourceImage = loadImageIfNecessary("7sac9xt9.bmp");

  // to do - check for bad image data!
  addNewShape(blankImage);
  currentShape.srcColor = color(255, 255);
  currentShape.dstColor = color(255, 255);

  // dynamic graphics
  setupDynamicImages();

  loadedImagesNodes = new ArrayList<DrawableNode>();

  hint(DISABLE_DEPTH_TEST);


  // finally, read in XML config automagically - this is good for standalone apps  
  // readConfigXML();
}


// cleanup

void resetAllData()
{
  currentShape = null;
  // clear all shape refs
  for (ProjectedShape projShape : shapes)
  {
    projShape.clear();
  }
  shapes.clear();
  sourceImages.clear();

  //shapes = new LinkedList<ProjectedShape>();

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

  // add a default shape...
  //addNewShape(blankImage);
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

    /// add new image button

    int numImages = sourceImages.size();
    int imgsPerRow = 4;
    int imgW = width/8; // (width/2) / 4)
    int imgIndex = loadedImagesNodes.size();

    float imgx =  (imgIndex % imgsPerRow)*imgW;
    float imgy =  (imgIndex/imgsPerRow)*imgW; 

    loadedImagesNodes.add( new ImageNode(loadedImage, imgx, imgy, imgW, imgW ) );
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
  // for rendering
  //  incTime();

  //
  // DEBUG
  //

  //PsychedelicWhitney psw = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME ));
  //psw.strategy1();


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
    for (DrawableNode node : loadedImagesNodes)
    {
      node.draw();
    }

    /*
    int numImages = sourceImages.size();
     int imgsPerRow = 4;
     int imgW = width/8; // (width/2) / 4)
     int count = 0;
     
     for (PImage srcimg : sourceImages.values())
     {
     if (srcimg instanceof GLGraphicsOffScreen)
     srcimg = ((GLGraphicsOffScreen)srcimg).getTexture();
     
     image(srcimg, (count % imgsPerRow)*imgW, floor(count/imgsPerRow)*imgW, imgW, imgW); 
     ++count;
     }
     */
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

    if (displayMode == SHOW_SOURCE || displayMode == EDIT_MAPPED && currentShape != null)
      shapeRenderer.drawDestShape(currentShape);

    shapeRenderer.endRender();
    // done with drawing mapped shapes


    if (displayMode == SHOW_SOURCE && currentShape != null)
    {
      // start drawing source shapes
      shapeRenderer.beginRender(editingShapesView);

      // draw shape we're editing currently
      shapeRenderer.drawSourceShape(currentShape, drawImage);

      shapeRenderer.endRender();


      //
      // post-render effects could go here.
      //

      //doGLGlow(mappedView);

      //     PImage mappedImage = (PImage)destTex;

      // otherwise...

      PImage mappedImage = mappedView.getTexture();

      noTint();
      image(editingShapesView.getTexture(), 0, 0);
      image(mappedImage, width/2, 0, width/2, height/2);
      strokeWeight(3);
      stroke(255);
      line(width/2-1, 0, width/2-1, height);
    }

    // now draw for reals
    else
    {

      //
      // post-render effects could go here.
      //
      // doGLGlow(mappedView);
      // PImage mappedImage = (PImage)destTex;

      // otherwise...


      PImage mappedImage = mappedView.getTexture();

      image(mappedImage, 0, 0, width, height);
    }

    noStroke();

    // BLEND MODE LEAKS!
    // That's why this is necessary
    shapeRenderer.screenBlend(BLEND, (PGraphicsOpenGL)(this.g));
    if (showFPS)
    {
      //      fill(255);
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

  if (rendering)
    saveFrame("frames/frame-"+ nf(renderedFrames, 6)+ ".png");
}



void mousePressed()
{

  println("MOUSE PRESSED");

  // first check if we're in the GUI
  if (!gui.window(this).isMouseOver())
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

        int boundaryX = editingShapesView.width;

        if (mouseX < boundaryX)
        {
          int nmx = (int)map(mouseX, 0, editingShapesView.width, 0, mappedView.width);        
          int nmy = int( mappedView.height * mouseY/float(editingShapesView.height) );

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
          int nmx = int((mouseX-boundaryX)*mappedView.width/(width-editingShapesView.width));
          int nmy  = int(mouseY*float(mappedView.height)/(editingShapesView.height));
          int nmpx =int((pmouseX-boundaryX)*mappedView.width/(width-editingShapesView.width));
          int nmpy = int(pmouseY*float(mappedView.height)/(editingShapesView.height));

          //println("mx" + (mouseX-currentShape.srcImage.width));

          //DEST

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

    case SHOW_IMAGES:

      for (DrawableNode node : loadedImagesNodes)
      {
        if (node.pointInside(mouseX, mouseY))
        {
          currentShape.srcImage = ((ImageNode)node).img;
        }
        displayMode = SHOW_SOURCE;
      }


      break;
      // end mode switch
    }

    // end if mouse is not over GUI
  }
  //end mouse pressed
}



void mouseReleased()
{
  // Now we know no vertex is pressed, so stop tracking the current one
  currentVert = null;

  hitSrcShape = hitDestShape = false;
}


void mouseDragged()
{
  if (!gui.window(this).isMouseOver())
  {
    // if we have a closest vertex, update it's position

    int nmx = mouseX;
    int nmy = mouseY;
    int nmpx = pmouseX;
    int nmpy = pmouseY;

    if (displayMode == SHOW_SOURCE)
    {
      nmx = (int)map(mouseX, 0, editingShapesView.width, 0, mappedView.width);        
      nmy = int( mappedView.height * mouseY/float(editingShapesView.height) );
      nmpx = (int)map(pmouseX, 0, editingShapesView.width, 0, mappedView.width);        
      nmpy = int( mappedView.height * pmouseY/float(editingShapesView.height) );
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
}




void movieEvent(Movie movie) {
  movie.read();
}

/*
// for rendering... to replace millis() with a standard time per frame
 // uncomment when rendering to disk
 int millis()
 {
 return fakeTime;
 }
 
 void incTime()
 {
 fakeTime += 25; // 33 ms/frame
 //  println("ooot" + fakeTime);
 if (rendering)
 renderedFrames++;
 }
 */
