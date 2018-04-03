String[] lines;
int index = 0;

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(20);
  lines = loadStrings("datat.txt");
}

void draw() {
  if (index < lines.length) {
    String[] pieces = split(lines[index], '\t');
    String[] pieces2 = split(lines[index+1], '\t');
      
    int x = int(pieces[0]) * 2;
    int y = int(pieces2[0]) * 2;
    point(x, y);
    
    // Go to the next line for the next run through draw()
    index = index + 2;
  }
}