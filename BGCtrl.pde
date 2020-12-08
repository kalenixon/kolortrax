class BGCtrl {
  int[] rgb;
  int[] prevRgb;
  float idxMax;
  float idxMin;
  boolean IsBgChange;
  int BgTimer;
  boolean change;
  
  BGCtrl(int r, int g, int b, float iMax, float iMin) {
    rgb = new int[3];
    rgb[0] = r;
    rgb[1] = g;
    rgb[2] = b;
    
    idxMax = iMax;
    idxMin = iMin;
    IsBgChange = false;
    change = true;
    background(rgb[0], rgb[1], rgb[2]);
  }
  
  void update(float idx, int bgMod, boolean bgChange) {
    change = bgChange;
    
    if (idx > .04 && !IsBgChange && (millis() - BgTimer) >= BGCOLORTIME) {
      IsBgChange = true;
      BgTimer = millis();
      
      int []newRgb = new int[3];
      newRgb[0] = (int)random(255);
      newRgb[1] = (int)random(255);
      newRgb[2] = (int)random(255);
      
      // Generate two values based on volume input and assign them to two random items in the rgb array
      newRgb[(int)random(3)] = (int)map(idx, 0.05, .6, 255, 0);
      newRgb[(int)random(3)] = (int)map(idx, 0.05, .6, 0, 255);
      
      println("Color change: " + idx + " 0: "   + rgb[0] + ", 1: " + rgb[1] + ", 2:" + rgb[2]);
    
      background(newRgb[0], newRgb[1], newRgb[2]);
      rgb = newRgb;
    } else {
     if (BGSTICK) {  
        background(rgb[0], rgb[1], rgb[2]);
        
        if (change) {
          IsBgChange = false;
        } else {
          IsBgChange = true;
        }
      } else {
        background(255);
        IsBgChange = false;
        BgTimer = 0;
      }
    }
  }
}
