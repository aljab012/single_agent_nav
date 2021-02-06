//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii) {
  for (int i = 0; i < numNodes; i++) {
    Vec2 randPos = new Vec2(random(maxEnvSize), random(maxEnvSize));
    boolean insideAnyCircle = pointInCircleList(circleCenters, circleRadii, numObstacles, randPos);
    while (insideAnyCircle ) {
      randPos = new Vec2(random(maxEnvSize), random(maxEnvSize));
      insideAnyCircle = pointInCircleList(circleCenters, circleRadii, numObstacles, randPos);
    }
    nodePos[i] = randPos;
  }
}

void placeRandomObstacles(int numObstacles) {
  //Initial obstacle position

  for (int i = 0; i < numObstacles; i++) {
    circlePos[i] = new Vec2(random(50, maxEnvSize), random(50, maxEnvSize));
    circleRad[i] = (random(1, 4)+pow(random(1), 2)) ;
  }
  circleRad[0] = 5; //Make the first obstacle big
}
int numCollisions;
float pathLength;
boolean reachedGoal;
void pathQuality() {
  Vec2 dir;
  hitInfo hit;
  float segmentLength;
  numCollisions = 9999; 
  pathLength = 9999;
  if (curPath.size() == 1 && curPath.get(0) == -1) return; //No path found  

  pathLength = 0; 
  numCollisions = 0;

  if (curPath.size() == 0 ) { //Path found with no nodes (direct start-to-goal path)
    segmentLength = startPos.distanceTo(goalPos);
    pathLength += segmentLength;
    dir = goalPos.minus(startPos).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
    if (hit.hit) numCollisions += 1;


    return;
  }

  segmentLength = startPos.distanceTo(nodePos[curPath.get(0)]);
  pathLength += segmentLength;
  dir = nodePos[curPath.get(0)].minus(startPos).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
  if (hit.hit) numCollisions += 1;

  for (int i = 0; i < curPath.size()-1; i++) {
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    segmentLength = nodePos[curNode].distanceTo(nodePos[nextNode]);
    pathLength += segmentLength;

    dir = nodePos[nextNode].minus(nodePos[curNode]).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[curNode], dir, segmentLength);
    if (hit.hit) numCollisions += 1;
  }

  int lastNode = curPath.get(curPath.size()-1);
  segmentLength = nodePos[lastNode].distanceTo(goalPos);
  pathLength += segmentLength;
  dir = goalPos.minus(nodePos[lastNode]).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[lastNode], dir, segmentLength);
  if (hit.hit) numCollisions += 1;
}

Vec2 sampleFreePos() {
  Vec2 randPos = new Vec2(random(maxEnvSize), random(maxEnvSize));
  boolean insideAnyCircle = pointInCircleList(circlePos, circleRad, numObstacles, randPos);
  while (insideAnyCircle ) {
    randPos = new Vec2(random(maxEnvSize), random(maxEnvSize));
    insideAnyCircle = pointInCircleList(circlePos, circleRad, numObstacles, randPos);
  }
  return randPos;
}
void copyInputObs() {
  if (mousePos.size()==1) {
    println("need start and goal!");
    exit();
  }
  numObstacles =mousePos.size();
  //startPos = mousePos.get(0);
  //goalPos = mousePos.get(1);
  for (int i = 0; i < numObstacles; i++) {
    circlePos[i] = new Vec2((mousePos.get(i).x/width)*maxEnvSize, (mousePos.get(i).y/height)*maxEnvSize);
    circleRad[i] = 3.5;
  }
  //circleRad[0] = 30; //Make the first obstacle big
}

void setupPRM() {
  //camera.position =new PVector( 104.7137, -96.44736, 233.79297 );
  //camera.theta         = -6.282747   ; 
  //camera.phi           = -0.88035196;
  //paused = true;
  long startTime, endTime;

  do {
    if (mousePos.size()==0) {
      placeRandomObstacles(numObstacles);
      startPos = sampleFreePos();
      goalPos = sampleFreePos();
    } else {
      copyInputObs();
      startPos = sampleFreePos();
      goalPos = sampleFreePos();
    }

    generateRandomNodes(numNodes, circlePos, circleRad);
    startTime = millis();
    curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
    endTime = millis();
    pathQuality();

    //println("Nodes:", numNodes, " Obstacles:", numObstacles, " Time (ms):", endTime-startTime, 
    //  " Path Len:", pathLength, " Path Segment:", curPath.size()+1, " Num Collisions:", numCollisions);
  } while (curPath.size() <= 1 || curPath.get(0) == -1 ||(curPath.size()<5));
  setPath();
  updateAgent();
}
void updatePath() {
  curPath = new ArrayList();
  while (curPath.size() <= 1 || curPath.get(0) == -1 ||(curPath.size()<5)) {
     generateRandomNodes(numNodes, circlePos, circleRad);
    curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
    pathQuality();

  }
  println("finish update path");
   setPath();
  updateAgent();
}
void setPath() {
  agentPrevPos= new ArrayList();
  //copy complete path
  index =0;
  step = 0;
  completePath = new Vec2[curPath.size()+2];
  completePath[0] = startPos;
  if (curPath.size()!=1) {
    for (int i =0; i<curPath.size(); i++) {
      completePath[i+1] = nodePos[curPath.get(i)];
    }
    completePath[curPath.size()+1] = goalPos;
    curAgentPos = completePath[index];
    endAgentPos = completePath[index+1];
  }
}
