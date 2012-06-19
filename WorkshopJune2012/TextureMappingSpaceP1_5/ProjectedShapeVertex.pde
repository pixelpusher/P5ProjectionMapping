// This is simply a PVector linked to another - so you can get a 
// link from a source vertex to a destination one, or the reverse

class ProjectedShapeVertex
{
  PVector src = null; 
  PVector dest = null;


  ProjectedShapeVertex(PVector _src, PVector _dest)
  {
    src = new PVector(_src.x, _src.y, _src.z);
    dest = new PVector(_dest.x, _dest.y, _dest.z);
  }

  ProjectedShapeVertex(ProjectedShapeVertex srcVert)
  {
    src = new PVector(srcVert.src.x, srcVert.src.y, srcVert.src.z);
    dest = new PVector(srcVert.dest.x, srcVert.dest.y, srcVert.dest.z);
  }
  
  void clear()
  {
    src = null;
    dest = null;
  }
 
  String toString()
  {
    return ("[ (" + src.x +","+src.y +") (" + dest.x +","+dest.y +") ]"); 
  }
}

