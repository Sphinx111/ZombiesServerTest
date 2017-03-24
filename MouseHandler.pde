import org.jbox2d.collision.AABB;
import org.jbox2d.callbacks.QueryCallback;

class MouseHandler {
  Vec2 firstClick;
  Vec2 releasePoint;
  Vec2 thirdClick;
  BlockType currentType = BlockType.FIXED;
  boolean holdClick = false;
  boolean readyForStageOne = true;
  boolean readyForStageTwo = false;
  boolean readyForStageThree = false;
  boolean readyForDoorLink = false;
  
  MapObject lastCreatedMapObject;
  MapObject doorToEdit;
  QueryCaller queryCaller;
  
  public MouseHandler() {
    queryCaller = new QueryCaller();
  }
  
  void mouseInCheck() {
    if (mouseButton == LEFT) {
      if (mouseX > uiLayer.uiPanelX && mouseY < uiLayer.uiPanelY + uiLayer.uiPanelHeight || (mouseX > uiLayer.uiActiveXMin && mouseX < uiLayer.uiActiveXMax && mouseY > uiLayer.uiActiveYMin && mouseY < uiLayer.uiActiveYMax)) {
          currentType = uiLayer.getClickedType(currentType);
          //get selections from any active UI windows.
          
      } else { 
        if (creatorMode) {
          //Do one thing if in FIXED, SENSOR, or DOOR MODE
          if (currentType == BlockType.FIXED || currentType == BlockType.SENSOR && !readyForDoorLink) {
            if (readyForStageOne) {
              firstClick = new Vec2(box2d.scalarPixelsToWorld(newMouseX-(width/2)), box2d.scalarPixelsToWorld(newMouseY-(height/2)));
              readyForStageOne = false;
              readyForStageTwo = true;
            } else if (readyForStageThree) {
              thirdClick = new Vec2(box2d.scalarPixelsToWorld(newMouseX-(width/2)), box2d.scalarPixelsToWorld(newMouseY-(height/2)));
              lastCreatedMapObject = mapHandler.createMapObjectByMouse(firstClick,releasePoint,thirdClick, currentType);
              firstClick = null;
              releasePoint = null;
              thirdClick = null;
              readyForStageOne = true;
              readyForStageTwo = false;
              readyForStageThree = false;
              if (currentType == BlockType.SENSOR && lastCreatedMapObject != null) {
                readyForDoorLink = true;
              }
            }
          //OR if in Actor mode, create an actor instead.
          } if (readyForDoorLink) {
            MapObject doorUnderMouse = getMapObjectUnderMouse(BlockType.DOOR,BlockType.DOOR);//call objundermousefunc
            if (doorUnderMouse != null) {
              lastCreatedMapObject.linkedDoorID = doorUnderMouse.myID;
              lastCreatedMapObject.linkToDoor(doorUnderMouse);
              doorUnderMouse.myColor = doorUnderMouse.LINKED_DOOR_COLOR;
              readyForDoorLink = false;
            }
          } else if (currentType == BlockType.DOOR) {
            if (doorToEdit == null) {
              doorToEdit = getMapObjectUnderMouse(BlockType.DOOR, BlockType.FIXED);
              if (doorToEdit != null) {
                if (doorToEdit.myType == BlockType.FIXED) {
                  Vec2 newPos = doorToEdit.body.getPosition();
                  float wide = box2d.scalarPixelsToWorld(doorToEdit.pixWidth);
                  float tall = box2d.scalarPixelsToWorld(doorToEdit.pixHeight);
                  float newAngle = doorToEdit.body.getAngle();
                  int newID = doorToEdit.myID;
                  mapHandler.createMapObjectFromCopy(newPos,wide,tall,newAngle,BlockType.DOOR,newID);
                  mapHandler.removeObject(doorToEdit);
                  doorToEdit = null;
                }
              }
            } else {
              Vec2 mousePos = new Vec2(newMouseX,newMouseY);
              doorToEdit.doorOpenPos = box2d.coordPixelsToWorld(mousePos);
              doorToEdit = null;
            }
            
          } else {
            //actor creation mode
          }
        } else {
          holdClick = true;
        }
      }
    } else if (mouseButton == RIGHT) {
      if (readyForDoorLink) {
        mapHandler.removeObject(lastCreatedMapObject);
        lastCreatedMapObject = null;
        readyForDoorLink = false;
      }
    }
  }
 
  
  MapObject getMapObjectUnderMouse(BlockType desiredType,BlockType alternateType) {
    stroke(255);
    strokeWeight(15);
    Vec2 pixPos = new Vec2(newMouseX - 0.5, newMouseY - 0.5);
    Vec2 clickPos = box2d.coordPixelsToWorld(pixPos);
    point(pixPos.x,pixPos.y);
    Vec2 boundingBox = new Vec2(1,1);
    MapObject result = null;
     AABB checkArea = new AABB(clickPos,clickPos.add(boundingBox));
     box2d.world.queryAABB(queryCaller,checkArea);
     for (Fixture f : queryCaller.allFixtures) {
       if (f.testPoint(clickPos)) {
         Object other = f.getUserData();
         if (other instanceof MapObject) {
           MapObject stranger = (MapObject)other;
           if (stranger.myType == desiredType || stranger.myType == alternateType) {
             result = stranger;
             stroke(0);
             point(newMouseX - (width/2),newMouseY - (height/2));
           }
        }
      }
    }
    queryCaller.allFixtures.clear();
    return result;
  }
  
  void mouseOutCheck() {
    if (creatorMode) {
      if (readyForStageTwo) {
        releasePoint = new Vec2(box2d.scalarPixelsToWorld(newMouseX-(width/2)), box2d.scalarPixelsToWorld(newMouseY-(height/2)));
        if (releasePoint.add(firstClick.mul(-1)).length() < box2d.scalarPixelsToWorld(2)) {
          releasePoint = null;
          firstClick = null;
          readyForStageOne = true;
          readyForStageTwo = false;
        } else { 
          readyForStageTwo = false;
          readyForStageThree = true;
        }
      }
    }
    holdClick = false;
  }
  
  void show() {
    if (creatorMode) {
      if (readyForStageTwo) {
        stroke(255);
        strokeWeight(1);
        fill(255);
        text("Drawing something in MouseHandler", 10,20);
        line(box2d.scalarWorldToPixels(firstClick.x)+(width/2),box2d.scalarWorldToPixels(firstClick.y)+(height/2),newMouseX,newMouseY);
      } else if (readyForStageThree && thirdClick == null) {
        stroke(255);
        strokeWeight(1);
        Vec2 currentMouseWorld = new Vec2(box2d.scalarPixelsToWorld(newMouseX-(width/2)), box2d.scalarPixelsToWorld(newMouseY-(height/2)));
        float widthVectorLength = releasePoint.add(currentMouseWorld.mul(-1)).length();
        float projectedWidth = box2d.scalarWorldToPixels(widthVectorLength);
        strokeWeight(projectedWidth);
        line(box2d.scalarWorldToPixels(firstClick.x)+(width/2),box2d.scalarWorldToPixels(firstClick.y)+(height/2),box2d.scalarWorldToPixels(releasePoint.x)+(width/2),box2d.scalarWorldToPixels(releasePoint.y)+(height/2));
        strokeWeight(1);
      } else if (readyForDoorLink) {
        stroke(0,150,150);
        strokeWeight(1);
        Vec2 origin = box2d.coordWorldToPixels(lastCreatedMapObject.body.getPosition());
        line(origin.x,origin.y, newMouseX,newMouseY);
      } else if (doorToEdit != null) {
        Vec2 pixPos = new Vec2(newMouseX,newMouseY);
        float angle = doorToEdit.body.getAngle();
      
        rectMode(CENTER);
        pushMatrix();
        translate(pixPos.x, pixPos.y);
        rotate(-angle);
        noFill();
        stroke(255);
        strokeWeight(2);
        rect(0, 0, doorToEdit.pixWidth, doorToEdit.pixHeight);
        popMatrix(); 
      }
    }
  }
  
  void update() {
    newMouseX = mouseX - mainCamera.xOff;
    newMouseY = mouseY - mainCamera.yOff;
    
    actorControl.player.turnTowards(new Vec2(newMouseX,newMouseY));
    if (holdClick && !isPaused) {
      actorControl.player.shoot();
    }
    
    fill(255);
    text(mouseX + "," + mouseY,0,0);
    
    if (!creatorMode) {
      firstClick = null;
      releasePoint = null;
      thirdClick = null;
      readyForStageOne = true;
      readyForStageTwo = false;
      readyForStageThree = false;
    }
  }
  
  class QueryCaller implements QueryCallback{
    
    ArrayList<Fixture> allFixtures = new ArrayList<Fixture>();
    
    boolean reportFixture(Fixture fix) {
      if (!allFixtures.contains(fix)) {
        allFixtures.add(fix);
      }
      return true;
    }
    
    
  }
  
}