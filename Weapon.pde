import org.jbox2d.dynamics.World;

class Weapon {
  //This class will hold data about the type of weapon the player is holding, which define's their attack options.
  int damage = 5;
  float pushback = 25;
  float range = 1500;
  float maxSpread = 4 * (2 * PI / 360); //spread converted to radians.
  int fireDelay = 4;
  int lastFired = 0;
  int defaultRounds = 30;
  int roundsInMagazine = 30;
  int reloadDelay = 120;
  boolean isReloading = false;
  int reloadCounter = 0;
  
  RayCastDetector rayDetect;
  
  public Weapon() {
    rayDetect = new RayCastDetector();
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
      Vec2 origin = firer.body.getPosition();
      Vec2 endPoint = new Vec2(origin.x + (box2d.scalarPixelsToWorld(range) * (float)Math.cos(angle)), origin.y + (box2d.scalarPixelsToWorld(range) * (float)Math.sin(angle)));
      //send out a raycast, which will be caught by the RayDetect object
      box2d.world.raycast(rayDetect, origin,endPoint);
      
      //tell main camera to apply screenShake
      //add sounds
      if (firer.isPlayer) {
        mainCamera.screenShake(5);
        soundManager.triggerSound("gunshot",1);
      } else if (damage > 500) {
        mainCamera.screenShake(1);
      } else {
        soundManager.triggerSound("gunshotOther",0.5);
      }
      
      //draw line to the point hit
      strokeWeight(2);
      stroke(250,30,30);
      if (rayDetect.pointHit != null) {
        Vec2 bulletEnd = box2d.coordWorldToPixels(rayDetect.pointHit);
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
      
      
      if (rayDetect.targetFixtureHit != null) {
        //Find out what type of Fixture was hit
        Fixture fixHit = rayDetect.targetFixtureHit;
        Object testObject = fixHit.getUserData();
        Actor actorHit = null;
        if (testObject != null) {
          if (testObject instanceof Actor) {
            actorHit = (Actor)testObject;
          }
        }
        if (actorHit != null && actorHit.myTeam == Team.ZOMBIE) {
          Vec2 shotDir = endPoint.add(origin.mul(-1));
          shotDir = shotDir.mul(pushback);
          actorHit.wasHit(shotDir,damage);
        }
      }
      rayDetect.cleanup();
    }
  }
}