// MIDI CCs
final int PIXSIZECC = 1;
final int REDCC = 2;
final int GREENCC = 7;
final int BLUECC = 8;
final int PIXSHAPECC = 3;
final int BGCHANGECC = 9;
final int SHADERCC = 10;
final int JOYCLICKCC = 4;
final int JOYXCC = 5;
final int JOYYCC = 6;
final int SHADERAMTCC = 11;
final int IRCC = 12;

// Sound
final float DEFFUND = 49; 
final float MAXFUND = 98;
final int HARM1 = 3;
final int HARM2 = 4;
final int HARM3 = 5;
final int HARM4 = 6;

final int SNDUPDATE = 3; // Update sound after this number of calls to draw()
final int SNDHITHRESH = 12000;
final int SNDLOTHRESH = 8000;
final int SNDDIFFHIMAX = 50000;
final int SNDDIFFHIMIN = 10000;
final int SNDDIFFLOMAX = 8000;
final int SNDDIFFLOMIN = 2500;
final String SNDROUTE = "/kt";
final float MAXFREQ = 8000;
final int FLOATPREC = 4; // Float precision for freqs sent to max

// OSC / UDP 
final int UDPSENDPORT = 34000;
final int UDPRECVPORT = 14000;
final int TOUCHOSCPORT = 16000;
final String UDPSENDADDR = "127.0.0.1";

// Other
final boolean PSYCHGENINIT = false;
final int PSYCHMAX = 100;
final int PSYCHWAITTIME = 8000; // for capture + hsb mod
final int THRESH = 34;
final int XSIZE = 1280;
final int YSIZE = 960;
final int BGCOLOR = 255;
final int BGCOLORTIME = 750;
final float BGIDXMAX = .6;
final float BGIDXMIN = .05;
final boolean BGSTICK = true;
final boolean DEBUG = false;

// Pixel dims etc
final int DIMINIT = 2;
final int MAXDIM = 20;
final int MINDIM = 2;
final int ADDDIM = 3;
final int SUBDIM = 2;
final boolean PERLINNOISE = false;
final boolean DRAWSQ = true; // true = square, false = circle

// Frame rate
final int FRAMERT = 15;
final int FRAMERTLOW = 10;

// Scope and selector 
final int MAXSCOPES = 10;
final int HIDESELECTTIME = 3000;
final int SELMOVEPIX = 10;
final int SELECTORDIM = 100;
