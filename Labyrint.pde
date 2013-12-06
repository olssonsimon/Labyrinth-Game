import cc.arduino.*;
import processing.serial.*;
import cc.arduino.*;
import java.awt.AWTException;
import java.awt.Robot;
 
Robot robot;
Arduino arduino;
ArrayList<Wall> walls;

int redPin = 11;
int greenPin = 10;
int bluePin = 9;

int currentColor = 0;

int[][] level1 =
{{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
{1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};

void setup() {
  size(600, 600);
  background(100);
  walls  = new ArrayList<Wall>();
  arduino = new Arduino(this, Arduino.list()[5], 115200);

  arduino.pinMode(redPin, Arduino.OUTPUT);
  arduino.pinMode(greenPin, Arduino.OUTPUT);
  arduino.pinMode(bluePin, Arduino.OUTPUT);
    
  for (int i = 0; i < 12; i++) {
   for (int j = 0; j < 12; j++) {
    if (level1[i][j] == 1) {
      // Create a wall
      Wall w = new Wall(180, i*50, j*50, 50);
      walls.add(w);
      w.drawMe(0);
    } else {
      // Create a rect
      fill(100);
      rect(i*50, j*50, 50, 50);
    }
   } 
  }
  placeMouseAtStart();
}

void draw() {
  drawMovement();
  int red = 0;
  int yellow = 0;
  int black = 0;
  for (Wall w: walls) {
    int val = w.isMouseOver(w);
    w.drawMe(val);
    if(val == 1) {
      yellow++;
    }else if (val == 2){
      red++;
    }else if(val == 3){
      black++;
    }
  }
  chooseColor(black, red, yellow);
  delay(10);
}

void setColor(int red, int green, int blue)
{
  // Invert the colors and write them
  arduino.analogWrite(redPin, 255 - red);
  arduino.analogWrite(greenPin, 255 - green);
  arduino.analogWrite(bluePin, 255 - blue);
}

// Doesn't really work...
void placeMouseAtStart() {
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }
  robot.mouseMove(400, 120); 
}

void chooseColor(int black, int red, int yellow){
  if (black > 0){
    if(!isSameColor(currentColor, 3)) {
      setColor(255, 255, 255);
      currentColor = 3;
    }
  }else if(red > 0){ 
    if (!isSameColor(currentColor, 2)){
      setColor(255, 0, 0);
      currentColor = 2;
    }
  }else if(yellow > 0){
    if(!isSameColor(currentColor, 1)) {
      setColor(255, 140, 0);
      currentColor = 1;
    }
  }else{
    if(!isSameColor(currentColor, 0)) {
      setColor(0, 255, 0);
      currentColor = 0;  
    }
  }
}

boolean isSameColor(int currColor, int newColor){
  if(currColor == newColor){
    return true;
  }else {
    return false;
  }
}

void drawMovement() {
  fill(255);
  ellipse(mouseX, mouseY, 25, 25);
  stroke(255);
}

class Wall {
  
  color c;
  int xpos;
  int ypos;
  int size;
 
 Wall(color col, int x, int y, int s) {
   c = col;
   xpos = x;
   ypos = y;
   size = s;
 }
 
 void drawMe(int val) {
   if (val == 0) {
     fill(this.c);
   } else if (val == 1) {
     fill(245, 238, 30);
   } else if (val == 2) {
     fill(255, 3, 3); 
   } else {
     fill(0);
   }
   rect(this.xpos, this.ypos, this.size, this.size);
 }
 
 // 0 = ok, 1 = yellow, 2 = red, 3 = dead
 int isMouseOver(Wall w) {
   if ((mouseX >= this.xpos && mouseX <= this.xpos+this.size) &&
        (mouseY >= this.ypos && mouseY <= this.ypos+this.size)) {
     return 3;
   } else if ((mouseX >= this.xpos-10 && mouseX <= this.xpos+this.size+10) &&
               (mouseY >= this.ypos-10 && mouseY <= this.ypos+this.size+10)) {
     w.direction();
     return 2;
   } else if ((mouseX >= this.xpos-20 && mouseX <= this.xpos+this.size+20) &&
               (mouseY >= this.ypos-20 && mouseY <= this.ypos+this.size+20)) {
     w.direction();
     return 1;
   } 
   return 0;
 }
 
 // First element:  0 = left, 1 = right
 // Second element: 0 = up, 1 = down
 int[] direction() {
   int x;
   int y;
   if (mouseX <= this.xpos) {
     x = 0;
   } else {
     x = 1; 
   }
   if (mouseY <= this.ypos) {
     y = 0;
   } else {
     y = 1; 
   }
   //println("x = ", x, " y = ", y);
   int[] d = {x, y};
   return d;
 }
}


