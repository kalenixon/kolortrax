class Selector {
  int x;
  int y;
  int dim;
  float timer;
  boolean movingX;
  boolean movingY;
  boolean showing;
  
  Selector(int initX, int initY, int d) {
    x = initX;
    y = initY;
    dim = d;
    timer = millis() - HIDESELECTTIME; 
    movingX = false;
    movingY = false;
    showing = false;
  }
  
  void update() {
    float curTime = millis();
    
    if (curTime - timer > HIDESELECTTIME) {
      this.hide();
    } else if (curTime - timer < HIDESELECTTIME) {
      this.show(false);
    }
  }
  
  void hide() {
  }
  
  void show(boolean timerUpdate) {
    if (!showing) {
      showing = true;
      
      stroke(204, 102, 0);
      noFill();
      rect(x, y, dim, dim);
      noStroke();

      if (timerUpdate) {
        timer = millis();
      }
      showing = false;
    }
  }
  
  void moveX(int dir) {
    if (!movingX) {
      movingX = true;
      x += dir * SELMOVEPIX;
      if (x > width - dim) {
        x = width - dim;
      } else if (x < 0) {
        x = 0;
      }
      this.show(true);
      movingX = false;
    }
  }
  
  void moveY(int dir) {
    if (!movingY) {
      movingY = true;
      y += dir * SELMOVEPIX;
      if (y > height - dim) {
        y = height - dim;
      } else if (y < 0) {
        y = 0;
      }
      this.show(true);
      movingY = false;
    }
  }
}
