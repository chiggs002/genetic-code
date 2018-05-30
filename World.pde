// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Evolution EcoSystem

// The World we live in
// Has bloops and food

class World {

  //ArrayList<Bloop> bloops;    // An arraylist for all the creatures
  Food food;
  int mx,my;

  // Constructor
  World(int num) {
    
  
    // Start with initial food and creatures
    
    //create "num" amounts of food at random x,y
    //  ARRAYLIST
    //
    //
    food = new Food(num);
    
    
    // CREATE "NUM" BLOOPS
    // RANDOM X,Y
    //
    bloops = new ArrayList<Bloop>();              // Initialize the arraylist
    for (int i = 0; i < num; i++) {
      PVector l = new PVector(random(width),random(height));
      DNA dna = new DNA();
      bloops.add(new Bloop(l,dna));
    }
  }

  // Make a new creature
  void born(float x, float y) {
    PVector l = new PVector(x,y);
    DNA dna = new DNA();
    bloops.add(new Bloop(l,dna));
  }

  // Run the world
  
  //
  void run(int mx,int my) {
    
    // Deal with food
    food.run(mx,my);
   // println("MX= ",mx,"MY =",my);
    PVector m= new PVector(mx,my);
    
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = bloops.size()-1; i >= 0; i--) {
      // All bloops run and eat
      Bloop b = bloops.get(i);
      
      //random run
      b.run();
      
      
      b.applyBehaviors(bloops,mx,my);
      b.updateOtherForce();
      b.display();
      
      b.eat(food);
      
      // select food for health if i roll over it
      b.selectHealth(m);
      
      
      
      // If it's dead, kill it and make food
      if (b.dead()) {
        bloops.remove(i);
        
         //println("mouseX= ",mx,"mouseY =",my);
       food.add(b.position); 
       
       // ADD FOOD AT MOUSE POSITION
        //food.add(m);
      }
      // Perhaps this bloop would like to make a baby?
      Bloop child = b.reproduce();
      if (child != null) bloops.add(child);
    }
  }
}