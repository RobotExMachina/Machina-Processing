/*
  A Processing sketch to draw strokes, and send them to the robot via WebSockets
 
 Before runnign this sketch, make sure you are running the attached version of the 
 Machina Bridge App in the `bridgeapp` folder.
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

FloatList traceX = new FloatList();
FloatList traceY = new FloatList();



// Virtual paper data
// We will be using pixel coordinates as mm coordinates
float cornerX = 200, 
      cornerY = 200, 
      cornerZ = 200;

int travelSpeed = 200, 
  drawingSpeed = 50;

float approachDistance = 25;
int approachPrecision = 5, 
  drawingPrecision = 1;

float threshold = 10;

void setup() {
  pixelDensity(displayDensity());
  size(300, 300);
  stroke(0);
  strokeWeight(3);

  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge");
  bot = new MachinaRobot(wsc);
  thread("homeRobot");
}

void draw() {

  background(255);

  drawTrace();
}

void drawTrace() {
  beginShape();
  for (int i = 0; i < traceX.size(); i++) {
    vertex(traceX.get(i), traceY.get(i));
  }
  endShape();
}

void mousePressed() {
  traceX = new FloatList();
  traceY = new FloatList();
  traceX.append(mouseX);
  traceY.append(mouseY);
}

void mouseDragged() {
  float lastX = traceX.get(traceX.size() - 1);
  float lastY = traceY.get(traceY.size() - 1);

  if (dist(lastX, lastY, mouseX, mouseY) > threshold) {
    traceX.append(mouseX);
    traceY.append(mouseY);
  }
}

void mouseReleased() {
  thread("robotDrawingRequest");
}

void keyPressed() {
  if (key == 'h' || key == 'H') {
    thread("homeRobot");
  }
}



void robotDrawingRequest() {
  println("Streaming stroke to the robot");

  // Go above the first drawing point
  bot.PushSettings();
  bot.MotionMode("joint");
  bot.SpeedTo(travelSpeed);
  bot.Precision(approachPrecision);
  // Note we are flipping XY coordinates to translate from display pixel space to physical paper space
  bot.TransformTo(cornerX + traceY.get(0), cornerY + traceX.get(0), cornerZ + approachDistance, -1, 0, 0, 0, 1, 0);  // Note robot XY and processing XY are flipped... 
  bot.PopSettings();

  // Go down to the paper
  bot.PushSettings();
  bot.MotionMode("linear");
  bot.SpeedTo(drawingSpeed);
  bot.Precision(drawingPrecision);
  bot.Move(0, 0, -approachDistance);  // note first point is not included in the stroke model
  
  // Go over all the point
  for (int i = 0; i < traceX.size(); i++) {
    bot.MoveTo(cornerX + traceY.get(i), cornerY + traceX.get(i), cornerZ);  // Note robot XY and processing XY are flipped... 
  }
  
  // Move back up
  bot.Move(0, 0, approachDistance);
  bot.PopSettings();

  homeRobot();  
}

void homeRobot() {
  bot.Message("Homing Robot");
  bot.PushSettings();
  bot.SpeedTo(400);
  bot.AxesTo(0, 0, 0, 0, 90, 0);
  bot.PopSettings();
}


//This is an event like onMouseClicked. If you chose to use it, it will be executed whenever the server sends a message 
void webSocketEvent(String msg) {
  println("Message from the server: " + msg);
}
