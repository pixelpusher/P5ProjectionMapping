/*
 * Example of using the SurfaceMapper library for Processing
 * to create projection-mapped sketches of images, movies, and dynamic graphics.
 *
 * By PixelPusher / Evan Raskob, 2012 <evan@openlabworkshops.org>
 *   for a Projection-mapping workshop by 
 *   Openlab Workshops <http://openlabworkshops.org> and
 *   Codasign <http://codasign.com> 
 *
 * Licensed under a BSD license. No warrantee provided.
 *
 */

import codeanticode.gsvideo.*;
import ixagon.SurfaceMapper.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;


GLTexture kittenTex, movieTex;

GLGraphicsOffScreen mappedTexture;
SurfaceMapper surfaceMapper;
GSMovie movie;

// dynamic drawings
DynamicGraphic bwDynamicImage;

// possible names for surfaces
final String SurfaceNames[] = { 
  "bars", "movie", "kitten"
}; 


void setup()
{
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);

  // this image will be drawn to the screen in the end
  mappedTexture = new GLGraphicsOffScreen(this, width, height, false);

  // we create the image with whatever dimensions (width,height) we need
  bwDynamicImage = new DynamicBWGraphic(this, 256, 64);

  kittenTex = new GLTexture(this, "kitten.bmp");
  movieTex = new GLTexture(this);

  //Create new instance of SurfaceMapper
  surfaceMapper = new SurfaceMapper(this, width, height);

  //Creates one surface with subdivision 3, at center of screen
  SuperSurface kittenSurface = surfaceMapper.createQuadSurface(3, width/2, height/2);
  kittenSurface.setSurfaceName("kitten");

  //get the 1st surface (the one we just created
  //SuperSurface surface = surfaceMapper.getSurfaces().get(0);

  //Creates one surface with subdivision 3, at (10,10) for our flashing bars
  SuperSurface barsSurface = surfaceMapper.createQuadSurface(3, 50, 50);
  barsSurface.setSurfaceName("bars");

  //Creates one surface with subdivision 3, at center of screen
  SuperSurface movieSurface = surfaceMapper.createQuadSurface(3, 150, 150);
  movieSurface.setSurfaceName("movie");

  movie = new GSMovie(this, "streets.mp4");
  movie.setPixelDest(movieTex);  
  movie.loop();
}

void draw()
{
  // clear background of main sketch
  background(0);

  // clear background and set up 3D depth for mapped image
  mappedTexture.beginDraw();
  mappedTexture.clear(0);
  mappedTexture.hint(ENABLE_DEPTH_TEST);
  mappedTexture.endDraw();

  //get movie frame form our playing movie
  movieTex.putPixelsIntoTexture();

  //render all surfaces in calibration mode
  if (surfaceMapper.getMode() == surfaceMapper.MODE_CALIBRATE) 
    surfaceMapper.render(mappedTexture);

  //render all surfaces in render mode
  if (surfaceMapper.getMode() == surfaceMapper.MODE_RENDER) 
  {

    for (SuperSurface ss : surfaceMapper.getSurfaces()) 
    {   
      if (ss.getSurfaceName().equals("kitten"))   
      {
        ss.render(mappedTexture, kittenTex);
      }
      else if (ss.getSurfaceName().equals("bars") )  
      {
        ss.render(mappedTexture, bwDynamicImage.getTexture());
      }
      else if (ss.getSurfaceName().equals("movie"))   
      {
        ss.render(mappedTexture, movieTex);
      }
    }
  }
  //display the mapped image on the full screen
  image(mappedTexture.getTexture(), 0, 0, width, height);
}


//
// We need this for the movie to play properly
//
void movieEvent(GSMovie movie) 
{
  movie.read();
}

