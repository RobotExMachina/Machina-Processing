/*
  SAMPLE 02: CONTROL UI
  
  This sketch displays a visual UI with buttons to control the motion of a robot in real time.  
  
  Instructions:
    - Follow the same setup as in Sample 01
  
  A project by Jose Luis Garcia del Castillo. More info on https://github.com/RobotExMachina
 */

import websockets.*;

WebsocketClient wsc;
MachinaRobot bot;

String robotBrand = "ABB";  // replace with "UR" if needed

float inc = 50;

ArrayList<ClickButton> arrows;
ToggleButton connectButton;
Console console;
PFont neon24;

void setup() {
  size(500, 800);
  colorMode(HSB, 360, 100, 100, 100);
  shapeMode(CENTER);
  rectMode(CENTER);
  
  neon24 = loadFont("Neon80s-24.vlw");
  textFont(neon24);
  textAlign(CENTER, CENTER);
  
  println("Icons made by Freepik from www.flaticon.com and Rami McMin from http://www.ramimcm.in/");
  println("Neon80 font by https://www.dafont.com/neon-80s.font");

  arrows = new ArrayList<ClickButton>();

  arrows.add(new ClickButton(200, 100, 50, 50, "up-arrow", "moveXNeg"));
  arrows.add(new ClickButton(100, 100, 35, 35, "diagonal-arrow-1", "moveXNegYNeg"));
  arrows.add(new ClickButton(100, 200, 50, 50, "left-arrow", "moveYNeg"));
  arrows.add(new ClickButton(100, 300, 35, 35, "diagonal-arrow", "moveXPosYNeg"));
  arrows.add(new ClickButton(200, 300, 50, 50, "down-arrow", "moveXPos"));
  arrows.add(new ClickButton(300, 300, 35, 35, "diagonal-arrow-2", "moveXPosYPos"));
  arrows.add(new ClickButton(300, 200, 50, 50, "right-arrow", "moveYPos"));
  arrows.add(new ClickButton(300, 100, 35, 35, "diagonal-arrow-3", "moveXNegYPos"));

  arrows.add(new ClickButton(400, 100, 50, 50, "chevron-1", "moveZPos"));
  arrows.add(new ClickButton(400, 200, 50, 50, "chevron", "moveZNeg"));
  
  // arrows.add(new ClickButton(400, 300, 50, 50, "home", "axesHome"));
  
  arrows.add(new ClickButton(100, 400, 50, 50, "add-circular-button", "increaseMotion"));
  arrows.add(new ClickButton(300, 400, 50, 50, "minus-circular-button", "decreaseMotion"));

  
  console = new Console(250, 600, 350, 250, 10, "Consolas-14.vlw");
  
  // Initialize the Websocket client and the Machina robot
  startCommunication();
}

void draw() {
  background(0, 0, 100);
  
  for (ClickButton b : arrows) {
    b.run();
  }
  
  console.run();
  
  pushStyle();
  fill(0);
  text(inc + " mm", 200, 400);
  popStyle();
  
}

void mousePressed() {
  for (ClickButton b : arrows) {
    b.checkClick();
  }
}

// -------------------------------------------------------------------------------------------

void startCommunication() {
  println(frameCount + ": Connecting to server");
  
  // Start a websocket connection with the Bridge
  wsc = new WebsocketClient(this, "ws://127.0.0.1:6999/Bridge?name=Processing");
    
  // Initialize the wrapper class with the socket
  bot = new MachinaRobot(wsc);
  
  bot.SpeedTo(50);
  bot.PrecisionTo(1);
  
  console.log("Connected to Bridge");
}

void closeCommunication() {
  println(frameCount + ": Disconnecting from Bridge");
  wsc.dispose();
  bot = null;
  console.log("Disconnecting from Bridge");
}

void toggleConnection() {
  if (bot != null) {
    closeCommunication();
  } else {
    startCommunication();
  }

  connectButton.toggled = (wsc != null);
}

// -------------------------------------------------------------------------------------------

void axesHome() {  
  if (bot != null) {
    if (robotBrand == "ABB") {
      bot.AxesTo(0, 0, 0, 0, 90, 0);
      console.log("AxesTo(0, 0, 0, 0, 90, 0);");
    }
    else if (robotBrand == "UR") {
      bot.AxesTo(0, -90, -90, -90, 90, 90);
      console.log("AxesTo(0, -90, -90, -90, 90, 90);");
    }
  } else {
    console.log("Connect to server before homing");
  }
}

void move(float x, float y, float z) {
  if (bot != null && wsc != null) {
    println(frameCount + ": Move " + x + " " + y + " " + z);
    bot.Move(x, y, z);
    console.log("Move(" + x + ", " + y + ", " + z + ");");
  } else {
    console.log("Connect to server before moving");
  }
}

void increaseMotion() {
  inc += 25;
  console.log("Increased motion step to " + inc + " mm");
}

void decreaseMotion() {
  inc -= 25;
  if (inc < 0) {
    inc = 0;
  }
  console.log("Decreased motion step to " + inc + " mm");
}

// -------------------------------------------------------------------------------------------

void moveXPos() {
  move(inc, 0, 0);
}

void moveXNeg() {
  move(-inc, 0, 0);
}

void moveYPos() {
  move(0, inc, 0);
}

void moveYNeg() {
  move(0, -inc, 0);
}

void moveXPosYPos() {
  move(inc, inc, 0);
}

void moveXNegYPos() {
  move(-inc, inc, 0);
}

void moveXPosYNeg() {
  move(inc, -inc, 0);
}

void moveXNegYNeg() {
  move(-inc, -inc, 0);
}

void moveZPos() {
  move(0, 0, inc);
}

void moveZNeg() {
  move(0, 0, -inc);
}
