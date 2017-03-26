class StateManager {
  
  int framesToReset = 120; 
  int DEATH_NULL = 999999;
  int gameEndMoment = DEATH_NULL;
  boolean startingReset = false;
  boolean gameEnded = false;
  int teamWon = 0; // 0 - nobody, 1 - zombies, 2 - humans
 
 void update() {
   if (actorControl.player.myTeam == Team.ZOMBIE && !startingReset) {
     gameEnded = true;
   }
   
   if (gameEnded && !startingReset) {
     gameEndMoment = frameCount;
     startingReset = true;
   }
   
   if (startingReset) {
     fill(255,0,0);
     textSize(22);
     text("You were killed",width/2 + 40,height/2 + 40);
     textSize(12);
   }
   
   if (frameCount >= gameEndMoment + framesToReset) {
     endGameActions();
   }
   
 }
 
 public void endGameByMapLoad() {
   endGameActions();
 }
 
 protected void endGameActions() {
   performCleanup();
     numOfActors -= 5;
     if (numOfActors < 15) {
       numOfActors = 15;
     }
     actorControl = new ActorController(numOfActors);
     mapHandler.loadMap("testMap");
     gameEndMoment = DEATH_NULL;
     startingReset = false;
     gameEnded = false;
   
 }
 
 void performCleanup() {
   for (MapObject o : mapHandler.allObjects) {
     mapHandler.removeObject(o);
   }
   mapHandler.cleanup();
   for (Actor a : actorControl.actorsInScene) {
     actorControl.removeActor(a);
   }
   actorControl.cleanup();
 }
  
}