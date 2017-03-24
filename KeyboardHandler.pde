class KeyboardHandler {
  
  boolean[] keys = new boolean[9];
  // 0 - Shoot (x)
  // 1 - W Forward
  // 2 - S Backwards
  // 3 - A Left
  // 4 - D Right
  // 5 - Pause (p)
  // 6 - Creator Mode (m)
  // 7 - SaveMap (o);
  // 8 - LoadMap (l);
  
  void processKeyInput() {
    if (keys[0]) {
      actorControl.shoot(actorControl.player);
    }
    if (keys[1]) {
      actorControl.moveForward(actorControl.player);
    } else if (keys[2]) {
      actorControl.moveBackward(actorControl.player);
    }
    if (keys[3]) {
      actorControl.moveLeft(actorControl.player);
    } else if (keys[4]) {
      actorControl.moveRight(actorControl.player);
    }
    //if (keys[5]) {
    //  if (isPaused) {
    //    isPaused = false;
    //  } else {
    //    isPaused = true;
    //  }
    //}
    //if (keys[6]) {
    //  if (creatorMode) {
    //    creatorMode = false;
    //  } else {
    //    creatorMode = true;
    //  }
    //}
  }
  
  void keyInCheck() {
    if (key == 'x') {
      keys[0] = true;
    }
    if (key == 'w' || key == 'W') {
      keys[1] = true;
    }
    if (key == 's' || key == 'S') {
      keys[2] = true;
    }
    if (key == 'a' || key == 'A') {
      keys[3] = true;
    }
    if (key == 'd' || key == 'D') {
      keys[4] = true;
    }
    if (key == 'p') {
      //keys[5] = true;
      if (isPaused) {
        isPaused = false;
      } else {
        isPaused = true;
      }
    }
    if (key == 'r' || key == 'R') {
      actorControl.player.myWeapon.reload();
    }
    if (key == 'm') {
      //keys[6] = true;
      if (creatorMode) {
        creatorMode = false;
      } else {
        creatorMode = true;
      }
    }
    if (key == 'o') {
      mapHandler.saveMap();
    }
    if (key == 'l') {
      mapHandler.loadMap("testMap");
    }
  }
  
  void keyOutCheck() {
    if (key == 'x') {
      keys[0] = false;
    }
    if (key == 'w' || key == 'W') {
      keys[1] = false;
    }
    if (key == 's' || key == 'S') {
      keys[2] = false;
    }
    if (key == 'a' || key == 'A') {
      keys[3] = false;
    }
    if (key == 'd' || key == 'D') {
      keys[4] = false;
    }
    if (key == 'p') {
      keys[5] = false;
    }
    if (key == 'm') {
      keys[6] = false;
    }
  }
  
}