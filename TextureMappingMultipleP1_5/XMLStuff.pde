

/*
 * XML file format:
 *
 * <config>
 *
 *   <shapes>
 *      <shape name="" media="[path]" mediaType="image|movie|other" mediaPath="..." color="r,g,b,a">
 *        <vertices count="">
 *          <vertex sx="" sy="" dx="" dy="" />
 *          <vertex sx="" sy="" dx="" dy="" />
 *        </vertices>
 *      </shape>
 *    </shapes>
 *
 *    </config>
 */


// root xml node for config data
XML configXML;


final String XML_MEDIA_MOVIE_TYPE = "movie";
final String XML_MEDIA_IMAGE_TYPE = "image";
final String XML_MEDIA_OTHER_TYPE = "other";

String CONFIG_FILE_NAME = "data/config.xml";


void writeXML(String name, XML theXml)
{
  PrintWriter xmlfile = createWriter(name);

  // DEBUG
  print("WRITING XML FILE: ");
  println(theXml.getName() + ":::::::::");
  println("::CONTENT::");
  println(theXml.getContent());
  println("::END CONTENT::");
  // END DEBUG

  // write file
  xmlfile.print(configXML.toString());
  xmlfile.flush();
  xmlfile.close();
}


void writeMainConfigXML()
{
  writeXML(CONFIG_FILE_NAME, configXML);
}



void createConfigXML()
{ 
  configXML = new XML("config");
  configXML.setString("updated", year()+"."+month()+"."+day()+"-"+hour()+":"+minute()+":"+second() );
  configXML.setFloat("version", 1.0);

  XML shapesXML = configXML.addChild("shapes");

  // look through shapes and null out image...
  for (ProjectedShape ps : shapes)
  {

    // only add it if it has vertices!

    if (ps.verts.size() > 0)
    {
      XML shapeXML = shapesXML.addChild("shape");

      shapeXML.setString("name", ps.name);

      String dgName = "";


      if ((ps.srcImage) instanceof DynamicGraphic)
      {
        for (String name : sourceDynamic.keySet() )
        {
          DynamicGraphic dg = sourceDynamic.get(name);
          if (dg == ps.srcImage)
          {
            dgName = name;
            break;
          }
        }

        // image name
        shapeXML.setString("media", dgName);
        // image path
        shapeXML.setString("mediaPath", dgName);
        // other type
        shapeXML.setString("mediaType", XML_MEDIA_OTHER_TYPE);

        // end dynamic
      }


      else if (ps.srcImage instanceof Movie)
      {
        String moviePath = movieFiles.get((Movie)ps.srcImage);

        // same method we use when loading it...
        File f = new File(moviePath);
        String movieName = f.getName();

        // movie name
        shapeXML.setString("media", movieName);
        // movie path
        shapeXML.setString("mediaPath", moviePath);
        // movie type
        shapeXML.setString("mediaType", XML_MEDIA_MOVIE_TYPE);

        // end movie
      }


      else if (ps.srcImage instanceof PImage)
      {
        String imgPath = imageFiles.get(ps.srcImage);
        String imgName = "";

        if (imgPath != null)
        {
          // same method we use when loading it...
          File f = new File(imgPath);
          imgName = f.getName();
        }
        else
        {
          imgPath = "";
        }
        // image name
        shapeXML.setString("media", imgName);
        // image path
        shapeXML.setString("mediaPath", imgPath);
        // image type
        shapeXML.setString("mediaType", XML_MEDIA_IMAGE_TYPE);
      }

      //
      // now add vertices
      //

      XML vertsXML = shapeXML.addChild("vertices");
      vertsXML.setInt("count", ps.verts.size());

      for (ProjectedShapeVertex pv : ps.verts)
      {
        XML vertXML = vertsXML.addChild("vertex");
        vertXML.setFloat("sx", pv.src.x);
        vertXML.setFloat("sy", pv.src.y);
        vertXML.setFloat("dx", pv.dest.x);
        vertXML.setFloat("dy", pv.dest.y);
      }
    }
    // done with shapes
  }

  println("CREATED XML:");
  println(configXML.toString());
}



//
// Read configuration XML file, create shapes from it
//

boolean readConfigXML()
{
  println("READING XML CONFIG FROM: " + CONFIG_FILE_NAME);

  BufferedReader reader = null;

  reader = createReader(CONFIG_FILE_NAME);

  // open XML file  
  //configXML = new XML (this, CONFIG_FILE_NAME);

  if (reader != null)
  {
    resetAllData();

    configXML = new XML (reader);
    XML shapeNodes[] = configXML.getChildren("shapes/shape");

    println("XML: Found " + shapeNodes.length + " shape nodes");

    //
    // HANDLE SHAPES
    //   
    for (int i=0; i < shapeNodes.length; ++i)
    {
      XML shapeNode = shapeNodes[i];

      // 1. create new shape
      // 2. assign media by name
      // 3. add vertices

      String mediaType = shapeNode.getString("mediaType");
      String mediaPath = shapeNode.getString("mediaPath");
      String shapeName = shapeNode.getString("name");

      // debug
      println("["+i+"]: shape[" + shapeName + " :: mediaPath:" + mediaPath + " :: mediaType:" + mediaType+"**");

      ProjectedShape newShape = null;

      if (mediaType.equals(XML_MEDIA_MOVIE_TYPE))
      {
        println("FOUND MOVIE!");

        if (mediaPath != "")
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
          newShape = addNewShape(movie);

          // finally, add to keyed array for this shape
          sourceMovies.put(newShape, movie);
        }
        else
        {
          newShape = addNewShape(blankImage);
        }
      }

      else if (mediaType.equals(XML_MEDIA_IMAGE_TYPE))
      {
        println("FOUND IMAGE!");

        PImage sourceImage = blankImage;

        if (mediaPath != "")
        {
          // load and add to HashMap of <path,PImage>
          sourceImage = loadImageIfNecessary(mediaPath);
        }
        newShape = addNewShape(sourceImage);
      }

      else if (mediaType.equals(XML_MEDIA_OTHER_TYPE))
      {
        println("FOUND OTHER!");

        // in this case dynamic graphics are loaded once at the start and stay loaded,
        // so we just look it up in the hashmap:
        DynamicGraphic sd = sourceDynamic.get(mediaPath);

        newShape = addNewShape(sd);
        newShape.srcColor = color(random(0, 255), random(0, 255), random(0, 255), 180);
        newShape.dstColor = newShape.srcColor;
        newShape.blendMode = ADD;
      }


      if (newShape == null)
      {
        println("ERROR:::creating shape failed!");
        return false;
      }

      // load verts
      XML vertsNode = shapeNode.getChild("vertices");
      //int numVertNodes = vertsNode.getChildCount();

      XML vertexNodes[] = vertsNode.getChildren("vertex");

      println("XML: Found " + vertexNodes.length + " verts");
      print(" :: (should be " + vertsNode.getString("count") + ")");

      for (int v=0; v < vertexNodes.length; ++v)
      {
        XML vertNode = vertexNodes[v];
        newShape.addVert(vertNode.getFloat("sx"), vertNode.getFloat("sy"), 
        vertNode.getFloat("dx"), vertNode.getFloat("dy"));
      }

      // done with each shape node
      //done with all shapes
      // done with xml root
    }
    // DONE LOADING XML
  }
  else
  {
    println("FAILED OPENING CONFIG FILE! Bad name?? Check it:" + CONFIG_FILE_NAME);
  }

  return (reader != null);
}

