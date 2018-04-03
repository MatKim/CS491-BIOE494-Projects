BufferedReader reader;
String line;
int x = 0;
import javax.swing.*; 
String TimeBetweenHB;
String BeatsPerMin;
FirstApplet fa;
SecondApplet sa;
float baseLineBPM = 0.0;
float currTime;

void setup() {
  // Open the file from the createWriter() example
  reader = createReader("datat.txt");
  String args1[] = {"Plot device"};
  String args2[] = {"BPM Monitor"};
  fa = new FirstApplet();
  sa = new SecondApplet();
  PApplet.runSketch(args1, fa);
  PApplet.runSketch(args2, sa);
  currTime = millis();
}

void draw() {
} 

public class FirstApplet extends PApplet {
  public void settings() {
    size(450, 450);
  }
  public void setup() {
    background(0);
    stroke(255);
    frameRate(30);
  }
  public void draw() {
    if (x > 450) {
      x = 0;
      clear();
    }
    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) {
      // Stop reading because of an error or file is empty
      redraw();
    } else {
      String[] pieces = split(line, ", ");
      if (pieces.length != 2) {
        redraw();
      } else {
        
        TimeBetweenHB = "Time Between heartbeats:" + pieces[0];
        float y = float(pieces[1]);
        if (millis() - currTime > 30000)
        {
          baseLineBPM = y;
          String baselineBPMText = "Baseline BPM: " + baseLineBPM;
        }
        BeatsPerMin = "BPM: " + y;
        y = 450 - y;

        ellipse(x, y, 2, 2);
        x++;
      }
    }
  }
}

public class SecondApplet extends PApplet {

  public void settings() {
    size(400, 200);
  }
  public void draw() {
    background(0);
    textSize(16);
    this.clear();

    if (TimeBetweenHB != null && BeatsPerMin != null) {
      text(TimeBetweenHB, 50, 50);
      text(BeatsPerMin, 50, 100);
    }
  }
}