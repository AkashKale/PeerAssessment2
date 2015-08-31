
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

Physics physics;
ForceUtils forceUtils;
float physicsBorderX;
float boxBaseHeight;
float boxBaseWidth;
float fBoxMagnitude;
float boxSpawnDuration;
float boxSpawnTimer;
float timerIncrement;//the value with which the timer will be incremented
float speed, marginOfRandomness;
Body player;
ArrayList<Box> boxes;
Vec2 fBoxDirection;
CollisionDetector detector;

void setup()
{
  size(500, 500);
  physics=new Physics(this, width, height, 0, -10, width*2, height*2, width*2.5, height, 100);
  forceUtils=new ForceUtils();
  physics.setDensity(10.0);  
  physicsBorderX=-100;
  boxBaseHeight=50;
  boxBaseWidth=50;
  boxSpawnDuration=50;
  boxSpawnTimer=0;
  timerIncrement=1;
  speed=25;
  marginOfRandomness=10;
  //player=physics.createRect(width/2,height-30,width/2+30,height);
  player=physics.createCircle(width/2,height-15,15);  
  boxes=new ArrayList<Box>();
  fBoxDirection=new Vec2(-1, 0);
  detector = new CollisionDetector (physics, this);
}
void draw()
{
  background(255);
  Iterator<Box> iBoxes=boxes.iterator();
  while (iBoxes.hasNext ()) {
    Box box = iBoxes.next();
    if (box.getX()<physicsBorderX)
    {
      physics.removeBody(box.body);
      iBoxes.remove();
      //print("removed");      
      continue;
    }
    fBoxMagnitude=box.h*box.w/220;
    forceUtils.push(box.body, fBoxDirection, fBoxMagnitude);
    text("force:"+fBoxMagnitude, box.getX(), box.getY());
    text("mass:"+box.body.getMass(), box.getX(), box.getY()+10);
  }
  boxSpawnTimer+=timerIncrement;
  if (boxSpawnTimer>=boxSpawnDuration)
  {    
    boxSpawnTimer=0;
    spawnBox();
  }
  if(physics.worldToScreenX(player.getPosition().x,player.getPosition().y)<0)
  {
    Vec2 fPlayer=new Vec2(2000,0);
    physics.applyForce(player,fPlayer);
  }
  if(physics.worldToScreenX(player.getPosition().x,player.getPosition().y)>width)
  {
    Vec2 fPlayer=new Vec2(-2000,0);
    physics.applyForce(player,fPlayer);
  }
}
void spawnBox()
{ 
  Box box=new Box(boxBaseHeight, boxBaseWidth, marginOfRandomness);
  boxes.add(box);
}
class Box {
  Body body;
  float h, w;
  Box(float baseHeight, float baseWidth, float marginOfRandomness)
  {
    h=baseHeight;
    w=baseWidth;
    generateRandom(marginOfRandomness);
    body=physics.createRect(width+100, height-100, width+100+w, height-100+h);
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
float randomize(float value, float marginOfRandomness) 
{
  int randomSign;    
  int[] signs = { 
    1, 0, -1
  };
  randomSign=signs[(int)random(3)];
  return value+(randomSign*random(marginOfRandomness));
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP)
    {
      Vec2 fPlayer=new Vec2(1000,18000);
      physics.applyForce(player,fPlayer);
    }
    if (keyCode == RIGHT)
    {
      Vec2 fPlayer=new Vec2(2000,0);
      physics.applyForce(player,fPlayer);
    }
  }
}
void collision(Body b1, Body b2, float impulse)
{
  print("\n",b1.getMass(),b2.getMass());
  //if(b1==player&&b2.getMass()>0||b2==player&&b1.getMass()>0)
  if(b1==player||b2==player)
  {
    //print("\n",b1.getMass(),b2.getMass());
  }
}
