/*
  A convenience class to streamline sending socket messages to
  Machina's Bridge app, mimicking the core library's API.
  
  You can talk to the Bridge directly by sending a string in the form
  of an instruction, this just makes it faster to write. 
  
  This code needs the Websockets library to work. 
  Go to Sketch > Import Library... > Add Library... > Contribution Manager >
    > (search for Websockets library and install it)
  Alternatively, you can install it manually from:
    https://github.com/alexandrainst/processing_websockets
*/

class MachinaRobot {
  
  private WebsocketClient socket;
  
  MachinaRobot(WebsocketClient socket) {
    this.socket = socket;
  }
  
  void Move(float xInc, float yInc) {
    socket.sendMessage("Move(" + xInc + "," + yInc + ",0);");
  }
  
  void Move(float xInc, float yInc, float zInc) {
    socket.sendMessage("Move(" + xInc + "," + yInc + "," + zInc + ");");
  }
  
  void MoveTo(float x, float y, float z) {
    socket.sendMessage("MoveTo(" + x + "," + y + "," + z + ");");
  }
  
  void TransformTo(float x, float y, float z, double x0, double x1, double x2, double y0, double y1, double y2) {
    socket.sendMessage("TransformTo(" + x + "," + y + "," + z + "," +
        x0 + "," + x1 + "," + x2 + "," +
        y0 + "," + y1 + "," + y2 + ");");
  }
  
  void Rotate(float x, float y, float z, float angleInc) {
    socket.sendMessage("Rotate(" + x + "," + y + "," + z + "," + angleInc + ");");
  }
  
  void RotateTo(double x0, double x1, double x2, double y0, double y1, double y2) {
    socket.sendMessage("RotateTo(" + x0 + "," + x1 + "," + x2 + "," +
        y0 + "," + y1 + "," + y2 + ");");
  }
  
  void Axes(double j1, double j2, double j3, double j4, double j5, double j6) {
    socket.sendMessage("Axes(" + j1 + "," + j2 + "," + j3 + "," + j4 + "," + j5 + "," + j6 + ");");
  }
  
  void AxesTo(double j1, double j2, double j3, double j4, double j5, double j6) {
    socket.sendMessage("AxesTo(" + j1 + "," + j2 + "," + j3 + "," + j4 + "," + j5 + "," + j6 + ");");
  }
  
  void Speed(double speedInc) {
    socket.sendMessage("Speed(" + speedInc + ");");
  }
  
  void SpeedTo(double speed) {
    socket.sendMessage("SpeedTo(" + speed + ");");
  }
  
  void Acceleration(double accelerationInc) {
    socket.sendMessage("Acceleration(" + accelerationInc + ");");
  }
  
  void AccelerationTo(double acceleration) {
    socket.sendMessage("AccelerationTo(" + acceleration + ");");
  }
  
  void Precision(double precisionInc) {
    socket.sendMessage("Precision(" + precisionInc + ");");
  }
  
  void PrecisionTo(double precision) {
    socket.sendMessage("PrecisionTo(" + precision + ");");
  }
  
  void MotionMode(String mode) {
    socket.sendMessage("MotionMode(\"" + mode + "\");");
  }
  
  void Message(String msg) {
    socket.sendMessage("Message(\"" + msg + "\");");
  }
  
  void Wait(int millis) {
    socket.sendMessage("Wait(" + millis + ");");
  }
 
  void PushSettings() {
    socket.sendMessage("PushSettings();");
  }
  
  void PopSettings() {
    socket.sendMessage("PopSettings();");
  }
  
  void DefineTool(String name, 
    double x, double y, double z, 
    double x0, double x1, double x2, double y0, double y1, double y2, 
    double weight, 
    double cogX, double cogY, double cogZ) 
  {
    socket.sendMessage("DefineTool(\"" + name + "\"," + x + "," + y + "," + z + "," + x0 + "," + x1 + "," + x2 + "," + y0 + ","+ y1 + ","+ y2 + "," + weight + "," + cogX + "," + cogY + "," + cogZ + ");");
  }
  
  void AttachTool(String name) {
    socket.sendMessage("AttachTool(\"" + name + "\");");
  }
  
  void DetachTool() {
    socket.sendMessage("DetachTool()");
  }
  
  void WriteDigital(int pin, boolean on) {
    socket.sendMessage("WriteDigital(" + pin + "," + on + ");");
  }
  
  void WriteAnalog(int pin, double value) {
    socket.sendMessage("WriteAnalog(" + pin + "," + value + ");");
  }
}
