import processing.video.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Capture cam;
Minim minim;
AudioOutput out;
Oscil osc;

int camW = 160;
int camH = 120;
float[] prevPixels;
boolean started = false;
int t = 0;

void setup() {
  fullScreen();
  noFill();
  cam = new Capture(this, camW, camH);
  cam.start();
  String[] listaDeCamaras = Capture.list(); printArray( listaDeCamaras ); //inicializacion camara = new Capture( this, ancho, alto ); //inicializo el objeto opencv opencv = new OpenCV(this, ancho, alto ); //enciende la camara camara.start(); background(0); minim = new Minim(this); out = minim.getLineOut();
  minim = new Minim(this);
  out = minim.getLineOut();
  osc = new Oscil(440, 0.0f, Waves.SQUARE);
  osc.patch(out);
}

void draw() {
  background(255);

  if (!started) {
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
   // text("Click to start", width/2, height/2);
    return;
  }

  if (cam.available()) cam.read();
  cam.loadPixels();
  if (cam.pixels.length == 0) return;

  float leftMotion = 0, rightMotion = 0;

  if (prevPixels != null) {
    for (int y = 0; y < camH; y+=2) {
      for (int x = 0; x < camW; x+=2) {
        int idx = y * camW + x;
        float b = brightness(cam.pixels[idx]);
        float diff = abs(b - prevPixels[idx]);
        if (x < camW/2) leftMotion += diff;
        else rightMotion += diff;
      }
    }
  }

  // save current frame brightness
  prevPixels = new float[cam.pixels.length];
  for (int i = 0; i < cam.pixels.length; i++) {
    prevPixels[i] = brightness(cam.pixels[i]);
  }

  // reduce bars to max 20 each
  int numBarsX = (int)map(leftMotion, 0, 5000, 5, 20);
  int numBarsY = (int)map(rightMotion, 0, 5000, 5, 20);

  float barWidth = width / (float)numBarsX;
  float barHeight = height / (float)numBarsY;

  stroke(0);
  for (int i = 0; i < numBarsX; i++) {
    if (noise(i*0.2f, t*0.01f) > 0.5) rect(i*barWidth, 0, barWidth, height);
  }
  for (int j = 0; j < numBarsY; j++) {
    if (noise(j*0.2f, t*0.01f+100) > 0.5) rect(0, j*barHeight, width, barHeight);
  }

  // oscillator mapping
  osc.setFrequency(map(leftMotion, 0, 5000, 100, 800));
  osc.setAmplitude(map(rightMotion, 0, 5000, 0.05f, 0.2f));

  t++;
  image(cam,0,0);
}

void mousePressed() {
  started = true;
}
