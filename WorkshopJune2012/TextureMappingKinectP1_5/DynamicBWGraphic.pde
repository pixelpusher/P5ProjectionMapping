//------------------------------------------------------------------
// This draws a black and white grid that chages over time
//------------------------------------------------------------------

import hypermedia.video.*;
import org.openkinect.*;
import org.openkinect.processing.*;


public class DynamicBWGraphic extends DynamicGraphic
{
  // Based in part on WhitneyScope by Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "bwgraphic";

  // Kinect Library object
  Kinect kinect;

  ControlP5 gui;

  OpenCV opencv;

  // Size of kinect image
  int w = 640;
  int h = 480;

  int deg = 15;
  int thresh = 15; // opencv thresh - also lens angle

  float xdist, ydist, zdist, xRotation, yRotation, zRotation;

  // We'll use a lookup table so that we don't have to repeat the math over and over
  float[] depthLookUp = new float[2048];


  //
  // Constructor - runs when this graphic is first created.
  //
  DynamicBWGraphic(PApplet app, int iwidth, int iheight)
  {
    super( app, iwidth, iheight);

    // add ourself to the glboal lists of dynamic images
    // Do we want to do this in the constructor or is that potentially evil?
    // Maybe we want to register copies with different params under different names...
    // Or potentially check for other entries in the HashMap and save to a different name
    sourceDynamic.put( NAME, this );
    sourceImages.put( NAME, this );    


    opencv = new OpenCV(app);
    // make space for depth image!
    opencv.allocate(640, 480);
    /*
    gui = new ControlP5(app);
     
     int guiX=20;
     int guiY=80;
     int guiYPadding = 4;
     int sliderHeight = 16;
     int sliderWidth = 200;
     
     //addSlider(String theName, float theMin, float theMax, float theDefaultValue, int theX, int theY, int theW, int theH) 
     gui.addSlider("thresh", 0, 255, 80, guiX, guiY, sliderWidth, sliderHeight)
     .setColorBackground(color(255, 0, 255, 255));
     guiY += sliderHeight+guiYPadding*2;
     
     gui.addSlider("xdist", -w, w, 0, guiX, guiY, sliderWidth, sliderHeight)
     .setColorBackground(color(255, 255, 0, 255));
     guiY += sliderHeight+guiYPadding;
     
     gui.addSlider("ydist", -h, h, 0, guiX, guiY, sliderWidth, sliderHeight)
     .setColorBackground(color(255, 255, 0, 255));
     guiY += sliderHeight+guiYPadding;
     
     gui.addSlider("zdist", -h, h, h/2, guiX, guiY, sliderWidth, sliderHeight)
     .setColorBackground(color(255, 255, 0, 255));
     guiY += sliderHeight+guiYPadding;
     
     zdist = w/2;
     
     gui.addSlider("xRotation", -PI, PI, 0f, guiX, guiY, sliderWidth, sliderHeight);
     guiY += sliderHeight+guiYPadding;
     
     gui.addSlider("yRotation", -PI, PI, 0f, guiX, guiY, sliderWidth, sliderHeight);
     guiY += sliderHeight+guiYPadding;
     
     gui.addSlider("zRotation", -PI, PI, 0f, guiX, guiY, sliderWidth, sliderHeight);
     guiY += sliderHeight+guiYPadding;
     
     
     //addNumberbox(String theIndex, String theName, float theDefaultValue, int theX, int theY, int theWidth, int theHeight) 
     //  gui.addNumberbox(
     */

    kinect = new Kinect(app);
    kinect.start();
    kinect.tilt(deg);
    kinect.enableDepth(true);
    // We don't need the grayscale image in this example
    // so this makes it more efficient
    //kinect.processDepthImage(true);

    // Lookup table for all possible depth values (0 - 2047)
    for (int i = 0; i < depthLookUp.length; i++) {
      depthLookUp[i] = rawDepthToMeters(i);
    }
  }


  //
  // do the actual drawing (off-screen)
  //
  void drawGraphic()
  {
    background(0);
    fill(255);
    stroke(255);
    strokeWeight(2);

    //textMode(SCREEN);
    //text("Kinect FR: " + (int)kinect.getDepthFPS() + "\nProcessing FR: " + (int)frameRate, 10, height-16);

    // Get the raw depth as array of integers
    int[] depth = kinect.getRawDepth();



    // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
    int skip = 2;

    hint(ENABLE_DEPTH_TEST);
    pushMatrix();
//    float fov = PI/3.0;
    float fov = radians(this.thresh);
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), 
    cameraZ/10.0, cameraZ*10.0);

    scale(this.width/640f);
    // Translate and rotate
    translate(xdist+w/2, ydist+h/2, zdist);
    rotateX(xRotation);
    rotateY(yRotation);
    rotateZ(zRotation);

    beginShape(POINTS);
    for (int x=0; x<w; x+=skip) {
      for (int y=0; y<h; y+=skip) {
        int offset = x+y*w;

        // Convert kinect data to world xyz coordinate
        int rawDepth = depth[offset];

        PVector v = depthToWorld(x, y, rawDepth);
        // Scale up by 200
        float factor = 200;
        //        pushMatrix();
        // add a point
        stroke( map(v.z, 0, 400, 255, 10));
        vertex(v.x*factor, v.y*factor, factor-v.z*factor);
        //ellipse(0,0,2,2);
        //        popMatrix();
      }
    }
    endShape();
    popMatrix();
    hint(DISABLE_DEPTH_TEST);
  }


  void drawOpenCV()
  {
    PImage depthImage = kinect.getDepthImage();

    if (depthImage != null && depthImage.width > 0)
    {
      // copy the RGB image into opencv

      opencv.copy(kinect.getDepthImage(), 
      0, 0, depthImage.width, depthImage.height, 
      0, 0, depthImage.width, depthImage.height);

      opencv.threshold(this.thresh);
      opencv.absDiff();


      image(opencv.image(), 0, 0, width, height);

      Blob blobs[] = opencv.blobs(10, depthImage.width*depthImage.height/2, 10, true, OpenCV.MAX_VERTICES*4 );

      fill(0, 255, 0, 180);
      for (int i = 0; i< blobs.length; i++) {
        ellipse(blobs[i].rectangle.x, blobs[i].rectangle.y, blobs[i].rectangle.width, blobs[i].rectangle.height);
      }
    }
  }



  // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
  float rawDepthToMeters(int depthValue) {
    if (depthValue < 2047) {
      return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
    }
    return 0.0f;
  }

  PVector depthToWorld(int x, int y, int depthValue) {

    final double fx_d = 1.0 / 5.9421434211923247e+02;
    final double fy_d = 1.0 / 5.9104053696870778e+02;
    final double cx_d = 3.3930780975300314e+02;
    final double cy_d = 2.4273913761751615e+02;

    PVector result = new PVector();
    double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
    result.x = (float)((x - cx_d) * depth * fx_d);
    result.y = (float)((y - cy_d) * depth * fy_d);
    result.z = (float)(depth);
    return result;
  }

  void stop() {
    kinect.quit();
    opencv.stop();
  }

  // end class DynamicBWGraphic
}

