import org.jbox2d.dynamics.World;

class Weapon {
  //This class will hold data about the type of weapon the player is holding, which define's their attack options.
  WeaponType myType;
  int damage;
  float pushback;
  float range;
  float maxSpread;
  int fireDelay;
  int lastFired = 0;
  int defaultRounds;
  int roundsInMagazine;
  int reloadDelay;
  boolean isReloading = false;
  int reloadCounter = 0;
  String rifleSound;
  
  RayCastDetector rayDetect;
  SoundManager mySoundManager;
  
  public Weapon(WeaponType type) {
    rayDetect = new RayCastDetector();
    mySoundManager = new SoundManager(parentApplet, "gunshot");
    
    if (type == WeaponType.RIFLE) {
      damage = type.RIFLE_DAMAGE;
      pushback = type.RIFLE_PUSHBACK;
      range = type.RIFLE_RANGE;
      maxSpread = type.RIFLE_MAXSPREAD;
      fireDelay = type.RIFLE_FIREDELAY;
      defaultRounds = type.RIFLE_MAGAZINESIZE;
      reloadDelay = type.RIFLE_RELOADTIME;
      rifleSound = type.RIFLE_SOUND;
    } else if (type == WeaponType.HANDGUN) {
      damage = type.HANDGUN_DAMAGE;
      pushback = type.HANDGUN_PUSHBACK;
      range = type.HANDGUN_RANGE;
      maxSpread = type.HANDGUN_MAXSPREAD;
      fireDelay = type.HANDGUN_FIREDELAY;
      defaultRounds = type.HANDGUN_MAGAZINESIZE;
      reloadDelay = type.HANDGUN_RELOADTIME;
      rifleSound = type.HANDGUN_SOUND;
    }
    roundsInMagazine = defaultRounds;
  }
  
  void update() {
    if (isReloading) {
      reloadCounter -= 1;
    }
    if (isReloading & reloadCounter == 0) {
      roundsInMagazine = defaultRounds;
      isReloading = false;
    }
    if (!isReloading && roundsInMagazine == 0) {
      isReloading = true;
      reloadCounter = reloadDelay;
    }
    fill(255);
    uiLayer.showText("rounds Left: " + roundsInMagazine, width - 100, 20);
  }
  
  void reload() {
    if (roundsInMagazine > 0) {
      isReloading = true;
      roundsInMagazine = 0;
      reloadCounter = reloadDelay;
    }
    
  }
  
  boolean canShoot() {
    if (frameCount > lastFired + fireDelay && roundsInMagazine > 0 && !isPaused) {
      return true;
    } else {
      return false;
    }
  }
  
  void shoot(Actor firer, float angle) {
    if (canShoot()) {
      //update firing information on weapon
      lastFired = frameCount;
      roundsInMagazine -= 1;
      
      //define a line for the raycast.
      angle = angle - (PI/2); // correct for "front" of player
      angle = angle - maxSpread + ((float)Math.random() * maxSpread * 2); //bulletSpread
      Vec2 origin = firer.body.getWorldCenter();
      Vec2 endPoint = new Vec2(origin.x + (box2d.scalarPixelsToWorld(range) * (float)Math.cos(angle)), origin.y + (box2d.scalarPixelsToWorld(range) * (float)Math.sin(angle)));
      //send out a raycast, which will be caught by the RayDetect object
      box2d.world.raycast(rayDetect, origin,endPoint);
      
      //tell main camera to apply screenShake
      //add sounds
      if (firer.isPlayer) {
        mainCamera.screenShake(5);
        mySoundManager.triggerSound(1);
      } else if (damage > 500) {
        mainCamera.screenShake(1);
        mySoundManager.triggerSound(2);
      } else {
        mySoundManager.triggerSound(0.5);
      }
      
      //draw line to the point hit
      strokeWeight(2);
      stroke(250,30,30);
      if (rayDetect.closestPointHit != null) {
        Vec2 bulletEnd = box2d.coordWorldToPixels(rayDetect.closestPointHit);
        Vec2 drawOrigin = box2d.coordWorldToPixels(origin);
        line(drawOrigin.x,drawOrigin.y,bulletEnd.x,bulletEnd.y);
        strokeWeight(15);
        stroke(240,240,0);
        point(bulletEnd.x,bulletEnd.y);
      } else {
        Vec2 drawOrigin = box2d.coordWorldToPixels(origin);
        Vec2 endPointPixels = box2d.coordWorldToPixels(endPoint);
        line(drawOrigin.x,drawOrigin.y,endPointPixels.x,endPointPixels.y);
      }
      
      //get object reference and apply a force and add damage to it;
      Object obj = rayDetect.closestObjectHit;
      if (obj != null && obj instanceof Actor) {
        Actor aHit = (Actor)obj;
        Vec2 vecToTarget = aHit.body.getPosition().add(origin.mul(-1));
        //vecToTarget.normalize();
        Vec2 forceToApply = vecToTarget.mul(pushback);
        aHit.wasHit(forceToApply,damage);
      }
      rayDetect.cleanup();
    }
  }
}
