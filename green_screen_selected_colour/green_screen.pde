import processing.video.*;
import controlP5.*;

int numPixels;
Capture video;
int keyColor = 0xff000000;
int keyR = (keyColor >> 16) & 0xFF;
int keyG = (keyColor >> 8) & 0xFF;
int keyB = keyColor & 0xFF;
PVector chromaAreaStart;
PVector chromaAreaEnd;
boolean setChromaArea = false;
int thresh = 20; // tolerance of 
ControlP5 cp5;

void setup() {
  size(960, 720); 

  video = new Capture(this, width, height);
  numPixels = video.width * video.height;

  video.start(); 
  addSlider();

  chromaAreaStart = new PVector(0, 0);
  chromaAreaEnd = new PVector(width, height);
}

void slider(int theThreshold) {
  thresh = theThreshold;
  println("a slider event. setting background to "+theThreshold);
}

void addSlider() {
  noStroke();
  cp5 = new ControlP5(this);

  // add a vertical slider
  cp5.addSlider("slider")
    .setPosition(10, 10)
    .setSize(200, 20)
    .setRange(0, 255)   
    .setValue(thresh)
    ;
}

void draw() {
  if (video.available()) {
    background(0xFFFFFF);
    loadPixels();    
    video.read(); // Read a new video frame
    video.loadPixels(); // Make the pixels of video available

    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      // Fetch the current color in that location
      color currColor = video.pixels[i];
      int currR = (currColor >> 16) & 0xFF; // apparently this is faster than using red(currColor);
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;

      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - keyR);
      int diffG = abs(currG - keyG);
      int diffB = abs(currB - keyB);

      // Render the pixels wich are not the close to the keyColor to the screen
      int pixelX = i % width;
      int pixelY = floor(i/width);

      if ((diffR + diffG + diffB)> thresh && isWithinChromeArea(pixelX, pixelY)) {
        pixels[i] = color(currR, currG, currB);
      }
    }
    updatePixels();

    if (setChromaArea) {
      fill(255, 0, 255, 60);
      noStroke();
      int rectW = abs(round(chromaAreaEnd.x - chromaAreaStart.x));
      int rectH = abs(round(chromaAreaEnd.y - chromaAreaStart.y));
      int startX = min(int(chromaAreaStart.x), int(chromaAreaEnd.x));
      int startY = min(int(chromaAreaStart.y), int(chromaAreaEnd.y));
      rect(startX, startY, rectW, rectH);
    }
  }
}

boolean isWithinChromeArea(int xPos, int yPos) {
  boolean withinChromaArea = true;

  int startX = min(int(chromaAreaStart.x), int(chromaAreaEnd.x));
  int startY = min(int(chromaAreaStart.y), int(chromaAreaEnd.y));
  int endX = max(int(chromaAreaStart.x), int(chromaAreaEnd.x));
  int endY = max(int(chromaAreaStart.y), int(chromaAreaEnd.y));

  withinChromaArea = xPos > startX && xPos < endX;

  if (withinChromaArea) {
    withinChromaArea = yPos > startY && yPos < endY;
  }

  return withinChromaArea;
}

void mousePressed() {
  if (keyPressed) {
    chromaAreaStart = new PVector(mouseX, mouseY);
  } else if (mouseY > 100) {
    setChromaColour();
  }
}

void mouseDragged() {
  if (keyPressed) {
    setChromaArea = true;
    chromaAreaEnd = new PVector(mouseX, mouseY);
  }
}

void mouseReleased() {
  setChromaArea = false;
}

void setChromaColour() {
  keyColor = get(mouseX, mouseY);
  keyR = (keyColor >> 16) & 0xFF;
  keyG = (keyColor >> 8) & 0xFF;
  keyB = keyColor & 0xFF;
}