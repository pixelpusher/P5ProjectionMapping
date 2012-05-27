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

  float cr=0f, cg=0f, cb=0f, ca=1f; // clear colour
  
  //PGraphics renderer = null;   // rendering target object
  PGraphicsOpenGL renderer;

  ProjectedShapeRenderer(PGraphicsOpenGL pgl)
  {
    //renderer = g;   // get default graphics object for this sketch
    renderer = pgl;
  }


  // This is taken directly from the PGraphics2.java renderer
  // Copyright (c) 2004-08 Ben Fry and Casey Reas

    final public void screenBlend(int mode, PGraphicsOpenGL renderTarget) {

    boolean blendEqSupported = true;   // necessary?
    //GL gl = renderTarget.beginGL();
    renderTarget.pgl.glEnable(GL.GL_BLEND);
    renderTarget.pgl.glDisable(GL.GL_DEPTH_TEST);

    if (mode == REPLACE) {
      // This is equivalent to disable blending.
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
  renderTarget.pgl.glBlendFunc(GL.GL_ONE, GL.GL_ZERO);
    } 
    else if (mode == BLEND) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
    } 
    else if (mode == ADD) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
    } 
    else if (mode == SUBTRACT) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ZERO);
    } 
    else if (mode == LIGHTEST) {
      if (blendEqSupported) {
        renderTarget.pgl.glBlendEquation(GL2.GL_MAX);
        renderTarget.pgl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == DARKEST) {
      if (blendEqSupported) {
        renderTarget.pgl.glBlendEquation(GL2.GL_MIN);
        renderTarget.pgl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == DIFFERENCE) {
      if (blendEqSupported) {
        renderTarget.pgl.glBlendEquation(GL.GL_FUNC_REVERSE_SUBTRACT);
        renderTarget.pgl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
      } 
      else {
        PGraphics.showWarning("OPENGL2: This blend mode is currently unsupported.");
      }
    } 
    else if (mode == EXCLUSION) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ONE_MINUS_SRC_COLOR);
    } 
    else if (mode == MULTIPLY) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_DST_COLOR, GL.GL_SRC_COLOR);
    } 
    else if (mode == SCREEN) {
      if (blendEqSupported) renderTarget.pgl.glBlendEquation(GL.GL_FUNC_ADD);
      renderTarget.pgl.glBlendFunc(GL.GL_ONE_MINUS_DST_COLOR, GL.GL_ONE);
    }
    // HARD_LIGHT, SOFT_LIGHT, OVERLAY, DODGE, BURN modes cannot be implemented
    // in fixed-function pipeline because they require conditional blending and
    // non-linear blending equations.

    //renderTarget.endGL();
  }




//
// various flavours of starting off rendering
// 

  void beginRender()
  {
    beginRender(this.renderer, true);
  }

  void beginRender(boolean clearScreen)
  {
    beginRender(this.renderer, clearScreen);
  }

  void beginRender(PGraphics renderTarget)
  {
    beginRender(renderTarget, true);
  }
  
  void beginRender(PGraphics renderTarget, boolean clearScreen)
  {
    renderer = (PGraphicsOpenGL)renderTarget;
    
    renderer.beginDraw();

    // black background
    //  mappedView.background(0);
    if (clearScreen)
    {
      /*
      GL gl = renderer.beginGL();
      gl.glClearColor(cr,cg,cb,ca);
      gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
      renderer.endGL();
      */
      renderer.background(0);
    }
  }



  void endRender()
  {
    this.renderer.endDraw();
  }



  // Draw the source shape (no texture)
  //

  final void drawSourceShape(final ProjectedShape projShape)
  {
    drawSourceShape( projShape, renderer, false);
  } 

  final void drawSourceShape(final ProjectedShape projShape, boolean showSrcImage)
  {
    drawSourceShape( projShape, renderer, showSrcImage);
  } 


  final void drawSourceShape(final ProjectedShape projShape, PGraphics renderTarget, boolean showSrcImage)
  {
    this.screenBlend(REPLACE, (PGraphicsOpenGL)renderTarget);
    if (showSrcImage)
    {
       renderTarget.noSmooth();  // otherwise we see white lines!
       renderTarget.image( projShape.srcImage, 0, 0, projShape.srcImage.width/2, projShape.srcImage.height/2);
    }

    renderTarget.smooth();
    renderTarget.strokeWeight(2);
    renderTarget.noFill();
    renderTarget.stroke(projShape.srcColor);
    // draw the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      renderTarget.beginShape();
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        renderTarget.vertex(vert.src.x/2, vert.src.y/2);
      }
      renderTarget.endShape(CLOSE);
    }

    for (ProjectedShapeVertex vert : projShape.verts)
    {
      // add it to our shape
      renderTarget.pushMatrix();
      renderTarget.translate(vert.src.x/2, vert.src.y/2);
      renderTarget.ellipse(0, 0, 8, 8);
      renderTarget.popMatrix();
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
    this.screenBlend(REPLACE, (PGraphicsOpenGL)renderTarget);
    renderTarget.smooth();
    renderTarget.strokeWeight(2);
    renderTarget.stroke(projShape.dstColor);
    //renderTarget.stroke(255);
    renderTarget.noFill();

    // draw the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      renderTarget.beginShape();
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        //renderTarget.vertex(vert.dest.x, vert.dest.y, vert.dest.z);
        renderTarget.vertex(vert.dest.x, vert.dest.y);
      }
      renderTarget.endShape(CLOSE);
    }
    
    for (ProjectedShapeVertex vert : projShape.verts)
    {
      // add it to our shape
      renderTarget.pushMatrix();
      //renderTarget.translate(vert.dest.x, vert.dest.y, vert.dest.z);
      renderTarget.translate(vert.dest.x, vert.dest.y);
      renderTarget.ellipse(0, 0, 8, 8);
      renderTarget.popMatrix();
    }
  }


  //
  // Draw the projected shape properly (with texture)
  //

  final void draw(final ProjectedShape projShape)
  {
    this.draw( projShape, renderer );
  }

  final void draw(final ProjectedShape projShape, PGraphics renderTarget)
  {
    //  the shape using source and destination vertices
    if (projShape.verts != null && projShape.verts.size() > 0)
    {
      this.screenBlend(projShape.blendMode, (PGraphicsOpenGL)renderTarget);
      renderTarget.noTint();
      renderTarget.noStroke();
      renderTarget.noSmooth();
      renderTarget.beginShape();
      renderTarget.texture( projShape.srcImage );
      for (ProjectedShapeVertex vert : projShape.verts)
      {
        // add it to our shape
        renderTarget.vertex(vert.dest.x, vert.dest.y, vert.dest.z, vert.src.x, vert.src.y);
      }
      renderTarget.endShape(CLOSE);
    }
  }

  // end class ProjectedShapeRenderer
}
