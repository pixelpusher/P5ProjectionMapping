
ControlP5 gui;

import javax.swing.JFileChooser;
import javax.swing.SwingUtilities;

int guiX = 10;
int guiY = 40;

void initGUI()
{
  gui = new ControlP5(this);
  gui.addButton("buttonOpenFile", 0, 100, 100, 80, 19);
  gui.addDropdownList("AvailableImages", 90, 100, 100, 120);
  Slider slider = gui.addSlider("fx", 0.001f, 1f, 0.1f, guiX, guiY, 200, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fy", 0.001f, 1f, 0.1f, guiX, guiY, 200, 20);
  gui.hide();

}

void buttonOpenFile(int theValue)
{
  noLoop();
  
  loadImageFile();
   
  loop();
}

void AvailableImages(int val)
{
  DropdownList dl = (DropdownList)gui.getGroup("AvailableImages");
    //println(dl.getStringValue());
}

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
//    println(theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    
    DropdownList dl = (DropdownList)theEvent.getGroup();
    int i=0;
    int index = int(dl.value());
    
    // TODO: FINISH THIS
    // THIS SUCKS
    // controlP5 CAN BE A DIRTY WHORE
    
  } 
  else if (theEvent.isController()) {
    //println("controller");
    //println(theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}



String filename = null;

JFileChooser file_chooser = new JFileChooser();

void loadImageFile() {
  try {
    SwingUtilities. invokeLater(new Runnable() {
      public void run() {
 
        int return_val = file_chooser.showOpenDialog(null);
        if ( return_val == JFileChooser.CANCEL_OPTION )   System.out.println("canceled");
        if ( return_val == JFileChooser.ERROR_OPTION )    System.out.println("error");
        if ( return_val == JFileChooser.APPROVE_OPTION )  
        {
          System.out.println("approved");
        
          File file = file_chooser.getSelectedFile();
          filename = file.getAbsolutePath();
        } else {
          filename = "none";
        }
        if (filename != "none") loadImageIfNecessary(filename);
      }
    }
    );
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}


void loadXMLFile() {
  try {
    SwingUtilities. invokeLater(new Runnable() {
      public void run() {
 
        int return_val = file_chooser.showOpenDialog(null);
        if ( return_val == JFileChooser.CANCEL_OPTION )   System.out.println("canceled");
        if ( return_val == JFileChooser.ERROR_OPTION )    System.out.println("error");
        if ( return_val == JFileChooser.APPROVE_OPTION )  
        {
          System.out.println("approved");
        
          File file = file_chooser.getSelectedFile();
          filename = file.getAbsolutePath();
        } else {
          filename = "none";
        }
        if (filename != "none") 
        {
          CONFIG_FILE_NAME = filename;
          readConfigXML();
        }
      }
    }
    );
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}


void saveXMLFile() {
  try {
    SwingUtilities. invokeLater(new Runnable() {
      public void run() {
 
        int return_val = file_chooser.showSaveDialog(null);
        if ( return_val == JFileChooser.CANCEL_OPTION )   System.out.println("canceled");
        if ( return_val == JFileChooser.ERROR_OPTION )    System.out.println("error");
        if ( return_val == JFileChooser.APPROVE_OPTION )  
        {
          System.out.println("approved");
        
          File file = file_chooser.getSelectedFile();
          filename = file.getAbsolutePath();
        } else {
          filename = "none";
        }
        if (filename != "none") 
        {
          CONFIG_FILE_NAME = filename;

          println("Chose: " + CONFIG_FILE_NAME + " for saving");
          createConfigXML();
          writeMainConfigXML();
        }
      }
    }
    );
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}




