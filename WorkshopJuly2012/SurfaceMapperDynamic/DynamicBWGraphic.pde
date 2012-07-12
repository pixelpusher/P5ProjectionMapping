//------------------------------------------------------------------
// This draws a black and white grid that chages over time
//------------------------------------------------------------------

public class DynamicBWGraphic extends DynamicGraphic
{

  // the name of this class
  static final String NAME = "bwgraphic";

  //--------------------------------------
  // these variables are like the ones that go on top of the main sketch....
  
  // the blinking rate of each bar
  float[] rates = { 0.5f, 1f, 2f, 3.5f, 4f };

  // the width of a single bar
  float barWidth;

  //
  // Constructor - runs when this graphic is first created. Like setup() in the main sketch
  //
  DynamicBWGraphic(PApplet app, int iwidth, int iheight)
  {
    // need this to make sure it does things automagically
    super( app, iwidth, iheight);

    //---------------SETUP STUFF GOES HERE----------------------------

    // width of a single rectangle
    barWidth = width / rates.length; 
  }


  //
  // do the actual drawing inside this texture (off-screen), just like in draw()
  //
  void drawGraphic()
  {
    noStroke();
    background(0);
    
    // get the current time and animate each bar based on it
    float currentTime = millis() * 0.005;
    
    // draw a rect for each
    for (int i=0; i < rates.length; i++)
    {
       fill( 255f*0.5f*(sin( rates[i] * currentTime ) + 1f) );
       rect(i*barWidth, 0, barWidth, this.height);
    }
  }

  // end class DynamicBWGraphic
}

