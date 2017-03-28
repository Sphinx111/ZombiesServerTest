import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import ddf.minim.*;
import java.io.Serializable;

Zombies parentApplet;
Box2DProcessing box2d;
StateManager gameStateManager;
ActorController actorControl;
MapHandler mapHandler;
KeyboardHandler keyHandler;
FogOfWar fogOfWar;
UILayer uiLayer;
MouseHandler mouseHandler;
SoundManager soundManager;
ServerModule server;
ClientModule client;
Camera mainCamera;
Boolean isPaused = true;
Boolean creatorMode = false;
Boolean isServer = true;

Vec2 playerStartPos;
int numOfActors = 10;
int totalHumanPlayers = 2;

float newMouseX;
float newMouseY;

void setup() {
  size(1300,720);
  parentApplet = this;
  box2d = new Box2DProcessing(parentApplet);
  box2d.setScaleFactor(20);
  box2d.createWorld(new Vec2(0,0));
  playerStartPos = new Vec2(width/2, height/2);
  mainCamera = new Camera();
  gameStateManager = new StateManager();
  mapHandler = new MapHandler();
  actorControl = new ActorController(numOfActors);
  keyHandler = new KeyboardHandler();
  mouseHandler = new MouseHandler();
  fogOfWar = new FogOfWar();
  uiLayer = new UILayer();
  soundManager = new SoundManager(parentApplet, "zombie");
  mapHandler.loadMap("testMap");
  if (isServer) {
    server = new ServerModule();
    server.start();
  } else if (!isServer) {
    client = new ClientModule();
    client.start();
  }
}

void draw() {
  background(51);
  mainCamera.applyTransform();
  mouseHandler.update();
  keyHandler.processKeyInput();
  mouseHandler.show();
  mapHandler.update();
  mapHandler.show();
  if (!isPaused) {
    box2d.step();
    actorControl.update();
    fogOfWar.update();
  }
    actorControl.show();
  if (!isPaused && !creatorMode) {
    fogOfWar.show();
  }
  uiLayer.show();
  //Last step of each frame, perform cleanup over iterable lists, undoes camera transform matrix, checks gameState at end of tick.
  actorControl.cleanup();
  mapHandler.cleanup();
  mainCamera.undoTransform();
  gameStateManager.update();
  if (isServer) {
    server.communicateWorldState();
  }
}

void keyPressed() {
  keyHandler.keyInCheck();
}

void keyReleased() {
  keyHandler.keyOutCheck();
}

void mousePressed() {
  mouseHandler.mouseInCheck();
}

void mouseReleased() {
  mouseHandler.mouseOutCheck();
}