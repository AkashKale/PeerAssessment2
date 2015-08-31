
//Physics based game
import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;
import java.util.Iterator;
import java.awt.Color;

//world variables
Physics physics;
ForceUtils forceUtils;
float physicsBorderX;
float timerIncrement;
float speed, marginOfRandomness;
float score;
int numOfJumpBoxes;

//sound
Maxim maxim;    
AudioPlayer audioPlayer;
AudioPlayer collectSpecialBox;
AudioPlayer tick;

//box variables
float boxBaseHeight;
float boxBaseWidth;
float fBoxMagnitude;
float boxSpawnDuration;
float boxSpawnTimer;
Vec2 fBoxDirection;
ArrayList<Box> boxes;
float specialBoxSize;

//backBox variables
float backBoxSpawnDuration;
float backBoxSpawnTimer;
ArrayList<BackBox> backBoxes;

//backBackBox variables
ArrayList<BackBox> backBackBoxes;
boolean spawnBackBackBox;

//player variables
Body player;
int deathTimer;
boolean dead=false;
float playerHeight,playerWidth;
Vec2 fPlayerUp,fPlayerRight;
float specialBoxTimer;
boolean startSpecialBoxTimer;

//colors
Color backBackBoxColor,backBoxColor,gameOverBackColor,gameOverTextColor,specialBoxStroke,specialBoxColor,playerColor,playerStroke,gridStroke,scoreBackColor,scoreTextColor;
void setup()
{
  //world setup
  size(500, 250);
  frameRate(60);
  physics=new Physics(this, width, height, 0, -10, width*2, height*2, width*2.5, height, 100);
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  forceUtils=new ForceUtils();
  physics.setDensity(10.0);  
  physicsBorderX=-100;
  timerIncrement=1;
  speed=25;
  marginOfRandomness=10;
  numOfJumpBoxes=0;
  
  //sound setup
  maxim = new Maxim(this);
  audioPlayer = maxim.loadFile("background.wav");
  audioPlayer.setLooping(true);
  audioPlayer.play();
  collectSpecialBox = maxim.loadFile("collectSpecialBox.wav");
  collectSpecialBox.setLooping(false);
  tick = maxim.loadFile("tick.wav");
  tick.setLooping(true);
  tick.speed(0.8);
  
  //font setup
  PFont font;
  font = loadFont("SegoeUI-Light-48.vlw");
  textFont(font);
  
  noStroke();
  
  //box variables setup
  boxBaseHeight=50;
  boxBaseWidth=50;
  boxSpawnDuration=50;
  boxSpawnTimer=0;
  boxes=new ArrayList<Box>();
  fBoxDirection=new Vec2(-1, 0);
  
  //backBox variables setup
  backBoxSpawnDuration=50;
  backBoxSpawnTimer=0;
  backBoxes=new ArrayList<BackBox>();
  
  //backBackBox variables setup
  backBackBoxes=new ArrayList<BackBox>();
  spawnBackBackBox=true;
  
  //playerSetup
  //player=physics.createRect(width/2,height-30,width/2+30,height,0x0001,0x0002);
  playerHeight=playerWidth=30;
  player=physics.createRect(width/2,height-playerHeight,width/2+playerWidth,height);
  fPlayerUp=new Vec2(1000,18000);
  fPlayerRight=new Vec2(2000,0);
  specialBoxSize=30;
  specialBoxTimer=10*60;
  startSpecialBoxTimer=false;
  
  //color setup
  backBackBoxColor=new Color(200,200,200,255);
  backBoxColor=new Color(150,150,150,255);
  gameOverBackColor=new Color(0,0,0,255);
  gameOverTextColor=new Color(255,255,255,255);
  specialBoxStroke=new Color(255,255,255,255);
  specialBoxColor=new Color(50,50,50,255);
  playerColor=new Color(225,225,225,255);
  playerStroke=new Color(50,50,50,255);
  gridStroke=new Color(200,200,200,255);
  scoreBackColor=new Color(50,50,50,255);
  scoreTextColor=new Color(255,255,255,255);
}
class Box {
  Body body;
  float h, w;
  String type;
  Box(float baseHeight, float baseWidth, float marginOfRandomness)
  {
    h=baseHeight;
    w=baseWidth;
    generateRandom(marginOfRandomness);
    //body=physics.createRect(width+100, height-100, width+100+w, height-100+h,0x0002,0x0001);
    body=physics.createRect(width+100, height-100, width+100+w, height-100+h);
    type="normal";
  }
  Box(float baseHeight, float baseWidth, float marginOfRandomness, String special)
  {
    h=baseHeight;
    w=baseWidth;    
    //body=physics.createRect(width+100, height-100, width+100+w, height-100+h,0x0002,0x0001);
    body=physics.createRect(width+100, height-100, width+100+w, height-100+h);
    type=special;
  }
  void generateRandom(float marginOfRandomness)
  {
    h=randomize(h, marginOfRandomness*3);
    w=randomize(w, marginOfRandomness);
  }
  float getX()
  {
    return physics.worldToScreenX(body.getPosition().x, body.getPosition().y);
  }
  float getY()
  {
    return physics.worldToScreenY(body.getPosition().x, body.getPosition().y);
  }
}
class BackBox {  
  float h,w,x,y;
  BackBox(float baseHeight, float baseWidth, float marginOfRandomness)
  {
    h=baseHeight;
    w=baseWidth;
    generateRandom(marginOfRandomness);
    x=width+100;
    y=height-h;
  }
  void generateRandom(float marginOfRandomness)
  {
    h=randomize(h, marginOfRandomness*3);
    w=randomize(w, marginOfRandomness);
  }
}
void draw()
{
}

void myCustomRenderer(World world)
{ 
  drawBackground();
  boxSpawnTimer+=timerIncrement;
  if (boxSpawnTimer>=boxSpawnDuration)
  {    
    boxSpawnTimer=0;
    spawnBox();
  }
  backBoxSpawnTimer+=timerIncrement;
  if (backBoxSpawnTimer>=backBoxSpawnDuration)
  {    
    backBoxSpawnTimer=0;
    spawnBackBox();
  }  
  drawBoxes();
  if(dead)
  {
    displayGameOverMessage();
  }
  else
  {
    displayScore();
    displaySpecialBoxes();
    checkIfPlayerGoesOutOfScreen();
    drawPlayer();
    score+=0.01;
    if(startSpecialBoxTimer)
    {
      specialBoxTimer--;
      displaySpecialBoxTimer();
      if(specialBoxTimer==0)
      {
        print("stopped");
        specialBoxTimer=10*60;
        startSpecialBoxTimer=false;
        fPlayerUp=new Vec2(1000,18000);
        tick.stop();
      }
    }
  }
}
void drawBackground()
{  
  background(255);  
  drawGrid();
  //backBackBoxes
  Iterator<BackBox> iBackBackBoxes=backBackBoxes.iterator();  
  while (iBackBackBoxes.hasNext ()) 
  {
    BackBox backBackBox = iBackBackBoxes.next();    
    if (backBackBox.x<physicsBorderX)
    {      
      iBackBackBoxes.remove();      
      continue;
    }
    backBackBox.x-=2*(speed/50);
    setFill(backBackBoxColor);
    rectMode(CORNER);
    rect(backBackBox.x,backBackBox.y,backBackBox.w,backBackBox.h);
  }
  //backBoxes
  Iterator<BackBox> iBackBoxes=backBoxes.iterator();
  while (iBackBoxes.hasNext ()) 
  {
    BackBox backBox = iBackBoxes.next();
    if (backBox.x<physicsBorderX)
    {      
      iBackBoxes.remove();
      continue;
    }
    backBox.x-=2*(speed/25);
    setFill(backBoxColor);
    rectMode(CORNER);
    rect(backBox.x,backBox.y,backBox.w,backBox.h);
  }
  strokeWeight(10);
  setStroke(new Color(50,50,5,255));
  line(0,0,width,0);
  line(0,height,width,height);
}
void spawnBox()
{ 
  Box box;
  int r=(int)random(10);
  if(r==1)
  {        
    box=new Box(specialBoxSize, specialBoxSize, marginOfRandomness,"jump");
  }
  else
  {
    box=new Box(boxBaseHeight, boxBaseWidth, marginOfRandomness);
  }
  boxes.add(box);
}
void spawnBackBox()
{ 
  BackBox backBox=new BackBox(boxBaseHeight*1.5, boxBaseWidth*1.5, marginOfRandomness*1.5);
  backBoxes.add(backBox);
  if(spawnBackBackBox)
  {
    BackBox backBackBox=new BackBox(boxBaseHeight*2, boxBaseWidth*1.5, marginOfRandomness*2);
    backBackBoxes.add(backBackBox);
  }
  spawnBackBackBox=!spawnBackBackBox;
}

float randomize(float value, float marginOfRandomness) 
{
  int randomSign;
  int[] signs = { 
    1, 0, -1
  };
  randomSign=signs[(int)random(3)];
  return value+(randomSign*random(marginOfRandomness));
}

float getBodyX(Body body)
{
  return physics.worldToScreenX(body.getPosition().x,body.getPosition().y);
}
float getBodyY(Body body)
{
  return physics.worldToScreenY(body.getPosition().x,body.getPosition().y);
}

void keyPressed() 
{
  if (key == CODED) 
  {
    if (keyCode == UP)
    {
      physics.applyForce(player,fPlayerUp);
    }
    if (keyCode == RIGHT)
    {
      physics.applyForce(player,fPlayerRight);
    }
  }
  if (keyCode == 'J')
  {
    if(numOfJumpBoxes>0&&startSpecialBoxTimer==false)
    {
      numOfJumpBoxes--;
      fPlayerUp=new Vec2(1000,18000*2);
      startSpecialBoxTimer=true;
      tick.play();
    }
  }
}

void displayGameOverMessage()
{ 
  noStroke();
  setFill(gameOverBackColor);
  rectMode(CORNER);
  rect(0,0,width,height/2);
  setFill(gameOverTextColor);
  textAlign(CENTER,CENTER);
  textSize(35);
  text("Boxy died :(\nYour Score : "+(int)score,0,0,width,height/2);
}
boolean overlap(Box box)
{
  float playerXMin,playerXMax,playerYMin,playerYMax,boxXMin,boxXMax,boxYMin,boxYMax;
  playerXMin=getBodyX(player)-playerWidth/2;
  playerXMax=getBodyX(player)+playerWidth/2;
  playerYMin=getBodyY(player)-playerHeight/2;
  playerYMax=getBodyY(player)+playerHeight/2;
  boxXMin=box.getX()-box.w/2;
  boxXMax=box.getX()+box.w/2;
  boxYMin=box.getY()-box.h/2;
  boxYMax=box.getY()+box.h/2;
  if((playerXMin < boxXMax) && (playerXMax > boxXMin) &&
      (playerYMin < boxYMax) && (playerYMax > boxYMin))
      return true;
  return false;
}
void drawBoxes()
{
  Iterator<Box> iBoxes=boxes.iterator();
  while (iBoxes.hasNext ()) 
  {
    Box box = iBoxes.next();
    if (box.getX()<physicsBorderX)
    {
      physics.removeBody(box.body);
      iBoxes.remove();
      continue;
    }
    fBoxMagnitude=box.h*box.w/220;
    forceUtils.push(box.body, fBoxDirection, fBoxMagnitude);
    if(box.type.equals("jump"))
    {
      strokeWeight(5);
      setStroke(specialBoxStroke);
      if(overlap(box))
      {
        print("Overlap");
        boxes.remove(box);
        physics.removeBody(box.body);
        numOfJumpBoxes++;
        collectSpecialBox.play();
        break;
      }
    }
    else
    {
      noStroke();
    }
    setFill(specialBoxColor);
    rectMode(CENTER);
    pushMatrix();
    translate(box.getX(),box.getY());
    rotate(-(physics.getAngle(box.body)));    
    rect(0,0,box.w,box.h);
    popMatrix();
  }
}
void drawPlayer()
{
  setFill(playerColor);
  pushMatrix();
  translate(getBodyX(player),getBodyY(player));
  rotate(-(physics.getAngle(player)));
  strokeWeight(0.5);
  setStroke(playerStroke);
  rectMode(CENTER);
  rect(0,0,playerHeight,playerWidth);  
  noStroke();
  popMatrix();
}
void checkIfPlayerGoesOutOfScreen()
{
  if(getBodyX(player)>width)
  {
    Vec2 fPlayer=new Vec2(-2000,0);
    physics.applyForce(player,fPlayer);
  }
  if(getBodyX(player)<0)
  {
    Vec2 fPlayer=new Vec2(2000,0);
    physics.applyForce(player,fPlayer);
    deathTimer--;
    if(deathTimer==0)
    {
      dead=true;
      physics.removeBody(player);
    }
  }
  else{
    deathTimer=100;
  }
}

void drawGrid()
{
  float strokeWeight=0.5;
  for(int i=-250;i<width;i+=20)
  {
    setStroke(gridStroke);
    strokeWeight(strokeWeight);
    strokeWeight+=0.1;
    line(i,0,i+250,height);
    line(i+250,0,i,height);
  }
  strokeWeight(0.3);
  noStroke();
}
void displayScore()
{
  noStroke();
  pushMatrix();
  translate(width-110,10);
  setFill(scoreBackColor);
  rectMode(CORNER);
  rect(0,0,100,50);
  setFill(scoreTextColor);
  textSize(20);
  textAlign(CENTER,CENTER);
  text("Score : "+(int)score,0,0,100,50);
  popMatrix();
}
void displaySpecialBoxes()
{
  if(numOfJumpBoxes>0)
  {
    setStroke(specialBoxStroke);
    strokeWeight(5);
    pushMatrix();
    translate(width-120-specialBoxSize,10);
    setFill(specialBoxColor);
    rectMode(CORNER);
    rect(0,0,specialBoxSize,specialBoxSize);
    ellipseMode(CENTER);
    strokeWeight(2);
    ellipse(specialBoxSize,specialBoxSize,16,16);
    setFill(scoreTextColor);
    textSize(20);
    textAlign(CENTER,CENTER);
    text("J",0,0,specialBoxSize,specialBoxSize);
    textSize(12);
    text(numOfJumpBoxes+"",specialBoxSize-14,specialBoxSize-14,specialBoxSize,specialBoxSize);
    popMatrix();
  }
}
void displaySpecialBoxTimer()
{
  noStroke();
  strokeWeight(5);
  pushMatrix();
  translate(10,10);
  setFill(specialBoxColor);
  ellipseMode(CORNER);  
  ellipse(0,0,specialBoxSize,specialBoxSize);
  setFill(scoreTextColor);
  textSize(20);
  textAlign(CENTER,CENTER);
  text(((int)specialBoxTimer/60)+"",16,16,specialBoxSize,specialBoxSize);
  setStroke(specialBoxStroke);
  float x,y;
  for(int i=0;i<(int)map(specialBoxTimer,600,0,360,0);i++)
  {
    x=specialBoxSize/2+(specialBoxSize/2)*cos(radians(-i-90));
    y=specialBoxSize/2+(specialBoxSize/2)*sin(radians(-i-90));
    point(x,y);
  }
  popMatrix();
}
void setFill(Color colorToSet)
{
  fill(colorToSet.getRed(),colorToSet.getGreen(),colorToSet.getBlue(),colorToSet.getAlpha());
}
void setStroke(Color colorToSet)
{
  stroke(colorToSet.getRed(),colorToSet.getGreen(),colorToSet.getBlue(),colorToSet.getAlpha());
}
