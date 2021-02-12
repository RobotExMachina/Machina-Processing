/*
  SAMPLE 04: ENDLESS LOOP
  
  This sketch starts motion in the robot, 
  listens to the execution state, and responds
  with a new set of instructions once done. 
  
  Instructions:
    - Follow the same setup as in Sample 01
  
  A project by Jose Luis Garcia del Castillo. 
  More info on https://github.com/RobotExMachina
 */



import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

float thresholdZ = 250;
float travelDistance = 100;
float currentZ = 0;
boolean pingPong = false;

void setup() {
  size(400, 200);
  
  // Start a websocket connection with the Bridge
  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge?name=Processing");
  
  // Initialize the wrapper class with the socket
  bot = new MachinaRobot(wsc);
}

void draw() {
  background(0);
  text("Press 's' to start/stop moving the robot up and down!", 20, 20);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    pingPong = !pingPong;
    
    if (pingPong == true) {
      // Threading the request to initialize
      // to avoid halting Processing.
      thread("initializeRobot");
    }
  }
}

void initializeRobot() {
  bot.Message("Let's get dizzy!");  // displays a message on the robot
  bot.SpeedTo(100);
  bot.PrecisionTo(1);
  
}

void moveDown() {
  bot.Move(0, 0, -travelDistance);
}

void moveUp() {
  bot.Move(0, 0, travelDistance);
}

// This is an event like onMouseClicked. 
// If you chose to use it, it will be executed 
// whenever a message is received from the Machina Bridge. 
void webSocketEvent(String msg) {
  println("Message from the Bridge: " + msg);
  
  // The Bridge send messages when actions are 
  //  - Issued (join the queue),
  //  - Released (reached the robot and waiting to be executed),
  //  - Executed (finished executing, or depending on the robot, a bit before).
  // 
  // Let's parse the message to find out if it is an "execution"
  // acknowledgement, and if there are no actions left to execute.
  
  // Let's turn the string message into a JSON object
  JSONObject json = parseJSONObject(msg);

  // Was this an "execute" event?
  String eventType = json.getString("event");
  if (eventType.equalsIgnoreCase("action-executed"))
  {
    // How many actions are pending? 
    int pendingActions = json.getInt("pendTot");

    // If no actions are pending (everything on the queue has
    // finished executing), decide what to do:
    if (pendingActions == 0) 
    {
      // Figure out the robot's position
      JSONArray arr = json.getJSONArray("pos");
      float[] coords = arr.getFloatArray();
      currentZ = coords[2];

      // Decide what to do
      if (pingPong == true) {
        if (currentZ >= thresholdZ) {
          thread("moveDown");
        } else {
          thread("moveUp");
        }
      }

    }
  }
}
