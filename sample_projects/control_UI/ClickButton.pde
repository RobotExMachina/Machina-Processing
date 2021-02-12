class ClickButton {
  
  float x, y;
  float w, h;
  String shapeName;
  PShape shape;
  String callback;
  boolean hover = false;
  boolean clicking = false;
  
  ClickButton(float x, float y, float w, float h, String shapeName, String callback) {
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
  }
  
  void run() {
    checkMouse();
    render();
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
    if (clicking) {
      shape.disableStyle();
      pushStyle();
      noStroke();
      fill(120, 85, 75);
      shape(shape, this.x, this.y, this.w, this.h);
    } else if (hover) {
      shape.disableStyle();
      pushStyle();
      noStroke();
      fill(359, 100, 85);
      shape(shape, this.x, this.y, this.w, this.h);
      popStyle();
    } else {
      shape.enableStyle();
      shape(shape, this.x, this.y, this.w, this.h);
    }
    popStyle();
  }
  
  boolean isInside(float xpos, float ypos) {
    return xpos > x - 0.5 * w && xpos < x + 0.5 * w 
        && ypos > y - 0.5 * h && ypos < y + 0.5 * h;
  }
}
