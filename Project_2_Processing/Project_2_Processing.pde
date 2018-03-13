import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float height_old = 0;
float height_new = 0;
float inByte;
float breath;
String row[] = new String[2];
String inString = "";
String heartbeatString = "";
String breathString = "";
boolean isHeartbeat = false;
int heartbeats = 0;
int time;
int currBPM = 0;
int baseLine = -1;
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
  // set inital background:
  background(0xff);
}


void draw () {
  // everything happens in the serialEvent()
  if (heartbeatString.equals("!")) { 
    stroke(0, 0, 0xff); //Set stroke to blue ( R, G, B)
    inByte = 512;  // middle of the ADC range (Flat Line)
  }
  // If the data is good let it through
  else {
    stroke(0xff, 0, 0); //Set stroke to red ( R, G, B)
    inByte = float(heartbeatString);
  }
  breath = float(breathString);
  println(breath);
  if (inByte > 800) {
    countHeartbeat();
  } 
  else {
    isHeartbeat = false;
  }
  println(inString);
  int currTime = millis() - time;
  if(isBaseLine == true){
    if(currTime > 30000){
      baseLine = (heartbeats / currTime) * 2;
      time = millis();
      heartbeats = 0;
      isBaseLine = false;
    }
  }
  else if (currTime > 15000) {
    currBPM = (heartbeats / currTime) * 4;
    time = millis();
    heartbeats = 0;
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
  if (currBPM != 0) {
    bpm = "BPM: " + currBPM;
  } else {
    bpm = "PLEASE PUT ON HEART RATE MONITOR";
  }
  if(baseLine == -1){
    baselineBPM = "Please wait for baseline bpm";
  }
  else{
    baselineBPM = "Baseline BPM: " + baseLine;
  }
  text(bpm, 250, 350);
  text(baselineBPM, 250, 300);
  fill(50);
}

void countHeartbeat() {
  if (isHeartbeat == false) {
    heartbeats++;
    isHeartbeat = true;
  }
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  inString = myPort.readStringUntil('\n');
  inString = trim(inString);
  row = split(inString, ",");
  heartbeatString = row[0];
  breathString = row[1];
}