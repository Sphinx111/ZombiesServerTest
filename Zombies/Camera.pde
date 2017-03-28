class Camera {
  float xOff = playerStartPos.x;
  float yOff = playerStartPos.y;
  float screenShakeValue = 0;
  float angleChangeX = 0;
  float angleChangeY = 0;
  float playerPosX = box2d.scalarPixelsToWorld(playerStartPos.x);
  float playerPosY = box2d.scalarPixelsToWorld(playerStartPos.y);
  float oldAngleChangeX = angleChangeX;
  float oldAngleChangeY = angleChangeY;
  float oldPlayerPosX = playerPosX;
  float oldPlayerPosY = playerPosY;
  float screenCenterX = width/2;
  float screenCenterY = height/2;
  float fractionChangePerTick = 0.04;
  float defaultFractionChange = 0.04;
  
  public Camera() {
    fractionChangePerTick = 1;
  }
  
  void applyTransform() {
    if (creatorMode) {
      fractionChangePerTick = 0.2;
    }
    float oldXOff = xOff;
    float oldYOff = yOff;
    oldAngleChangeX = angleChangeX;
    oldAngleChangeY = angleChangeY;
    oldPlayerPosX = playerPosX;
    oldPlayerPosY = playerPosY;
    playerPosX = box2d.getBodyPixelCoord(actorControl.player.body).x;
    playerPosY = box2d.getBodyPixelCoord(actorControl.player.body).y;
    float playerFacing = actorControl.player.body.getAngle() + (PI);
    angleChangeX = width/5 * (float)Math.sin(playerFacing);
    angleChangeY = height/5 * (float)Math.cos(playerFacing);
    xOff = angleChangeX + screenCenterX  - playerPosX;
    yOff = angleChangeY + screenCenterY  - playerPosY;
    xOff = (oldXOff + ((xOff - oldXOff) * fractionChangePerTick)) + applyScreenShake();
    yOff = (oldYOff + ((yOff - oldYOff) * fractionChangePerTick)) + applyScreenShake();
    pushMatrix();
    translate(xOff,yOff);
    screenShakeValue -= 5;
    if (screenShakeValue < 0){
      screenShakeValue = 0;
    }
    fractionChangePerTick = defaultFractionChange;
  }
  
  //this function name is misleading. it should convert from camera transform coordinates into... something where the mousePos is constantly relative to middle Of screen
  Vec2 getPlayerPixPos() {
    float xChangeDiff = (oldAngleChangeX + ((angleChangeX - oldAngleChangeX) * fractionChangePerTick));
    float yChangeDiff = (oldAngleChangeY + ((angleChangeY - oldAngleChangeY) * fractionChangePerTick));
    float xPlayerDiff = (oldPlayerPosX + ((playerPosX - oldPlayerPosX) * fractionChangePerTick));
    float yPlayerDiff = (oldPlayerPosY + ((playerPosY - oldPlayerPosY) * fractionChangePerTick));
    //return new Vec2(-xOff + (xChangeDiff * 2) + xPlayerDiff*2 , -yOff + (yChangeDiff * 2) + yPlayerDiff*2);
    //inverse of xOff is: - (oldXOff + ((xOff - oldXOff) * fractionChangePerTick)) - Screenshake
    //which breaks down to: - ((oldAngleChangeX + screenCenterX - playerPosX) + ((angelChangeX + screenCenterX - playerPosX) - (oldAngleChangeX + screenCenterX - playerPosX) * fractionChangePerTick)) - screenShake; 
    return new Vec2(xChangeDiff - screenShakeValue - xPlayerDiff + screenCenterX,yChangeDiff - screenShakeValue - yPlayerDiff + screenCenterY);
  }
  
  void screenShake(float amount) {
    screenShakeValue += amount;
  }
  
  float applyScreenShake() {
    float newAmount = ((float)Math.random() * 2 * screenShakeValue) - screenShakeValue;
    return newAmount;
  }
  
  void undoTransform() {
    popMatrix();
  }
  
}