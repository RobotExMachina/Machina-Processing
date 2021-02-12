/*
  SAMPLE 05: AUTONOMOUS 3D PRINT
  
  This sketch starts a "3d print" motion of a 
  square cylinder in the air. 
  When auto mode is on, the sketch sends one
  layer at a time, and when the height reaches
  a limit, the robot is reset and starts over.
  
  This example shows more advanced techniques
  on how to listen to execution acknowledgements
  from the robot, and uses them to repond with
  new actions.
  
  Instructions:
    - Follow the same setup as in Sample 01
  
  A project by Jose Luis Garcia del Castillo. 
  More info on https://github.com/RobotExMachina
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

String robotBrand = "ABB";
PVector startPoint = new PVector(300, 50, 300);
float squareSize = 100;
float verticalStep = 50;
float heightLimit = 600;
boolean autoMode = false;

void setup() {
  size(400, 200);

  connect();
}

void draw() {
  background(0);
  text("Press 'i' to initialize the robot", 20, 20);
  text("Press 'l' to trace a square", 20, 40);
  text("Auto mode: " + autoMode + ", press 'a' to switch", 20, 60);
  text("Press 'r' to reconnect", 20, 80);
}

void keyPressed() {
  if (key == 'i' || key == 'I') {
    thread("initializeRobot");  // threading the request to send a message to the robot
  } else if (key == 'l' || key == 'L') {
    thread("traceSquare");
  } else if (key == 'a' || key == 'A') {
    autoMode = !autoMode;
  } else if (key == 'r' || key == 'R') {
    connect();
  }
}

void connect() {
  
  if (wsc != null) {
    wsc.dispose();
    wsc = null;
  }
  
  if (bot != null) {
    bot = null;
  }
  
  // Start a websocket connection with the Bridge
  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge?name=Processing");

  // Initialize the wrapper class with the socket
  bot = new MachinaRobot(wsc);
}

// Sets the robot to a "ready" position
void initializeRobot() {
  println(">> Initializing Robot");
  bot.SpeedTo(150);
  bot.PrecisionTo(5);
  if (robotBrand == "ABB") {
    bot.AxesTo(0, 0, 0, 0, 90, 0);
  } else if (robotBrand == "UR") {
    bot.AxesTo(0, -90, -90, -90, 90, 90);
  }
  bot.Message("Drawing 50x50 squares");
  bot.MotionMode("linear");
  bot.TransformTo(startPoint.x, startPoint.y, startPoint.z, -1, 0, 0, 0, 1, 0);
}

// Performs a square loop
void traceSquare() {
  println(">> Tracing a Square");
  bot.Move(squareSize, 0, 0);
  bot.Move(0, squareSize, 0);
  bot.Move(-squareSize, 0, 0);
  bot.Move(0, -squareSize, 0);
  bot.Move(0, 0, verticalStep);
}




// This is an event like onMouseClicked. 
// If you chose to use it, it will be executed whenever a message is received from the Machina Bridge. 
void webSocketEvent(String msg) {
  println("Message from the Bridge: " + msg);

  // If auto mode is disabled, no need to do anything else here...
  if (!autoMode) return;

  // Let's turn the string message into a JSON object
  JSONObject json = parseJSONObject(msg);

  // Was this an "execute" event?
  String eventType = json.getString("event");
  if (eventType.equalsIgnoreCase("action-executed"))
  {
    // How many actions are pending? 
    int pendingActions = json.getInt("pendTot");

    // If no actions are pending (everything else has been executed), decide what to do
    if (pendingActions == 0) 
    {
      // Figure out the robot's position
      JSONArray arr = json.getJSONArray("pos");
      float[] coords = arr.getFloatArray();
      float zHeight = coords[2];

      // Decide what to do
      if (zHeight >= heightLimit) {
        thread("initializeRobot");
      } else {
        thread("traceSquare");
      }
    }
  }
}
