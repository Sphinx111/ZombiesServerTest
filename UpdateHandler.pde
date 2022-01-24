//This class creates update snapshots for different players, depending on what packets they've acked receipt of.
//each step, any objects that have changed add themselves to the list of objects to be checked. 

class UpdateHandler {
  
  int tickBuffer = 5;
  int serverTick = 0;
  HashMap<Integer,Object> objectsUpdating = new HashMap<Integer,Object>(); //all the objects being updated this turn
  HashMap<Integer,ObjectUpdateWrapper> previousUpdates = new HashMap<Integer,ObjectUpdateWrapper>(); //storage for objects in last X ticks.
  int clientsConnected = 1;
  ObjectUpdateWrapper[] currentUpdates = new ObjectUpdateWrapper[clientsConnected];
  
  //methods available for update wrappers:
  //- prepareObjectForUpdate(Object)
  //- prepareObjectForDelete(int classInt, int objectID)
  //- getIDOfChangedObjects() returns Set of Integers
  
  public UpdateHandler() {
    for (int i = 0; i < clientsConnected; i++) {
      currentUpdates[i] = new ObjectUpdateWrapper(serverTick);
    }
  }
  
  byte[] getByteArrayCurrent () {
    byte[] nullByte = null;
    try {
     return Serializer.serialize(currentUpdates[0]);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return nullByte;
  }
  
  void addMeToUpdate(MapObject me) {
    Object[] add = {(Object)me};
    currentUpdates[0].prepareObjectForUpdate(add);
  }
  void addMeToUpdate(Actor me) {
    Object[] add = {(Object)me}; 
    currentUpdates[0].prepareObjectForUpdate(add);
  }
  
  void deleteMe(MapObject me) {
    int[] classID = {0};
    int[] someID = {me.myID};
    currentUpdates[0].prepareObjectForDelete(classID,someID);
  }
  void deleteMe(Actor me) {
    int[] classID = {1};
    int[] someID = {me.actorID};
    currentUpdates[0].prepareObjectForDelete(classID,someID);
  }
  
  int[] getDifferencesFromLastAck (int lastAckTick) {
    //When I do this bit, it will list all objects changed since the last tick given 
    int[] currentlyNull = null;
    return currentlyNull;
  }
  
  //tell the current UpdateWrapper to list an object for deletion.
  void networkDeleteObjects (int[] classInt, int[] objID, int clientID) {
    currentUpdates[clientID].prepareObjectForDelete(classInt,objID);
  }
  
  //tell the current UpdateWrapper to list an object for updating.
  void networkUpdateObjects (Object[] toUpdate, int clientID) {
    currentUpdates[clientID].prepareObjectForUpdate(toUpdate);
  }
  
  
}

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public static class Serializer {

    public static byte[] serialize(Object obj) throws IOException {
        try {
          ByteArrayOutputStream b = new ByteArrayOutputStream();
          ObjectOutputStream o = new ObjectOutputStream(b);
          o.writeObject(obj);
          return b.toByteArray();
        } finally {
          return null;
        }
    }

    public static Object deserialize(byte[] bytes) throws IOException, ClassNotFoundException {
        try {
          ByteArrayInputStream b = new ByteArrayInputStream(bytes);
          ObjectInputStream o = new ObjectInputStream(b);
          return o.readObject();
        } finally {
          return null;
        }
    }

}