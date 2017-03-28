class MapObject implements Serializable {
 
  int myID;
  transient Body body; 
  transient Fixture myFix;
  BlockType myType;
  ItemType myItemType;
  float pixWidth;
  float pixHeight;
  Vec2 bodyPos;
  transient color myColor = color(100);
  transient public color DOOR_COLOR = color(50);
  transient public color LINKED_DOOR_COLOR = color (75);
  
  //if this object should be transmitted in full to a client this tick, all key variables will be updated.
  transient boolean fullTransmit = false;
  
  transient MapObject linkedDoor;
  transient int linkedDoorID = -1;
  transient int sensorTimeDelay = 60;
  transient int TIMER_NULL = 999999999;
  transient int timeButtonPressed = TIMER_NULL;
  transient boolean buttonPressed = false;
  transient Actor lastTouchedActor;
  
  transient boolean doorOpen = false;
  transient Vec2 doorOpenPos;
  transient Vec2 doorClosedPos;
  transient int doorOpenTime = 10; //currently doesn't define 'time' for opening.
  transient int doorCloseTime = 10; //
  transient boolean doorMoving = false;
  
  transient boolean endGameTrigger = false;
  
  public MapObject (Vec2 worldPosCenter, float worldWidth, float worldHeight, float angleOfRotation, BlockType type, int newID) {
    pixWidth = box2d.scalarWorldToPixels(worldWidth);
    pixHeight = box2d.scalarWorldToPixels(worldHeight);
    myType = type;
    if (myType == BlockType.NO_TYPE) {
      myType = BlockType.FIXED;
    }
    myID = newID;
    doorClosedPos = worldPosCenter;
    makeBody(worldPosCenter, worldWidth, worldHeight, angleOfRotation);
    
    if (myType == BlockType.SENSOR) {
      myColor = color(100,0,0);
    } else if (myType == BlockType.DOOR) {
      myColor = color(50);
    }
  }
  
  //overloaded creation method for creating ItemTypes instead of normal MapObjects.
  public MapObject (Vec2 worldPosCenter, float worldWidth, float worldHeight, float angleOfRotation, ItemType type, int newID) {
    pixWidth = box2d.scalarWorldToPixels(worldWidth);
    pixHeight = box2d.scalarWorldToPixels(worldHeight);
    myType = BlockType.ITEM;
    myItemType = type;
    myID = newID;
    doorClosedPos = worldPosCenter;
    myColor = color(120,120,255);
    makeBody(worldPosCenter, worldWidth, worldHeight, angleOfRotation);
    
  }
    
  void linkToDoor (MapObject linkedDoor) {
    if (linkedDoor.myType == BlockType.DOOR) {
      if (myType == BlockType.SENSOR) {
        this.linkedDoor = linkedDoor;
      }
    } else if (linkedDoor.myType == BlockType.SENSOR) {
      myColor = color(150,150,90);
      endGameTrigger = true;
    }
  }
  
  void setTimerDelay(int newDelay) {
    this.sensorTimeDelay = newDelay;
  }
  
  Boolean checkSensorCollision() {
    for (ContactEdge ce = body.getContactList(); ce != null; ce = ce.next) {
      Object other = ce.other.getUserData();
      if (other instanceof Actor) {
        Actor stranger = (Actor)other;
        lastTouchedActor = stranger;
        if (stranger.myTeam == Team.HUMAN) {
          return true;
        }
      }
    }
    return false;
  }
  
  void pressButton() {
    if (!buttonPressed) {
      timeButtonPressed = frameCount;
      buttonPressed = true;
    }
  }
  
  void buttonActivateIfDelayDone() {
    if (myType == BlockType.SENSOR) {
      if (frameCount > timeButtonPressed + sensorTimeDelay) {
        if (linkedDoor != null) {
          linkedDoor.openDoor();
          buttonPressed = false;
        }
      }
    }
  }
  
  void openDoor() {
    if (doorOpenPos != null) {
      Vec2 openDirection = doorOpenPos.add(body.getPosition().mul(-1));
      if (!doorMoving && !doorOpen) {
        openDirection.mul(1/doorOpenTime);
        body.setLinearVelocity(openDirection);
        doorMoving = true;
      }
    } else {
      myType = BlockType.FIXED;
      myColor = color(100);
    }
  }
  
  void prepareToSerialize() {
    bodyPos = body.getWorldCenter();
  }
  
  void checkDoorMovement() {
    if (doorMoving && !doorOpen) {
      Vec2 openDirection = doorOpenPos.add(body.getPosition().mul(-1));
      float distToOpen = openDirection.length();
      if (distToOpen < 0.2) {
        body.setLinearVelocity(new Vec2(0,0));
        doorOpen = true;
        doorMoving = false;
      }
    }
    if (doorMoving && doorOpen) {
      Vec2 closeDirection = doorClosedPos.add(body.getPosition().mul(-1));
      float distToClosed = closeDirection.length();
      if (distToClosed < 0.2) {
        body.setLinearVelocity(new Vec2(0,0));
        doorOpen = false;
        doorMoving = false;
      }
    }
  }
  
  void closeDoor() {
    Vec2 closeDirection = doorClosedPos.add(body.getPosition().mul(-1));
    if (!doorMoving && doorOpen) {
      closeDirection.mul(1/doorCloseTime);
      body.setLinearVelocity(closeDirection);
    }
  }
  
  
  void makeBody(Vec2 pos, float worldWidth, float worldHeight, float angleOfRotation) {
    
    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    sd.setAsBox(worldWidth/2,worldHeight/2);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0;
    fd.restitution = 0.05;
    if (myType == BlockType.SENSOR || myType == BlockType.ITEM) {
      fd.isSensor = true;
    } else {
      fd.isSensor = false;
    }
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    if (myType == BlockType.FIXED) {
      bd.type = BodyType.STATIC;
    } else if (myType == BlockType.SENSOR || myType == BlockType.ITEM) {
      bd.type = BodyType.DYNAMIC;
    } else if (myType == BlockType.DOOR) {
      bd.type = BodyType.KINEMATIC;
    }
    bd.position.set(pos);

    body = box2d.createBody(bd);
    body.setTransform(body.getWorldCenter(), angleOfRotation);
    myFix = body.createFixture(fd);
    body.setUserData(this);
    myFix.setUserData(this);
  }
  
  void update() {
    if (myType == BlockType.SENSOR) {
      buttonActivateIfDelayDone();
    }
    if (myType == BlockType.SENSOR || myType == BlockType.ITEM) {
      if (checkSensorCollision()) {
        if (myType == BlockType.ITEM) {
          if (!lastTouchedActor.hasItem(myItemType)) {
            lastTouchedActor.addItem(myItemType);
            mapHandler.removeObject(this);
          }
        } else {
          pressButton();
        } 
        if (endGameTrigger) {
          gameStateManager.endGameBySensor();
        }
      }
    } else if (myType == BlockType.DOOR) {
      checkDoorMovement();
    }
    if (fullTransmit) {
      prepareToSerialize();
    }
  }
  
  void show() {
    
      Vec2 pixPos = box2d.getBodyPixelCoord(body);
      float angle = body.getAngle();
      
      rectMode(CENTER);
      pushMatrix();
      translate(pixPos.x, pixPos.y);
      rotate(-angle);
      fill(myColor);
      stroke(0);
      strokeWeight(1);
      rect(0, 0, pixWidth, pixHeight);
      popMatrix();
  }
  
  
}