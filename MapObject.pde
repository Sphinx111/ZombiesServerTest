class MapObject {
 
  int myID;
  Body body; 
  Fixture myFix;
  BlockType myType;
  float pixWidth;
  float pixHeight;
  color myColor = color(100);
  public color DOOR_COLOR = color(50);
  public color LINKED_DOOR_COLOR = color (75);
  
  MapObject linkedDoor;
  int linkedDoorID = -1;
  int sensorTimeDelay = 60;
  int TIMER_NULL = 999999999;
  int timeButtonPressed = TIMER_NULL;
  boolean buttonPressed = false;
  
  boolean doorOpen = false;
  Vec2 doorOpenPos;
  Vec2 doorClosedPos;
  int doorOpenTime = 10; //currently doesn't define 'time' for opening.
  int doorCloseTime = 10; //
  boolean doorMoving = false;
  
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
  
  void linkToDoor (MapObject linkedDoor) {
    if (myType == BlockType.SENSOR) {
      this.linkedDoor = linkedDoor;
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
        linkedDoor.openDoor();
        buttonPressed = false;
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
    if (myType == BlockType.SENSOR) {
      fd.isSensor = true;
    }
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    if (myType == BlockType.FIXED) {
      bd.type = BodyType.STATIC;
    } else if (myType == BlockType.SENSOR) {
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
      if (checkSensorCollision()) {
        pressButton();
      }
      buttonActivateIfDelayDone();
    } else if (myType == BlockType.DOOR) {
      checkDoorMovement();
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