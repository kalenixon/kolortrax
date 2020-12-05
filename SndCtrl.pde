class SndCtrl {
  float fund;
  float f1;
  float f2;
  float f3;
  float f4;
  float h1;
  float h2;
  float h3;
  float h4;
  float fxAmt;
  String route = "/kt";
  
  // OSC objects
  OscP5 oscP5;
  NetAddress myBroadcast;
  
  SndCtrl(float f, float harm1, float harm2, float harm3, float harm4) {
    fund = f;
    h1 = harm1;
    h2 = harm2;
    h3 = harm3;
    h4 = harm4;
    
    oscP5 = new OscP5(this, UDPRECVPORT);
    myBroadcast = new NetAddress(UDPSENDADDR,UDPSENDPORT);
  }
  
  void update(float scale, float fx) {
    f1 = fund * h1*scale;
    f2 = fund * h2*scale;
    f3 = fund * h3*scale;
    f4 = fund * h4*scale;
    fxAmt = fx;
  }
  
  void send() {
    String m = this.route + "/" +  
      this.fund + "/" + 
      nf(f1, 0,  FLOATPREC) + "/" + 
      nf(f2, 0,  FLOATPREC) + "/" + 
      nf(f3, 0,  FLOATPREC) + "/" + 
      nf(f4, 0,  FLOATPREC) + "/" + 
      nf(fxAmt, 0, FLOATPREC);
    
    OscMessage msg = new OscMessage(m);
    oscP5.send(msg, myBroadcast);
  }
}
