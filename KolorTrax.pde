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

color TrackColor;   // color we are tracking
boolean ShowStroke; // show stroke or don't
boolean DrawSq;     // Draw squares or cirlces for our pixels
boolean NoBgChange; // Make whatever bg we have set stick 
boolean PerlinNoise;// Turn on/off shader effect
int Dim;            // dimension of objects we are using as pixels
int Saved[][];      // similar pixels to trackColor
int Prev[][];       // previous pixels
int Colors[][];     // saved colors from previous draw()

// Scopes and related
Scope Scopes[];
Selector Sel;
int CurScope = 0;

// Hsb mod
float Timer = 0.0;

// Double click tracking for scope clearing
int ClickCt = 0;
int ClickTime = 0;

// Global midi vals
int PotMidi = 0; 
int Pot2Midi = 0;
int Pot3Midi = 0;
int Pot4Midi = 0;
int IrMidi = 0;
int BtnMidi = 0;
int FsrMidi = 0;

// Sound globals
SndCtrl Snd;
int SndUpdateCt = 0;

// Have we run init?
boolean DidInit = false;

// Is psych gen on ?
boolean PsychGen = false;
int PsychAmt = 0;

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
  
  // Listen for OSC msgs 
  osc = new OscP5(this, TOUCHOSCPORT);
    
  // Saved pixels (similar to trackColor) and the previous draw() verisond in prev
  Saved = new int[XSIZE][YSIZE];
  Prev = new int[XSIZE][YSIZE];
  Colors = new int[XSIZE][YSIZE];
  
  // Scopes
  Scopes = new Scope[MAXSCOPES];

  // Color we are tracking
  TrackColor = 0;
 
  // Default "pixel" attributes
  ShowStroke = SHOSTROKE;
  Dim = SQRDIM;
  DrawSq = DRAWSQ;
  PerlinNoise = PERLINNOISE;
  PsychGen = PSYCHGEN;
  
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
  color currentColor;
  color c;
  float r1;
  float g1;
  float b1;
  int loc;
  int savedCt = 0;
  int diff = 0;
  int pot2Val = (int)map(Pot2Midi, 0, 127, 0, 255);
  int pot3Val = (int)map(Pot3Midi, 0, 127, 0, 255);
  int pot4Val = (int)map(Pot4Midi, 0, 127, 0, 255);
  float noiseScale = .01;
  float sndScale = 0;
  
  noiseScale = map(FsrMidi+5, 0, 127, .001, .034);
  
  // Handle BG change through detecting external sounds
  Bg.update(volume, IrMidi, NoBgChange);
  
  Dim = (int)map(PotMidi, 0, 127, MINDIM, MAXDIM);
  
  Saved = new int[XSIZE][YSIZE];
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < Video.width; x +=Dim) {
    for (int y = 0; y < Video.height; y +=Dim) {
      loc = x + y*Video.width;
      currentColor = Video.pixels[loc];
      Prev[x][y] = Saved[x][y];
      Colors[x][y] = 0;

      // Using euclidean distance to compare colors
      float d = dist(
        red(currentColor), 
        green(currentColor), 
        blue(currentColor), 
        red(TrackColor), 
        green(TrackColor), 
        blue(TrackColor)
      );
      
      if (d < THRESH) {    
        Saved[x][y] = 1;
        savedCt++;
      }
      
      /**** Begin drawing pixels ****/
      
      int i = x;
      int j = y;
      if (!PsychGen || millis() > Timer + PSYCHWAITTIME) {
        frameRate(FRAMERT);
        Timer = millis();
        
        if (Saved[i][j] == Prev[i][j]) continue;
        
        if (Saved[i][j] == 1) { 
          if (!PerlinNoise) {
            c = color(
              pot2Val > 0 ? pot2Val : random((int)map(j, 0, Video.height, 0, 255)),
              pot3Val > 0 ? pot3Val : random((int)map(j, 0, Video.height, 0, 255)),
              pot4Val > 0 ? pot4Val : random((int)map(j, 0, Video.height, 0, 255))
            );
            fill(c);      
          } else { 
            float noiseVal1 = noise((pot2Val+i)*noiseScale, (pot2Val+j)*noiseScale);
            float noiseVal2 = noise((pot3Val+i)*noiseScale, (pot3Val+j)*noiseScale);
            float noiseVal3 = noise((pot4Val+i)*noiseScale, (pot4Val+j)*noiseScale);
            c = color(
              (pot2Val*noiseVal1), 
              (pot3Val*noiseVal2), 
              (pot4Val*noiseVal3)
            );
            colorMode(HSB);     
            fill(hue(c), saturation(c), brightness(c)*1.5);
            colorMode(RGB);
          }
          
          Colors[i][j] = c;
          
          // Make the pixel size responsive to audio input
          // Only if pixel size is larger than minimum
          int dimAdd = 0;
          if (!NoBgChange) {
            dimAdd = (int)map(volume, 0.1, .8, MINDIM, MAXDIM);
          }
          
          noStroke();
          if (DrawSq) {
            square(width-i-1 , j, Dim + dimAdd);
          } else {
            ellipse(width-i-1, j, Dim +dimAdd, Dim + dimAdd);
          }
        } else if (isSavedNearby(Saved, i, j)) {
          savedCt++;
          r1 = pot2Val;
          g1 = pot3Val; 
          b1 = pot4Val; 
        
          Colors[i][j] = color(r1, g1, b1);
          
          noStroke();
          fill(r1, g1, b1);
          if (DrawSq) {
            square(width-i-1 , j, Dim);
          } else {
            ellipse(width-i-1, j, Dim, Dim);
          }   
        } else {
          Colors[i][j] = 0;
        }
      } else if (PsychGen) {
        frameRate(FRAMERTLOW);
        if (Saved[i][j] == 1) {
          c = Colors[i][j];
          if (c == 0) {
            if (!PerlinNoise) {
              c = color(
                pot2Val > 0 ? pot2Val : random((int)map(j, 0, Video.height, 0, 255)),
                pot3Val > 0 ? pot3Val : random((int)map(j, 0, Video.height, 0, 255)),
                pot4Val > 0 ? pot4Val : random((int)map(j, 0, Video.height, 0, 255))
              );     
            } else { 
              float noiseVal1 = noise((pot2Val+i)*noiseScale, (pot2Val+j)*noiseScale);
              float noiseVal2 = noise((pot3Val+i)*noiseScale, (pot3Val+j)*noiseScale);
              float noiseVal3 = noise((pot4Val+i)*noiseScale, (pot4Val+j)*noiseScale);
              c = color(
                (pot2Val*noiseVal1), 
                (pot3Val*noiseVal2), 
                (pot4Val*noiseVal3)
              );
            }
          }
          
          pushMatrix();
     /*     colorMode(HSB, 100);
      //    float noiseSat = noise((saturation(c)+i)*noiseScale, (saturation(c)+j)*noiseScale);
          fill(
            constrain(hue(c), 0, 100), 
            constrain(saturation(c), 0, 100), 
            constrain(brightness(c), 0, 100)
          );
          colorMode(RGB);*/
          fill(c);
    
          translate(width-i-1+Dim/2, j+Dim/2);
          
          // Amt = amount of rotation and pixel length increase 
          int amt = (int)map(millis(), Timer, Timer + PSYCHWAITTIME, 0, PsychAmt / 2);
          if (brightness(c) > 50) {   
            rotate((2 * PI * brightness(c)) / amt);
          }
          
          if (DrawSq) {
            noStroke();
            rectMode(CENTER);
            rect(0, 0, Dim ,(Dim)+amt ); 
            rectMode(CORNER); 
          } else {
            ellipse(0, 0, Dim, Dim+amt);
          }
          popMatrix(); 
        }
      }

      /**** End drawing pixels ****/
      
      if (Saved[x][y] != Prev[x][y]) {
        diff++;
      }
    }
  }
  
  diff = savedCt;
  
  // Max updates -- this needs to follow the loop above
  SndUpdateCt++;
  if (SndUpdateCt == SNDUPDATE) {
    if (diff > SNDHITHRESH) {
      sndScale = 
        (int)map(
          diff, 
          SNDDIFFHIMIN, 
          SNDDIFFHIMAX, 1, 6
         );
      sndScale = constrain(sndScale, 1, 6);
      
      println("Scaling up: " + sndScale);
    } else if (diff < SNDLOTHRESH) {
      sndScale = map(diff, SNDDIFFLOMIN, SNDDIFFLOMAX, 0.1, 1.0);
      println("scaling down: " + sndScale);
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
    
    Snd.fund = map(Pot3Midi, 0, 127, DEFFUND, MAXFUND);
    Snd.update(sndScale, PsychAmt);
    Snd.send();
    
    SndUpdateCt = 0;
  }
  
  Sel.update();
  
  // Draw saved scopes
  for (int i = 0; i < Scopes.length; i++) {
    if (Scopes[i] != null) {
      Scopes[i].paint(PerlinNoise ? noiseScale : 0.0);
    }
  }
}

void captureEvent(Capture video) {
  video.read();
}

// Track a new color on mouse click
void mousePressed() {
  int loc = width-mouseX-1 + mouseY*Video.width;
  TrackColor = Video.pixels[loc];
  Timer = millis();
}

void controllerChange(int channel, int number, int value) {
//  println("Value: " + value + ", CHANNEL " + channel + ", number: " + number);
  
  try {
    if (number == POTCC) {
      PotMidi = value;
    } else if (number == POT2CC) {
      Pot2Midi = value;
      println("pot2: " + Pot2Midi);
    } else if (number == POT3CC) {
      Pot3Midi = value;
    } else if (number == POT4CC) {
      Pot4Midi = value;
    } else if (number == JOYXCC) {
      if (value == 0) {
        Sel.moveX(-1);
      } else if (value == 127) {
        Sel.moveX(1);
      }
    } else if (number == JOYYCC) {
      if (value == 0) {
        Sel.moveY(1);
      } else if (value == 127) {
        Sel.moveY(-1);
      }
    } else if (number == JOYCLICKCC && value == 0) {  
      if (ClickCt > 0 && millis() - ClickTime < 1000) {
        clearScopes();
        ClickCt = 0;
      } else {
        ClickTime = millis();
        ClickCt++;
        addScope(Sel.x, Sel.y, Sel.dim);
      } 
    } else if (number == BUTTONCC && value == 0) {   
      DrawSq = !DrawSq;
    } else if (number == BUTTON2CC && value == 0) {   
      NoBgChange = !NoBgChange;
    } else if (number == BUTTON3CC && value == 0) {   
      PerlinNoise = !PerlinNoise;
    } else if (number == FSRCC) {
      FsrMidi = value;
    } else if (number == IRCC) {
      IrMidi = value;
    }
  } catch (ArrayIndexOutOfBoundsException e) {
    e.printStackTrace();
    println("CAUGHT Array Out of Bounds EXCEPTION");
  }
}

void addScope(int x, int y, int dim) {
  Scope s = new Scope(x, y, dim);
  s.paint(0);
  Scopes[CurScope] = s;
  CurScope++;
  
  if (CurScope == Scopes.length) {
    CurScope = 0;
  }
}

void clearScopes() {
  for (int i = 0; i < Scopes.length; i++) {
    Scopes[i] = null;
  }
  CurScope = 0;
}

// Run once on the first call to draw()
void init() {
  frameRate(FRAMERT);
  background(255);
  Sel = new Selector(0, 0, SELECTORDIM);
  
  Input.amp(1);
    
  // Choose a randomish pixel to track 
  int loc = int(width/3 +(height/3)*Video.width);
  TrackColor = Video.pixels[loc];
}

void trackRandomColor() {
  int loc = int(random(width-1) +random(height-1)*Video.width);
  TrackColor = Video.pixels[loc];
}

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
  
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  
  if(theOscMessage.checkTypetag("f")) {
    firstValue = theOscMessage.get(0).floatValue(); 
    println("First msg: " + firstValue);
  }
  
  // A = pixel dimension
  if(theOscMessage.checkAddrPattern("/1/rotary4")== true) {
    PotMidi = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // B = red
  if(theOscMessage.checkAddrPattern("/1/rotary1")== true) {
    Pot2Midi = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // C = green
  if(theOscMessage.checkAddrPattern("/1/rotary2")== true) {
    Pot3Midi = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
 
  // D = blue
  if(theOscMessage.checkAddrPattern("/1/rotary3")== true) {
    Pot4Midi = (int)map(firstValue, 0.0, 1.0, 0, 127);
  }
  
  // Crossfade = Psychgen + amt
  if(theOscMessage.checkAddrPattern("/1/fader2")== true) {
    if (firstValue >=.1) {
      PsychGen = true;
      PsychAmt = (int)map(firstValue, .1, 1.0, 0, PSYCHMAX);
    } else {
      PsychGen = false;
    }  
  }
  
  if(theOscMessage.checkAddrPattern("/1/toggle1")== true) {
    NoBgChange = !NoBgChange;
  }
  
  if(theOscMessage.checkAddrPattern("/1/toggle2")== true) {
    PerlinNoise = !PerlinNoise;
  }
  
  if(theOscMessage.checkAddrPattern("/1/toggle3")== true) {
    DrawSq = !DrawSq;
  }
}
