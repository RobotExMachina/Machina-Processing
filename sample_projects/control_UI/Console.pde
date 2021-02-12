class Console {

  float x, y;
  float w, h;
  float pad;
  StringList lines;
  String output;
  int maxLines = 14;
  PFont font;
  String fontName;

  Console(float x, float y, float w, float h, float padding, String fontName) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.pad = padding;
    this.fontName = fontName;

    initialize();
  }

  void initialize() {
    this.lines = new StringList();
    this.font = loadFont(this.fontName);
    
    this.log("Machina for Processing UI!");
    this.log("A project by @garciadelcastillo");
    this.log("Connect to the robot to start...");
  }

  void run() {
    this.render();
  }

  void log(String msg) {
    lines.append(msg);
    if (lines.size() > maxLines) {
      lines.remove(0);
    }
    output = "";
    int it = 0;
    for (String line : lines) {
      output += line;
      it++;
      if (it < lines.size()) {
        output += "\n\r";
      }
    }
  }

  void render() {
    pushStyle();
    noStroke();

    stroke(171, 4, 70);
    strokeWeight(4);
    strokeJoin(ROUND);
    fill(220, 23, 20, 75);
    rectMode(CENTER);
    rect(this.x, this.y, this.w, this.h);

    fill(171, 4, 70);
    textFont(this.font);
    textAlign(LEFT, BOTTOM);
    text(this.output, this.x, this.y, this.w - 2 * this.pad, this.h - 2 * this.pad);

    popStyle();
  }
}
