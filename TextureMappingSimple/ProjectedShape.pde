
class ProjectedShape
{

  PImage myImage = null;

  LinkedList<ProjectedShapeVertex> verts = null; // list of points in the image (PVectors)

  ProjectedShape(PImage img)
  {
    if (img != null)
      myImage = img;
    else
      println("ERROR::::IMAGE FOR PROJECTED SHAPE CANNOT BE NULL!!");
    verts    = new LinkedList<ProjectedShapeVertex>();
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
    for (ProjectedShapeVertex v : verts)
      v.clear();

    verts.clear();
  }


  void draw()
  {
    //  the shape using source and destination vertices
    if (verts != null && verts.size() > 0)
    {
      beginShape();
      texture( myImage );
      for (ProjectedShapeVertex vert : verts)
      {
        // add it to our shape
        vertex(vert.dest.x, vert.dest.y, vert.src.x, vert.src.y);
      }
      endShape(CLOSE);
    }
  }

  void drawSourceShape()
  {
    strokeWeight(2);
    stroke(0, 255, 0, 80);
    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 0)
    {
      beginShape();
      for (ProjectedShapeVertex vert : verts)
      {
        // add it to our shape
        vertex(vert.src.x, vert.src.y);
      }
      endShape(CLOSE);
    }

    for (ProjectedShapeVertex vert : verts)
    {
      // add it to our shape
      ellipse(vert.src.x, vert.src.y, 8, 8);
    }
  }

  void drawDestShape()
  {
    strokeWeight(2);
    stroke(255, 0, 255,80);

    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 0)
    {
      beginShape();
      for (ProjectedShapeVertex vert : verts)
      {
        // add it to our shape
        vertex(vert.dest.x, vert.dest.y);
      }
      endShape(CLOSE);
    }

    stroke(255, 0, 255, 80);
    for (ProjectedShapeVertex vert : verts)
    {
      // add it to our shape
      ellipse(vert.dest.x, vert.dest.y, 8, 8);
    }
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
      PVector p = new PVector (x, y);
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

          float d = distancePointToLine(vert1.src, vert2.src, p);

          println("d:" + d);

          if ( d < distanceSquared)
          {
            println("add a point["+ iter.previousIndex() +"] " + p.x + "," + p.y);
            // add a new point!
            iter.previous();
            result = new ProjectedShapeVertex(p, p); 
            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        vert2 = verts.peekLast();
        vert1 = verts.peekFirst();

        float d = distancePointToLine(vert1.src, vert2.src, p);

        println("d:" + d);

        if ( d < distanceSquared)
        {
          // add a new point!
          result = new ProjectedShapeVertex(p, p); 
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
      PVector p = new PVector (x, y);
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

          float d = distancePointToLine(vert1.dest, vert2.dest, p);

          println("d:" + d);

          if ( d < distanceSquared)
          {
            //println("add a point["+ iter.previousIndex() +"] " + p.x + "," + p.y);
            // add a new point!
            iter.previous();
            result = new ProjectedShapeVertex(p, p); 
            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        vert2 = verts.peekLast();
        vert1 = verts.peekFirst();

        float d = distancePointToLine(vert1.dest, vert2.dest, p);

        println("d:" + d);

        if ( d < distanceSquared)
        {
          // add a new point!
          result = new ProjectedShapeVertex(p, p); 
          verts.addLast( result );
        }
      }
    }

    return result;
  }


  // end class ProjectedShape
}

