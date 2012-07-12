void keyPressed()
{
  //create a new QUAD surface at mouse pos
  if(key == 'a') surfaceMapper.createQuadSurface(3,mouseX,mouseY);
  //create new BEZIER surface at mouse pos
  if(key == 'z') surfaceMapper.createBezierSurface(3,mouseX,mouseY);
  //switch between calibration and render mode
  if(key == 'c') surfaceMapper.toggleCalibration();
  
  //increase subdivision of surface
  if(key == 'p')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.increaseResolution();
    }
  }
  
  //decrease subdivision of surface
  if(key == 'o')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.decreaseResolution();
    }
  }
  
  //save layout to xml
  if(key == 's')surfaceMapper.save("config.xml");
  //load layout from xml
  if(key == 'l')surfaceMapper.load("config.xml");
  //rotate how the texture is mapped in the QUAD (clockwise)
  if(key == 'j')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.rotateCornerPoints(0);
    }
  }
  //rotate how the texture is mapped in the QUAD (counter clockwise)
  if(key == 'k')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.rotateCornerPoints(1);
    }
  }
  
  //increase the horizontal force on a BEZIER surface
  if(key == 't')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.increaseHorizontalForce();
    }
  }
  //decrease the horizontal force on a BEZIER surface  
  if(key == 'y')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.decreaseHorizontalForce();
    }
  }
  //increase the vertical force on a BEZIER surface  
  if(key == 'g')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.increaseVerticalForce();
    }
  }
  
  //decrease the vertical force on a BEZIER surface  
  if(key == 'h')
  {
    for(SuperSurface ss : surfaceMapper.getSelectedSurfaces()){
      ss.decreaseVerticalForce();
    }
  }
}
