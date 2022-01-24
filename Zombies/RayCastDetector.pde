import org.jbox2d.callbacks.*;

class RayCastDetector implements RayCastCallback {
  
  Vec2 closestPointHit; //point data for drawing of raycast lines/debug lines
  Object closestObjectHit;
  float closestFraction = 1;
  
  float reportFixture(Fixture fix, Vec2 point, Vec2 normal, float fraction) {

    //debug draw points hit by Raycast.
    //Vec2 rayCastPixHit = box2d.coordWorldToPixels(point);
    //stroke(0);
    //strokeWeight(15);
    //point(rayCastPixHit.x,rayCastPixHit.y);
    
    float valueToReturn = 1;
    
    //if this fraction is closer than the next nearestFixture hit...
    if (fraction < closestFraction) {
      //determine type of fixture hit.
      Object o = fix.getUserData();
      if (o instanceof Actor) {
        valueToReturn = reportActorHit(o,point,fraction);
      } else if (o instanceof MapObject) {
        valueToReturn = reportMapHit(o,point,fraction);
      }
    }
    return valueToReturn;
  }
  
  float reportActorHit(Object o, Vec2 hitPoint, float fraction) {
    Actor actHit = (Actor)o;
    if (actHit.myTeam == Team.HUMAN) {
      return 1;
    } else {
      closestObjectHit = actHit;
      closestPointHit = hitPoint;
      closestFraction = fraction;
      return fraction;
    }
  }
  
  float reportMapHit(Object o, Vec2 hitPoint, float fraction) {
    MapObject mapHit = (MapObject)o;
    if (mapHit.myType != BlockType.SENSOR) {
      closestObjectHit = mapHit;
      closestPointHit = hitPoint;
      closestFraction = fraction;
      return fraction;
    } else {
      return 1;
    }
  }

  
  void cleanup() {
    closestPointHit = null;
    closestObjectHit = null;
    closestFraction = 1;
  }
  
  
}
