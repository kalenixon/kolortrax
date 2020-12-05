class BGCtrl {
  int[] rgb;
  int[] prevRgb;
  float idxMax;
  float idxMin;
  boolean IsBgChange;
  int BgTimer;
  boolean NoChange;
  
  BGCtrl(int r, int g, int b, float iMax, float iMin) {
    rgb = new int[3];
    rgb[0] = r;
    rgb[1] = g;
    rgb[2] = b;
    
    idxMax = iMax;
    idxMin = iMin;
    IsBgChange = false;
    NoChange = false;
    background(rgb[0], rgb[1], rgb[2]);
  }
  
  void update(float idx, int bgMod, boolean nbc) {
    NoChange = nbc;
    
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
      
 /*     color bgColor = color(newRgb[0], newRgb[1], newRgb[2]);
      colorMode(HSB, 100);
        
      bgMod = (int)map(bgMod, 0, 127, 100, 0);
      background(hue(bgColor), saturation(bgMod), brightness(bgColor)); 
      colorMode(RGB);
     */ 
      println("Color change: " + idx + " 0: "   + rgb[0] + ", 1: " + rgb[1] + ", 2:" + rgb[2]);
    
     background(newRgb[0], newRgb[1], newRgb[2]);
      rgb = newRgb;
    } else {
      if (BGSTICK) {  
        background(rgb[0], rgb[1], rgb[2]);
        
        if (NoChange) {
          IsBgChange = true;
        } else {
          IsBgChange = false;
        }
      } else {
        background(255);
        IsBgChange = false;
        BgTimer = 0;
      }
    }
  }
}
