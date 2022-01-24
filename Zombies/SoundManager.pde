class SoundManager {
  Minim minim;
  AudioSample soundZ;
  AudioSample soundG;
  String mySoundFile;
  
  float zombieVolMax = -10;
  float zombieVolMin = -20;
  float zombieVolRange = Math.abs(zombieVolMin-zombieVolMax);
  float gunshotVolMax = -15;
  float gunshotVolMin = -30;
  float gunshotVolRange = Math.abs(gunshotVolMin-gunshotVolMax);
  
  public SoundManager(PApplet parent,String fileToPlay) {
    minim = new Minim(parent);
    try {
      if (fileToPlay.contains("zombie")) {
        soundZ = minim.loadSample("zombie.mp3", 512);
        soundZ.setGain(-20);
        mySoundFile = "zombie.mp3";
      } else if (fileToPlay.contains("gunshot")) {  
        soundG = minim.loadSample("gunshot.mp3", 512);
        soundG.setGain(-15);
        mySoundFile = "gunshot.mp3";
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  void triggerSound(String sound, float fractionalVolume) {
    if (sound == "zombie_moan") {
      float newGain = zombieVolMin + (fractionalVolume * zombieVolRange);
      soundZ.setGain(newGain);
      soundZ.trigger();
    }
    if (sound == "gunshot") {
      float newGain = gunshotVolMin + (fractionalVolume * gunshotVolRange);
      soundG.setGain(newGain);
      soundG.trigger();
    }    
  }
  
  void triggerSound(float fractionalVolume) {
    if (mySoundFile.contains("gunshot")) {
      float newGain = gunshotVolMin + (fractionalVolume * gunshotVolRange);
      soundG.setGain(newGain);
      soundG.trigger();
    }
  }
  
}
