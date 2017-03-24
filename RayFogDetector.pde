import org.jbox2d.callbacks.*;

class RayFogDetector implements RayCastCallback {
  
  public HashMap<Integer,Vec2> nearestRayHits = new HashMap<Integer,Vec2>();
  public ArrayList<MapObject> allMapObjects = new ArrayList<MapObject>();
  FogOfWar owner;
  Vec2 lastPointHit;
  
  public RayFogDetector(FogOfWar owner) {
    this.owner = owner;
  }
  
  float reportFixture(Fixture fix, Vec2 point, Vec2 normal, float fraction) {
    Object testObject = fix.getUserData();
    if (testObject instanceof MapObject) {
      int current_i = owner.ray_index;
      MapObject map = (MapObject)testObject;
      if (!allMapObjects.contains(map)) {
        allMapObjects.add(map);
      }
      if (!nearestRayHits.containsKey(current_i)) {
        nearestRayHits.put(current_i,point.clone());
        lastPointHit = point;
      } else if (nearestRayHits.get(current_i).add(owner.origin.mul(-1)).length() > point.add(owner.origin.mul(-1)).length()) {
        nearestRayHits.put(current_i,point.clone());
        lastPointHit = point;
      }
    }
    if (testObject instanceof Actor) {
      return 1;
    }
    return fraction;
  }
  
  Collection getVertices() {
    return nearestRayHits.values();
  }
  
  ArrayList<MapObject> getMapObjects() {
    return allMapObjects;
  }
  
  void cleanup() {
    nearestRayHits = new HashMap<Integer,Vec2>();
  }
  
}