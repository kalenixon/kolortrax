class Scope {
  int x;
  int y;
  int dim;
  
  Scope(int xval, int yval, int d) {
    x = xval;
    y = yval;
    dim = d;
  }
  
  void paint(float noiseScale) {
    // All the (width-x) uses below are to correct the mirror effect of the webcam
    int xMax = width-x + dim >= width ? width-1 : width-x - dim;
    int yMax = y + dim >= height ? height-1 : y + dim;
    
   // for (int i = width-x; i < xMax; i++) {
     for(int i = xMax; i < width-x; i++) {
      for (int j = y; j < yMax; j++) {
        int loc = i + j*Video.width;
        color currentColor = Video.pixels[loc];
        
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
        
        if (noiseScale > 0) {
          //two options here to get brighter: 
          // colorMode
          
          float n1 = noise((r1+i)*noiseScale, (r1+j)*noiseScale);
          float n2 = noise((g1+i)*noiseScale, (g1+j)*noiseScale);
          float n3 = noise((b1+i)*noiseScale, (b1+j)*noiseScale);
          color noisedColor = color(r1*n1, g1*n2, b1*n3);
                  
          float h = hue(noisedColor);
          float s = saturation(noisedColor);
          float b = brightness(noisedColor);
          
          noStroke();
          colorMode(HSB);
          fill(h, s, b*2.9);
          colorMode(RGB);
          
        } else {
          fill(r1, g1, b1);
        }
        square(width-i-1, j, 1);
      }
    }
  }
}
