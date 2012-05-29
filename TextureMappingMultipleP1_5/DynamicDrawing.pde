
/*
 * This shows how to use a dynamic animation to draw into 
 * a projection-mapped shape.
 *
 */


void setupDynamicImages()
{
  // Right now there is only the Whitney one
  // All we need to do is create it, and it does the rest! 

  DynamicGraphic whitneyDynamicImage = new DynamicWhitney(this, 1024, 1024);
  DynamicGraphic whitneyDynamicImage2 = new DynamicWhitneyTwo(this, 512, 512);
  DynamicGraphic whitneyDynamicImage3 = new PsychedelicWhitney(this, 1024, 1024);
  DynamicGraphic bwDynamicImage = new DynamicBWGraphic(this, 256, 64);
}



//------------------------------------------------------------------
// Base class that represents a dynamic image (that changes every frame).
// Needs to be overridden (see DynamicWhitney)
//------------------------------------------------------------------
// 

abstract public class DynamicGraphic extends GLGraphicsOffScreen
{
  static final String NAME = "default";
  boolean enabled;
  PApplet app;

  DynamicGraphic(PApplet _app, int iwidth, int iheight)
  {    
    super(_app, iwidth, iheight);
//    this.setParent(app);
//    this.setPrimary(false);
    //setAntiAlias(true);
//    this.setSize(iwidth, iheight);
//    this.enabled = true;
      
      this.app = _app;

    initialize();  // set up intial stuff
  
    // this attaches itself automagically to run the preDraw() method when the main
    // Processing app does
    app.registerPre(this);
  }


  // set up initial variables, etc.
  // like setup() but we can't call it that (or else we get a conflict and
  // a very tricky error)
  
  void initialize()
  {
  }


  //
  // do the actual drawing (off-screen, before draw() runs in the
  // parent sketch)
  //
  void pre()
  {
  }
  
// end class DynamicGraphic
}
