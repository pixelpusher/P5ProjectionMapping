// This is simply a PVector linked to another - so you can get a 
// link from a source vertex to a destination one, or the reverse

class ProjectedShapeVertex
{
  PVector src = null; 
  PVector dest = null;


  ProjectedShapeVertex(PVector _src, PVector _dest)
  {
    src = _src;
    dest = _dest;
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

