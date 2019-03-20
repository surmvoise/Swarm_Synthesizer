import codeanticode.syphon.*;
SyphonServer server;

Flock flock;

float v1;
float v2;
float v3;
float v4;
float v5;
float v6;
float v7;
float v8;

void setup() {

  size(1014, 720, OPENGL);
  noCursor();
  smooth();
  colorMode(HSB, 360, 100, 100);

  initVSynth();

  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");

  midi.direct[0] = 0.1;
  midi.direct[1] = 0.33;
  midi.direct[2] = 0.66;
  midi.direct[3] = 0.33;
  midi.direct[4] = 0.33;
  midi.direct[5] = 0.04;
  midi.direct[6] = 0.00;
  midi.direct[7] = 0.00;

  midi.direct[64] = 0;
  midi.direct[65] = 0;
  midi.direct[66] = 0;
  midi.direct[67] = 0;
  midi.direct[68] = 0;

  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 1; i++) {
    flock.addBoid(new Boid( width/2, height/2 ));
  }
}

void draw() {

  updateVSynth();

  //maxspeed
  v1 = midi.eased(0, 0, 15);
  //maxforce
  v2 = midi.eased(1, 0.01, 0.4);
  //separation & inverted cohesion
  v3 = midi.eased(2, 0, 15);
  //align 
  v4 = midi.eased(3, 0, 15);
  //seek
  v5 = midi.eased(4, 0, 15);
  //tail
  v6 = midi.eased(5, 2, 50);
  //color
  v7 = midi.eased(6, 0, 360);
  //bg color
  v8 = midi.eased(7, 0, 360);

  //add one
  if (midi.value(64, 0, 127) == 127) {
    flock.addBoid(new Boid( random(width), random(height) ) );
  }

  //add five
  if (midi.value(65, 0, 127) == 127) {
    for (int i = 0; i < 5; i++) {
      flock.addBoid(new Boid(random(width), random(height)));
    }
  }

  //add fifty
  if (midi.value(66, 0, 127) == 127) {
    for (int i = 0; i < 50; i++) {
      flock.addBoid(new Boid( random(width), random(height) ));
    }
  }

  //kill random
  if (midi.value(67, 0, 127) == 127) {
    for (int i = 0; i < 8; i++) {
      flock.killRandomBoid();
    }
  }

  //kill all
  if (midi.value(68, 0, 127) == 127) {
    flock.killAll();
  }

  background(v8, 70, 20);
  flock.run();

  server.sendScreen();
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX, mouseY));
}

void keyPressed() {

  //add one at center
  if ( key == '1' ) {
    flock.addBoid(new Boid( width/2, height/2 ) );
  }
}
