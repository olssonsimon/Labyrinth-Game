import cc.arduino.*;
import processing.serial.*;
import cc.arduino.*;
import java.awt.AWTException;
import java.awt.Robot;
import ddf.minim.*;

Minim minim;
AudioPlayer win;
AudioPlayer gameover;
AudioPlayer ohcrap;
 
Robot robot;
Arduino arduino;
ArrayList<Wall> walls;

int lives = 3;

int redPin = 11;
int greenPin = 10;
int bluePin = 9;

int leftMotor = 6;
int rightMotor = 3;
int topMotor = 13;
int bottomMotor = 5;

int currentColor = 0;

int prevx;
int prevy;

PImage img = loadImage("/Users/simonolsson/Documents/Processing/Labyrint/apple.png");
PImage pig = loadImage("/Users/simonolsson/Documents/Processing/Labyrint/pig.png");

int[][] oldlevel =
{{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
{1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};

int[][] level1 =
{{1, 1, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 1}, 
{1, 0, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 0, 1}, {1, 0, 0, 0, 0, 0, 1},
{1, 0, 1, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 0, 1}, {1, 1, 1, 1, 1, 1, 1}};

void setup() {
  size(1200, 700);
  background(100);
  walls  = new ArrayList<Wall>();
  arduino = new Arduino(this, Arduino.list()[5], 115200);
  
  minim = new Minim(this);
  win = minim.loadFile("/Users/simonolsson/Documents/Processing/Labyrint/nom.mp3");
  gameover = minim.loadFile("/Users/simonolsson/Documents/Processing/Labyrint/gameover.mp3");
  ohcrap = minim.loadFile("/Users/simonolsson/Documents/Processing/Labyrint/ohcrap.mp3");
  
  arduino.pinMode(redPin, Arduino.OUTPUT);
  arduino.pinMode(greenPin, Arduino.OUTPUT);
  arduino.pinMode(bluePin, Arduino.OUTPUT);
  
  arduino.pinMode(leftMotor, Arduino.OUTPUT);
  arduino.pinMode(rightMotor, Arduino.OUTPUT);
  arduino.pinMode(topMotor, Arduino.OUTPUT);
  arduino.pinMode(bottomMotor, Arduino.OUTPUT);
    
  for (int i = 0; i < 12; i++) {
   for (int j = 0; j < 7; j++) {
     // Add the apple
     if (j == 5 && i == 10) {
       image(img, i * 100, j * 100);
     }
      if (level1[i][j] == 1) {
        // Create a wall
        Wall w = new Wall(180, i*100, j*100, 100);
        walls.add(w);
        w.drawMe(0);
      }
   } 
  }
  placeMouse(200, 200);
  prevx = 200;
  prevy = 200;
}

void draw() {
  cursor(pig);
  //moveMouse();
  drawMovement();
  int red = 0;
  int yellow = 0;
  int black = 0;
  // Check victory
  if ((mouseX >= 1000 && mouseX <= 1100) && (mouseY >= 500 && mouseY <= 600)) {
    frame.setTitle("Victory!");
    play(win);
    while(1 == 1);
  }
    
  for (Wall w: walls) {
    int val = w.isMouseOver();
    w.drawMe(val);
    if(val == 1) {
      yellow++;
    } else if (val == 2) {
      red++;
    } else if(val == 3) {
      if (lives > 0) {
       // Play sound when life is lost 
       play(ohcrap);
      }
      black++;
    }
  }
  
  chooseColor(black, red, yellow);

  if (lives <= 0) {
     play(gameover);
     lives = 3;
     int i = 0;
     // Lock mouse in place for a while
     while (10000 > i++) {
       placeMouse(200, 200);
     }
  }
  String title = "Labyrint - Lives: " + lives;
  frame.setTitle(title);
  delay(10);
}

// not used atm
void moveMouse() {
  if (mouseX > prevx + 10) {
    println("hej");
    prevx = prevx + 5;
    placeMouse(prevx, mouseY);
  } else if (mouseX <= prevx - 10) {
    prevx = prevx - 5;
    placeMouse(prevx, mouseY);
  } else {
    prevx = mouseX;
  }
  
  if (mouseY > prevy + 10) {
    prevy = prevy + 5;
    placeMouse(mouseX, prevy);
  } else if (mouseY <= prevy - 10) {
    prevy = prevy - 5;
    placeMouse(mouseX, prevy);
  } else {
    prevy = mouseY; 
  }
  
  // for debug
  println("MouseX: " + mouseX + " prevx: " + prevx + "MouseY: " + mouseY + " prevy: " + prevy);
}

void setColor(int red, int green, int blue)
{
  // Invert the colors and write them
  arduino.analogWrite(redPin, 255 - red);
  arduino.analogWrite(greenPin, 255 - green);
  arduino.analogWrite(bluePin, 255 - blue);
}

void placeMouse(int x, int y) {
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }
  robot.mouseMove(x, y); 
}

void chooseColor(int black, int red, int yellow){
  if (black > 0){
    if(!isSameColor(currentColor, 3)) {
      setColor(255, 255, 255);
      currentColor = 3;
      lives--;
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
      stopMotors();  
    }
  }
}

boolean isSameColor(int currColor, int newColor){
  if(currColor == newColor){
    return true;
  }
  return false;
}

void drawMovement() {
  fill(255);
  ellipse(mouseX, mouseY, 15, 15);
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
 int isMouseOver() {
   if ((mouseX >= this.xpos && mouseX <= this.xpos+this.size) &&
        (mouseY >= this.ypos && mouseY <= this.ypos+this.size)) {
     return 3;
   } else if ((mouseX >= this.xpos-10 && mouseX <= this.xpos+this.size+10) &&
               (mouseY >= this.ypos-10 && mouseY <= this.ypos+this.size+10)) {
     this.vibrate(2);
     return 2;
   } else if ((mouseX >= this.xpos-20 && mouseX <= this.xpos+this.size+20) &&
               (mouseY >= this.ypos-20 && mouseY <= this.ypos+this.size+20)) {
     this.vibrate(1);
     return 1;
   } 
   return 0;
 }
 
 // First element:  0 = left, 1 = right
 // Second element: 0 = up, 1 = down
 void vibrate(int i) {
   int motorSpeed = 100;
   
   if (i == 2) {
     motorSpeed = 250;
   }
   
   if (mouseX <= this.xpos) {
     arduino.analogWrite(leftMotor, motorSpeed);
   } else {
     arduino.analogWrite(rightMotor, motorSpeed);
   }
   if (mouseY <= this.ypos) {
     arduino.analogWrite(topMotor, motorSpeed);
   } else {
     arduino.analogWrite(bottomMotor, motorSpeed);
   }
 }
}

void stopMotors() {
  arduino.analogWrite(leftMotor, 0);
  arduino.analogWrite(rightMotor, 0);
  arduino.analogWrite(topMotor, 0);
  arduino.analogWrite(bottomMotor, 0);
}

void play(AudioPlayer player) {
  if (!player.isPlaying()) {
    player.rewind();
    player.play();
  }
}
