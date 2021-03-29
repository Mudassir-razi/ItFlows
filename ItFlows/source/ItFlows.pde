//showman stuff
int count = 30;    //number of lines
float space;

//calculation variables
float del = 0.2;
float k, omega1, omega2;
float x[];
float y[];

//plot variable
float x_min = -5;
float x_max = 5;
float y_min = -5;
float y_max = 5;
float offset = 2.8;
float offsetMultipler = 2.5;
boolean resetting;

float prev_x_map[];
float prev_y_map[];

//colorizing stuff
float map_minV = 0;
float map_maxV = 13;
int rMax, rMin, gMax, gMin, bMax, bMin;
float minResetTime = 1000;
float delTime1 = 0, delTime2 = 0;
float prevDelTime = 0;
boolean bgReset = false;

//menu stuff
int menuWidth = 0;

void setup()
{
  size(1000, 1000);
  colorMode(HSB, 100);

  space = abs(x_max - x_min)/(float)count;

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
  delTime2 = millis();
  if(bgReset)
  {
    background(max(gMax, gMin)- min(gMax, gMin), 42 , 22);
    //background(random(0, 200));
    bgReset = false;
  }
  
  if (!resetting) {
    for (int i = 0; i < count * 4; i++) { 
      if (mousePressed && delTime2 - delTime1 >= minResetTime) {
        delTime1 = millis();
        thread("reset");
        resetting = true;
        break;
      }
      if(keyPressed)
      {
        if(key == 'c')
        {
          save("diagonal.tif");
        }
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
      strokeWeight(2);
      line(prev_x_map[i], prev_y_map[i], x_map, y_map);
      
      
      prev_x_map[i] = x_map;
      prev_y_map[i] = y_map;

      y[i] = y[i] + evalY(x[i], y[i]) * del;
      x[i] = x[i] + evalX(x[i], y[i]) * del;
    }
  }
}

//for independent x
float eval(float x, float y)
{
  //EDIT THE FUNCTION HERE
  float dy_dx = ((1-0.8) * sin(y) - 0.8 * cos(x))/((1-0.8) * sin(x) + 0.8 * sin(y));

  return dy_dx;
}

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
    x[i] = x_min + offset;
    y[i] = y_min + space * i;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width-menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  for (int i = count; i < count * 2; i++)
  {
    x[i] = x_min + offset * offsetMultipler;
    y[i] = y_min + space * (i - count);

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width- menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }
  
  for (int i = count * 2; i < count * 3; i++)
  {
    x[i] = x_min + space*(i-count * 2);
    y[i] = y_min + offset;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width- menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }
  
  for (int i = count * 3; i < count * 4; i++)
  {
    x[i] = x_min + space*(i-count * 3);
    y[i] = y_min + offset * offsetMultipler;

    prev_x_map[i] = map(x[i], x_min, x_max, 0, width - menuWidth);
    prev_y_map[i] = map(y[i], y_min, y_max, 0, height);
  }

  bgReset = true;
  resetting = false;
}

//for dependent x and y
float evalX(float x, float y)
{
  float x_prime = (1-k) * sin(x * omega1 + omega2) + k * sin(y * omega1);
  if(gMax > 200) x_prime += exp(-x / (bMin + 1));
  return x_prime;
}

float evalY(float x, float y)
{
  float y_prime = (1-k) * sin(y * omega1) - k * cos(x * omega1 - omega2);
  if(bMax > 200) y_prime += exp(-y/(rMin + 1));
  return y_prime;
}
