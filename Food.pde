// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Evolution EcoSystem

// A collection of food in the world

class Food {
  ArrayList<PVector> food;
     int mx,my;
  Food(int num) {
    // Start with some food
    
    food = new ArrayList();
    for (int i = 0; i < num; i++) {
       food.add(new PVector(random(width),random(height))); 
       //food.add(new PVector(mX,mY)); 
       //println("mouseX= ",mouseX,"mouseY =",mouseY);
    }
  } 
  
  // Add some food at a position
  void add(PVector l) {
     food.add(l.get()); 
  }
  
  // Display the food
  void run( int mX, int mY) {
    for (PVector f : food) {
       rectMode(CENTER);
       stroke(0);
       fill(175);
       rect(f.x,f.y,8,8);
    } 
    
    //// foodfolows mouse
    //if (random(1) < 0.9) {
    //  //food.add(new PVector(random(width),random(height))); 
    //   food.add(new PVector(mX,mY)); 
    //   println("mx= ",mX,"my =",mY);
    //}
    
    // There's a small chance food will appear randomly
    if (random(1) < 0.004) {
      food.add(new PVector(random(width),random(height))); 
       food.add(new PVector(mX,mY)); 
      // println("mx= ",mX,"my =",mY);
    }
    
    
  }
  
  // Return the list of food
  ArrayList getFood() {
    return food; 
  }
}