// MIDI CCs
final int POTCC = 1;
final int POT2CC = 2;
final int POT3CC = 7;
final int POT4CC = 8;
final int BUTTONCC = 3;
final int BUTTON2CC = 9;
final int BUTTON3CC = 10;
final int JOYCLICKCC = 4;
final int JOYXCC = 5;
final int JOYYCC = 6;
final int FSRCC = 11;
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
final float MAXFREQ = 8000;

// OSC / UDP 
final int UDPSENDPORT = 34000;
final int UDPRECVPORT = 14000;
final int TOUCHOSCPORT = 16000;
final String UDPSENDADDR = "127.0.0.1";

// Other
final boolean PSYCHGEN = false; // Generate psychedelic effect
final int PSYCHMAX = 100;
final boolean DO3D = false;
final int THRESH = 34;
final int SQRDIM = 4;
final int XSIZE = 1280;
final int YSIZE = 960;
final int BGCOLOR = 255;
final int BGCOLORTIME = 750;
final float BGIDXMAX = .6;
final float BGIDXMIN = .05;
final boolean BGSTICK = true;
final float STROKEWT = 0.5;
final boolean SHOSTROKE = false;
final int STROKECOLOR = 255;
final int MAXDIM = 20;
final int MINDIM = 2;
final int ADDDIM = 3;
final int SUBDIM = 2;
final float STKADD = 0.5;
final boolean DRAWSQ = true; // true = square, false = circle
final int FRAMERT = 15;
final int FRAMERTLOW = 10;
final boolean PERLINNOISE = false;
final int FLOATPREC = 4; // Float precision, used in SndCtrl
final int PNCOMP = 30;  // Compensate for perlin noise darkness
final int PSYCHWAITTIME = 8000; // for capture + hsb mod

// Scope and selector 
final int MAXSCOPES = 10;
final int HIDESELECTTIME = 3000;
final int SELMOVEPIX = 10;
final int SELECTORDIM = 100;
