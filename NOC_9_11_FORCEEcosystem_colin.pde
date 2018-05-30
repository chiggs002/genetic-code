// Evolution EcoSystem
// Daniel Shiffman <http://www.shiffman.net>
// The Nature of Code

// test code
// A World of creatures that eat food
// The more they eat, the longer they survive
// The longer they survive, the more likely they are to reproduce
// The bigger they are, the easier it is to land on food
// The bigger they are, the slower they are to find food
// When the creatures die, food is left behind

 ArrayList<Bloop> bloops;    // An arraylist for all the creatures

World world;


//extra stuff from my algorithms
int CountBrightNumber;

void setup() {
  
 //frameRate(104);
  //size(640, 360);
  size(1920, 1080,P3D);
  // World starts with 20 creatures
  // and 20 pieces of food
  world = new World(20);
  smooth();
  
  CountBrightNumber=0;
  
}

void draw() {
  
    
  background(255);
  world.run(mouseX,mouseY);
}

// We can add a creature manually if we so desire
void mousePressed() {
  world.born(mouseX,mouseY); 
}

void mouseDragged() {
  world.born(mouseX,mouseY); 
}