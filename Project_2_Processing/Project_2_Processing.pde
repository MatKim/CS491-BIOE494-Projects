import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float height_old = 0;
float height_new = 0;
float inByte = 0;
String inString = "";
boolean isHeartbeat = false;
float heartbeats = 0;
int time;
float currBPM = 0;
float baseLine = -1;
int baseLineTime;
float baseLineHeartbeats = 0;
boolean isBaseLine = true;

void setup () {
  // set the window size:
  size(1000, 400);        

  // List all the available serial ports
  println(Serial.list());
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  time = millis();
  baseLineTime = millis();
  // set inital background:
  background(0xff);
}


void draw () {
  // everything happens in the serialEvent()
  if (inString.equals("!")) { 
    stroke(0, 0, 0xff); //Set stroke to blue ( R, G, B)
    inByte = 512;  // middle of the ADC range (Flat Line)
  }
  // If the data is good let it through
  else {
    stroke(0xff, 0, 0); //Set stroke to red ( R, G, B)
    inByte = float(inString);
  }
  if (inByte > 800) {
    if (isBaseLine==true) {
      if (isHeartbeat == false) {
        baseLineHeartbeats++;
        isHeartbeat = true;
      }
    } 
    countHeartbeat();
  } else {
    isHeartbeat = false;
  }

  int currTime = millis() - time;

  if (isBaseLine == true) {
    int currBaseLineTime = millis() - baseLineTime;
    if (currBaseLineTime > 30000) {
      baseLine = (baseLineHeartbeats / currTime) * 1000 * 2;
      time = millis();
      heartbeats = 0;
      isBaseLine = false;
    }
  }
  if (currTime > 4000) {
    currBPM = (heartbeats / currTime) * 1000 * 15;
    time = millis();
    heartbeats = 0;
    println(currBPM);
  }
  //Map and draw the line for new data point
  inByte = map(inByte, 0, 1023, 0, height);
  height_new = height - inByte; 
  line(xPos - 1, height_old, xPos, height_new);
  height_old = height_new;

  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
    background(0xff);
  } else {
    // increment the horizontal position:
    xPos += 2;
  }
  textSize(24);
  String bpm;
  String baselineBPM;

  bpm = "BPM: " + currBPM;
  if (baseLine == -1) {
    baselineBPM = "Please wait for baseline bpm";
  } else {
    baselineBPM = "Baseline BPM: " + baseLine;
  }
  text(bpm, 250, 350);
  text(baselineBPM, 250, 300);
  fill(50);
}

void countHeartbeat() {
  println("COUNT A HEARTBEAT: " + heartbeats);
  if (isHeartbeat == false) {
    println("We GOT A HEARTBEAT");
    heartbeats++;
    isHeartbeat = true;
  }
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  inString = myPort.readStringUntil('\n');
  inString = trim(inString);
}