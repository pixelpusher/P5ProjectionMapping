
/*******
 * Keys: 
 *
 * 'a': new quad surface
 * 'A': new bezier surface
 * 't': change surface texture
 * 'c': switch between performance mode and calibration mode
 * 'p': increase surface resolution (mesh points)
 * 'o': decrease surface resolution (mesh points)
 * 's': save XML configuration file
 * 'l': load XML configuration file
 * 'f' / 'F': increase / decrease horizontal force (bezier surface only)
 * 'g' / 'G': increase / decrease vertical force (bezier surface only)
 *
 ********/



void keyReleased()
{
  //create a new QUAD surface at mouse pos
  if (key == 'a') 
  {  
    SuperSurface newSurface = surfaceMapper.createQuadSurface(3, mouseX, mouseY);
    newSurface.setSurfaceName("movie");
  } 
  else if (key == 'A') 
  {
    //create new BEZIER surface at mouse pos
    SuperSurface newSurface = surfaceMapper.createBezierSurface(3, mouseX, mouseY);
    newSurface.setSurfaceName("movie");
  }
  else if (key == 't')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces())
    {
      int namesIndex = -1;
      boolean found = false;
      while (!found && (namesIndex < SurfaceNames.length) )
      {
        namesIndex++;
        
        // check if we match the current surface name, if so, go to the next (and wrap around the list)  
        if (ss.getSurfaceName().equals( SurfaceNames[namesIndex] ))   
        {
          found = true;
          ss.setSurfaceName(SurfaceNames[ (namesIndex+1) % SurfaceNames.length]);
        }
      }
    }
    // end 't' key
  }

  //switch between calibration and render mode
  if (key == 'c') surfaceMapper.toggleCalibration();

  //increase subdivision of surface
  if (key == 'p')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.increaseResolution();
    }
  }

  //decrease subdivision of surface
  if (key == 'o')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.decreaseResolution();
    }
  }

  //save layout to xml
  if (key == 's')surfaceMapper.save("config.xml");
  //load layout from xml
  if (key == 'l')surfaceMapper.load("config.xml");
  //rotate how the texture is mapped in the QUAD (clockwise)
  if (key == 'j')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.rotateCornerPoints(0);
    }
  }
  //rotate how the texture is mapped in the QUAD (counter clockwise)
  if (key == 'k')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.rotateCornerPoints(1);
    }
  }

  //increase the horizontal force on a BEZIER surface
  if (key == 'f')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.increaseHorizontalForce();
    }
  }
  //decrease the horizontal force on a BEZIER surface  
  if (key == 'F')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.decreaseHorizontalForce();
    }
  }
  //increase the vertical force on a BEZIER surface  
  if (key == 'g')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.increaseVerticalForce();
    }
  }

  //decrease the vertical force on a BEZIER surface  
  if (key == 'G')
  {
    for (SuperSurface ss : surfaceMapper.getSelectedSurfaces()) {
      ss.decreaseVerticalForce();
    }
  }
}

