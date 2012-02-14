/*
 * This class contains the VerletPhysics world and 
 * keeps it working
 *
 */


import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;


class PhysicsModule extends VerletPhysics2D
{
  // Reference to physics world
  VerletPhysics2D physics;  

  float DEFAULT_STRING_STRENGTH = 0.08;


  PhysicsModule(float x, float y, float w, float h)
  {
    super();
    setWorldBounds(new Rect(x, y, x+w, y+h));
  }

  void addVertexConnector(ProjectedShapeVertex psv)
  {
    addParticle(new PhysicsVertexConnector(psv) );
  }


  void addSpring(ProjectedShapeVertex v1, ProjectedShapeVertex v2, float strength)
  {
    Vec2D v1pos = new Vec2D(v1.dest.x, v1.dest.y);
    Vec2D v2pos = new Vec2D(v2.dest.x, v2.dest.y);

    VerletParticle2D vp1=null, vp2=null;

    int i=0;

    // see if we already have these particles in our system
    while (i < particles.size () && vp1==null && vp2==null)
    {
      VerletParticle2D currentp = particles.get(i);
      if (currentp.equals(v1pos))
      {
        vp1 = currentp;
      }
      else if (currentp.equals(v2pos))
      {
        vp2 = currentp;
      }
      ++i;
    }

    if (vp1 != null && vp2 != null)
    {
      // destroy old one so we can make a new one
      VerletSpring2D oldSpring = getSpring(vp1, vp2); 
      if (oldSpring != null) removeSpring(oldSpring);
    }

    if (vp1 == null) vp1 = (VerletParticle2D)(new PhysicsVertexConnector(v1));

    if (vp2 == null) vp2 = (VerletParticle2D)(new PhysicsVertexConnector(v2));

    // add it
    addSpring(new VerletConstrainedSpring2D( vp1, vp2, vp1.distanceTo(vp2), strength, 0.1) );

    // end addSpring
  }

  //DEFAULT_STRING_STRENGTH

  /*
  VerletSpring2D getIntersectingSpring(ProjectedShapeVertex v1, ProjectedShapeVertex v2)
   {
   for (int i=0; i< springs.size(); ++i)
   {
   VerletSpring2D spring = springs.get(i);
   
   //PVector sv1 = spring.
   //  float lineDist = distancePointToLine(
   
   //if (
   }
   }
   */
  // end class PhysicsModule
}

//
// Note: use boolean removeSpringElements(VerletSpring2D s)
// Removes a spring connector and its both end point particles from the simulation
//


//
// This is a physics particle linked to a vertex in a shape.
// It updates the vertex whenever it updates it's position
//
class PhysicsVertexConnector extends VerletParticle2D 
{
  ProjectedShapeVertex psvertex;

  PhysicsVertexConnector(ProjectedShapeVertex psv) 
  {
    super(psv.dest.x, psv.dest.y);
    psvertex = psv;
  }


  //
  // override this to also update the attached vertex's destination position
  //
  void update() 
  {
    super.update();
    psvertex.dest.x = this.x;
    psvertex.dest.x = this.y;
  }
}

