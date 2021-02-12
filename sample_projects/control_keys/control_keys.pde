/*
  SAMPLE 02: CONTROL KEYS
  
  This sketch allows you to control the robot in real time using ASDW keys!
  
  Instructions:
    - Follow the same setup as in Sample 01
  
  A project by Jose Luis Garcia del Castillo. More info on https://github.com/RobotExMachina
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

PVector dir;
float dist = 50;

void setup() {
  size(400, 200);
  
  // Start a websocket connection with the Bridge
  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge?name=Processing");
  
  // Initialize the wrapper class with the socket
  bot = new MachinaRobot(wsc);
  
  // Send some initial instructions
  bot.Message("Initializing robot...");
  bot.SpeedTo(150);
  bot.PrecisionTo(1);
  
  println("Connected to Bridge");
}

void draw() {
  background(0);
  text("Press ASDW QE keys to move the robot.", 20, 20);
}

void keyPressed() {
  
  switch(key) {
    case 'h': 
      thread("helloRobot");  // threading the request to send a message to the robot
      break;
    
    case 'a':
      dir = new PVector(0, -dist, 0);
      thread("moveRobot");
      break;
      
    case 'd':
      dir = new PVector(0, dist, 0);
      thread("moveRobot");
      break;
      
    case 's':
      dir = new PVector(dist, 0, 0);
      thread("moveRobot");
      break;
      
    case 'w':
      dir = new PVector(-dist, 0, 0);
      thread("moveRobot");
      break;
      
    case 'q':
      dir = new PVector(0, 0, -dist);
      thread("moveRobot");
      break;
      
    case 'e':
      dir = new PVector(0, 0, dist);
      thread("moveRobot");
      break;
  }
}

void helloRobot() {
  bot.Message("Hello Robot from Machina!");  // displays a message on the robot
}

void moveRobot() {
  bot.Move(dir.x, dir.y, dir.z);
}

// This is an event like onMouseClicked. 
// If you chose to use it, it will be executed whenever a message is received from the Machina Bridge. 
void webSocketEvent(String msg) {
  println("Message from the Bridge: " + msg);
}
