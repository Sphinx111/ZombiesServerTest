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
     teamWon = 1;
   }
   
   if (gameEnded && !startingReset) {
     gameEndMoment = frameCount;
     startingReset = true;
   }
   
   if (startingReset && teamWon == 1) {
     fill(255,0,0);
     textSize(22);
     text("You were killed",width/2 + 40,height/2 + 40);
     textSize(12);
   } else if (teamWon == 2) {
     fill(15,15,255);
     textSize(22);
     text("Humans have won",width/2 + 40,height/2 + 40);
     textSize(12);
   }
   
   if (frameCount >= gameEndMoment + framesToReset) {
     endGameActions();
   }
   
 }
 
 public void endGameByMapLoad() {
   gameEnded = true;
   teamWon = 0;
 }
 
 public void endGameBySensor() {
   gameEnded = true;
   teamWon = 2;
 }
 
 protected void endGameActions() {
   mainCamera.fractionChangePerTick = 0.9;
   performCleanup();
     if (teamWon == 1) {
       numOfActors -= 5;
     } else if (teamWon == 2) {
       numOfActors += 5;
     }
     if (numOfActors < 10) {
       numOfActors = 10 + totalHumanPlayers;
     }
     actorControl = new ActorController(numOfActors);
     mapHandler.loadMap("testMap");
     gameEndMoment = DEATH_NULL;
     startingReset = false;
     gameEnded = false;
     teamWon = 0;
     mainCamera.fractionChangePerTick = mainCamera.defaultFractionChange;
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
