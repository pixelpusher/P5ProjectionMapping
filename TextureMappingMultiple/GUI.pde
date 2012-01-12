
ControlP5 gui;


void initGUI()
{
  gui = new ControlP5(this);
  gui.addButton("buttonOpenFile", 0, 100, 100, 80, 19);
  gui.addDropdownList("AvailableImages", 90, 100, 100, 120);
}

void buttonOpenFile(int theValue)
{
  String filename = selectInput("Choose an image to load:");
  if (filename != null)
  {
    loadImageIfNecessary(filename);
  }
}

void AvailableImages(int val)
{
  DropdownList dl = (DropdownList)gui.getGroup("AvailableImages");
    println(dl.getStringValue());
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
    println("controller");
    println(theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

