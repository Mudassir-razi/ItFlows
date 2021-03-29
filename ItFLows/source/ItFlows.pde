//showman stuff
int count = 80;    //number of lines
float space;

//calculation variables
float del = 0.01;
float k, omega1, omega2;
float x[];
float y[];

//plot variable
float x_min = -6;
float x_max = 6;
float y_min = -5;
float y_max = 5;
float offsetX = 2.8;
float offsetY;
float offsetMultipler = 2.5;
boolean resetting;

float prev_x_map[];
float prev_y_map[];

//colorizing stuff
float map_minV = 0;
float map_maxV = 13;
int rMax, rMin, gMax, gMin, bMax, bMin;
float minResetTime = 500;
float timeResetCounter = 0;
boolean bgReset = false;

//menu stuff
int menuWidth = 0;
int ssCount = 0;
ArrayList<String> statement;
ArrayList<String> funny;
String currentStr;
boolean savingNow = false;

//time keeping
float delTime = 0;      //universal delta time
float prevTime = 0;    //universal


//anim speed stuff
float maxDel = 0.4;
float minDel = 0.005;
float delDel = 0.01;
float minDelChangeTime = 200;  //minimum response time of delta. I.E. slowmo control stuff
float timeDelCounter = 0;
void setup()
{
  fullScreen();

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

void draw()
{ 
  delTime = millis() - prevTime;  //time from last frame
  prevTime = millis();

  if (bgReset)
  {
    background(max(gMax, gMin)- min(gMax, gMin), 42, 22);
    //background(random(0, 200));
    bgReset = false;
  }

  if (!resetting) {
    for (int i = 0; i < count * 4; i++) { 

      //reset control
      if (mousePressed && timeResetCounter >= minResetTime) {
        timeResetCounter = 0;
        thread("reset");
        resetting = true;
        currentStr = getText();
        break;
      }

      //key control
      if (keyPressed)
      {
        //  if (key == 'c' && !savingNow)
        //  {
        //    savingNow = true;
        //    thread("saveImage");
        //  }
        KeyPressed();
      }
      float x_map = map(x[i], x_min, x_max, 0, width - menuWidth);
      float y_map = map(y[i], y_min, y_max, 0, height);

      //calculating velocity
      float vel = sqrt(x[i] * x[i] + y[i] * y[i]);

      float h = map(i, 0, count * 4, rMin, rMax);
      float s = map(exp(-vel/40), 0, 1, gMin, gMax);
      float v = map( i + vel, 0, count* 4 + map_maxV, bMin, bMax);

      color c = color(h, s, v);

      stroke(c);
      //strokeWeight(5 * exp(- millis()/tau));
      strokeWeight(1);
      line(prev_x_map[i], prev_y_map[i], x_map, y_map);


      prev_x_map[i] = x_map;
      prev_y_map[i] = y_map;

      y[i] = y[i] + evalY(x[i], y[i]) * del;
      x[i] = x[i] + evalX(x[i], y[i]) * del;
    }
    timeResetCounter += delTime;
    timeDelCounter += delTime;
  }

  //adding helper texts
  textSize(13);

  if (!savingNow) {
    fill(50, 10);
    text(currentStr, 5, displayHeight - 5);
  }
}

//resets every time mouse is clicked
void reset()
{
  //randomizing stuff
  k = random(0.5, 1);
  omega1 = random(0.2, 2);
  omega2 = random(0.5, 5);

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

//keycontrol
void KeyPressed()
{
  if (key == 'c' && !savingNow)
  {
    savingNow = true;
    thread("saveImage");
  }

  if (key == 'w' && timeDelCounter > minDelChangeTime)
  {
    del += delDel;
    timeDelCounter = 0;
  }

  if (key == 's' && timeDelCounter > minDelChangeTime)
  {
    del -= delDel;
    timeDelCounter = 0;
  }

  //clamping delta value
  if (del > maxDel)del = maxDel;
  if (del < minDel)del = minDel;
}

//UI talks
void SetStatement()
{
  statement.add("Press C to save image");
  statement.add("Esc to quit");
  statement.add("mouse click for new pattern");
  statement.add("W to speedup, S to slow down");
}

//say someting funny
void SetFunny()
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


//returns a random text from two types of texts
String getText()
{
  float i = random(0, 1);
  int index;
  if (i > 0.95)
  {
    index = (int)random(0, funny.size());
    return funny.get(index);
  }
  index = (int)random(0, statement.size());
  return statement.get(index);
}

//saves image
//should run on a different thread
void saveImage()
{
  String date = Integer.toString(day()) + Integer.toString(month()) + Integer.toString(year());
  String fileName = "ItFlows" + date +"_00"+ Integer.toString(ssCount + 1) + ".png";
  ssCount++;
  println("Saving now");
  save(fileName);
  println("Saved image");
  savingNow = false;
}

//math stuff
//for dependent x and y
float evalX(float x, float y)
{
  float x_prime = (1-k) * sin(x * omega1 + omega2) + k * sin(y * omega1);
  if (gMax > 200) x_prime += exp(-x / (bMin + 1));
  return x_prime;
}

float evalY(float x, float y)
{
  float y_prime = (1-k) * sin(y * omega1) - k * cos(x * omega1 - omega2);
  if (bMax > 200) y_prime += exp(-y/(rMin + 1));
  if (rMax < 100) y_prime += log(abs(x * omega1)/22 + 1) * omega2;
  return y_prime;
}
