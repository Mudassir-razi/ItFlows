import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ItFlows extends PApplet {

//showman stuff
int count = 30;    //number of lines
float space;

//calculation variables
float del = 0.2f;
float k, omega1, omega2;
float x[];
float y[];

//plot variable
float x_min = -6;
float x_max = 6;
float y_min = -5;
float y_max = 5;
float offsetX = 2.8f;
float offsetY;
float offsetMultipler = 2.5f;
boolean resetting;

float prev_x_map[];
float prev_y_map[];

//colorizing stuff
float map_minV = 0;
float map_maxV = 13;
int rMax, rMin, gMax, gMin, bMax, bMin;
float minResetTime = 500;
float delTime1 = 0, delTime2 = 0;
float prevDelTime = 0;
boolean bgReset = false;

//menu stuff
int menuWidth = 0;
int ssCount = 0;
ArrayList<String> statement;
ArrayList<String> funny;
String currentStr;
boolean savingNow = false;
float delTime;
float prevTime;
float maxTime = 3000;

public void setup()
{
  
  y_max = x_max * displayHeight/displayWidth;
  y_min = -y_max;
  
  statement = new ArrayList<String>();
  funny = new ArrayList<String>();

  SetStatement();
  SetFunny();
  currentStr = statement.get(2);

  //offsetX = map(displayWidth/3, 0, displayWidth, x_min, x_max);
  //offsetY = map(displayHeight/3, 0, displayHeight, y_min, y_max);

  offsetX = (x_max - x_min)/3;
  offsetY = (y_max - y_min)/3;

  print(x_max);
  print(y_max);
  colorMode(HSB, 100);

  space = abs(x_max - x_min)/(float)count;
  delTime = 0;
  //initialize arrays
  x = new float[count * 4];
  y = new float[count * 4];

  prev_x_map = new float[count * 4];
  prev_y_map = new float[count * 4];

  reset();
  background(0);
}

public void draw()
{ 
  delTime2 = millis();
  if (bgReset)
  {
    background(max(gMax, gMin)- min(gMax, gMin), 42, 22);
    //background(random(0, 200));
    bgReset = false;
  }

  if (!resetting) {
    for (int i = 0; i < count * 4; i++) { 
      if (mousePressed && delTime2 - delTime1 >= minResetTime) {
        delTime1 = millis();
        thread("reset");
        resetting = true;
        currentStr = getText();
        break;
      }
      if (keyPressed)
      {
        if (key == 'c' && !savingNow)
        {
          savingNow = true;
          thread("saveImage");
        }
      }
      float x_map = map(x[i], x_min, x_max, 0, width - menuWidth);
      float y_map = map(y[i], y_min, y_max, 0, height);

      //calculating velocity
      float vel = sqrt(x[i] * x[i] + y[i] * y[i]);

      float h = map(i, 0, count * 4, rMin, rMax);
      float s = map(exp(-vel/40), 0, 1, gMin, gMax);
      float v = map( i + vel, 0, count* 4 + map_maxV, bMin, bMax);

      int c = color(h, s, v);

      stroke(c);
      //strokeWeight(5 * exp(- millis()/tau));
      strokeWeight(2);
      line(prev_x_map[i], prev_y_map[i], x_map, y_map);


      prev_x_map[i] = x_map;
      prev_y_map[i] = y_map;

      y[i] = y[i] + evalY(x[i], y[i]) * del;
      x[i] = x[i] + evalX(x[i], y[i]) * del;
    }
  }

  //adding helper texts
  textSize(13);
  
  if (!savingNow) {
      fill(50,10);
      text(currentStr, 5, displayHeight - 5);
  }
}

//for independent x
public float eval(float x, float y)
{
  //EDIT THE FUNCTION HERE
  float dy_dx = ((1-0.8f) * sin(y) - 0.8f * cos(x))/((1-0.8f) * sin(x) + 0.8f * sin(y));

  return dy_dx;
}

public void reset()
{
  //randomizing stuff
  k = random(0.5f, 1);
  omega1 = random(0.2f, 2);
  omega2 = random(0.5f, 5);

  rMax = (int)random(0, 255);
  rMin = (int)random(0, 255);
  gMax = (int)random(0, 255);
  gMin = (int)random(0, 255);
  bMax = (int)random(0, 255);
  bMin = (int)random(0, 255);

  println(k);
  resetting = true;


  for (int i = 0; i < count; i++)
  {
    x[i] = x_min + offsetX;
    y[i] = y_min + space * i;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width-menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  for (int i = count; i < count * 2; i++)
  {
    x[i] = x_min + offsetX * 2;
    y[i] = y_min + space * (i - count);

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width- menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  for (int i = count * 2; i < count * 3; i++)
  {
    x[i] = x_min + space*(i-count * 2);
    y[i] = y_min + offsetY;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width- menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  for (int i = count * 3; i < count * 4; i++)
  {
    x[i] = x_min + space*(i-count * 3);
    y[i] = y_min + offsetY * 2;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width - menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  bgReset = true;
  resetting = false;
}

public void SetStatement()
{
  statement.add("Press C to save image");
  statement.add("Esc to quit");
  statement.add("mouse click for new pattern");
}

public void SetFunny()
{
  funny.add("i hope u like math..");
  funny.add("you are breathtaking!!");
  funny.add("<3");
  funny.add("what did you say??");
  funny.add("Hola!!");
  funny.add("udon't want to quit, do u?");
  funny.add("No, you can't turn me of.");
  funny.add("Seriously?");
  funny.add("looks nice");
  funny.add("DOOpe..");
}

public String getText()
{
  float i = random(0, 1);
  int index;
  if(i > 0.95f)
  {
    index = (int)random(0, funny.size());
    return funny.get(index);
  }
  index = (int)random(0, statement.size());
  return statement.get(index);
}

public void saveImage()
{
  String date = Integer.toString(day()) + Integer.toString(month()) + Integer.toString(year());
  String fileName = "ItFlows" + date +"_00"+ Integer.toString(ssCount + 1) + ".png";
  ssCount++;
  println("Saving now");
  save(fileName);
  println("Saved image");
  savingNow = false;
}

//for dependent x and y
public float evalX(float x, float y)
{
  float x_prime = (1-k) * sin(x * omega1 + omega2) + k * sin(y * omega1);
  if (gMax > 200) x_prime += exp(-x / (bMin + 1));
  return x_prime;
}

public float evalY(float x, float y)
{
  float y_prime = (1-k) * sin(y * omega1) - k * cos(x * omega1 - omega2);
  if (bMax > 200) y_prime += exp(-y/(rMin + 1));
  if (rMax < 100) y_prime += log(abs(x * omega1)/22 + 1) * omega2;
  return y_prime;
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "ItFlows" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
