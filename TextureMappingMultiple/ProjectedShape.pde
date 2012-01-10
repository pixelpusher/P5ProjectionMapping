/*
 * Represents a projection-mapped shape using a source image
 * and set of source points in that image (forming a polygon)
 * and a destination set of points (forming a polgon) that
 * the image should be mapped to.
 *
 *
 */

class ProjectedShape
{
  PImage srcImage = null;
  
  // for tinting:
  int r;
  int g;
  int b;
  int a;
  int blendMode = LIGHTEST;

  // for outlining:
  color srcColor = color(0, 255, 0, 180);
  color dstColor = color(255, 0, 255, 180);
  
  String name = null;
  
  LinkedList<ProjectedShapeVertex> verts = null; // list of points in the image (PVectors)

  ProjectedShape(PImage img)
  {
    if (img != null)
      srcImage = img;
    else
      println("ERROR::::IMAGE FOR PROJECTED SHAPE CANNOT BE NULL!!");
    verts    = new LinkedList<ProjectedShapeVertex>();
    
    // give it a random name
    name = "shape" + random(0,MAX_INT);
  }
  
  
  // deep copy ProjectedShape
  
  ProjectedShape(ProjectedShape srcShape)
  {
    if (srcShape.srcImage != null)
      srcImage = srcShape.srcImage;
    else
      println("ERROR::::IMAGE FOR PROJECTED SHAPE CANNOT BE NULL!!");
    
    // deep copy verts
    verts    = new LinkedList<ProjectedShapeVertex>();
    
    for (ProjectedShapeVertex psvert : srcShape.verts )
    {
     verts.add(new ProjectedShapeVertex(psvert) );
    }
    
    // give it a random name
    name = "shape" + random(0,MAX_INT);
  }
  


  // Add a new source and destination vertex
  ProjectedShapeVertex addVert(float srcX, float srcY, float destX, float destY)
  {
    PVector srcVert  =  new PVector(srcX, srcY);
    PVector destVert = new PVector(destX, destY);

    ProjectedShapeVertex newVert = new ProjectedShapeVertex( srcVert, destVert); 

    verts.add( newVert );

    return newVert;
  }


  void removeVert( ProjectedShapeVertex v)
  {
    verts.remove( v );
  }


  void clear()
  {
    srcImage = null;
    
    clearVerts();
  }

void clearVerts()
  {    
    for (ProjectedShapeVertex v : verts)
      v.clear();

    verts.clear();
  }

  // sync all the projected vertices to the source verts
  void syncVertsToSource()
  {
    for (ProjectedShapeVertex v : verts)
      v.dest.set(v.src);
  }

  // sync all the projected vertices to the source verts
  void syncVertsToDest()
  {
    for (ProjectedShapeVertex v : verts)
      v.src.set(v.dest);
  }


  // Find the closest vertex - return null if none is within the distance
  ProjectedShapeVertex getClosestVertexToSource( float x, float y, float distanceSquared)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    for (int i=0; i < verts.size(); ++i)
    {
      ProjectedShapeVertex vert = verts.get(i);

      float xdiff =  vert.src.x - x;
      float ydiff =  vert.src.y - y;
      float dsquared = xdiff*xdiff+ydiff*ydiff;

      if ( dsquared <= distanceSquared)
      {
        result = vert;
      }
    }

    return result;
  }



  // Find the closest vertex - return null if none is within the distance
  ProjectedShapeVertex getClosestVertexToDest( float x, float y, float distanceSquared)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    for (int i=0; i < verts.size(); ++i)
    {
      ProjectedShapeVertex vert = verts.get(i);

      float xdiff =  vert.dest.x - x;
      float ydiff =  vert.dest.y - y;
      float dsquared = xdiff*xdiff+ydiff*ydiff;

      if ( dsquared <= distanceSquared)
      {
        result = vert;
      }
    }
    return result;
  }


  ProjectedShapeVertex addClosestSourcePointToLine( float x, float y, float distanceSquared)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 1)
    {
      PVector ps = new PVector (x, y);
      PVector pd = new PVector (x, y);

      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();

      int i=0;

      ProjectedShapeVertex vert1 = iter.next();
      ProjectedShapeVertex vert2 = vert1;

      while (iter.hasNext () && result == null)
      {
        //println("iter:" + iter.nextIndex() + "["+ i++ +"]" + " / " + verts.size());
        //print (" vert1 " + vert1 + "::: ");

        // make sure we're not at the last element
        if (iter.hasNext() )
        {
          vert1 = vert2;

          vert2 = iter.next();

          //println(" vert2 " + vert2);

          float d = distancePointToLine(vert1.src, vert2.src, ps);

          //println("d:" + d);

          if ( d < distanceSquared)
          {
            //println("add a point["+ iter.previousIndex() +"] " + ps.x + "," + ps.y);
            // add a new point!
            iter.previous();
            result = new ProjectedShapeVertex(ps, pd); 
            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        vert2 = verts.peekLast();
        vert1 = verts.peekFirst();

        float d = distancePointToLine(vert1.src, vert2.src, ps);

        //println("d:" + d);

        if ( d < distanceSquared)
        {
          // add a new point!
          result = new ProjectedShapeVertex(ps, pd); 
          verts.addLast( result );
        }
      }
    }

    return result;
  }




  ProjectedShapeVertex addClosestDestPointToLine( float x, float y, float distance)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 1)
    {
      PVector ps = new PVector (x, y);
      PVector pd = new PVector (x, y);

      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();

      int i=0;

      ProjectedShapeVertex vert1 = iter.next();
      ProjectedShapeVertex vert2 = vert1;

      while (iter.hasNext () && result == null)
      {
        //println("iter:" + iter.nextIndex() + "["+ i++ +"]" + " / " + verts.size());
        //print (" vert1 " + vert1 + "::: ");

        // make sure we're not at the last element
        if (iter.hasNext() )
        {
          vert1 = vert2;

          vert2 = iter.next();

          //println(" vert2 " + vert2);

          float d = distancePointToLine(vert1.dest, vert2.dest, ps);

          //println("d:" + d);

          if ( d < distance)
          {
            //println("add a point["+ iter.previousIndex() +"] " + p.x + "," + p.y);
            // add a new point!
            iter.previous();
            result = new ProjectedShapeVertex(ps, pd); 
            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        vert2 = verts.peekLast();
        vert1 = verts.peekFirst();

        float d = distancePointToLine(vert1.dest, vert2.dest, ps);

        println("d:" + d + " / " + distance);

        if ( d < distance)
        {
          // add a new point!
          result = new ProjectedShapeVertex(ps, pd); 
          verts.addLast( result );
          println("added new pt");
        }
      }
    }

    return result;
  }



  void move(float x, float y, boolean useSource)
  {
    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 1)
    {      
      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();

      while (iter.hasNext ())
      {
        PVector v1 = useSource ? iter.next().src : iter.next().dest;


        v1.x += x;
        v1.y += y;
      }
    }
  }



  // end class ProjectedShape
}

