

/*
 * XML file format:
 *
 * <config>
 *
 *   <shapes>
 *      <shape name="" media="[path]" mediatype="image|movie|other" mediaPath="...">
 *        <vertices count="">
 *          <vertex sx="" sy="" dx="" dy="" />
 *          <vertex sx="" sy="" dx="" dy="" />
 *        </vertices>
 *      </shape>
 *    </shapes>
 *
 *    </config>
 */
 
/*


// root xml node for config data
XML configXML;


final String XML_MEDIA_MOVIE_TYPE = "movie";
final String XML_MEDIA_IMAGE_TYPE = "image";
final String XML_MEDIA_OTHER_TYPE = "other";



void setupXML()
{ 
  configXML = new XML();

  configXML.setName("config");
  configXML.setAttribute("updated", year()+"."+month()+"."+day()+"-"+hour()+":"+minute()+":"+second());

 // shapesXML = new XML();
}


void readXMLConfig(String filename)
{
  resetAllData();

  // open XML file  
  configXML = new XML (this, filename); // Tor Lundstrom

  int numChildren = configXML.getChildCount();

  // handle nodes in file
  for (int i=0; i < numChildren; ++i)
  {
    // top-level nodes (media, shapes)
    XML xmlNode = configXML.getChild(i);

    String nodeName = xmlNode.getName();

    //
    // HANDLE MEDIA FILES
    //    


    //
    // HANDLE SHAPES
    //
    if (nodeName == "shapes")
    {
      int numShapeNodes = xmlNode.getChildCount();

      println("XML: Found " + numShapeNodes + " shapes");

      for (int j=0; j < numShapeNodes; ++j)
      {
        XML shapeNode = xmlNode.getChild(i);

        // 1. create new shape
        // 2. assign media by name
        // 3. add vertices

        String mediaType = shapeNode.getStringAttribute("mediaType");
        String mediaPath = shapeNode.getStringAttribute("mediaPath");
        String shapeName = shapeNode.getStringAttribute("name");

        // debug
        println("... mediaPath["+j+"]:" + mediaPath);


        if (mediaType == XML_MEDIA_MOVIE_TYPE)
        {
          // load Movie
          Movie movie = new Movie(this, mediaPath);

          File f = new File(mediaPath);
          String pathEnd = f.getName();

          String newPath = pathEnd+"";
          int tries=1;

          // handle duplicate names
          while (sourceImages.containsKey (newPath))
          {
            newPath = pathEnd + tries;
            ++tries;
          }

          // add to our list of available media
          sourceImages.put(newPath, movie);

          // to do - check for bad image data!
          ProjectedShape newShape = addNewShape(movie);

          // finally, add to keyed array for this shape
          sourceMovies.put(newShape, movie);
        }

        else if (mediaType == XML_MEDIA_IMAGE_TYPE)
        {
          // load and add to HashMap of <path,PImage>
          PImage sourceImage = loadImageIfNecessary(mediaPath);

          ProjectedShape newShape = addNewShape(sourceImage);
        }
        else if (mediaType == XML_MEDIA_OTHER_TYPE)
        {
          // in this case dynamic graphics are loaded once at the start and stay loaded,
          // so we just look it up in the hashmap:
          DynamicGraphic sd = sourceDynamic.get(mediaPath);

          ProjectedShape newShape = addNewShape(sd);
        }
      
      // done with each shape node   
      }
    //done with all shapes  
    }
  // done with xml root  
  }
  // DONE LOADING XML
}


void writeXML()
{

  // file schreiben
  PrintWriter xmlfile;

  xmlfile = createWriter("config.xml");

  // DEBUG
  println(configXML.getName());
  println(configXML.getContent());

  //write file
  try
  {
    XMLWriter xmlwriter = new XMLWriter(xmlfile) ;

    xmlwriter.write(configXML);

    xmlfile.flush();
    xmlfile.close();
  }
  catch (IOException e)
  {
    e.printStackTrace();
  }
}
*/
