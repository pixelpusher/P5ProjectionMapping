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
  float proj = PVector.dot(w,direction);

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

