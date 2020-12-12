/*
 * KolorTrax 0.0.1 by Kale Nixon
 * Retro/psych color tracking via webcam  
 * Controlled by midi and/or OSC
 * 
 * Style: 
 *   - Globals have capitalized first letter,
 *   - constants in all caps
 *   - locals camelcase
 */
import themidibus.*; 
import processing.video.*;
import netP5.*;
import oscP5.*;
import processing.sound.*;

Capture Video; 
MidiBus MyBus;
AudioIn Input;
Amplitude Loudness;
OscP5 osc;

// App ctrl - all variables that control aspects of the application are held here
AppCtrl app;

int Saved[][];      // similar pixels to trackColor
int Prev[][];       // previous pixels
int Colors[][];     // saved colors from previous draw()

// Sound globals
SndCtrl Snd;
int SndUpdateCt = 0;

// Have we run init?
boolean DidInit = false;

// Background control
BGCtrl Bg;

void setup() {
  size(1280, 960);
  
  String[] cameras = Capture.list();
  Video = new Capture(this, width, height, cameras[0]);
  Video.start();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }
  
  app = new AppCtrl();
  
  // Listen for OSC msgs 
  osc = new OscP5(this, TOUCHOSCPORT);
    
  // Keep track of saved pixels and colors
  Saved = new int[XSIZE][YSIZE];
  Prev = new int[XSIZE][YSIZE];
  Colors = new int[XSIZE][YSIZE];

  // Set up sound
  Snd = new SndCtrl(DEFFUND, HARM1, HARM2, HARM3, HARM4); 
  Input = new AudioIn(this, 0);
  Input.start();
  Loudness = new Amplitude(this);
  Loudness.input(Input);
  
  Bg = new BGCtrl(255, 255, 255, BGIDXMAX, BGIDXMIN);
  
  // Set up midi
  MyBus = new MidiBus(this, "Teensy MIDI", "to Max 1");
  MyBus.addInput("Teensy MIDI");
}

void draw() {  
  if (!DidInit) {
    init();
    DidInit = true;
  }
  
  float volume = Loudness.analyze();
  float noiseScale = .01;
  float sndScale = 0;
  color currentColor;
  color c;
  int loc;
  int savedCt = 0;
  
  noiseScale = map(app.shaderAmt + 5, 0, 127, .001, .034);
  
  // Handle BG change through detecting external sounds
  Bg.update(volume, app.irMidi, app.bgChange);
  
  Saved = new int[XSIZE][YSIZE];
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < Video.width; x += app.pixelSize) {
    for (int y = 0; y < Video.height; y += app.pixelSize) {
      loc = x + y*Video.width;
      currentColor = Video.pixels[loc];
      Prev[x][y] = Saved[x][y];
      Colors[x][y] = 0;

      // Using euclidean distance to compare colors
      float d = dist(
        red(currentColor), 
        green(currentColor), 
        blue(currentColor), 
        red(app.trackColor), 
        green(app.trackColor), 
        blue(app.trackColor)
      );
      
      if (d < THRESH) {    
        Saved[x][y] = 1;
        savedCt++;
      }
      
      /**** Begin drawing pixels ****/
      if (!app.psychGen || millis() > app.psychTimer + PSYCHWAITTIME) {
        frameRate(FRAMERT);
        app.psychTimer = millis();
        
        if (Saved[x][y] == Prev[x][y]) continue;
        
        if (Saved[x][y] == 1) { 
          if (!app.shader) {
            c = app.getColor(y);          
            fill(c);      
          } else {             
            c = app.getShaderColor(x, y, noiseScale);
            colorMode(HSB);     
            fill(hue(c), saturation(c), brightness(c)*1.5);
            colorMode(RGB);
          }
          
          Colors[x][y] = c;
          
          // Make the pixel size responsive to audio input
          // Only if pixel size is larger than minimum       
          int dimAdd = app.dimChange ? (int)map(volume, 0.1, .8, MINDIM, MAXDIM) : 0;
          
          drawPixel(app.pixelSize + dimAdd, app.drawSquare, width-x-1, y);  
        
        // Also draw this pixel if it's nearby a saved pixel
        } else if (isSavedNearby(Saved, x, y)) {   
          Colors[x][y] = color(app.red, app.green, app.blue);        
          fill(Colors[x][y]);    
          drawPixel(app.pixelSize, app.drawSquare, width-x-1, y); 
          savedCt++;  
        } else {
          Colors[x][y] = 0;
        }
      
      // Display additional "psychgen" pixels here that progressively get longer and rotate
      } else if (app.psychGen) {
        frameRate(FRAMERTLOW);
        
        if (Saved[x][y] == 1) {
          c = Colors[x][y];
          
          // If we don't have a color set here, set one
          if (c == 0) {
            if (!app.shader) {
              c = app.getColor(y);    
            } else { 
              c = app.getShaderColor(x, y, noiseScale);
            }
          }
          
          pushMatrix();
          translate(width-x-1 + app.pixelSize/2, y + app.pixelSize/2);
          fill(c);
          
          // Amt = amount of rotation and pixel length increase 
          int amt = (int)map(millis(), app.psychTimer, app.psychTimer + PSYCHWAITTIME, 0, app.psychAmt / 2);
          if (brightness(c) > 50) {   
            rotate((2 * PI * brightness(c)) / amt);
          }
          
          if (app.drawSquare) {
            noStroke();
            rectMode(CENTER);
            rect(0, 0, app.pixelSize, app.pixelSize + amt); 
            rectMode(CORNER); 
          } else {
            ellipse(0, 0, app.pixelSize, app.pixelSize + amt);
          }
          popMatrix(); 
        }
      }
      /**** End drawing pixels ****/
    }
  }
  
  // Max updates -- this needs to follow the loop above
  SndUpdateCt++;
  if (SndUpdateCt == SNDUPDATE) {
    if (savedCt > SNDHITHRESH) {
      sndScale = 
        (int)map(
          savedCt, 
          SNDDIFFHIMIN, 
          SNDDIFFHIMAX, 1, 6
         );
      sndScale = constrain(sndScale, 1, 6);
      if (DEBUG) println("SCALING UP: " + sndScale);
      
    } else if (savedCt < SNDLOTHRESH) {
      sndScale = map(savedCt, SNDDIFFLOMIN, SNDDIFFLOMAX, 0.1, 1.0);
      if (DEBUG) println("SCALING DOWN: " + sndScale);
      
      // Force these values to be "good" ratios
      if (sndScale <= .25) {
        sndScale = 0.25;
      } else if (sndScale <= .5) {
        sndScale = 0.5;
      } else if (sndScale <= .75) {
        sndScale = 0.75;
      } else {
        sndScale = 1;
      }
    } else {
      sndScale = 1;
    }
    
    Snd.fund = map(app.fundScale, 0, 127, DEFFUND, MAXFUND);
    Snd.update(sndScale, app.psychAmt);
    Snd.send();
    
    SndUpdateCt = 0;
  }
  
  app.sel.update();
  
  // Draw saved scopes
  for (int i = 0; i < app.scopes.length; i++) {
    if (app.scopes[i] != null) {
      app.scopes[i].paint(app.shader ? noiseScale : 0.0);
    }
  }
}

void drawPixel(int pixelSize, boolean drawSquare, int x, int y) {
  noStroke();
  if (drawSquare) {
      square(x , y, pixelSize);
    } else {
      ellipse(x, y, pixelSize, pixelSize);
    }
}

void captureEvent(Capture video) {
  video.read();
}

// Track a new color on mouse click
void mousePressed() {
  int loc = width - mouseX - 1 + mouseY * Video.width;
  app.trackColor = Video.pixels[loc];
  app.psychTimer = millis();
}

// Handle MIDI updates
void controllerChange(int channel, int number, int value) {
  if (DEBUG) 
    println("Value: " + value + ", CHANNEL " + channel + ", number: " + number);
  
  app.midiUpdate(channel, number, value);
}


// Run once on the first call to draw()
void init() {
  frameRate(FRAMERT);
  background(255);
  
  Input.amp(1);
    
  // Choose a randomish pixel to track 
  int loc = int(width/3 +(height/3)*Video.width);
  app.trackColor = Video.pixels[loc];
}

void trackRandomColor() {
  int loc = int(random(width-1) +random(height-1)*Video.width);
  app.trackColor = Video.pixels[loc];
}

// Is there a cell nearby that is set to 1
boolean isSavedNearby(int[][] arr, int i, int j) {
  boolean ret = false;
  
  // Array OOB errors kept occuring so I added this hack
  if (i == 0 || j == 0 || i == arr.length - 1 || j == arr[0].length - 1) {
    return false;
  }
  
  try {
    if ( 
      (i > 0 && 
        (arr[i-1][j] == 1 || (j > 0 && arr[i-1][j-1] == 1) || (j < arr[i-1].length && arr[i-1][j+1] == 1 ))
      ) || 
      (j > 0 && arr[i][j-1] == 1) || 
      (j < arr[i].length && arr[i][j+1] == 1) ||
      (j < arr[i].length && i > 0 && arr[i-1][j+1] == 1) ||
      (j < arr[i].length && i < arr.length && arr[i+1][j+1] == 1) ||
      (i < arr.length && j > 0 && arr[i+1][j-1] == 1)
      
    ) {
      ret = true;
    }
   } catch (ArrayIndexOutOfBoundsException e) {
    e.printStackTrace();
    println("CAUGHT Array Out of Bounds EXCEPTION i: " + i + ", j:" + j);
    return ret;
  }
  return ret;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  float firstValue = 0;
  
  if (DEBUG) {
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
  
  if(theOscMessage.checkTypetag("f")) {
    firstValue = theOscMessage.get(0).floatValue(); 
    if (DEBUG)
      println("First msg: " + firstValue);
  }
  
  // pixel dimension
  if(theOscMessage.checkAddrPattern("/1/rotary4")== true) {
    app.pixelSize = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // red
  if(theOscMessage.checkAddrPattern("/1/rotary1")== true) {
    app.red = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // green
  if(theOscMessage.checkAddrPattern("/1/rotary2")== true) {
    app.green = (int)map(firstValue, 0.0, 1.0, 0, 127);
    app.fundScale = app.green;
  }
 
  // blue
  if(theOscMessage.checkAddrPattern("/1/rotary3")== true) {
    app.blue = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // Psychgen amount
  if(theOscMessage.checkAddrPattern("/1/fader2")== true) {
    if (firstValue >=.1) {
      app.psychGen = true;
      app.psychAmt = (int)map(firstValue, .1, 1.0, 0, PSYCHMAX);
    } else {
      app.psychGen = false;
    }  
  }
  
  // Bg change on/off
  if(theOscMessage.checkAddrPattern("/1/toggle1")== true) {
    app.bgChange = !app.bgChange;
  }
  
  // shader on/off
  if(theOscMessage.checkAddrPattern("/1/toggle2")== true) {
    app.shader = !app.shader;
  }
  
  // pixel shape 
  if(theOscMessage.checkAddrPattern("/1/toggle3")== true) {
    app.drawSquare = !app.drawSquare;
  }
}
