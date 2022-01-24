import java.util.Set;

class ObjectUpdateWrapper implements Serializable {
  //this class is serialized into a byte stream and transferred to clients, about 20 times a second, a separate thread will prepare this for each client.
  //Needs to have as few methods as possible, and allow for very quick processing of state changes/updates.
  
  int updateSerialNo = 1;
  HashMap<Integer,UpdateElement> updates = new HashMap<Integer,UpdateElement>();
  
  public ObjectUpdateWrapper(int serverTick) {
    updateSerialNo = serverTick;
  }
  
  Set<Integer> getIDOfChangedObjects () {
    return updates.keySet();
  }
  
  void addUpdateElement(UpdateElement newElement) {
    updates.put(newElement.objectID, newElement);
  }
  
  void prepareObjectForDelete(int[] classInt, int[] objID) {
    for (int i = 0; i < classInt.length; i++) {
      UpdateElement newUpdateElement = new UpdateElement(classInt[i], objID[i], 1);
      updates.put(objID[i], newUpdateElement);
    }
  }
  //This update currently only adds MapObjects and Actors to the update wrapper.
  void prepareObjectForUpdate(Object[] feedIn) {
    for (Object o : feedIn) {
      int objectClass = -1;
      int objID = -1;
      int deleteFlag = 0;
      Vec2 savePos = null;
      float angle = 0;
      
      UpdateElement newStaticEl = null;
      
      if (o instanceof MapObject) {
        MapObject obj = (MapObject)o;
        objectClass = 0;
        objID = obj.myID;
        savePos = obj.body.getWorldCenter();
        angle = obj.body.getAngle();
        newStaticEl = new UpdateElement(objectClass, objID, deleteFlag, savePos, angle);
      } else if (o instanceof Actor) {
        objectClass = 1;
        Actor obj = (Actor)o;
        objID = obj.actorID;
        savePos = obj.body.getWorldCenter();
        angle = obj.body.getAngle();
        newStaticEl = new UpdateElement(objectClass, objID, deleteFlag, savePos,angle);
      } else {return;}
      
      addUpdateElement(newStaticEl);
    }
  }
  
  
  class UpdateElement implements Serializable {
    int objectClass; //-1 = null, 0 = MapObject, 1 = Actor 
    int objectID;
    int deleteFlag;
    Vec2 pos;
    float angle;
    
    public UpdateElement(int objClass, int objID, int deleteFlag) {
      //If this constructor is called, the update element specifies removal of an object.
      objectClass = objClass;
      objectID = objID;
      this.deleteFlag = deleteFlag;
    }
    
    public UpdateElement(int objClass, int objID, int deleteFlag, Vec2 pos, float angle) {
      objectClass = objClass;
      objectID = objID;
      this.deleteFlag = deleteFlag;
      this.pos = pos;
      this.angle = angle;
    }
    
  }
  
}