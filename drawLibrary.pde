void drawPathGoals() {
  fill(20, 60, 250);
  float sphereSize =0.5;
  pushMatrix();
  translate(startPos.x, -sphereSize, startPos.y);
  sphere(sphereSize);
  popMatrix();
  fill(250, 30, 50);
  //circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
  //goalllll
  //pushMatrix();
  //translate(goalPos.x, -sphereSize, goalPos.y);
  //sphere(sphereSize);
  //popMatrix();
  pushMatrix();
  translate(goalPos.x, 0, goalPos.y);
  //sphere(sphereSize);
  rotate(PI);
  //scale(2);
  shape(flag);
  popMatrix();
}

void drawPath() {
  float pathHeight =-1;
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found

  //Draw Planned Path
  stroke(0, 255, 0);
  strokeWeight(2);
  if (curPath.size() == 0) {
    line(startPos.x, pathHeight, startPos.y, goalPos.x, pathHeight, goalPos.y);
    return;
  }
  line(startPos.x, pathHeight, startPos.y, nodePos[curPath.get(0)].x, pathHeight, nodePos[curPath.get(0)].y);
  for (int i = 0; i < curPath.size()-1; i++) {
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    line(nodePos[curNode].x, pathHeight, nodePos[curNode].y, nodePos[nextNode].x, pathHeight, nodePos[nextNode].y);
  }
  line(goalPos.x, pathHeight, goalPos.y, nodePos[curPath.get(curPath.size()-1)].x, pathHeight, nodePos[curPath.get(curPath.size()-1)].y);
}

void drawPRM() {

  //Draw PRM Nodes
  fill(200);
  for (int i = 0; i < numNodes; i++) {
    pushMatrix();
    translate(nodePos[i].x, -1, nodePos[i].y);
    //drawCylinder( 30, circleRad[0],circleRad[0] );
    sphere(0.05);
    popMatrix();
  }
  //Draw graph
  stroke(60);
  strokeWeight(0.5);
  for (int i = 0; i < numNodes; i++) {
    for (int j : neighbors[i]) {
      line(nodePos[i].x, 0, nodePos[i].y, nodePos[j].x, 0, nodePos[j].y);
      //println(nodePos[i].x, 0, nodePos[i].y);
    }
  }
}


void drawCirclesObs() {
  fill(200); //set obstcles color
  for (int i = 1; i < numObstacles; i++) {
    Vec2 c = circlePos[i];
    float r = circleRad[i];
    noStroke();
    pushMatrix();
    translate(c.x, -r/2, c.y);
    drawCylinder( 30, r, r );
    translate(0, -r/2, 0);
    sphere(r);
    popMatrix();
  }
    stroke(0,0,200);
    Vec2 c = circlePos[0];
    float r = circleRad[0];
    pushMatrix();
    translate(c.x, -r/2, c.y);
    drawCylinder( 30, r, r );
    translate(0, -r/2, 0);
    sphere(r);
    popMatrix();
}

void drawFloor() {
  int floorSize =maxEnvSize/2 +50;
  noLights();
  pushMatrix();
  translate(maxEnvSize/2, 0, maxEnvSize/2);
  beginShape();
  //fill(173, 216, 230);
  texture(seaImg);
  vertex(-floorSize, 0, -floorSize, 0, 0);
  vertex(floorSize, 0, -floorSize, seaImg.width, 0);
  vertex(floorSize, 0, floorSize, seaImg.width, seaImg.height);
  vertex(-floorSize, 0, floorSize, 0, seaImg.height);
  endShape();
  popMatrix();
  lights();
}
void drawAgent() {
  //draw the agent
  if (!paused && frameCount % 8==0 && index<completePath.length-1) {
    agentPrevPos.add(agent);
  }
  fill(128, 0, 128);
  stroke(128, 0, 128);
  pushMatrix();
  Vec2 dir = endAgentPos.minus(curAgentPos).normalized();
  Vec2 change = dir.minus(prevDir).times(0.05);
  //if(agentPrevPos.size()>2){

  //}
  prevDir.add(change);
  translate(agent.x, 0, agent.y);
  rotateX(PI/2);
  rotate(prevDir.heading());
  rotateY(PI/2);
  rotateZ(PI/2);

  rotateY(PI); // comment if not pirate ship

  shape(agentShape, 0, 0, agentWidth, agentHeight);
  popMatrix();
}
void drawAgentPrePath() {
  fill(255, 215, 0);
  stroke(255, 215, 0);
  for (int i=0; i<agentPrevPos.size(); i++) {
    pushMatrix();
    translate(agentPrevPos.get(i).x, -1, agentPrevPos.get(i).y);
    sphere(0.3);
    popMatrix();
  }
}

void drawSetup() {
  //drawing set-up
  noStroke(); // remove any Strokes
  background(150); //Grey background
  lights(); // set-up lights
}
// source https://vormplus.be/full-articles/drawing-a-cylinder-with-processing
void drawCylinder( int sides, float r, float h)
{
  float angle = 360 / sides;
  float halfHeight = h / 2;

  // draw sides
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, halfHeight, y);
    vertex( x, -halfHeight, y);
  }
  endShape(CLOSE);
}
