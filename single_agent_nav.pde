//Working base code
//CSCI 5611 Project 2
//Instructor: Stephen J. Guy <sjguy@umn.edu>

PImage seaImg; // https://freestocktextures.com/texture/clear-blue-sea,961.html

//Change the below parameters to change the scenario/roadmap size
int numObstacles = 40;
int numNodes  = 100;
PShape agentShape; // from the class provided 3D shape
PShape flag; // from the class provided 3D shape
float agentSpeed ;
float speedScale =0.20;

int step =0;
int index =0;

int agentWidth = 3;
int agentHeight = 6;

boolean paused =true;
boolean backCam =true;
Camera camera;
ArrayList<Vec2> agentPrevPos;
boolean obsMode = false;
Vec2 prevDir = new Vec2(0, 0);
static int maxNumObstacles = 61;
Vec2 circlePos[] = new Vec2[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii


Vec2 startPos;
Vec2 goalPos;
int maxEnvSize = 200;

static int maxNumNodes = 1000;
Vec2[] nodePos = new Vec2[maxNumNodes];
Vec2[] completePath;

Vec2 curAgentPos = new Vec2(0, 0);
Vec2 endAgentPos =  new Vec2(0, 0);

ArrayList<Integer> curPath;

Vec2 agent = new Vec2(0, 0);

void setup() {
  println("press ENTER to skip user scenario editing");
  size(600, 600, P3D);
  camera = new Camera();
  agentShape = loadShape("ship_light.obj");
  agentShape.scale(0.1);  
  flag = loadShape("Flag.obj");
  flag.scale(1);
  seaImg = loadImage("img.png");
}

void draw() {
  camera.Update(1.0/frameRate);
  if (drawSim) drawSimulation();
  else drawInputBoard();
  if (width!=600 && !drawSim) {
    println("cannot extend the windows before the simulation run!");
    exit();
  }
}
void drawInputBoard() {
  background(200);
  noStroke();
  fill( 255 );
  for (int i=0; i<mousePos.size(); i++) {
    pushMatrix();
    translate(-width/2, -height/2, 0);
    translate( mousePos.get(i).x, mousePos.get(i).y, far );

    sphere( 10 );
    popMatrix();
  }
  if (startPos !=null && goalPos!=null) {
    fill( 255, 0, 0);
    pushMatrix();
    translate(-width/2, -height/2, 0);
    translate( (startPos.x/maxEnvSize) * width, (startPos.y/maxEnvSize) * height, far );

    sphere( 10 );
    popMatrix();
    pushMatrix();
    fill( 0, 0, 255);
    translate(-width/2, -height/2, 0);
    translate( (goalPos.x/maxEnvSize) * width, (goalPos.y/maxEnvSize) * height, far );

    sphere( 10 );
    popMatrix();
  }
}
void drawSimulation() {
  update();
  drawSetup();
  //drawPRM();

  drawFloor();
  drawCirclesObs();

  drawPathGoals();
  drawPath();

  drawAgent();
  drawAgentPrePath();
}

void update() {
  if (!paused)   updateAgent();
  if (backCam) updateCameraPos();
  updateObsPos();
}
void updateObsPos(){
if(up) circlePos[0].y -=1;
if(down) circlePos[0].y +=1;
if(left) circlePos[0].x -=1;
if(right) circlePos[0].x +=1;

}
void updateCameraPos() {
}
void updateAgent() {
  if (curPath.size()<=1) {
    return;
  }
  // calculate x and y position for the agent
  agentSpeed =1/endAgentPos.minus(curAgentPos).length();
  agentSpeed *=speedScale;
  float x = lerp(curAgentPos.x, endAgentPos.x, step*agentSpeed); 
  float y = lerp(curAgentPos.y, endAgentPos.y, step*agentSpeed); 
  agent = new Vec2(x, y);

  // if finished the this path segemnt
  if (step*agentSpeed>1) {
    step =0; // rest step
    index++;
    if (index<completePath.length-1) { //
      curAgentPos = completePath[index];
      endAgentPos = completePath[index+1];
    }
  } 
  if (index<completePath.length-2) {
    Vec2 dir = agent.minus(completePath[index+2]).normalized();
    float distBetween = agent.distanceTo(completePath[index+2]);
    hitInfo circleListCheck = rayCircleListIntersect(circlePos, circleRad, numObstacles, completePath[index+2], dir, distBetween);
    if (!circleListCheck.hit ) {
      index++;
      step =0;
      curAgentPos = agent;
      endAgentPos = completePath[index+1];
    }
  }
  if (index>=completePath.length-1) {
    agent = goalPos;
  }
  step++;
}
