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

import javax.media.opengl.GL;
import javax.media.opengl.GL2;

class ProjectedShapeRenderer
{

  //PGraphics renderer = null;   // rendering target object
  PGraphicsOpenGL renderer;

  ProjectedShapeRenderer(PGraphicsOpenGL pgl)
  {
    //renderer = g;   // get default graphics object for this sketch
    renderer = pgl; 
  }

 
   // This is taken directly from the PGraphics2.java renderer
   // Copyright (c) 2004-08 Ben Fry and Casey Reas
   
  public void screenBlend(int mode) {

    boolean blendEqSupported = true;   // necessary?
    GL gl = renderer.beginGL();
    gl.glEnable(GL.GL_BLEND);

    if (mode == REPLACE) {
      // This is equivalent to disable blending.
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_ONE, GL.GL_ZERO);
    } 
    else if (mode == BLEND) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
    } 
    else if (mode == ADD) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
    } 
    else if (mode == SUBTRACT) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ZERO);
    } 
    else if (mode == LIGHTEST) {
      if (blendEqSupported) {
        gl.glBlendEquation(GL2.GL_MAX);
        gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == DARKEST) {
      if (blendEqSupported) {
        gl.glBlendEquation(GL2.GL_MIN);
        gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == DIFFERENCE) {
      if (blendEqSupported) {
        gl.glBlendEquation(GL.GL_FUNC_REVERSE_SUBTRACT);
        gl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == EXCLUSION) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ONE_MINUS_SRC_COLOR);
    } 
    else if (mode == MULTIPLY) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_DST_COLOR, GL.GL_SRC_COLOR);
    } 
    else if (mode == SCREEN) {
      if (blendEqSupported) gl.glBlendEquation(GL.GL_FUNC_ADD);
      gl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ONE);
    }
    // HARD_LIGHT, SOFT_LIGHT, OVERLAY, DODGE, BURN modes cannot be implemented
    // in fixed-function pipeline because they require conditional blending and
    // non-linear blending equations.
    
    renderer.endGL();
  }


  // Draw the source shape (no texture)
  //

  final void drawSourceShape(final ProjectedShape projShape)
  {
    drawSourceShape( projShape, renderer);
  } 


  final void drawSourceShape(final ProjectedShape projShape, PGraphics renderTarget)
  {
    renderTarget.smooth();
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
    renderTarget.smooth();
    renderTarget.strokeWeight(2);
    renderTarget.stroke(255, 0, 255, 80);

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
      renderTarget.noStroke();
      renderTarget.noSmooth();
      screenBlend(projShape.blendMode);
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

