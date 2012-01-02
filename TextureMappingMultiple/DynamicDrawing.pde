/*
 * This shows how to use a dynamic animation to draw into 
 * a projection-mapped shape.
 *
 */

void setupDynamicImages()
{
  // right now there is only the Whitney one

  // TODO: instead of PGraphics, make it a subclass with app.RegisterPreDraw() ? http://wiki.processing.org/w/Register_events
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


    PGraphics whitneyDynamicImage = createGraphics(256, 256, OPENGL); 
    setupWhitneyDynamicImage(whitneyDynamicImage);
    sourceDynamic.put( "whitneydynamic", whitneyDynamicImage );
    sourceImages.put( "whitneydynamic", whitneyDynamicImage );
  }



  // WhitneyScope - Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"


  int   nbrPoints = 400;
  int   cx, cy;
  float crad;
  float cycleLength;
  float startTime;
  int   counter =0 ;
  float   speed = 1;
  boolean classicStyle = false;

  void setupWhitneyDynamicImage(PGraphics renderer)
  {
    renderer.beginDraw();
    cx = renderer.width/2;
    cy = renderer.height/2;
    crad = (min(renderer.width, renderer.height)/2) * 0.95;
    renderer.noStroke();
    renderer.smooth();
    renderer.colorMode(HSB, 1);

    renderer.background(0);

    if (classicStyle)
      cycleLength = 15*60;
    else
      cycleLength = 2000*15*60;
    speed = (2*PI*nbrPoints) / cycleLength;
    startTime = -random(cycleLength);
    // speed = 10;
    renderer.endDraw();
  }

  void drawWhitneyDynamicImage(PGraphics renderer)
  {

    float my = 20;

    renderer.beginDraw();
    renderer.smooth();
    renderer.colorMode(HSB, 1);
    startTime = -(cycleLength*20) / (float) renderer.height;
    float timer = (millis()*.001 - startTime)*speed;

    renderer.background(0);
    counter = int(timer / cycleLength);

    for (int i = 0; i < nbrPoints; ++i)
    {

      float r = i/(float)nbrPoints;
      if ((counter & 1) == 0)
        r = 1-r;

      float a = timer * r; // pow(i * .001,2);
      // float a = timer*2*PI/(cycleLength/i); same thing
      float len = i*crad/(float)nbrPoints;
      float rad = max(2, len*.05);
      if (!classicStyle)
        len *= sin(a*timer);  // big fun!
      int x = (int) (cx + cos(a)*len);
      int y = (int) (cy + sin(a)*len);
      float h = r + timer * .01;
      h -= int(h);
      renderer.fill(h, .5, 1-r/2);
      renderer.ellipse(x, y, rad, rad);
    }
    renderer.endDraw();
  }

