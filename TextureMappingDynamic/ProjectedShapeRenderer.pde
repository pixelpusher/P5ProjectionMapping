/*
 * This object renders a ProjectedShape in a variety of ways.
 * Methods can optionally take a target renderer (PGraphics object)
 * so you can do some offscreen magic or use a shader for edge blending, for
 * example.
 *
 * Ideally, if done properly, this would class would only have static functions.
 * But this is done wuickly in the Processing IDE - perhaps in the future it will become a 
 * standalone library (and then will be structured a bit better).  For instance,
 * it should take the argument of a PApplet to render into...
 * 
 * by Evan Raskob 2012
 */


final class ProjectedShapeRenderer
{
  
  PGraphics renderer = null;   // rendering target object
  
  
  ProjectedShapeRenderer()
  {
    renderer = g;   // get default graphics object for this sketch
  }
  
  
   // Draw the source shape (no texture)
   //
   
  final void drawSourceShape(final ProjectedShape projShape)
  {
   drawSourceShape( projShape, renderer);
  } 
   
  
  final void drawSourceShape(final ProjectedShape projShape, PGraphics renderTarget)
  {
    renderTarget.strokeWeight(2);
    renderTarget.stroke(0, 255, 0, 80);
    // draw the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      renderTarget.beginShape();
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        renderTarget.vertex(vert.src.x, vert.src.y);
      }
      renderTarget.endShape(CLOSE);
    }

    for (ProjectedShapeVertex vert : projShape.verts)
    {
      // add it to our shape
      renderTarget.ellipse(vert.src.x, vert.src.y, 8, 8);
    }
  }





  // Draw the destination (projected) shape with no texture
  //
  final void drawDestShape(final ProjectedShape projShape)
  {
    drawDestShape( projShape, renderer );
  }
  

  final void drawDestShape(final ProjectedShape projShape, PGraphics renderTarget)
  {
    renderTarget.strokeWeight(2);
    renderTarget.stroke(255, 0, 255,80);

    // draw the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      renderTarget.beginShape();
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        renderTarget.vertex(vert.dest.x, vert.dest.y);
      }
      renderTarget.endShape(CLOSE);
    }

    renderTarget.stroke(255, 0, 255, 80);
    for (ProjectedShapeVertex vert : projShape.verts)
    {
      // add it to our shape
      renderTarget.ellipse(vert.dest.x, vert.dest.y, 8, 8);
    }
  }
  
  
  //
  // Draw the projected shape properly (with texture)
  //
  
  final void draw(final ProjectedShape projShape)
  {
    draw( projShape, renderer );
  }
  
  final void draw(final ProjectedShape projShape, PGraphics renderTarget)
  {
    //  the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      renderTarget.beginShape();
      renderTarget.texture( projShape.srcImage );
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        renderTarget.vertex(vert.dest.x, vert.dest.y, vert.src.x, vert.src.y);
      }
      renderTarget.endShape(CLOSE);
    }
  }
  
  
// end class ProjectedShapeRenderer
}
