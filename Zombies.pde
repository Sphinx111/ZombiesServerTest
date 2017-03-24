import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import ddf.minim.*;

Box2DProcessing box2d;
StateManager gameStateManager;
ActorController actorControl;
MapHandler mapHandler;
KeyboardHandler keyHandler;
FogOfWar fogOfWar;
UILayer uiLayer;
MouseHandler mouseHandler;
SoundManager soundManager;
Camera mainCamera;
Boolean isPaused = true;
Boolean creatorMode = false;

Vec2 playerStartPos;
int numOfActors = 15;
int totalHumanPlayers = 3;

float newMouseX;
float newMouseY;

void setup() {
  size(1300,720);
  box2d = new Box2DProcessing(this);
  box2d.createWorld(new Vec2(0,0));
  playerStartPos = new Vec2(width/2, height/2);
  mainCamera = new Camera();
  gameStateManager = new StateManager();
  actorControl = new ActorController(numOfActors);
  mapHandler = new MapHandler();
  keyHandler = new KeyboardHandler();
  mouseHandler = new MouseHandler();
  fogOfWar = new FogOfWar();
  uiLayer = new UILayer();
  soundManager = new SoundManager(this);
  mapHandler.loadMap("testMap");
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