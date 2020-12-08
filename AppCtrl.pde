class AppCtrl {
  
  // the color we are tracking
  color trackColor;
  
  // how big are the pixels we are displaying
  int pixelSize;
  
  // raw midi value for pixel size
  int pixelSizeMidi;
  
  // 0-255 red value
  int red;
  
  // raw midi for red
  int redMidi;
  
  // 0-255 green value
  int green;
  
  // raw midi for green
  int greenMidi;
  
  // 0-255 blue value
  int blue;
  
  // raw midi for blue
  int blueMidi;
  
  // ir midi
  int irMidi;
  
  // joystick stuff
  int joyX;
  int joyY;
  int joyClick;
  
  // amount of perlin noise to apply
  int shaderAmt;
  
  // scale the harmonics by this number
  int fundScale;
  
  // psychgen related stuff
  int psychAmt;
  int psychTimer;
  boolean psychGen;
  
  // Dim change based on ext. sound on/off
  boolean dimChange;
  
  // bg change on/off
  boolean bgChange;
  
  // shader (perlin noise) on/off
  boolean shader;
  
  // draw squares or circles
  boolean drawSquare;
  
  // Selector for creating new scopes
  Selector sel;
  
  // Scopes and related
  Scope scopes[];
  int curScope;
  
  // Double click tracking for scope clearing
  int scopeClickCt = 0;
  int scopeClickTime = 0;
    
  AppCtrl () {
    bgChange = true;
    drawSquare = true;
    shader = false;
    dimChange = true;
    psychGen = PSYCHGENINIT;
    pixelSize = DIMINIT;
    fundScale = 1;
    curScope = 0;
    
    // Scopes
    scopes = new Scope[MAXSCOPES];
    
    // selector
    sel = new Selector(0, 0, SELECTORDIM);
  }
  
  void midiUpdate(int channel, int number, int value) {
    try {
      if (number == PIXSIZECC) {
        pixelSizeMidi = value;
        pixelSize = (int)map(pixelSizeMidi, 0, 127, MINDIM, MAXDIM);
      } else if (number == REDCC) {
        redMidi = value;
        red = (int)map(redMidi, 0, 127, 0, 255);
      } else if (number == GREENCC) {
        greenMidi = value;
        fundScale = value;      
        green = (int)map(greenMidi, 0, 127, 0, 255);
      } else if (number == BLUECC) {
        blueMidi = value;
        blue = (int)map(blueMidi, 0, 127, 0, 255);
      } else if (number == JOYXCC) {
        if (value == 0) {
          sel.moveX(-1);
        } else if (value == 127) {
          sel.moveX(1);
        }
      } else if (number == JOYYCC) {
        if (value == 0) {
          sel.moveY(1);
        } else if (value == 127) {
          sel.moveY(-1);
        }
      } else if (number == JOYCLICKCC && value == 0) {  
        if (scopeClickCt > 0 && millis() - scopeClickTime < 1000) {
          clearScopes();
          scopeClickCt = 0;
        } else {
          scopeClickTime = millis();
          scopeClickCt++;
          addScope(sel.x, sel.y, sel.dim);
        } 
      } else if (number == PIXSHAPECC && value == 0) {   
        drawSquare = !drawSquare;
      } else if (number == BGCHANGECC && value == 0) {   
        bgChange = !bgChange;
        dimChange = !dimChange;
      } else if (number == SHADERCC && value == 0) {   
        shader = !shader;
      } else if (number == SHADERAMTCC) {
        shaderAmt = value;
      } else if (number == IRCC) {
        irMidi = value;
      }
    } catch (ArrayIndexOutOfBoundsException e) {
      e.printStackTrace();
      println("CAUGHT Array Out of Bounds EXCEPTION");
    }
  }
  
  color getColor(int idx) {
    return color(
      red > 0 ? red : random((int)map(idx, 0, Video.height, 0, 255)),
      green > 0 ? green : random((int)map(idx, 0, Video.height, 0, 255)),
      blue > 0 ? blue : random((int)map(idx, 0, Video.height, 0, 255))
    );
  }
  
  color getShaderColor(int i, int j, float noiseScale) {
    float noiseVal1 = noise((red+i)*noiseScale, (red+j)*noiseScale);
    float noiseVal2 = noise((green+i)*noiseScale, (green+j)*noiseScale);
    float noiseVal3 = noise((blue+i)*noiseScale, (blue+j)*noiseScale);
    color c = color(
      (red*noiseVal1), 
      (green*noiseVal2), 
      (blue*noiseVal3)
    );
    
    return c;
  }
  
  void addScope(int x, int y, int dim) {
    Scope s = new Scope(x, y, dim);
    s.paint(0);
    scopes[curScope] = s;
    curScope++;
    
    if (app.curScope == scopes.length) {
      curScope = 0;
    }
  }
  
  void clearScopes() {
    for (int i = 0; i < scopes.length; i++) {
      scopes[i] = null;
    }
    curScope = 0;
  }
}
