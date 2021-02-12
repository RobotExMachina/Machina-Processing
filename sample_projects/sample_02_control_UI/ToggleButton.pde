class ToggleButton {

  float x, y;
  float w, h;
  String shapeName;
  PShape shape;
  String callback;
  boolean hover = false;
  boolean clicking = false;
  boolean toggled = false;

  ToggleButton(float x, float y, float w, float h, String shapeName, String callback) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.shapeName = shapeName;
    this.callback = callback;

    initialize();
  }

  void initialize() {
    shape = loadShape(this.shapeName + ".svg");
    shape.disableStyle();
  }

  void run() {
    checkMouse();
    render();
    
    //// This is super hardcoded, but oh well...
    // active() may return true even if the server stopped (socket is still active)
    //this.toggled = socket != null && socket.active();
  }

  void checkMouse() {
    hover = isInside(mouseX, mouseY);
    clicking = hover && mousePressed;
  }

  void checkClick() {
    if (isInside(mouseX, mouseY)) 
      press();
  }

  void press() {
    thread(callback);
  }

  void render() {
    pushStyle();
    shapeMode(CENTER);
    pushStyle();
    noStroke();
    if (this.toggled) {
      if (clicking) {
        fill(359, 100, 100);
      } else if (hover) {
        fill(359, 100, 85);
      } else {
        fill(120, 85, 75);
      }
    } else {
      if (clicking) {
        fill(120, 85, 100);
      } else if (hover) {
        fill(120, 85, 75);
      } else {
        fill(359, 100, 85);
      }
    }
    shape(shape, this.x, this.y, this.w, this.h);
    popStyle();
  }

  boolean isInside(float xpos, float ypos) {
    return xpos > x - 0.5 * w && xpos < x + 0.5 * w 
      && ypos > y - 0.5 * h && ypos < y + 0.5 * h;
  }
}
