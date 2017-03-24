import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Arrays;

class FogOfWar {
  
  Vec2 origin;
  Vec2 worldOrigin;
  float fogDistance = 10000;
  PShape fogShape;
  PShape fogShape2;
  
  RayFogDetector fogDetector = new RayFogDetector(this);
  int ray_index = 0;
  
  float angle = 0;
  float leftAngle = 0;
  float wLeftAngle = 0;
  float rightAngle = 0;
  float wRightAngle = 0;
  float bodyD = 1;
  float playerFOV = PI/2;
  float playerSightRange = 300;
  
  Vec2[] visibilityPolygon;
  
  void update() {
    Actor player = actorControl.player;
    playerFOV = player.FOV;
    angle = player.body.getAngle();
    rightAngle = angle + (playerFOV/2);
    wRightAngle = -rightAngle - PI/2; //the pi/2 deals with my stupid choice of player orientation...
    leftAngle = angle - (playerFOV/2);
    wLeftAngle = -leftAngle - PI/2;
    origin = box2d.getBodyPixelCoord(player.body);
    bodyD = player.myRadius;
    
    /*
    //Find mapobject blocks in the player's FOV.
    worldOrigin = player.body.getPosition();
    int exploreRays = 20;
    float[] angleLimits = {wLeftAngle,wRightAngle};
    ArrayList<MapObject> visibleMapObjects = exploratoryRaycast(angleLimits, exploreRays, playerSightRange);
    
    //raycast TACTIC: For each raycast, store the endpoint, and then overwrite the endpoint if the ray hits anything.
    
    ArrayList<Float> anglesToCast = new ArrayList<Float>();
    anglesToCast.add(wLeftAngle - PI/2);
    for (MapObject mo : visibleMapObjects) {
      Vec2[] vertices = ((PolygonShape)mo.myFix.m_shape).m_vertices;
      for (Vec2 v : vertices) {
        v = mo.body.getWorldPoint(v); //convert from local shape coords to body world coords
        Vec2 fromPlayer = v.add(worldOrigin.mul(-1));
        Float angleToV = (-(float)Math.atan2(fromPlayer.y,fromPlayer.x) + PI/2);
        Float leftV = angleToV - 0.02;
        Float rightV = angleToV + 0.02;
        //if (angleToV > wLeftAngle + PI/2 - PI/4 && angleToV < wRightAngle + PI/2 - PI/4) {
          anglesToCast.add(angleToV);
          anglesToCast.add(leftV);
          anglesToCast.add(rightV);
        //}
      }
    }
    anglesToCast.add(wRightAngle - PI/2);
    anglesToCast.trimToSize();
    float[] newAnglesArray = new float[anglesToCast.size()];
    int tempI = 0;
    for (Float f: anglesToCast) {
      newAnglesArray[tempI] = Float.valueOf(f);
      tempI += 1;
    }
    Arrays.sort(newAnglesArray);
    visibilityPolygon = new Vec2[newAnglesArray.length];
    ray_index = 0;
    
    for (int i = 0; i < newAnglesArray.length; i++) {
      float currentAngle = newAnglesArray[i];
      Vec2 castPoint = new Vec2(worldOrigin.x + ((box2d.scalarPixelsToWorld(playerSightRange)) * (float)Math.sin(currentAngle)), worldOrigin.y + ((box2d.scalarPixelsToWorld(playerSightRange) * (float)Math.cos(currentAngle))));
      ray_index = i;
      box2d.world.raycast(fogDetector,worldOrigin,castPoint);
      if (fogDetector.lastPointHit != null) {
        castPoint = fogDetector.lastPointHit;
      }
      visibilityPolygon[i] = castPoint;
      Vec2 castPointPix = box2d.coordWorldToPixels(castPoint);
      stroke(0,250,0);
      strokeWeight(0.5);
      line(origin.x,origin.y,castPointPix.x,castPointPix.y);
      fogDetector.lastPointHit = null;            
    }
    System.out.println("Polygons in visibility Polygon array: " + visibilityPolygon.length);
    if (visibilityPolygon[0] != null) {
      Vec2 newCheck = box2d.coordWorldToPixels(visibilityPolygon[0]);
      strokeWeight(2);
      stroke(255);
      line(origin.x,origin.y,newCheck.x,newCheck.y);
    }
    visibleMapObjects.clear();
    anglesToCast.clear();
    newAnglesArray = new float[newAnglesArray.length];
    */
  }
    
    /*
    //returns a list of MapObjects hit by the rays defined in parameters
    ArrayList<MapObject> exploratoryRaycast(float[] angleLimits, float numOfRays,float distCheck) {
      float arcToSweep = angleLimits[1] - angleLimits[0];
      float raySeparationAngle = arcToSweep / numOfRays;
      ray_index = 0;
      
      for (int i = 0; i < numOfRays; i++) {
        float angleForRay = angleLimits[1] + (raySeparationAngle * i);
        Vec2 rayEnd = new Vec2(worldOrigin.x + (box2d.scalarPixelsToWorld(distCheck) * (float)Math.sin(angleForRay)), worldOrigin.y + (box2d.scalarPixelsToWorld(distCheck) * (float)Math.cos(angleForRay)));
        ray_index = i;
        box2d.world.raycast(fogDetector,worldOrigin,rayEnd);
        Vec2 rayEndPix = box2d.coordWorldToPixels(rayEnd);
        stroke(255);
        strokeWeight(1);
        line(origin.x,origin.y,rayEndPix.x,rayEndPix.y);
      }
      ArrayList<MapObject> results = fogDetector.getMapObjects();
      fogDetector.cleanup();
      
      return results;
    }*/
  
  void show() {
    text("" + leftAngle, 20,20);
    Vec2 endLineLeft = new Vec2(origin.x + (fogDistance * (float)Math.sin(leftAngle)), origin.y + (fogDistance * (float)Math.cos(leftAngle)));
    Vec2 endLineRight = new Vec2(origin.x + (fogDistance * (float)Math.sin(rightAngle)), origin.y + (fogDistance * (float)Math.cos(rightAngle)));
    Vec2 offScreenLeft = new Vec2(origin.x + (fogDistance * (float)Math.sin(angle - (PI/2))), origin.y + (fogDistance * (float)Math.cos(leftAngle - (PI/2))));
    Vec2 offScreenRight = new Vec2(origin.x + (fogDistance * (float)Math.sin(angle + (PI/2))), origin.y + (fogDistance * (float)Math.cos(rightAngle + (PI/2))));
    Vec2 behindShape = new Vec2(origin.x + (fogDistance * (float)Math.sin(angle + PI)), origin.y + (fogDistance * (float)Math.cos(angle + PI)));
    Vec2 shapeLeftCorner = new Vec2(origin.x + (bodyD * (float)Math.sin(angle - (2 * PI / 360 * 135))), origin.y + (bodyD * (float)Math.cos(angle - (2 * PI / 360 * 135))));
    Vec2 shapeRightCorner = new Vec2(origin.x + (bodyD * (float)Math.sin(angle + (2 * PI / 360 * 135))), origin.y + (bodyD * (float)Math.cos(angle + (2 * PI / 360 * 135))));
    Vec2 endSightLeft = endLineLeft.mul(playerSightRange/fogDistance);
    Vec2 endSightRight = endLineRight.mul(playerSightRange/fogDistance);
    
    fogShape = createShape();
    fogShape.beginShape();
    fogShape.fill(0);
    fogShape.noStroke();
    fogShape.vertex(endLineLeft.x, endLineLeft.y);
    fogShape.vertex(offScreenLeft.x,offScreenLeft.y);
    fogShape.vertex(behindShape.x,behindShape.y);
    fogShape.vertex(offScreenRight.x,offScreenRight.y);
    fogShape.vertex(endLineRight.x,endLineRight.y);
    fogShape.vertex(endLineLeft.x, endLineLeft.y);
    fogShape.beginContour();
    fogShape.vertex(endLineRight.x,endLineRight.y);
    fogShape.vertex(shapeRightCorner.x,shapeRightCorner.y);
    /*for (int i = visibilityPolygon.length -1; i >= 0; i--) {
      Vec2 v = visibilityPolygon[i];
      Vec2 polPos = box2d.coordWorldToPixels(v);
      fogShape.vertex(polPos.x,polPos.y);    
    }*/
    //fogShape.vertex(origin.x,origin.y);
    fogShape.vertex(shapeLeftCorner.x,shapeLeftCorner.y);
    fogShape.vertex(endLineLeft.x, endLineLeft.y);

    fogShape.endContour();
    fogShape.endShape();
    shapeMode(CORNER);
    shape(fogShape,0,0);
    
  }
}