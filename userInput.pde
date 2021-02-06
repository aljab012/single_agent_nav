boolean drawSim =false;
boolean setUp =false;

boolean up=false;
boolean down=false;
boolean right = false;
boolean left =false;
void keyPressed() {
  if (key == 'r') {
    setupPRM();
  }
  if (key=='p') {
    setupPRM();
    updateAgent();
    setUp =true;
  }
  if (key ==ENTER) {
    println("simulation start ......");
    if (!setUp) {
      setupPRM();
      updateAgent();
    }
    drawSim =true;
    camera.position =new PVector( 104.7137, -96.44736, 233.79297 );
    camera.theta         = -6.282747   ; 
    camera.phi           = -0.88035196;
    paused = true;
  }
  if (key == ' ') paused = !paused;
  camera.HandleKeyPressed();

  if (key =='u') up = true;
  if (key =='h') left = true;
  if (key =='l') right = true;
  if (key =='j') down = true;
}

void keyReleased() {
  //println("cam pos: ", camera.position.x, camera.position.y, camera.position.z);
  //println("cam theta and phi ", camera.theta, camera.phi);
  camera.HandleKeyReleased();
  if (key =='u') {
    up = false;
    updatePath();
  } 
  if (key =='h') {
    left = false;
    updatePath();
  }
  if (key =='l') {
    updatePath();
    right = false;
  }
  if (key =='j') {
    updatePath();
    down = false;
  }
}
int far =-725;
ArrayList<Vec2> mousePos = new ArrayList();
void mousePressed() {
  if (drawSim) return;
  noStroke();
  fill( 255 );
  mousePos.add(new Vec2(mouseX, mouseY));
  if (setUp) {
    curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
  }
}
