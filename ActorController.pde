class ActorController {
  
  int MAX_PLAYER_COUNT = 200;
  ArrayList<Actor> actorsInScene = new ArrayList<Actor>();
  ArrayList<Actor> actorsToRemove = new ArrayList<Actor>(0);
  Actor player = null;
  Actor[] players = new Actor[MAX_PLAYER_COUNT];
  
  public ActorController(int n) {
    for (int i = 0; i < n; i++) {
      Vec2 newPos = new Vec2((playerStartPos.x - 50) + ((float)Math.random() * 100), (playerStartPos.y - 250) + ((float)Math.random() * 100));
      if (i < totalHumanPlayers) {
        newPos = new Vec2((playerStartPos.x - 50) + ((float)Math.random() * 100), (playerStartPos.y - 50) + ((float)Math.random() * 100));
        if (i == 0) {
          Actor newPlayer = new Actor(newPos, true, Team.HUMAN, Type.SOLDIER);
          actorsInScene.add(newPlayer);
          player = newPlayer;
        } else {
          Actor newPlayer = new Actor(newPos, false, Team.HUMAN, Type.SOLDIER);
          actorsInScene.add(newPlayer);
        }
      } else if (i % 10 == 0) {
        actorsInScene.add(new Actor(newPos, false, Team.ZOMBIE, Type.BIG_ZOMBIE));
      } else {
        actorsInScene.add(new Actor(newPos, false, Team.ZOMBIE, Type.BASIC_ZOMBIE));
      }
    }
  }
  
  public void addNewHumanPlayer(int id) {
    Actor newPlayer = new Actor(getJoinPos(),true, Team.HUMAN, Type.SOLDIER);
    players[id] = newPlayer;
    actorsInScene.add(newPlayer);
  }
  
  void createActor(Vec2 pos, boolean isPlayer, Team team, Type type) {
    actorsInScene.add(new Actor(pos,isPlayer,team,type));
  }
  
  void removeActor(Actor deadActor) {
    if (!actorsToRemove.contains(deadActor)) {
      actorsToRemove.add(deadActor);
    }
  }
  
  Vec2 getJoinPos() {
    return new Vec2((playerStartPos.x - 50) + ((float)Math.random() * 100), (playerStartPos.y - 50) + ((float)Math.random() * 100));
  }
  
  void cleanup() {
    //Go through list of actors removed this turn, and clear them from the activeActors ArrayList
    for (Actor a : actorsToRemove) {
      box2d.world.destroyBody(a.body);
      actorsInScene.remove(a);
      //if the player being removed is the player, nullify the "player" field/pointer in ActorController.
      if (a.isPlayer) {
        player = null;
      }
    }
    actorsToRemove.clear();
  }
  
  void update() {
    for (Actor a : actorsInScene) {
      //a.applyForce(new Vec2(50000,0));
      if (!a.isPlayer) {
        a.runBehaviour();
      }
      a.update();
    }
  }
  
  void show() {
    for (Actor a : actorsInScene) {
      a.show();
    }
  }
  
  void setAngle(int playerID, float angle) {
    players[playerID].setAngle(angle);
  }
  void shoot(Actor a) {
    a.shoot();
  }
  void shoot(int playerID) {
    players[playerID].shoot();
  }
  void moveForward(Actor a) {
    a.applyForce(new Vec2(0,1).mul(a.accel));
  }
  void moveForward(int playerID) {
      players[playerID].applyForce(new Vec2(0,1).mul(players[playerID].accel));
  }
  void moveBackward(Actor a) {
    a.applyForce(new Vec2(0,-1).mul(a.accel));
  }
  void moveBackward(int playerID) {
      players[playerID].applyForce(new Vec2(0,-1).mul(players[playerID].accel));
  }
  void moveLeft(Actor a) {
    a.applyForce(new Vec2(-1,0).mul(a.accel));
  }
  void moveLeft(int playerID) {
    players[playerID].applyForce(new Vec2(-1,0).mul(players[playerID].accel));
  }
  void moveRight(Actor a) {
    a.applyForce(new Vec2(1,0).mul(a.accel));
  }
  void moveRight(int playerID) {
    players[playerID].applyForce(new Vec2(1,0).mul(players[playerID].accel));
  }
  
}