public enum BlockType {
  FIXED, //static world geometry
  SENSOR, //dynamic sensor bodies, buttons etc
  DOOR, //KINEMATIC bodies (usually linked to sensors or gameLogic).
  ACTOR, // ie = not a worldBlock, use Actor Save/Load.
  NO_TYPE; // used to handle blocks loaded without any type information.
  
  
  public static String getString(BlockType testType) {
    if (testType == BlockType.FIXED) {
      return "FIXED";
    } else if (testType == BlockType.SENSOR) {
      return "SENSOR";
    } else if (testType == BlockType.DOOR) {
      return "DOOR";
    } else if (testType == BlockType.ACTOR) {
      return "ACTOR";
    } else {
      return "NO_TYPE";
    } 
  }
  
  public static BlockType getTypeFromString(String testString) {
    if (testString.equals("FIXED")) {
      return BlockType.FIXED;
    } else if (testString.equals("SENSOR")) {
      return BlockType.SENSOR;
    } else if (testString.equals("DOOR")) {
      return BlockType.DOOR;
    } else if (testString.equals("ACTOR")) {
      return BlockType.ACTOR;
    } else {
      return BlockType.NO_TYPE;
    }
    
  }
  
}

public enum Team {
  HUMAN,ZOMBIE,NEUTRAL,NONE;
}

public enum Type {
  CIVILIAN,
  SOLDIER,
  BASIC_ZOMBIE,
  BIG_ZOMBIE;
}

public enum PacketType {
  CLIENT_REGISTER,
  CLIENT_INPUT,
  SERVER_JOINDATA,
  SERVER_UPDATE,
  NO_TYPE; 
}