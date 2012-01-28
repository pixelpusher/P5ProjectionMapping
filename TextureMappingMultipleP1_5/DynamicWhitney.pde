//------------------------------------------------------------------
// This draws a "Whitney" image
//------------------------------------------------------------------

public class DynamicWhitney extends DynamicGraphic
{
  // Based in part on WhitneyScope by Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "whitney";

  float numPoints;
  float cx, cy;
  float crad;
  float cycleLength;
  float startTime;
  int   counter;
  int numPetals;
  float speed;
  boolean usePoints;

  PVector pts[];


  private GLModel glmodel;
  final int MAX_POINTS = 160*4;


  DynamicWhitney(PApplet app, int iwidth, int iheight)
  {
    super( app, iwidth, iheight);

    // add ourself to the glboal lists of dynamic images
    // Do we want to do this in the constructor or is that potentially evil?
    // Maybe we want to register copies with different params under different names...
    // Or potentially check for other entries in the HashMap and save to a different name
    sourceDynamic.put( NAME, this );
    sourceImages.put( NAME, this );
  }

  void initialize()
  {     
    numPetals = 2;
    usePoints = false;
    numPoints = 3*160;
    counter = 0;
    cx = this.width/2;
    cy = this.height/2;
    crad = (min(this.width, this.height)/2) * 0.95;
    cycleLength = 3200000;
    speed = (TWO_PI*numPoints) / cycleLength;
    startTime = millis();

    // initialize points array
    pts = new PVector[MAX_POINTS];

    for (int i=0; i<pts.length; i++)
      pts[i] = new PVector();

    initModel();


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

    GL gl = this.beginGL();
    gl.glClearColor(0f, 0f, 0f, 0f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

    //startTime = -(cycleLength*20) / (float) this.height;
    float timer = (millis() - startTime) % cycleLength;

    //this.background(0);

    //counter = int(timer / cycleLength);

    counter = int(timer);

    if (usePoints)
    {

      //    this.noFill();
      this.noStroke();
    }
    else
    {
      this.beginShape();
      this.noFill();
    }

    if (this.glmodel != null)
    {
      this.glmodel.beginUpdateVertices();


      for (int i = 0; i < numPoints; ++i)
      {
        float r = i/(numPoints-1f);
        float len = crad*r;

        //if ((counter & 1) == 0)
        //  r = 1-r;

        float a = timer * speed * r; // pow(i * .001,2);
        float rad = max(2, len*.05);

        if (false)
        {
          float tmps = sin(numPetals*a);
          float tmpc = cos(numPetals*a);

          len *= 2*tmps*tmpc;
        }

        if (true)
        {
          float tmps = sin(numPetals*(a+TWO_PI*timer/cycleLength));
          //float tmpc = cos(numPetals*a+timer);

          len *= tmps*tmps;
          
          len = len * constrain(0.5+sin(timer*0.0001),0.1,1);
          
        }

        float x = (cx + cos(a)*len);
        float y = (cy + sin(a)*len);
        //float h = map(sin(len*TWO_PI) * sin(PI*timer/cycleLength), -1, 1, 0, 1);
        //h -= int(h);

        //      if (usePoints)
        //      {
        //        this.fill(h, .9, 1-r/2);
        //        this.ellipse(x, y, rad, rad);
        //      }
        //      else
        //      {
        //        this.stroke(h, .8, 1-r/2, 0.7);
        //        this.curveVertex(x, y);
        //     }

        PVector v = pts[i];

        //        x = lerp(v.x, x, fadeAmount);
        //        y = lerp(v.y, y, fadeAmount);

        v.set( x, y, 0);

        this.glmodel.updateVertex(i, v.x, v.y, v.z);

        // end for()
      }

      this.glmodel.endUpdateVertices();
    }



    //      if (!usePoints)
    //      {
    //        this.endShape();
    //      }

    this.stroke(255);
    this.model(this.glmodel, 0, int(numPoints-1) );
    this.endGL();
    this.endDraw();
  }



  // 
  // Create the model initially
  //

  void initModel()
  {
    // make a geometry model with max size (we will only draw part of it as needed
    this.glmodel = new GLModel(this.app, MAX_POINTS, GLModel.LINES, GLModel.STREAM);

    println("MODEL CREATED? " + (this.glmodel != null));

    this.glmodel.beginUpdateVertices();
    int index = 0;

    for (PVector v : pts) 
    {
      this.glmodel.updateVertex(index, v.x, v.y, v.z);
      ++index;
    }
    this.glmodel.endUpdateVertices(); 

    //
    // Handle colors
    //

    this.glmodel.initColors();
    this.glmodel.beginUpdateColors();

    FloatBuffer cbuf = this.glmodel.colors;

    float col[] = { 
      1, 1, 1, 0.75
    };

    for (int n = 0; n < this.glmodel.getSize(); ++n) 
    {
      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }

    cbuf.rewind();
    this.glmodel.setLineWidth(2);
    this.glmodel.endUpdateColors();

    this.glmodel.setBlendMode(ADD);
  }

  // end class DynamicWhitney
}

