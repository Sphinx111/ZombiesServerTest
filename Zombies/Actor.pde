import org.jbox2d.dynamics.contacts.ContactEdge;

class Actor {
  
  boolean isPlayer = false; //is this the player's character
  Team myTeam; // which team this actor is assigned to
  float myRadius; // radius in pixels
  Type myType; //type of actor
  ArrayList<ItemType> myItems = new ArrayList<ItemType>();
  Weapon myWeapon = null; //weapon held by this actor
  color myColor;
  int playerID;
  int actorID;
  
  float maxSightRange = 1000; //max range in pixels that player can see.
  float FOV = PI/2; //angle player can see in Radians;
  float accel = 300;
  float maxSpeed = 30;
  float health = 100;
  
  int bittenTime = -1;
  int biteDelay = 10; // should be just enough time for players to see the spread of infection through a clustered mass of players.
  
  Body body; //The actor's physics simulation body.
  float humanSightRange = 500; //range at which AIs will see and engage zombies.
  
  Actor targetZombie = null; //making sure variable is initialized for AI Behaviour checks.
  
  public Actor(Vec2 pos, boolean isPlayer, Team team, Type type, int id) {
    this.isPlayer = isPlayer;
    playerID = id;
    myTeam = team;
    if (myTeam == Team.ZOMBIE) {
      myColor = color(myTeam.ZOMBIE_COLOR[0],myTeam.ZOMBIE_COLOR[1],myTeam.ZOMBIE_COLOR[2]);
    } else if (myTeam == Team.HUMAN) {
      myColor = color(myTeam.HUMAN_COLOR[0], myTeam.HUMAN_COLOR[1], myTeam.HUMAN_COLOR[2]);
      myWeapon = new Weapon(WeaponType.HANDGUN);
      myItems.add(ItemType.ITEM_HANDGUN);
    } else {
      myColor = color(myTeam.NEUTRAL_COLOR[0],myTeam.NEUTRAL_COLOR[1],myTeam.NEUTRAL_COLOR[2]);
    }
    myType = type;
    if (myType == Type.SOLDIER) {
      myRadius = myType.SOLDIER_RADIUS;
      health = myType.SOLDIER_HEALTH;
      accel = myType.SOLDIER_ACCEL;
      maxSpeed = myType.SOLDIER_MAXSPEED;
      maxSightRange = myType.SOLDIER_MAXSIGHTRANGE;
      FOV = myType.SOLDIER_FOV;
    } else if (myType == Type.BIG_ZOMBIE) {
      myRadius = myType.BIGZOMBIE_RADIUS;
      health = myType.BIGZOMBIE_HEALTH;
      accel = myType.SOLDIER_ACCEL * myType.BIGZOMBIE_ACCEL_MULTIPLIER;
      maxSpeed = myType.SOLDIER_MAXSPEED * myType.BIGZOMBIE_MAXSPEED_MULTIPLIER;
      maxSightRange = myType.BIGZOMBIE_MAXSIGHTRANGE;
      FOV = myType.BIGZOMBIE_FOV;
    } else if (myType == Type.BASIC_ZOMBIE) {
      myRadius = myType.ZOMBIE_RADIUS;
      maxSpeed = myType.SOLDIER_MAXSPEED * myType.ZOMBIE_MAXSPEED_MULTIPLIER;
      accel = myType.SOLDIER_ACCEL * myType.ZOMBIE_ACCEL_MULTIPLIER;
      health = myType.ZOMBIE_HEALTH;
      maxSightRange = myType.ZOMBIE_MAXSIGHTRANGE;
      FOV = myType.ZOMBIE_FOV;
    }
    
    makeBody(pos, myRadius);
    System.out.println("New player created!");
  }
  
  void applyForce(Vec2 force) {
    body.applyForceToCenter(force);
  }
  
  boolean hasItem(ItemType item) {
    if (myItems.contains(item)) {
      return true;
    } else {
      return false;
    }
  }
  
  void addItem(ItemType item) {
    if (item == ItemType.ITEM_RIFLE) {
      myWeapon = null;
      myWeapon = new Weapon(WeaponType.RIFLE);
      myItems.add(ItemType.ITEM_RIFLE);
      System.out.println("I've been given a Rifle!");
    }
  }
  
  void move(Vec2 dir) {
    this.applyForce(dir.mul(accel));
    
    //if the new speed is greater than the maxspeed, scale it down to maxspeed.
    Vec2 newVel = body.getLinearVelocity();
    if (newVel.length() > maxSpeed) {
      body.setLinearVelocity(new Vec2(newVel.mul(maxSpeed/newVel.length())));
    }
  }
  
  /*void turnTowards(Vec2 pixPos) {
    Vec2 worldPos = box2d.coordPixelsToWorld(pixPos);
    Vec2 vecToMouse = worldPos.add(body.getPosition().mul(-1));
    float newAngle = PI/2 + (float)Math.atan2(vecToMouse.y,vecToMouse.x);
    body.setTransform(body.getWorldCenter(), newAngle);
    body.setAngularVelocity(0);
  }*/
  
  void shoot() {
    if (myWeapon != null) {
      myWeapon.shoot(this, this.body.getAngle());
    }
  }
  
  void setAngle(float angle) {
    body.setTransform(body.getWorldCenter(),angle);
    body.setAngularVelocity(0);
  }
  
  void update() {
    //next two lines set body to face direction of travel (although this is not what the final version needs).
    //float newAngle = (float) Math.atan2((double) body.getLinearVelocity().y, (double) body.getLinearVelocity().x); 
    //body.setTransform(body.getWorldCenter(), newAngle - ((float)Math.PI)/2.0f);
    if (health < 0) {
      actorControl.removeActor(this);
    }
    if (myWeapon != null) {
      myWeapon.update();
    }
    
    for (ContactEdge ce = body.getContactList(); ce != null; ce = ce.next) {
      Object other = ce.other.getUserData();
      if (other instanceof Actor) {
        Actor stranger = (Actor)other;
        if (myTeam == Team.HUMAN && stranger.myTeam == Team.ZOMBIE && bittenTime == -1) {
          bittenTime = frameCount;
        }
      }
    }
    if (bittenTime != -1 && frameCount > bittenTime + biteDelay) {
      myTeam = Team.ZOMBIE;
      myWeapon = null;
      myColor = color(myTeam.ZOMBIE_COLOR[0], myTeam.ZOMBIE_COLOR[1], myTeam.ZOMBIE_COLOR[2]);
      myType = Type.BASIC_ZOMBIE;
      health = myType.ZOMBIE_HEALTH;
      accel = myType.SOLDIER_ACCEL * myType.ZOMBIE_ACCEL_MULTIPLIER;
      maxSpeed = myType.SOLDIER_MAXSPEED * myType.ZOMBIE_MAXSPEED_MULTIPLIER;
      maxSightRange = myType.ZOMBIE_MAXSIGHTRANGE;
      FOV = myType.ZOMBIE_FOV;
        if (isPlayer) {
          mainCamera.screenShake(50);
        }
      bittenTime = -1;
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
      rect(0, 0, myRadius, myRadius);
      if (myTeam == Team.ZOMBIE) {
        pushMatrix();
        translate(myRadius/2,(myRadius/4));
        rect(0,0,myRadius/4,myRadius);
        popMatrix();
        pushMatrix();
        translate(-myRadius/2,(myRadius/4));
        rect(0,0,myRadius/4,myRadius);
        popMatrix();
      }
      if (myTeam == Team.HUMAN && myType == Type.SOLDIER) {
        rect(0,myRadius/2,0,myRadius/2);
      }
      popMatrix();
  }
  
  void wasHit(Vec2 force, int damage) {
    this.applyForce(force);
    health -= damage;
  }
  
  void makeBody(Vec2 pos, float radius) {
    
    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dr = box2d.scalarPixelsToWorld(radius/2);
    sd.setAsBox(box2dr,box2dr);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    if (myType == Type.BIG_ZOMBIE) {
      fd.density = myType.BIGZOMBIE_DENSITY;
    }
    fd.friction = 0;
    if (!isPlayer) {
      fd.friction = -0.2;
    }
    fd.restitution = 0.05;
    
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(pos));

    body = box2d.createBody(bd);
    body.setAngularDamping(0.5);
    body.setLinearDamping(8);
    Fixture fix = body.createFixture(fd);
    body.setUserData(this);
    fix.setUserData(this);
  }
  
  Vec2 playerOffset;
  
  void runBehaviour() {
    if (!isPaused && !creatorMode) {
      if (myTeam == Team.ZOMBIE) {
        //This function carries out the default AI behaviour.
        boolean seekingTarget = true;
        float chanceOfSelecting = 1/totalHumanPlayers;
        Actor targetHuman = actorControl.player;
        if (targetHuman.myTeam == Team.ZOMBIE) {
          seekingTarget = true;
        }
        int maxTargetLoops = 40;
        int i = 0;
        while (seekingTarget) {
          for (Actor a : actorControl.actorsInScene) {
            if (a.myTeam == Team.HUMAN) {
              if (Math.random() < chanceOfSelecting) {
                targetHuman = a;
                seekingTarget = false;
              }
            }
          }
          i++;
          if (i > maxTargetLoops) {
            chanceOfSelecting = 1;
          }
          if (i > maxTargetLoops + 5) {
            break;
          }
        }
        Vec2 target = targetHuman.body.getWorldCenter();
        Vec2 directionToTarget = target.add(body.getWorldCenter().mul(-1));
        Vec2 moveToTarget = directionToTarget.mul(1/directionToTarget.length());
        float distToTarget = box2d.scalarWorldToPixels(directionToTarget.length());
        if (distToTarget < 300 && Math.random() < 0.001 && targetHuman == actorControl.player) {
          float volume = (300 - distToTarget) / 300;
          soundManager.triggerSound("zombie_moan", volume);
        }
        float newAngle = (float) Math.atan2((double)directionToTarget.y, (double)directionToTarget.x) + (PI/2);
        body.setTransform(body.getWorldCenter(),newAngle);
        body.setAngularVelocity(0);
        float moveChance = 1;
        if (targetHuman.myTeam == Team.HUMAN) {
          moveChance = 1;
        } else {
          moveChance = 0.1;
        }
        if ((float)Math.random() <= moveChance) {
          move(moveToTarget);
        }
      } else if (myTeam == Team.HUMAN) {
        //move roughly towards player
        if (playerOffset == null) {
          float radiansOffset = (float)Math.random() * 2 * PI;
          playerOffset = new Vec2(2.5 * (float)Math.sin(radiansOffset), 2.5 * (float)Math.cos(radiansOffset));
        }
        Vec2 moveTarget = actorControl.player.body.getWorldCenter().add(playerOffset);
        Vec2 directionToTarget = moveTarget.add(body.getWorldCenter().mul(-1));
        
        //debug draw moveTarget
        Vec2 pixMoveTarget = box2d.coordWorldToPixels(moveTarget);
        Vec2 bodyPos = box2d.coordWorldToPixels(body.getWorldCenter());
        Vec2 moveVecResult = box2d.coordWorldToPixels(body.getWorldCenter().add(directionToTarget));
        strokeWeight(1);
        stroke(0,0,255);
        line(bodyPos.x,bodyPos.y,pixMoveTarget.x,pixMoveTarget.y);
        strokeWeight(5);
        point(pixMoveTarget.x,pixMoveTarget.y);
        stroke(0,255,0);
        strokeWeight(1);
        line(bodyPos.x,bodyPos.y,moveVecResult.x,moveVecResult.y);
        
        
        
        directionToTarget.normalize();
        move(directionToTarget);
        
        //find and shoot at target
        boolean seekingTarget = true;
        float chanceOfSelecting = 1/(numOfActors - totalHumanPlayers);
        if (targetZombie == null) {
          seekingTarget = true;
        }
        int maxTargetLoops = 40;
        int i = 0;
        while (seekingTarget) {
          for (Actor a : actorControl.actorsInScene) {
            if (a.myTeam == Team.ZOMBIE) {
              if (Math.random() < chanceOfSelecting) {
                targetZombie = a;
                seekingTarget = false;
              }
            }
          }
          i++;
          if (i > maxTargetLoops) {
            chanceOfSelecting = 1;
          } 
          if (i > maxTargetLoops + 5) {
            break;
          }
        }        
        if (targetZombie == null) {
          targetZombie = actorControl.player;
        }
        Vec2 directionToTargetShoot = targetZombie.body.getWorldCenter().add(body.getWorldCenter().mul(-1));
        float distanceToTargetShoot = box2d.scalarWorldToPixels(directionToTarget.length());
        float newAngle = (float) Math.atan2((double)directionToTargetShoot.y, (double)directionToTargetShoot.x) + (PI/2);
        body.setTransform(body.getWorldCenter(),newAngle);
        body.setAngularVelocity(0);
        if (distanceToTargetShoot <= humanSightRange) {
          shoot();
        }
      }
    }
    
  }
  
}
