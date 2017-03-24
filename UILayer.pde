class UILayer {

  ArrayList<String> strings = new ArrayList<String>();
  float x = width - 100;
  float y = 20;
  float yDiff = 10;
  float uiPanelX = width - 120;
  float uiPanelY = 0;
  float uiPanelHeight = 120;
  float uiPanelWidth = 120;
  
  int numOfButtons = 4; 
  float buttonStartX = 0; //start pos for buttons relative to UI window
  float buttonStartY = 40; //start pos for buttons relative to UI window.
  float buttonWidth = 80;
  float buttonXDiff = 0;
  float buttonYDiff = 20;
  
  float uiActiveXMin = 0;
  float uiActiveXMax = 0;
  float uiActiveYMin = 0;
  float uiActiveYMax = 0;
  
  void showText(String textToShow,float x, float y) {
    strings.add(textToShow);
  }
  
  void show() {
    pushMatrix();
    translate(-mainCamera.xOff,-mainCamera.yOff);
    showUIButtons();
    int i = 0;
    for (String s : strings) {
      fill(255);
      float newY = y + (yDiff * i); 
      text(s, x, newY);
      i++;
    }
    strings.clear();
    popMatrix();
  }
  
  void createUIElement(float mouseX,float mouseY, String type) {
    //this method is called from mouseHandler when editing the map. Should open a uiPanel that lets the player edit the information of the block being placed/selected.
    
  }
  
  void showUIButtons() {
   
    rectMode(CORNER);
    fill(100);
    rect(uiPanelX,uiPanelY,uiPanelWidth,uiPanelHeight); // draws panel for UI elements
    textSize(12);
    
    for (int i = 0; i < numOfButtons; i++) {
      String buttonText;
      if (i == 0) {
        buttonText = "FIXED";
      } else if (i == 1) {
        buttonText = "SENSOR";
      } else if (i == 2) {
        buttonText = "DOOR";
      } else {
        buttonText = "ACTOR";
      }
      float newX = uiPanelX + buttonStartX + (i * buttonXDiff);
      float newY = uiPanelY + buttonStartY + (i * buttonYDiff);
      noFill();
      stroke(0);
      strokeWeight(1);
      rect(newX,newY,buttonWidth,buttonYDiff);
      fill(255);
      text(buttonText, newX + 2, newY + (buttonYDiff/2));
    }
    String activeType = BlockType.getString(mouseHandler.currentType);
    text(activeType, uiPanelX + buttonStartX, buttonStartY - 2);
    rectMode(CENTER);
    
  }
  
  BlockType getClickedType(BlockType current) {
    if (mouseX < uiPanelX + buttonWidth) {
      if (mouseY < uiPanelY + buttonStartY + buttonYDiff) {
        return BlockType.FIXED;
      } else if (mouseY < uiPanelY + buttonStartY + (2 * buttonYDiff)) {
        return BlockType.SENSOR;
      } else if (mouseY < uiPanelY + buttonStartY + (3 * buttonYDiff)) {
        return BlockType.DOOR;
      } else if (mouseY < uiPanelY + buttonStartY + (4 * buttonYDiff)) {
        return BlockType.ACTOR;
      } else {
        return current;
      }
    }
    else {
      return current;
    }
  }
  
}