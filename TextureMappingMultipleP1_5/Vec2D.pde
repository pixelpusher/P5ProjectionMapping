/**
 * These are "borrowed" form th excellent toxiclibs Vec2D class
 * http://toxiclibs.org
 */

public final Vec2D randomVector() {
  return new Vec2D(random(0, 1), random(0, 1));
}


public class Vec2D
{  
  float x, y;

  public Vec2D(float x, float y) 
  {
    this.x = x;
    this.y = y;
  }

  public Vec2D(float[] v) 
  {
    this.x = v[0];
    this.y = v[1];
  }

  public Vec2D() 
  {
    x = y = 0;
  }

  public final Vec2D scaleSelf(float s)
  {
    x *= s;
    y *= s;

    return this;
  }
  public final Vec2D addSelf(float a, float b) {

    x += a;

    y += b;

    return this;
  }

  public final Vec2D addSelf(Vec2D v) {

    x += v.x;

    y += v.y;

    return this;
  }

  public final Vec2D sub(float a, float b) {

    return new Vec2D(x - a, y - b);
  }

  public final Vec2D sub(Vec2D v) {
    return new Vec2D(x - v.x, y - v.y);
  }

  public final Vec2D add(float a, float b) {
    return new Vec2D(x + a, y + b);
  }


  public final Vec2D add(Vec2D v) {
    return new Vec2D(x + v.x, y + v.y);
  }


  public final Vec2D set(float x, float y) {
    this.x = x;
    this.y = y;

    return this;
  }

  public final Vec2D set(Vec2D v) {
    x = v.x;
    y = v.y;

    return this;
  }

  public final float magnitude() {
    return sqrt(x * x + y * y);
  }

  public final float dot(Vec2D v) {
    return x * v.x() + y * v.y();
  }
  public final float x() {

    return x;
  }



  public final float y() {

    return y;
  }
}

