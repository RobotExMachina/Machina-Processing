/*
  SAMPLE 06: MOUSE CHASING
  
  This sketch illustrates the difference between Actions 
  being _issued_ and _executed_ in Machina.
  The robot is given orders to follow the mouse when
  the distance to last target is over a certain threshold.
  Blue dots represent _issued_ actions: when the request 
  to move is sent to the robot.
  Red polys represent _executed_ actions: when the robot
  has completed executing the issued action and has reached 
  the target.
  
  Instructions:
    - Follow the same setup as in Sample 01
  
  A project by Jose Luis Garcia del Castillo. 
  More info on https://github.com/RobotExMachina
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

// Virtual plane data
// We will be using pixel coordinates as mm coordinates
String robotBrand = "ABB";
PVector startPoint = new PVector(300, 50, 300);

ArrayList<PVector> mouseTrace = new ArrayList<PVector>();
ArrayList<PVector> targetTrace = new ArrayList<PVector>();
ArrayList<PVector> robotTrace = new ArrayList<PVector>();

PVector lastTarget = new PVector(0, 0, 0);
float minDistance = 40;
boolean isRobotMoving = false;


void setup() {
  pixelDensity(displayDensity());
  size(200, 200);
  stroke(0);
  strokeWeight(3);

  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge?name=Processing");
  bot = new MachinaRobot(wsc);
  
  thread("homeRobot");
}

void draw() {
  background(255);

  drawTraces();
  
  if (isRobotMoving == false) {
    checkMouse();
  }
  
  mouseTrace.add(new PVector(mouseX, mouseY));
  
  //push();
  //fill(0);
  //text("isRobotMoving: " + isRobotMoving, 20, 20);
  //pop();
}

// Is the mouse far enough to make the robot chase it? 
void checkMouse() {
  float d = dist(mouseX, mouseY, lastTarget.x, lastTarget.y);
  if (d > minDistance) {
    lastTarget = new PVector(mouseX, mouseY);
    
    thread("chaseMouse");
  }
}

void chaseMouse() {
  // Note how XY for Processing and the Robot are inverted.
  // In this sketch, we assume the user is looking at the robot frontally, 
  // and the "paper" would be right in between them. 
  bot.MoveTo(startPoint.x + lastTarget.y, startPoint.y + lastTarget.x, startPoint.z);
  
  // Flag the robot as busy
  isRobotMoving = true;
}


void drawTraces() {
  push();
  
  // Draw mouse
  noFill();
  stroke(0, 100);
  strokeWeight(0.5);
  beginShape();
  for (PVector p : mouseTrace) {
    vertex(p.x, p.y);
  }
  endShape();
  
  // Draw targets
  noStroke();
  fill(0, 0, 255, 200);
  for (PVector t : targetTrace) {
    circle(t.x, t.y, 10);
  }
  
  // Draw completed robot motion
  noFill();
  stroke(255, 0, 0, 200);
  strokeWeight(5);
  beginShape();
  for (PVector r : robotTrace) {
    vertex(r.x, r.y);
  }
  endShape();
  
  pop();
}


void mouseReleased() {
  thread("robotDrawingRequest");
}

void keyPressed() {
  if (key == 'h' || key == 'H') {
    thread("homeRobot");
  }
}


void homeRobot() {
  bot.Message("Homing Robot");
  bot.SpeedTo(50);
  bot.Precision(1);
  if (robotBrand == "ABB") {
    bot.AxesTo(0, 0, 0, 0, 90, 0);
  } else if (robotBrand == "UR") {
    bot.AxesTo(0, -90, -90, -90, 90, 90);
  }
  bot.TransformTo(startPoint.x, startPoint.y, startPoint.z, -1, 0, 0, 0, 1, 0);
   
  // Flag the robot as busy
  isRobotMoving = true;
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
  
  // What kind of event was this?
  String eventType = json.getString("event");
  
  // If issued, store the coordinates as a target.
  if (eventType.equalsIgnoreCase("action-issued"))
  {
    // Figure out the robot's position from the action name, 
    // and store it to the target's trace
    String action = json.getString("last");
    String actionName = split(action, '(')[0];
    if (actionName.equalsIgnoreCase("MoveTo") || actionName.equalsIgnoreCase("TransformTo")) {
      String[] coords = split(split(split(action, ')')[0], '(')[1], ',');
      targetTrace.add(new PVector(float(coords[1]) - startPoint.y, float(coords[0]) - startPoint.x, 0));  // note flipped XY
    }
  }
  
  // If executed, and empty queue, draw path and send more actions! 
  if (eventType.equalsIgnoreCase("action-executed"))
  {
    // How many actions are pending? 
    int pendingActions = json.getInt("pendTot");

    // If no actions are pending (everything on the queue has
    // finished executing), decide what to do:
    if (pendingActions == 0) 
    {
      // Figure out the robot's position and store it to the trace
      JSONArray arr = json.getJSONArray("pos");
      float[] coords = arr.getFloatArray();
      robotTrace.add(new PVector(coords[1] - startPoint.y, coords[0] - startPoint.x, 0));  // note flipped XY
      
      // Not busy anymore
      isRobotMoving = false;
      
      // Should start moving again?
      checkMouse();
    }
  }
}
