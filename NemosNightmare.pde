// Nemo's Nightmare - a processing app using FaceOSC
// created by Anna von Reden, 2013
// for the IACD Spring 2013 class at the CMU School of Art
//
// created using a template for receiving face tracking osc messages from
// Kyle McDonald's FaceOSC https://github.com/kylemcdonald/ofxFaceTracker
//
// 2012 Dan Wilcox danomatika.com
// for the IACD Spring 2012 class at the CMU School of Art
//
// adapted from from Greg Borenstein's 2011 example
// http://www.gregborenstein.com/
// https://gist.github.com/1603230
//
//TEARDROP CURVE
//M. Kontopoulos  (11.2010)
//Based on the parametric equation found at
//http://mathworld.wolfram.com/TeardropCurve.html
//
//STEERING BEHAVIOR 
//Based on code examples by iainmaxwell, found here:
// http://www.supermanoeuvre.com/blog/?p=372

import oscP5.*;
OscP5 oscP5;


// num faces found
int found;

// pose
float poseScale;
PVector posePosition = new PVector();
PVector poseOrientation = new PVector();

// gesture
float mouthHeight;
float mouthWidth;
float eyeLeft;
float eyeRight;
float eyebrowLeft;
float eyebrowRight;
float jaw;
float nostrils;

// shape constants & variables
float r = 5;
float a = 5;

ArrayList nemos;       // an arraylist to store all of our nemos!
PVector shiny;         // The shiny will be the current position of the mouse!

int numnemos = 50;
int stageWidth      = 640;    // size of the environment in the X direction 
int stageHeight      = 480;    // size of the environment in the Y direction



void setup() {
  size(stageWidth, stageHeight, P3D);
  frameRate(30);

  nemos = new ArrayList();                        // make our arraylist to store our nemos

  shiny = new PVector(stageWidth/2, stageHeight/2, 0);      // make a starting shiny


  // loop to make our nemos!
  for (int i = 0; i < numnemos; i++) {
    nemos.add( new Nemo() );
  }

  smooth();

  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "poseScale", "/pose/scale");
  oscP5.plug(this, "posePosition", "/pose/position");
  oscP5.plug(this, "poseOrientation", "/pose/orientation");
  oscP5.plug(this, "mouthWidthReceived", "/gesture/mouth/width");
  oscP5.plug(this, "mouthHeightReceived", "/gesture/mouth/height");
  oscP5.plug(this, "eyeLeftReceived", "/gesture/eye/left");
  oscP5.plug(this, "eyeRightReceived", "/gesture/eye/right");
  oscP5.plug(this, "eyebrowLeftReceived", "/gesture/eyebrow/left");
  oscP5.plug(this, "eyebrowRightReceived", "/gesture/eyebrow/right");
  oscP5.plug(this, "jawReceived", "/gesture/jaw");
  oscP5.plug(this, "nostrilsReceived", "/gesture/nostrils");
}

void draw() {  
  background(0, 0, 30);
  noStroke();
  if (found > 0) {
    for (int i = 0; i < nemos.size(); i++) {
      Nemo A = (Nemo) nemos.get(i);    
      A.run();                                      // Pass the population of nemos to the nemo!
    }
    translate(posePosition.x, posePosition.y);
    scale(poseScale);
    shiny = new PVector(posePosition.x, posePosition.y-50, 0);        // if mouse is pressed then update shiny
    //  fill(140, 180, 240);
    //   stroke(0,0,30);
    // ellipse(-10, eyeLeft * -9, 5, 4);
    //ellipse(10, eyeRight * -9, 5, 4);
    //fill(0,0,30);
    //ellipse(0, 20, mouthWidth*5, mouthHeight * 5);
    noStroke();
    fill(25, 45, 45); 
    beginShape(TRIANGLES);
    vertex(mouthWidth-2, mouthHeight*5);
    vertex(mouthWidth+2, mouthHeight*5);
    vertex(mouthWidth+6, mouthHeight);
    vertex(mouthWidth-10, mouthHeight*6);
    vertex(mouthWidth-6, mouthHeight*2);
    vertex(mouthWidth-2, mouthHeight*5);
    vertex(mouthWidth-14, mouthHeight*6);
    vertex(mouthWidth-12, mouthHeight*2);
    vertex(mouthWidth-10, mouthHeight*6);
    vertex(mouthWidth-18, mouthHeight*6);
    vertex(mouthWidth-16, mouthHeight*2);
    vertex(mouthWidth-14, mouthHeight*6); 
    vertex(mouthWidth-26, mouthHeight*5);
    vertex(mouthWidth-22, mouthHeight*2);
    vertex(mouthWidth-18, mouthHeight*6);
    vertex(mouthWidth-34, mouthHeight);
    vertex(mouthWidth-30, mouthHeight*5);
    vertex(mouthWidth-26, mouthHeight*5);

    vertex(mouthWidth-2, mouthHeight*-7);
    vertex(mouthWidth+2, (mouthHeight*-5)+20);
    vertex(mouthWidth+6, mouthHeight*-3);
    vertex(mouthWidth-10, mouthHeight*-9);
    vertex(mouthWidth-6, (mouthHeight*-5)+20);
    vertex(mouthWidth-2, mouthHeight*-7);
    vertex(mouthWidth-14, mouthHeight*-9);
    vertex(mouthWidth-12, (mouthHeight*-5)+20);
    vertex(mouthWidth-10, mouthHeight*-9);
    vertex(mouthWidth-18, mouthHeight*-9);
    vertex(mouthWidth-16, (mouthHeight*-5)+20);
    vertex(mouthWidth-14, mouthHeight*-9); 
    vertex(mouthWidth-26, mouthHeight*-7);
    vertex(mouthWidth-22, (mouthHeight*-5)+20);
    vertex(mouthWidth-18, mouthHeight*-9);
    vertex(mouthWidth-34, mouthHeight*-3);
    vertex(mouthWidth-30, (mouthHeight*-5)+20);
    vertex(mouthWidth-26, mouthHeight*-7);


    endShape();

    fill(180, 200, 100);
    beginShape();
    for (int i=0; i<360; i++)
    {
      float x = (nostrils*-1)/4 + sin( radians(i) ) * pow(sin(radians(i)/2), 1.5) *r;
      float y = (nostrils*-1)/4 + cos( radians(i) ) *r;
      vertex(x+3, -y-15);
    }
    endShape();
    //ellipse(0, nostrils * -1, 10, 10);
  }
}

class Nemo {

  PVector pos, vel, acc;
  float maxVel, maxForce, nearTheShiny;
  int nemoSize;

  Nemo() {
    pos = new PVector( random(0, width), random(0, height), 0 );
    vel = new PVector( random(-1, 1), random(-1, 1), 0 );
    acc = new PVector(0, 0, 0);
    maxVel = random(.5, 1.0);
    maxForce = random(0.2, 1.5);    
    nearTheShiny = 200;
    nemoSize     = 20;
  }

  void run() { 

    seek(shiny.get(), nearTheShiny, true);  

    // update position
    vel.add(acc);         // add the acceleration to the velocity
    vel.limit(maxVel);    // clip the velocity to a maximum allowable 
    pos.add(vel);         // add velocity to position
    acc.set(0, 0, 0);       // make sure we set acceleration back to zero!

    toroidalBorders();   
    render();            
  }

  //Get to the Shiny!
  void seek(PVector shiny, float threshold, boolean slowDown) {
    acc.add( steer(shiny, threshold, slowDown) );
  }

  //Steering
  PVector steer (PVector shiny, float threshold, boolean slowDown ) {
    PVector steerForce;  // The steering vector
    shiny.sub(pos);
    float d2 = shiny.mag();

    if ( d2 > 0 && d2 < threshold) {
      shiny.normalize();
      if ( (slowDown) && d2 < threshold/2 ) shiny.mult( maxVel * (threshold/stageWidth) );
      else shiny.mult(maxVel);
      shiny.sub(vel);
      steerForce = shiny.get();
      steerForce.limit(maxForce);
    }
    else {
      steerForce = new PVector(0, 0, 0);
    }
    return steerForce;
  }

  //keep fishies on screen
  void toroidalBorders() {
    if (pos.x < 0   ) pos.x = stageWidth;
    if (pos.x > stageWidth) pos.x = 0;
    if (pos.y < 0   ) pos.y = stageHeight;
    if (pos.y > stageHeight) pos.y = 0;
  }

  void render() {
    stroke(120, 190, 200);
    fill(120, 190, 200);
    ellipse(pos.x, pos.y, nemoSize/(int(poseScale)+1), nemoSize/(int(poseScale)+1));
   line(pos.x, pos.y, pos.x-(vel.x*nemoSize/(int(poseScale)+1)), pos.y-(vel.y*nemoSize/(int(poseScale)+1)) );
  }
}

// OSC CALLBACK FUNCTIONS

public void found(int i) {
  println("found: " + i);
  found = i;
}

public void poseScale(float s) {
  println("scale: " + s);
  poseScale = s;
}

public void posePosition(float x, float y) {
  println("pose position\tX: " + x + " Y: " + y );
  posePosition.set(x, y, 0);
}

public void poseOrientation(float x, float y, float z) {
  println("pose orientation\tX: " + x + " Y: " + y + " Z: " + z);
  poseOrientation.set(x, y, z);
}

public void mouthWidthReceived(float w) {
  println("mouth Width: " + w);
  mouthWidth = w;
}

public void mouthHeightReceived(float h) {
  println("mouth height: " + h);
  mouthHeight = h;
}

public void eyeLeftReceived(float f) {
  println("eye left: " + f);
  eyeLeft = f;
}

public void eyeRightReceived(float f) {
  println("eye right: " + f);
  eyeRight = f;
}

public void eyebrowLeftReceived(float f) {
  println("eyebrow left: " + f);
  eyebrowLeft = f;
}

public void eyebrowRightReceived(float f) {
  println("eyebrow right: " + f);
  eyebrowRight = f;
}

public void jawReceived(float f) {
  println("jaw: " + f);
  jaw = f;
}

public void nostrilsReceived(float f) {
  println("nostrils: " + f);
  nostrils = f;
}

// all other OSC messages end up here
void oscEvent(OscMessage m) {
  if (m.isPlugged() == false) {
    println("UNPLUGGED: " + m);
  }
}

