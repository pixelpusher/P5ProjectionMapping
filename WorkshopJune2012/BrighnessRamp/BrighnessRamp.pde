import processing.opengl.*;


int whiteness = 0;
int speed     = 2;
int currentSpeed = speed;


void setup()
{
  size( 320,240, OPENGL );
}


void draw()
{
  background(whiteness);
  
  whiteness = whiteness + currentSpeed;
  
  if (whiteness > 255)
  {
    whiteness = 255;
    currentSpeed = -speed;
  }
  else if (whiteness < 0)
  {
    whiteness = 0;
    currentSpeed = speed;
  }
}


