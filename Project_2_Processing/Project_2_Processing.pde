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
float heartbeats = 0.0;
int time;
float currBPM = 0.0;
float baseLine = -1.0;
boolean isBaseLine = true;
float currheartbeat = 0.0;

void setup () {
  // set the window size:
  size(1000, 400);        

  // List all the available serial ports
  println(Serial.list());
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[1], 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  time = millis();
  // set inital background:
  background(0xff);
}


void draw () {
  ////println (inString);
  //if (inString.equals("!"))
  //{
  //  stroke(0, 0, 0xff);
  //  inByte = 512;
  //  inByte = map(inByte, 0, 1023, 0, height);
  //  //println (inByte);
  //  height_new = height - inByte; 
  //  line(xPos - 1, height_old, xPos, height_new);
  //  height_old = height_new;
  //  return;

  //}
  //{

  //}

  // everything happens in the serialEvent()
  if (inString.equals("!")) { 
    stroke(0, 0, 0xff); //Set stroke to blue ( R, G, B)
    inByte = 512;  // middle of the ADC range (Flat Line)
  }
  // If the data is good let it through
  else {
    stroke(0xff, 0, 0); //Set stroke to red ( R, G, B)
    row = split(inString, ",");
    heartbeatString = row[0];
    breathString = row[1];
    inByte = float(heartbeatString);
    //println ("heartbeatString" + inByte);
  }
  breath = float(breathString);
  //println(breath);
  if (inByte > 800.00) {
    countHeartbeat();
  } else {
    isHeartbeat = false;
  }
  //println(inString);
  int currTime = millis() - time;
  println (currTime);
  if (isBaseLine == true) {
    if (currTime > 30000) {
      println (heartbeats + ", " + currTime);
      baseLine = heartbeats * 2.0;
      time = millis();
      heartbeats = 0;
      isBaseLine = false;
    }
  } 
  else if (currTime > 5000) {
    currBPM = heartbeats  * 12.0;
    time = millis();
    heartbeats = 0;
    
  }
  //Map and draw the line for new data point
  inByte = map(inByte, 0, 1023, 0, height);
  //println (inByte);
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
  String fitnessStat = "Heart Rate Zone: ";
  String stressLevel = "Stress Level: ";
  float maxHR = 199.0;
  
  if (currBPM != 0 && baseLine != -1)
  {
      if (currBPM >= 0.9 * maxHR)
      {
        fitnessStat += "Max";
      }
      else if (currBPM >= 0.8 * maxHR)
      {
        fitnessStat += "Hard";
      }
      else if (currBPM >= 0.7 * maxHR)
      {
        fitnessStat += "Moderate";
      }
      else if (currBPM >= 0.6 * maxHR)
      {
        fitnessStat += "Light";
      }
      else if (currBPM >= 0.5 * maxHR)
      {
        fitnessStat += "Very Light";
      }   
      else
      {
        fitnessStat += "Resting";
      }
      if (currBPM < baseLine)
        stressLevel += "Calm";
      if (currBPM >= 1.3 * baseLine)
        stressLevel += "Definitely Not Calm";
      
  }
  else 
  {
    fitnessStat += "Not yet";
  }
  
  if (currBPM != 0) {
    bpm = "BPM: " + currBPM;
  } else {
    bpm = "PLEASE PUT ON HEART RATE MONITOR";
  }
  if (baseLine == -1) {
    baselineBPM = "Please wait for baseline bpm";
  } else {
    baselineBPM = "Baseline BPM: " + baseLine;
  }
  textSize(16);
  text(stressLevel, 250, 275);
  text(fitnessStat, 250, 300);
  text(baselineBPM, 250, 325);
  text("\n", 250, 350);
  text(bpm, 250, 350);
  fill(50);
}

void countHeartbeat() {
  if (isHeartbeat == false) {
    heartbeats++;
    println (heartbeats);
    isHeartbeat = true;
  }
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  inString = myPort.readStringUntil('\n');
  inString = trim(inString);
}