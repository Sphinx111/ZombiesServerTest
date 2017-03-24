class StateManager {
  
  int framesToReset = 120; 
  int DEATH_NULL = 999999;
  int playerDeathMoment = DEATH_NULL;
  boolean startingReset = false;
 
 void update() {
   if (actorControl.player.myTeam == Team.ZOMBIE && !startingReset) {
     playerDeathMoment = frameCount;
     startingReset = true;
   }
   
   if (startingReset) {
     fill(255,0,0);
     textSize(22);
     text("You were killed",width/2 + 40,height/2 + 40);
     textSize(12);
   }
   
   if (frameCount >= playerDeathMoment + framesToReset) {
     performCleanup();
     numOfActors -= 5;
     if (numOfActors < 15) {
       numOfActors = 15;
     }
     actorControl = new ActorController(numOfActors);
     mapHandler.loadMap("testMap");
     playerDeathMoment = DEATH_NULL;
     startingReset = false;
   }
   
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