class SoundManager {
  Minim minim;
  AudioSample soundZ;
  AudioSample soundG;
  AudioSample soundGO;
  
  float zombieVolMax = -10;
  float zombieVolMin = -20;
  float zombieVolRange = Math.abs(zombieVolMin-zombieVolMax);
  float gunshotVolMax = -15;
  float gunshotVolMin = -30;
  float gunshotVolRange = Math.abs(gunshotVolMin-gunshotVolMax);
  
  public SoundManager(PApplet parent) {
    minim = new Minim(parent);
    soundZ = minim.loadSample("zombie.mp3", 512);
    soundZ.setGain(-20);
    soundG = minim.loadSample("gunshot.mp3", 512);
    soundG.setGain(-15);
    soundGO = minim.loadSample("gunshot.mp3",512);
    soundGO.setGain(-15);
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
    if (sound == "gunshotOther") {
      float newGain = gunshotVolMin + (fractionalVolume * gunshotVolRange);
      soundGO.setGain(newGain);
      soundGO.trigger();
    }
    
  }
  
}