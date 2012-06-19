/**
 * Note from Evan: These are "borrowed" form th excellent toxiclibs Vec2D class:
 *
 *
 *   __               .__       .__  ._____.           
 * _/  |_  _______  __|__| ____ |  | |__\_ |__   ______
 * \   __\/  _ \  \/  /  |/ ___\|  | |  || __ \ /  ___/
 *  |  | (  <_> >    <|  \  \___|  |_|  || \_\ \\___ \ 
 *  |__|  \____/__/\_ \__|\___  >____/__||___  /____  >
 *                   \/       \/             \/     \/ 
 *
 * Copyright (c) 2006-2011 Karsten Schmidt
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
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

  public final float magSquared() {
    return x * x + y * y;
  }


  /**
   * Limits the vector's magnitude to the length given
   * 
   * @param lim
   *            new maximum magnitude
   * @return itself
   */
  public final Vec2D limit(float lim) {
    if (magSquared() > lim * lim) {
      return normalize().scaleSelf(lim);
    }
    return this;
  }


   /**
     * Normalizes the vector so that its magnitude = 1
     * 
     * @return itself
     */
    public final Vec2D normalize() {
        float mag = x * x + y * y;
        if (mag > 0) {
            mag = 1f / (float) Math.sqrt(mag);
            x *= mag;
            y *= mag;
        }
        return this;
    }

  public final float y() {

    return y;
  }
}

