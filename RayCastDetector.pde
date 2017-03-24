import org.jbox2d.callbacks.*;

class RayCastDetector implements RayCastCallback {
  
  Fixture targetFixtureHit;
  Vec2 pointHit;
  ArrayList<Vec2> allPointsHit = new ArrayList<Vec2>();
  
  float reportFixture(Fixture fix, Vec2 point, Vec2 normal, float fraction) {
    targetFixtureHit = fix;
    pointHit = point;
    Object testObject = fix.getUserData();
    if (testObject instanceof Actor) {
      Actor actorHit = (Actor)testObject;
      if (actorHit.myTeam == Team.HUMAN) {
        return 1;
      } else {
        targetFixtureHit = fix;
        pointHit = point;
        return fraction;
      }
    } else if (testObject instanceof MapObject) {
      return fraction;
    }
    return fraction;
  }
  
  void cleanup() {
    targetFixtureHit = null;
    pointHit = null;
  }
  
}