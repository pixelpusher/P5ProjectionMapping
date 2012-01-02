/*
 * This shows how to use a dynamic animation to draw into 
 * a projection-mapped shape.
 *
 */


void setupDynamicImages()
{
  // right now there is only the Whitney one

  DynamicGraphic whitneyDynamicImage = new DynamicGraphic(this, 512, 512); 
  whitneyDynamicImage.setupDynamic();
  


  // TODO: how about a registerDynamic( ) method that links a method to a specific PGraphics obj?

  /*
 // like this, but need a HashMap of <Method, PGraphics> to link them together
   java.lang.reflect.Method method;
   try {
   method = obj.getClass().getMethod(methodName, param1.class, param2.class, ..);
   } 
   catch (SecurityException e) {
   // ...
   } 
   catch (NoSuchMethodException e) {
   // ...
   }
   try {
   method.invoke(obj, arg1, arg2, ...);
   } 
   catch (IllegalArgumentException e) {
   } 
   catch (IllegalAccessException e) {
   } 
   catch (InvocationTargetException e) {
   */
}




// TODO: instead of PGraphics, make it a subclass with app.RegisterPreDraw() ? http://wiki.processing.org/w/Register_events
public class DynamicGraphic extends PGraphicsOpenGL
{
  // WhitneyScope - Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "whitney";

  float nbrPoints;
  float cx, cy;
  float crad;
  float cycleLength;
  float startTime;
  int   counter;
  float speed;
  
  DynamicGraphic(PApplet app, int iwidth, int iheight)
  {
    super();
    this.setParent(app);
    this.setPrimary(false);
    //setAntiAlias(true);
    this.setSize(iwidth, iheight);

    // this attaches itself automagically to run the preDraw() method when the main
    // Processing app does

      app.registerPre(this);
    }


    void setupDynamic()
    {
      // add ourself to the glboal lists of dynamic images
      // Do we want to do this in the constructor or is that potentially evil?
      // Maybe we want to register copies with different params under different names...
      // Or potentially check for other entries in the HashMap and save to a different name
      sourceDynamic.put( NAME, this );
      sourceImages.put( NAME, this );
      
      nbrPoints = 140;
      counter = 0;
      cx = this.width/2;
      cy = this.height/2;
      crad = (min(this.width, this.height)/2) * 0.95;
      cycleLength = 320000;
      speed = (TWO_PI*nbrPoints) / cycleLength;
      startTime = millis();

      this.beginDraw();      
      this.smooth();
      this.colorMode(HSB, 1);
      // this.noStroke();
      this.background(0);
      this.endDraw();
    }


    //
    // do the actual drawing (off-screen)
    //
    void pre()
    {
      float my = 20;

      this.beginDraw();
      this.smooth();
      this.colorMode(HSB, 1);
      this.strokeWeight(2);
      
      //startTime = -(cycleLength*20) / (float) this.height;
      float timer = (millis() - startTime) % cycleLength;

      this.background(0);
      //counter = int(timer / cycleLength);

      counter = int(timer);

      this.beginShape();
      this.noFill();
      
      //this.noStroke();
      for (float i = 0; i < nbrPoints; ++i)
      {
        float r = i/(nbrPoints-1f);
        float len = crad*r;
        
        //if ((counter & 1) == 0)
        //  r = 1-r;
          
        float a = timer * speed * r; // pow(i * .001,2);
        // float a = timer*2*PI/(cycleLength/i); same thing
       
        float rad = max(2, len*.05);
        
        //  len *= sin(a*timer);  // big fun!
          
        float x = (cx + cos(a)*len);
        float y = (cy + sin(a)*len);
        float h = map(sin(len*TWO_PI) * sin(PI*timer/cycleLength), -1,1, 0,1);
        //h -= int(h);
        
        //this.fill(h, .9, 1-r/2);
        this.stroke(h, .8, 1-r/2);        
        this.curveVertex(x, y);
        
        //this.ellipse(x, y, rad, rad);
      }
      this.endShape();
      this.endDraw();
    }
  }


