// These are adapted by Evan Raskob from Essential Mathematics for Game Designers and Interactive Applications
// by James M. Van Verth & Lars M. Bishop 
// http://www.amazon.com/Essential-Mathematics-Games-Interactive-Applications/dp/155860863X

PVector closestPointToLine(PVector l0, PVector l1, PVector p)
{
  PVector direction = PVector.sub(l1, l0);
  PVector w = PVector.sub(p, l0);
  float proj = w.dot(direction);

  if (proj <= 0)
    return l0;
  else
  {
    float vsq = direction.dot(direction);
    if (proj >= vsq)
      return PVector.add(l0, direction);
    else
    {
      direction.mult(proj/vsq);
      return PVector.add(l0, direction);
    }
  }
}

// Find the shortest possible distance between a point and a line.
final float distancePointToLine(PVector l0, PVector l1, PVector p)
{
  PVector direction = PVector.sub(l1, l0);
  PVector w = PVector.sub(p, l0);
  float proj = PVector.dot(w, direction);

  if (proj <= 0)
    return w.dot(w);
  else
  {
    float vsq = direction.dot(direction);
    if (proj >= vsq)
      return w.dot(w) - 2.0f*proj+vsq;
    else
      return w.dot(w) - proj*proj/vsq;
  }
}


// Adapted from http://paulbourke.net/geometry/insidepoly/
// Originally by Alexander Motrichuk (in C++)

boolean isInsideShape(ProjectedShape projShape, float x, float y, boolean testSource)
{
  final boolean bound = true;  // for boundary cases
  final PVector p = new PVector(x, y);

  int intersections = 0;

  // draw the shape using source and destination vertices
  if (projShape.verts != null && projShape.verts.size() > 1)
  {      
    ListIterator<ProjectedShapeVertex> iter = projShape.verts.listIterator();

    int i = -1;

    PVector v1 = testSource ? iter.next().src : iter.next().dest;
    PVector v2 = v1;
    float xinters;

    // make sure we're not at the last element
    while (iter.hasNext() )
    {
      ++i;

      v1 = v2;
      v2 = testSource ? iter.next().src : iter.next().dest;

      //if ray is outside of our interests
      if (p.y < min(v1.y, v2.y) || p.y > max(v1.y, v2.y))
      {
        continue;
      }

      //x is before ray
      if (p.x <= max(v1.x, v2.x))
      {
        //overlies on a horizontal ray
        if (v1.y == v2.y && p.x >= min(v1.x, v2.x)) return bound;

        //ray is vertical
        if (v1.x == v2.x)
        {
          //overlies on a ray
          if (v1.x == p.x) return bound;

          //before ray
          else ++intersections;
        }

        //cross point on the left side
        else
        {
          //cross point of x
          xinters = (p.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y) + v1.x;

          //overlies on a ray
          if (abs(p.x - xinters) < EPSILON) return bound;

          //before ray
          if (p.x < xinters) ++intersections;
        }
      }

      //special case when ray is crossing through the vertex
      else
      {
        //p crossing over p2
        if (p.y == v2.y && p.x <= v2.x)
        {
          //next vertex
          final PVector v3 = testSource ? iter.next().src : iter.next().dest;
          ++i;

          //p.y lies between p1.y & p3.y
          if (p.y >= min(v1.y, v3.y) && p.y <= max(v1.y, v3.y))
          {
            ++intersections;
          }
          else
          {
            intersections += 2;
          }

          v1 = v2;
          v2 = v3;
        }
      }
     
    // done while loop  
    }
  }

  //EVEN
  if (intersections % 2 == 0) return false;
  //ODD
  else return true;
}

