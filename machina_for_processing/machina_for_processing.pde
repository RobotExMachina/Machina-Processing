/*
  A simple example on how to use the Machina wrapper class to drive robots in 
  real-time through Processing.
  
  Instructions:
    - Download and execute the Machina Bridge App from https://github.com/RobotExMachina/Machina-Bridge
    - Run it and connect to your physical/virtual robot.
    - Download the WebSockets library for Processing from the contributions manager.
    - Run this sketch. You should see a message pop up on the console log of your robot.
    - Build your own project starting with this bolierplate. 
    - See sample files in this repo for more ellaborate examples. 
    
  See this repo's README for (hopefully) some video tutorial. 
  
  A project by Jose Luis Garcia del Castillo. More info on https://github.com/RobotExMachina
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

void setup() {
  // Start a websocket connection with the Bridge
  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge");
  
  // Initialize the wrapper class with the socket
  bot = new MachinaRobot(wsc);
}

void draw() {
  
}

void keyPressed() {
  if (key == 'h') {
    thread("helloRobot");  // threading the request to send a message to the robot
  }
}

void helloRobot() {
  bot.Message("Hello Robot!");  // displays a message on the robot
}

//This is an event like onMouseClicked. If you chose to use it, it will be executed whenever the server sends a message 
void webSocketEvent(String msg) {
  println("Message from the Bridge: " + msg);
}
