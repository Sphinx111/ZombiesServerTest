public enum BlockType {
  FIXED, //static world geometry
  SENSOR, //dynamic sensor bodies, buttons etc
  ITEM, //INGAME ITEM, often can be picked up or interacted with, uses isSensor setting on body/fixture.
  DOOR, //KINEMATIC bodies (usually linked to sensors or gameLogic).
  ACTOR, // ie = not a worldBlock, use Actor Save/Load.
  NO_TYPE; // used to handle blocks loaded without any type information
  
  public static String getStringFromType(BlockType testType) {
    if (testType == BlockType.FIXED) {
      return "FIXED";
    } else if (testType == BlockType.SENSOR) {
      return "SENSOR";
    } else if (testType == BlockType.DOOR) {
      return "DOOR";
    } else if (testType == BlockType.ACTOR) {
      return "ACTOR";
    } else if (testType == BlockType.ITEM) {
      return "ITEM";
    } else {
      return "FIXED";
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
    } else if (testString.equals("ITEM")) {
      return BlockType.ITEM;
    } else {
      return BlockType.FIXED;
    }
    
  }
  
}

public enum ItemType {
  ITEM_RIFLE,
  ITEM_HANDGUN,
  NO_ITEM;
  
  float RIFLE_LENGTH = 20;
  float RIFLE_WIDTH = 5; 
  
  public static String getStringFromItem(ItemType testType) {
    if (testType == ItemType.ITEM_RIFLE) {
      return "ITEM_RIFLE";
    } else if (testType == ItemType.ITEM_HANDGUN) {
      return "ITEM_HANDGUN";
    } else {
      return "NO_ITEM";
    }
  }
  
  public static ItemType getTypeFromString(String testString) {
    if (testString.equals("ITEM_RIFLE")) {
      return ItemType.ITEM_RIFLE;
    } else if (testString.equals("ITEM_HANDGUN")) {
      return ItemType.ITEM_HANDGUN;
    } else {
      return ItemType.NO_ITEM;
    }
  }
  
}

public enum Team {
  HUMAN,ZOMBIE,NEUTRAL,NONE;
  
  int[] HUMAN_COLOR = {100,100,200};
  int[] ZOMBIE_COLOR = {100,200,100};
  int[] NEUTRAL_COLOR = {150,150,150};
  
}

public enum Type {
  CIVILIAN,
  SOLDIER,
  BASIC_ZOMBIE,
  BIG_ZOMBIE;
  
  float SOLDIER_HEALTH = 100;
  float SOLDIER_MAXSPEED = 30;
  float SOLDIER_ACCEL = 300;
  float SOLDIER_FOV = PI/2;
  float SOLDIER_MAXSIGHTRANGE = 1000;
  float SOLDIER_RADIUS = 20;
  
  float ZOMBIE_HEALTH = 2500;
  float ZOMBIE_MAXSPEED_MULTIPLIER = 1.2;
  float ZOMBIE_ACCEL_MULTIPLIER = 1;
  float ZOMBIE_FOV = PI + (PI/4);
  float ZOMBIE_MAXSIGHTRANGE = 1000;
  float ZOMBIE_RADIUS = 20;
  
  float BIGZOMBIE_HEALTH = 25000;
  float BIGZOMBIE_MAXSPEED_MULTIPLIER = 1.1;
  float BIGZOMBIE_ACCEL_MULTIPLIER = 2;
  float BIGZOMBIE_FOV = PI + (PI/4);
  float BIGZOMBIE_MAXSIGHTRANGE = 800;
  float BIGZOMBIE_RADIUS = 30;
  
  float CIVILIAN_HEALTH = 80;
  float CIVILIAN_MAXSPEED = 28;
  float CIVILIAN_ACCEL = 300;
  float CIVILIAN_FOV = PI/2;
  float CIVILIAN_MAXSIGHTRANGE = 1000;
  float CIVILIAN_RADIUS = 20;
}

public enum PacketType {
  CLIENT_REGISTER,
  CLIENT_INPUT,
  SERVER_JOINDATA,
  SERVER_UPDATE,
  NO_TYPE; 
}

public enum WeaponType {
  RIFLE,
  HANDGUN,
  SMG;
  
  int RIFLE_DAMAGE = 15;
  float RIFLE_PUSHBACK = 100; //remember, this value is improved by the fire rate.
  float RIFLE_RANGE = 1500;
  float RIFLE_MAXSPREAD = 3 * (2 * PI / 360); //degrees + radians conversion.
  int RIFLE_FIREDELAY = 4;
  int RIFLE_MAGAZINESIZE = 30;
  int RIFLE_RELOADTIME = 120;
  String RIFLE_SOUND = "gunshot.mp3";
  
  int HANDGUN_DAMAGE = 5;
  float HANDGUN_PUSHBACK = 100;
  float HANDGUN_RANGE = 600;
  float HANDGUN_MAXSPREAD = 4.5 * (2 * PI / 360);
  int HANDGUN_FIREDELAY = 6;
  int HANDGUN_MAGAZINESIZE = 12;
  int HANDGUN_RELOADTIME = 30;
  String HANDGUN_SOUND = "gunshot.mp3";
  
  
  
}