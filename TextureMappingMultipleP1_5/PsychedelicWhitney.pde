

//------------------------------------------------------------------
// This draws a "Whitney" image
//------------------------------------------------------------------

public class PsychedelicWhitney extends DynamicGraphic
{

  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "psychowhitney";

  float speed = 0.01; // how fast it gains harmonics
  float periods = 0; // how many humps the sine wave has
  float waveHeight;  // the height of the wave
  int hueOffset = 56;
  int startTime = 0;
  float speedRatio = 1.1;
  int cycleLength = 60000;
  int numPoints = 160;


  PsychedelicWhitney(PApplet app, int iwidth, int iheight)
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
    waveHeight = this.height/3;
    startTime = millis();

    speed = 0.01; // how fast it gains harmonics
    periods = 1; // how many humps the sine wave has

    hueOffset = 56;

    speedRatio = 1.1;
    cycleLength = 60000;
    numPoints = 160;
  }


  //
  // do the actual drawing (off-screen)
  //
  void pre()
  {
    float s = sin(frameCount*speed);

    //float positiveSin = (1.0 + s) * 0.5; // from 0 - 1
    //  float varSpeed =  s*s * speed*speed + speed*speed;

    float varSpeed =  s * speed/speedRatio + speed;

    periods += varSpeed;

    this.beginDraw();

    GL gl = this.beginGL();
    gl.glClearColor(0f, 0f, 0f, 0f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    this.endGL();


    //this.smooth();
    // this.colorMode(HSB, 1);


    //startTime = -(cycleLength*20) / (float) this.height;
    float timer = (millis() - startTime) % cycleLength;


    this.gl.glDisable( GL.GL_DEPTH_TEST );
    this.gl.glEnable( GL.GL_BLEND );
    this.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);

    this.fill(255);
    this.noStroke();

    for (int index = 0; index < numPoints; index++)
    {
      float majorAngle = map(index, 0, numPoints, 0, TWO_PI);

      float angle = map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI);

      float heightValue = waveHeight+waveHeight * 
        sin(majorAngle);

      float widthValue = waveHeight+waveHeight * 
        cos(majorAngle);

      float x = widthValue + (sin(angle)+1)*0.5*waveHeight;
      float y = heightValue + (cos(angle)+1)*0.5*60;

      this.ellipse( x, y, 5, 5);
    }

    this.endDraw();
  }

  // end class PsychoWhitney
}

