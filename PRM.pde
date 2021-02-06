import java.util.*;
import java.lang.*;
//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of obstacles
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of position in the nodePos array will be inside an obstacle
//   - The start and the goal position will never be inside an obstacle

// There are many useful functions in CollisionLibrary.pde and Vec2.pde
// which you can draw on in your implementation. Please add any additional 
// functionality you need to this file.

// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it use BFS which will not provide the shortest path
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment (don't assume 
// this example funcationality is correct and copy it's mistakes!).




ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes) {
  for (int i = 0; i < numNodes; i++) {
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++) {
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit) {
        neighbors[i].add(j);
      }
    }
  }
}

//This is probably a bad idea and you shouldn't use it...
int closestNode(Vec2 point, Vec2[] nodePos, int numNodes, Vec2[] centers, float[] radii, int numObstacles) {
  int closestID = -1;
  float minDist = 999999;
  for (int i = 0; i < numNodes; i++) {
    float dist = nodePos[i].distanceTo(point);
    if (dist < minDist) {
      Vec2 dir = nodePos[i].minus(point).normalized();
      hitInfo temp= rayCircleListIntersect(centers, radii, numObstacles, point, dir, dist);
      if (!temp.hit ) {
        closestID = i;
        minDist = dist;
      }
    }
  }
  return closestID;
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes) {
  ArrayList<Integer> path = new ArrayList();

  connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);
  int startID = closestNode(startPos, nodePos, numNodes, centers, radii, numObstacles);
  int goalID = closestNode(goalPos, nodePos, numNodes, centers, radii, numObstacles);
  path = runAstar(nodePos, numNodes, startID, goalID);
  return path;
}


//A* Algorithm
ArrayList<Integer> runAstar(Vec2[] nodePos, int numNodes, int startID, int goalID) {
  ArrayList<Integer> path = new ArrayList();

  if (  numNodes<=0 || nodePos.length<=0 || startID < 0 || goalID < 0 ) {
    path.add(0, -1);
    return path;
  }

  //ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  PriorityQueue<Node> fringe = new PriorityQueue<Node>(); 

  if (goalID < 0) {
    return path;
  }

  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");

  visited[startID] = true;
  //float startCost = 0.0 + nodePos[startID].distanceTo(nodePos[goalID]); //Straight Line heuristic + gValue is 0.0 at start
  float startG = 0.0;
  float startH = nodePos[startID].distanceTo(nodePos[goalID]);
  Node startNode = new Node(startID, startG, startH);
  fringe.add(startNode);
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  //nodeCost currentNode = fringe.remove();
  while (fringe.size() > 0) {
    Node currentNode = fringe.remove(); //Will remove lowest cost node from fringe
    if (currentNode.nodeID == goalID) {
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode.nodeID].size(); i++) {
      int neighborNode = neighbors[currentNode.nodeID].get(i);
      if (!visited[neighborNode]) {
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode.nodeID;
        float gValue = currentNode.gValue + nodePos[neighborNode].distanceTo(nodePos[currentNode.nodeID]); //Continues to update the cost for each possible nodes
        float heuristic = nodePos[neighborNode].distanceTo(nodePos[goalID]); //Straight Line heuristic (admissible heuristic)
        Node temp_neighborNode = new Node(neighborNode, gValue, heuristic);
        fringe.add(temp_neighborNode);
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
      }
    }
  }

  if (fringe.size() == 0) {
    //println("No Path");
    path.add(0, -1);
    return path;
  }

  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0, goalID);
  //print(goalID, " ");
  while (prevNode >= 0) {
    //print(prevNode," ");
    path.add(0, prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  fringe.clear();
  return path;
}

////UCS (Uniform Cost Search)
//ArrayList<Integer> runUCS(Vec2[] nodePos, int numNodes, int startID, int goalID){
//  //ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
//  PriorityQueue<NodeUCS> fringe = new PriorityQueue<NodeUCS>(); 
//  ArrayList<Integer> path = new ArrayList();
//  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
//    visited[i] = false;
//    parent[i] = -1; //No parent yet
//  }

//  //println("\nBeginning Search");

//  visited[startID] = true;
//  NodeUCS startNode = new NodeUCS(startID, 0.0);
//  fringe.add(startNode);
//  //println("Adding node", startID, "(start) to the fringe.");
//  //println(" Current Fringe: ", fringe);
//  //nodeCost currentNode = fringe.remove();
//  while (fringe.size() > 0){
//    NodeUCS currentNode = fringe.remove(); //Will remove lowest cost node from fringe
//    if (currentNode.nodeID == goalID){
//      //println("Goal found!");
//      break;
//    }
//    for (int i = 0; i < neighbors[currentNode.nodeID].size(); i++){
//      int neighborNode = neighbors[currentNode.nodeID].get(i);
//      if (!visited[neighborNode]){
//        visited[neighborNode] = true;
//        parent[neighborNode] = currentNode.nodeID;
//        float gCost = currentNode.gValue + nodePos[neighborNode].distanceTo(nodePos[currentNode.nodeID]); //Continues to update the cost for each possible nodes
//        NodeUCS temp_neighborNode = new NodeUCS(neighborNode, gCost);
//        fringe.add(temp_neighborNode);
//        //println("Added node", neighborNode, "to the fringe.");
//        //println(" Current Fringe: ", fringe);
//      }
//    } 
//  }

//  if (fringe.size() == 0){
//    //println("No Path");
//    path.add(0,-1);
//    return path;
//  }

//  //print("\nReverse path: ");
//  int prevNode = parent[goalID];
//  path.add(0,goalID);
//  //print(goalID, " ");
//  while (prevNode >= 0){
//    //print(prevNode," ");
//    path.add(0,prevNode);
//    prevNode = parent[prevNode];
//  }
//  //print("\n");
//  fringe.clear();
//  return path;
//}

////BFS (Breadth First Search)
//ArrayList<Integer> runBFS(Vec2[] nodePos, int numNodes, int startID, int goalID){
//  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
//  ArrayList<Integer> path = new ArrayList();
//  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
//    visited[i] = false;
//    parent[i] = -1; //No parent yet
//  }

//  //println("\nBeginning Search");

//  visited[startID] = true;
//  fringe.add(startID);
//  //println("Adding node", startID, "(start) to the fringe.");
//  //println(" Current Fringe: ", fringe);

//  while (fringe.size() > 0){
//    int currentNode = fringe.get(0);
//    fringe.remove(0);
//    if (currentNode == goalID){
//      //println("Goal found!");
//      break;
//    }
//    for (int i = 0; i < neighbors[currentNode].size(); i++){
//      int neighborNode = neighbors[currentNode].get(i);
//      if (!visited[neighborNode]){
//        visited[neighborNode] = true;
//        parent[neighborNode] = currentNode;
//        fringe.add(neighborNode);
//        //println("Added node", neighborNode, "to the fringe.");
//        //println(" Current Fringe: ", fringe);
//      }
//    } 
//  }

//  if (fringe.size() == 0){
//    //println("No Path");
//    path.add(0,-1);
//    return path;
//  }

//  //print("\nReverse path: ");
//  int prevNode = parent[goalID];
//  path.add(0,goalID);
//  //print(goalID, " ");
//  while (prevNode >= 0){
//    //print(prevNode," ");
//    path.add(0,prevNode);
//    prevNode = parent[prevNode];
//  }
//  //print("\n");

//  return path;
//}

//Node Class used to tuple nodes with cost (A* Algorithm version)
class Node implements Comparable<Node> {
  int nodeID;
  float gValue;
  float hValue;
  float fValue;
  public Node(int id, float g, float h) {
    nodeID = id;
    gValue = g;
    hValue = h;
    fValue = gValue + hValue;
  }
  public boolean equals(Node n) {
    double EPSILON = 0.0001;
    return this.nodeID == n.nodeID && Math.abs(this.fValue - n.fValue) < EPSILON;
  }
  public int compareTo(Node node) {
    if (this.fValue > node.fValue) { //Greater than
      return 1;
    } else if (this.fValue < node.fValue) { //Less than
      return -1;
    } else { //Math.abs(this.nodeCost - n.nodeCost) < EPSILON Equal
      return 0;
    }
  }
}

//Node Class used to tuple nodes with cost (Uniform Cost Search Version)
class NodeUCS implements Comparable<NodeUCS> {
  int nodeID;
  float gValue;
  public NodeUCS(int id, float cost) {
    nodeID = id;
    gValue = cost;
  }
  public boolean equals(NodeUCS n) {
    double EPSILON = 0.0001;
    return this.nodeID == n.nodeID && Math.abs(this.gValue - n.gValue) < EPSILON;
  }
  public int compareTo(NodeUCS node) {
    if (this.gValue > node.gValue) { //Greater than
      return 1;
    } else if (this.gValue < node.gValue) { //Less than
      return -1;
    } else { //Math.abs(this.gValue - n.gValue) < EPSILON Equal
      return 0;
    }
  }
}
