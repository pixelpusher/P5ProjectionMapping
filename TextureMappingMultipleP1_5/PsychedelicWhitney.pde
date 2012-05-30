
import java.nio.FloatBuffer;

//------------------------------------------------------------------
// This draws a "Whitney" image
//------------------------------------------------------------------

public class PsychedelicWhitney extends DynamicGraphic
{
  private GLModel glmodel;
  private GLTexture tex;

  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "psychowhitney";
  final int MAX_POINTS = 160*4;

  float speed; // how fast it gains harmonics
  float periods; // how many humps the sine wave has
  float waveHeight;  // the height of the wave
  int hueOffset;
  int startTime;
  int currentTime;
  int lastIntervalTime;
  int[] intervalTime;
  int currentInterval;

  float speedRatio;
  int cycleLength;
  int numPoints;
  int blobSize;
  float fadeAmount;

  PVector pts[];

  PsychedelicWhitney(PApplet app, int iwidth, int iheight)
  {
    super( app, iwidth, iheight);

    // add ourself to the glboal lists of dynamic images
    // Do we want to do this in the constructor or is that potentially evil?
    // Maybe we want to register copies with different params under different names...
    // Or potentially check for other entries in the HashMap and save to a different name
    sourceDynamic.put( NAME, this );
    sourceImages.put( NAME, this );

    initialize();
  }


  void initialize()
  {     
    waveHeight = this.height/6;
    startTime = currentTime = millis();

    intervalTime = new int[6];
    intervalTime[0] = 1000 * 20; // 30 sec
    intervalTime[1] = 1000 * 30; // 30 sec
    intervalTime[2] = 1000 * 60; // 30 sec
    intervalTime[3] = 1000 * 30; // 30 sec
    intervalTime[4] = 1000 * 60; // 30 sec
    intervalTime[5] = 1000 * 30; // 30 sec

    fadeAmount = 0;

    currentInterval = 0;
    lastIntervalTime = 0;


    speed = 0.01; // how fast it gains harmonics
    periods = 2; // how many humps the sine wave has

    hueOffset = 56;

    speedRatio = 1.1;
    cycleLength = 60000;
    numPoints = 160*2;
    blobSize = 20;

    fadeAmount = 0.5;

    // initialize points array
    pts = new PVector[MAX_POINTS];

    for (int i=0; i<pts.length; i++)
      pts[i] = new PVector();

    tex = new GLTexture(this.app, "kittpart.png");

    initModel();

    println(this.NAME + "initialized");
  }


  //
  // do the actual drawing (off-screen)
  //
  void drawGraphic()
  {

    this.glmodel.beginUpdateVertices();

    for (int index=0; index < numPoints; index++ ) 
    {
      PVector v = pts[index];
      this.glmodel.updateVertex(index, v.x, v.y, v.z);
    }
    this.glmodel.endUpdateVertices();
    
    
    currentTime = (millis() - lastIntervalTime);
    
    

    if (currentTime > intervalTime[currentInterval]) 
    {
      currentInterval  = (currentInterval + 1) % intervalTime.length;
      lastIntervalTime = millis();
      fadeAmount = 1f;
    }
    else
    // if odd it's an interval time
    if (currentInterval % 2 == 0)
    {
      fadeAmount = 1-currentTime / float( intervalTime[currentInterval]);
      //println("currentTime=" + currentTime + " / " + fadeAmount);
    }
    else
      fadeAmount = 0f;

    float s = sin(frameCount*speed);

    //float positiveSin = (1.0 + s) * 0.5; // from 0 - 1
    //  float varSpeed =  s*s * speed*speed + speed*speed;

    float varSpeed =  s * speed/speedRatio + speed;

    periods += varSpeed;



    //    this.fill(255);
    //    this.noStroke();
    //    this.stroke(255);


    GL gll = this.beginGL();

    gll.glClearColor(0f, 0f, 0f, 0f);
    gll.glClear(GL.GL_COLOR_BUFFER_BIT);
    gll.glDisable( GL.GL_DEPTH_TEST );
    gll.glEnable( GL.GL_BLEND );
    gll.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);


    if (currentInterval < 2 )
    {
    strategy1();
    //strategy4X();
    }
    else if (currentInterval < 4)
    strategy2();

    else if (currentInterval < 6)
    strategy3();

    //for (PVector p : pts)
    //this.ellipse(p.x, p.y, blobSize, blobSize);
    this.setDepthMask(false); 

    this.model(this.glmodel, 0, numPoints-1); 

    // strategy2();

    this.setDepthMask(true);

    //this.glmodel.render(0,numPoints);  

    this.endGL();

    // strategy2();
  }



  void strategy1()
  {
    //    if (this.glmodel != null)
    //    {
    //      this.glmodel.beginUpdateVertices();

    int loops = 2;
    int loopPoints = numPoints/loops;

  for (int l=0; l<loops; l++)
  {
    for (int index = 0; index < loopPoints; index++)
    {
      float majorAngle = map(index, 0, loopPoints, 0, TWO_PI);

      float angle = map(index, 0, loopPoints, -periods*TWO_PI, periods*TWO_PI);

      float heightValue = 2*waveHeight*(1 + 
        sin(majorAngle));

      float widthValue = 2*waveHeight*(1 + 
        cos(majorAngle));

      float x = width/4 + waveHeight + waveHeight*(cos(l*PI)) + widthValue + (sin(angle)+1)*0.5*waveHeight;
      float y = waveHeight + waveHeight*(sin(l*PI)) + heightValue + (cos(angle)+1)*0.5*60;

      if ((l % 2) == 0) x = width-x;

      PVector v = pts[index+l*loopPoints];

      x = lerp( x, v.x, fadeAmount);
      y = lerp( y, v.y, fadeAmount);

      v.set( x, y, 0);

      //        this.glmodel.updateVertex(index, v.x, v.y, v.z);
    }
  }
    //      this.glmodel.endUpdateVertices();
    //    }
    //    else
    //      println("FAIL!");
  }


  void strategy2()
  {
    this.glmodel.setSpriteSize(abs(sin(frameCount*0.01))*40+5, 200);

    //    if (this.glmodel != null)
    //    {
    //      this.glmodel.beginUpdateVertices();

    for (int index = 0; index < numPoints; index++)
    {
      float majorAngle = map(index, 0, numPoints, 0, TWO_PI);

      float angle = map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI);

      float heightValue = waveHeight+waveHeight * 
        sin(majorAngle);

      float widthValue = waveHeight+waveHeight * 
        cos(majorAngle);

      float x = width/6 + widthValue + (sin(angle)+1)*0.5*waveHeight;
      float y = height/6 + heightValue + (cos(angle)+1)*0.5*waveHeight;

      PVector v = pts[index];

      x = lerp( x, v.x, fadeAmount);
      y = lerp( y, v.y, fadeAmount);

      v.set( x, y, 0);

      //        this.glmodel.updateVertex(index, v.x, v.y, v.z);
    }

    //      this.glmodel.endUpdateVertices();
    //    }
    //    else
    //      println("FAIL!");
  }


  void strategy4X()
  {
    
    // draw another few rotated 90 degrees or so
    if (true)
    {
      pushMatrix();
      translate(width/2, height/2);
      rotate(HALF_PI);

      //translate(waveHeight/2, waveHeight/2);
      this.model(this.glmodel, 0, numPoints-1); 

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);

      rotate(HALF_PI);
      this.model(this.glmodel, 0, numPoints-1);
      popMatrix();
    }
  }


  void strategy3()
  {
    waveHeight = this.height/2;
    this.glmodel.setSpriteSize(abs(sin(frameCount*0.01))*40+5, 200);
    this.glmodel.setBlendMode(ADD);
    periods = 3;

    //    if (this.glmodel != null)
    //    {
    //      this.glmodel.beginUpdateVertices();

    for (int index = 0; index < numPoints; index+=4)
    {
      PVector v = pts[index];

      // this is the moving index, from left to right. 
      int movedIndex = int(index + frameCount);
      movedIndex = movedIndex % numPoints; // wrap around width

      // draw sin wave 1 (point by point)

      // this is the damped height (fades out from left to right
      float dampedHeight = map(index, 0, numPoints, 1, 0) * waveHeight;

      // the y value (height) of the sine wave for this hrizontal screen position
      float heightValue = dampedHeight * 
        sin( map(movedIndex, 0, numPoints, 0, periods*2*TWO_PI) ) 
        + dampedHeight;

      heightValue *= abs(sin(frameCount*0.002)) * abs(sin(frameCount*0.002)) ;

      float nx = map(movedIndex, 0, numPoints, 0, this.width);

      float x = lerp( this.width-nx, v.x, fadeAmount);
      float y = lerp( heightValue, v.y, fadeAmount);

      v.set( x, y, 0);
      //        this.glmodel.updateVertex(index, v.x, v.y, 0);

      v = pts[index+1];

      // invert the height (so it grows from the bottom up instead of top down)
      heightValue = this.height-heightValue;

      x = lerp(nx, v.x, fadeAmount);
      y = lerp(heightValue, v.y, fadeAmount);

      v.set( x, y, 0);

      //        this.glmodel.updateVertex(index+1, v.x, v.y, 0);
      v = pts[index+2];

      //        this.glmodel.updateVertex(index+1, nx, heightValue, 0);


      // draw sine wave 2 (point-by-point)

      float timeVal = millis()*0.00006;

      float period1 = periods*4*sin(timeVal*2)*TWO_PI;
      float period2 = periods*sin(timeVal)*TWO_PI;

      float sinVal1 = sin( map(index, 0, numPoints, -period1, period1) );
      float sinVal2 = sin( map(index, 0, numPoints, -period2, period2) );

      float angle = map(index, 0, numPoints, -PI, PI);

      //
      // Add the two sin waves together, but mix them in different amounts.
      // We try to keep the sum of the coefficients (0.8 and 0.2, respectively)
      // equal to 1.0 (e.g., 0.2 + 0.8 = 1.0) because otherwise the height of the 
      // additive sin wave will be too large (greater than 1.0)
      // 
      heightValue = abs(sin(frameCount*0.002)) * dampedHeight * ( 0.6*sinVal1 + 0.4*sinVal2 + 1);

      x = heightValue*cos(angle) + this.width/2;
      //y = heightValue*sin(angle)*0.25 + this.height/2;
      y= heightValue;

      x = lerp( x, v.x, fadeAmount);
      y = lerp( y, v.y, fadeAmount);

      v.set( x, y, 0);         
      //this.glmodel.updateVertex(index+2, x, heightValue);


      v = pts[index+3];

      // invert the height (so it grows from the bottom up instead of top down)
      heightValue = this.height-heightValue;

      // this.glmodel.updateVertex(index+3, this.width-x, heightValue);


      //        point(width-x, heightValue);
      y = heightValue;
      x = width - x;
      x = lerp( x, v.x, fadeAmount);
      y = lerp( y, v.y, fadeAmount);

      v.set( x, y, 0);
    }

    //this.glmodel.endUpdateVertices();
    // this.glmodel.endUpdateColors();
    //}

    //this.model(this.glmodel, 0, numPoints-1);
  }


  void setTexture(GLTexture _tex)
  {
    tex = _tex;
    if (this.glmodel != null) this.glmodel.setTexture(0, tex);
  }




  void updateModelColors(float r, float g, float b, float a)
  {     
    this.glmodel.beginUpdateColors();

    FloatBuffer cbuf = this.glmodel.colors;

    float col[] = { 
      0.9, 0.0, 0.0, 0.8
    };

    for (int n = 0; n < this.glmodel.getSize(); ++n) {

      // get colors (debugging purposes)
      //cbuf.position(4 * n);
      //cbuf.get(col, 0, 4);  
      //println("Color["+n+"]="+ col[0] +","+col[1] +","+col[2] +","+col[3]);
      // process col... make opaque white for testing
      //col[0] = col[1] = col[2] = col[3] = 1.0f;


      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }

    cbuf.rewind();
    this.glmodel.endUpdateColors();
  }  




  // 
  // Create the model initially
  //

  void initModel()
  {
    // make a geometry model with max size (we will only draw part of it as needed
    this.glmodel = new GLModel(this.app, MAX_POINTS, this.glmodel.POINT_SPRITES, GLModel.STREAM);

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
      int i = (n % 4);

      if (i < 2) 
      {
        col[0] = 1;
        col[1] = 0;
        col[2] = 1;
      }
      else
      {
        col[0] = 1;
        col[1] = 1;
        col[2] = 0;
      }

      cbuf.position(4 * n);
      cbuf.put(col, 0, 4);
    }

    cbuf.rewind();
    this.glmodel.endUpdateColors();

    //float pmax = this.glmodel.getMaxSpriteSize();
    //println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   

    this.glmodel.initTextures(1);
    this.glmodel.setTexture(0, tex);  

    // Setting the maximum sprite to the 90% of the maximum point size.
    //    model.setMaxSpriteSize(0.9 * pmax);
    // Setting the distance attenuation function so that the sprite size
    // is 20 when the distance to the camera is 400.

    this.glmodel.setSpriteSize(20, 400);
    this.glmodel.setBlendMode(BLEND);
  }

  // end class PsychoWhitney
}

