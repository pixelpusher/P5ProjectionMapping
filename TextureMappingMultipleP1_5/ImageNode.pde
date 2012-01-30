class ImageNode extends DrawableNode
{
  PImage img = null;

  ImageNode()
  {
    super();
  }
  
  ImageNode(float _x, float _y, float _w, float _h)
  {
    super( _x,  _y,  _w,  _h);
  }
  

  ImageNode(PImage newImg, float _x, float _y, float _w, float _h)
  {
    super( _x,  _y,  _w,  _h);
    setImage(newImg);
  }
  
  ImageNode(PImage newImg, float _x, float _y)
  {
    super( _x,  _y,  newImg.width,  newImg.height);
    setImage(newImg);
  }


  void setImage(PImage newImg)
  {
    img = newImg;
  }


  void setImage(PImage newImg, boolean alterDims)
  {
    img = newImg;
    
    if (alterDims)
    {
      setW(img.width);
      setH(img.height);
    }
  }



  void draw()
  {
    // fill, or tint in this case
    if (hasFill) 
    {
      tint(fillColor);
    } 
    else {
      noFill();
    }

    imageMode(CORNER);
    image(img, minX, minY, w, h);
  }
  
  
  void unload()
  {
    img = null;
  }
  
// end class
}



