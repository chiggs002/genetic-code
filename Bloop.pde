// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Evolution EcoSystem

// Creature class

class Bloop {
  PVector position; // position
  DNA dna;          // DNA
  float health;     // Life timer
  float xoff;       // For perlin noise
  float yoff;
  // DNA will determine size and maxspeed
  float r;
  int noOfSides;
  float maxspeed;
  color c;
  float theta;
  float ameobaNoiseY;
  int displayNo;
  float calcSize;
  float oldSize;
  
  
  //seperate mouse attract force
  float fmaxforce;    // Maximum steering force
  float fmaxspeed;    // Maximum speed
  PVector velocity;
  PVector acceleration;
  float lastd;
   // time interval 01 no action
  int noMovement1Time;
  int noMovement1Interval;
  PVector lastPos;
  float barrierDistance;
  int  limitofMovedMouse;
  boolean diffForce;
  float randomMax;
  PVector randomPos;
  float xs;
  float ys;
  float attractionFactor;
  

  // Create a "bloop" creature
  Bloop(PVector l, DNA dna_) {
    attractionFactor=0;
    calcSize=0;
    oldSize=-1.0;
    displayNo=0;
    theta=0;
    position = l.get();
    lastPos  = new PVector(l.x, l.y);
    health = 200;
    xoff = random(1000);
    yoff = random(1000);
    dna = dna_;
    
    //seperate mouse attract force
    fmaxspeed = 1.0;
    fmaxforce = 1;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    noMovement1Interval=int(random(10000,20000));
    noMovement1Time=millis()+noMovement1Interval;
    diffForce = false;
    randomMax = 1.0;
    // random force vectors
    randomPos = new PVector(0,0);
       
    // random force bariers all differnt
    barrierDistance= random(20,300);
     // EVERY PARTICLE DIFFERNT MOUSE INTERVAL
    limitofMovedMouse =  int(random(10,1000));
    
    // Gene 0 determines maxspeed and r
    // The bigger the bloop, the slower it is
    
    // ACCESS DNA 0 SPEED
    // ACCESS DNA 0 RADIUS
    // ACCESS DNA 1,2,3 RGB
    // ACCESS DNA 4 NO. OF POLYGONS  
    // ACCESS DNA 5 TYPE OF DISPLAY
    // ACCESS DNA 6. ATTRACTION FORCE
    
    maxspeed = map(dna.genes[0], 0, 1, 10, 0);
    r = map(dna.genes[0], 0, 1, 0, 50);
    c = color(dna.genes[1]*255.0,dna.genes[2]*255.0,dna.genes[3]*255.0);
    noOfSides = int(map(dna.genes[4], 0, 1, 3, 9));
    displayNo = int(map(dna.genes[5], 0, 1, 0, 5));
    attractionFactor = dna.genes[6];
   // println("c= ",c);
   
    //println("dna.genes[1]=",dna.genes[1]);
  }

  void run() {
    updateNoise();
    borders();
    display();
  }

 // see if the mouse has selected a type phemotype
  void selectHealth(PVector m) {
   calcSize = m.mag();
   
   
   if ( calcSize != oldSize ) {
      oldSize = calcSize;
      float d = PVector.dist(position, m);
     
      // If we are, juice up our strength!
      if (d < r/2) {
        if (health < 250 ) {
         health += 100; 
         attractionFactor+=0.1;
         attractionFactor= constrain(attractionFactor, 0, 1);
         
       // println("-----------------------------------");
       // println("m=",m);
        //println("mouse=",mouseX,mouseY);
       println("HEALTH INCREASED");
       println("attractionFactor= ",attractionFactor);
        } // health less than 250
      }// end d size
      
   } //end calc size
    
  }//end slecthealth





  // A bloop can find food and eat it
  void eat(Food f) {
    ArrayList<PVector> food = f.getFood();
    // Are we touching any food objects?
    for (int i = food.size()-1; i >= 0; i--) {
      PVector foodposition = food.get(i);
      float d = PVector.dist(position, foodposition);
      // If we are, juice up our strength!
      if (d < r/2) {
        health += 100; 
        food.remove(i);
      }
    }
  }

  // At any moment there is a teeny, tiny chance a bloop will reproduce
  Bloop reproduce() {
    // asexual reproduction
    if (random(1) < 0.0005) {
      // Child is exact copy of single parent
      DNA childDNA = dna.copy();
      // Child DNA can mutate
      childDNA.mutate(0.09);
      return new Bloop(position, childDNA);
    } 
    else {
      return null;
    }
  }
  
//**********************SEPARATE AND SEEK********************
  
   // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
  PVector desired = PVector.sub(target,position);  // A vector pointing from the position to the target
    
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(fmaxspeed);
    // Steering = Desired minus velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(fmaxforce);  // Limit to maximum steering force
    
    return steer;
  }
  
  // Separation
  // Method checks for nearby vehicles and steers away
  PVector separate (ArrayList<Bloop> vehicles) {
    
    //genetic mapped radius
    float desiredseparation = r*2;
    PVector sum = new PVector();
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Bloop other : vehicles) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div(count);
      // Our desired vector is the average scaled to maximum speed
      sum.normalize();
      sum.mult(fmaxspeed);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.sub(velocity);
      sum.limit(fmaxforce);
    }
    return sum;
  }


  
  
  
  void applyBehaviors(ArrayList<Bloop> vehicles, int Mx,int My) {
     PVector separateForce = separate(vehicles);
   
     PVector seekForce = seek(new PVector(Mx,My));
      PVector inputVector = new PVector(Mx,My);
  
       //What are we seeking?
       
     // CHECK DISTANCE BETWEEN CURRENT INPUT POSITION  AND CURRENT PARTICLE POSN
      // lastd = PVector.dist(inputVector, lastPos);
       lastd = PVector.dist(inputVector, position);
      
     
     
    // update last pos every ten seconds
    
    if (millis() > noMovement1Time) {
      
      //if inputVector  to  lastpos  < 50
      
      
     // println("Mx=",Mx);
    //  println("lastPos.x=",lastPos.x,"Mx=",Mx);
      
   
       
      // println("diffForce=",diffForce[0]);
    //  println("noMovement1Time=",noMovement1Time,"currenttime=",millis());
    //   println("lastPos.x=",lastPos.x,"Mx=",Mx);
     //  println("MOUSE POSITION AND CURRENT PART POSN lastd=",lastd);
      
     noMovement1Time=millis()+noMovement1Interval;
     
     // change lastpos to current input value EVREY 10 SECONDS
     //UPDATE LAST POSITION EVERY 10 SECONDS
      lastPos.x  = Mx;
      lastPos.y  = My;
      
      
    }//MILLIS UPDATED 
    
       // check difference between lastpos is less than 10
       // CHECK IF MOUSE HAS MOVED
       
       //CHECK IF MOUSE HAS MOVED
       float lastPosDiff=  abs( lastPos.x-Mx);
       
       //NEW
       if (lastPosDiff==0) {
         
          attractionFactor-=0.1;
         attractionFactor= constrain(attractionFactor, 0, 1);
         
       // println("-----------------------------------");
       // println("m=",m);
        //println("mouse=",mouseX,mouseY);
       println("DECREASE ATTRACTION");
       println("attractionFactor= ",attractionFactor);
         
       }
       
       
       
     //  println("lastPosDiff=",lastPosDiff);
    
      //if (lastd < 5 && lastPosDiff  < 10) {
      //barrierDistance 
      // if (lastd < 70 && lastPosDiff  < 10)  {
        
        
        if (lastd < 10 && lastPosDiff  < 4)  {
         //  remove a  white vehicle
          if (bloops.size() >0) {
            println("1 white vehicle removed");
           
            CountBrightNumber--;
            println("CountBrightNumber =",CountBrightNumber);
            bloops.remove(0);
            }// delete a white vehicle
        }//
        
        
        //SWITCH FORCES RANDOM AND SEEK limitofMovedMouse
        if (lastd < barrierDistance && lastPosDiff  < limitofMovedMouse)  {
         diffForce = true;
       } else {
           //println("diffForce=",diffForce);
         diffForce = false;
       }
      // println("diffForce=",diffForce[0]);
     
     
     
     
     if (diffForce)  {
       // seek random force if pos difference is less than 50
    // println("seeking random force");
      seekForce = seek(RandomMove());
       }// lastpos diff from posn
     
     
       
     
     separateForce.mult(8);
     //seekForce.mult(1);
     seekForce.mult(attractionFactor);
    // println("attractionFactor= ",attractionFactor);
    
     
     // APPLY ALL FORCES
     applyForce(separateForce);
     applyForce(seekForce); 
  }// end Behaviurs
  
  
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  } //end applyforce
  
  
  // Method to update position
  void updateOtherForce() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(fmaxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

PVector RandomMove(){
      
  //random move please
        xs += random(-randomMax,randomMax);

        ys += random(-randomMax,randomMax);
        
        //access pvector
        randomPos.x+= xs;
        randomPos.y += ys;
        
        if(randomPos.x < 0) { randomPos.x = 0; xs *= -.5;}
        if(randomPos.x > width-20) { randomPos.x = width-20; xs *= -.5;}
        if(randomPos.y < 0) { randomPos.y = 0; ys *= -.5;}
        if(randomPos.y > height-20) { randomPos.y = height-20; ys *= -.5;}
        
        //println("randomPos=",randomPos);
        
        return randomPos;
        
    } //end RandomMove










  // Method to update position
  void updateNoise() {
    // Simple movement based on perlin noise
    float vx = map(noise(xoff),0,1,-maxspeed,maxspeed);
    float vy = map(noise(yoff),0,1,-maxspeed,maxspeed);
    PVector mvelocity = new PVector(vx,vy);
    
    //add random noise to velocity
    //velocity.add(mvelocity);
    xoff += 0.01;
    yoff += 0.01;

    //add random noise to position
    position.add(mvelocity);
    // Death always looming
    health -= 0.2;
  } //end update Noise

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Method to display
  void display() {
    ellipseMode(CENTER);
    stroke(c,health);
    //noStroke();
     //fill(c, health);
    fill(c, health);
  // ellipse(position.x, position.y, r, r);
    
    pushMatrix();
    translate(position.x, position.y);
    theta = position.heading2D() + PI/2;
    rotate(theta);
    
    
    //drawShape(noOfSides, r);
    
    //drawAmeoba02(r*0.5);
    //drawAmeoba(r*0.5);
    
    // DRAW DIFRENT OBJECTS
    switch(displayNo) {
  case 0: 
    //ellipse(position.x, position.y, r, r);
    drawAmeobaOld();
    //println("0");  // Does not execute
    break;
  case 1: 
    drawAmeobaSphere();
    //rect(position.x, position.y, r, r);
   // println("1");  // Prints "Bravo"
    break;
  case 2: 
    drawShape(noOfSides, r*0.5);
    //println("2");  // Prints "Bravo"
    break;
  case 3: 
    drawAmeoba(r*0.5);
   // println("3");  // Prints "Bravo"
    break;
  case 4: 
    drawAmeoba02(r*0.5);
   // println("4");  // Prints "Bravo"
    break;
  case 5: 
   // println("5");  // Prints "Bravo"
    break;
  default:
    //println("Zulu");   // Does not execute
    break;
}
    
    popMatrix();
  }

  // Death
  boolean dead() {
    if (health < 0.0) {
      return true;
    } 
    else {
      return false;
    }
  }// dead
  
  
  void drawShape(int nopoints, float l) {
    
    // Draw a polygon not filled (clear) of "nopoints" and length "l" sides
    // Use cosine and sine to calc point sources.
    //ofPolyline line;
    //ofPoint pt;
    ArrayList<PVector> a = new ArrayList<PVector>();
    
    beginShape();
   
    float length=l ;
    int numberofpoint =nopoints;
  
    float degreeChange= 360/numberofpoint;
      float angle= (nopoints-2) * degreeChange;
    //float increment;
    //line.clear();
    noFill();
    
    
    for (int i =0; i<numberofpoint;i++) {
      float length2= length+40*noise(i,ameobaNoiseY);
        
        float x = length2 * cos(radians((degreeChange+angle/1.0) *i));
        float y = length2 * sin(radians((degreeChange+angle/1.0)*i));
        PVector v1 = new PVector(x, y);
        a.add(v1);
        //vertex(x,y);
        curveVertex(x,y);
       // pt.set(x,y);
        //line.addVertex(pt);
        
        
    }//end loop
    curveVertex(a.get(a.size()-1).x,a.get(a.size()-1).y);
    curveVertex(a.get(0).x,a.get(0).y);
    curveVertex(a.get(0).x,a.get(0).y);
    
   // line.close();
   // line.draw();
    endShape(CLOSE);
    
    ameobaNoiseY+=.01;
}//drawshape


void drawAmeoba(float radius ){
//
//
//  Draw cellular figures with of set of joined vertices
//
//  not filled
//
//
//
 
//translate(width/2,height/2);
smooth();
//fill(4,1);
//stroke(r,g,b,254);
//strokeWeight(0.3);
noFill();
beginShape();
//background(0);

for(float i=0;i<2*PI;i+=PI/64) {
vertex((radius +10*noise(i,ameobaNoiseY))*cos(i),(radius +10*noise(i,ameobaNoiseY))*sin(i));
 
vertex((radius +13*noise(i,ameobaNoiseY))*cos(i), (radius +13*noise(i,ameobaNoiseY))*sin(i));
//println("250+(99+80*noise(i,g))*cos(i)=",250+(99+80*noise(i,ameobaNoiseY))*cos(i));
}

endShape(CLOSE);
ellipse(0, 0, 3, 3);
// rect(0,0,4,4);
ameobaNoiseY+=.01;


}//END AMEOBA 1




void drawAmeoba02(float radius ){
  //
//
//  Draw cellular figures with of set of joined vertices
//
//  filled
//
//
//
 
 
//translate(width/2,height/2);
//smooth();
//fill(r,g,b,1);
//stroke(r,g,b,254);
//strokeWeight(0.3);
//noFill();
beginShape();
//background(0);

for(float i=0;i<2*PI;i+=PI/64) {
vertex((radius +22*noise(i,ameobaNoiseY))*cos(i),(radius +22*noise(i,ameobaNoiseY))*sin(i));
 
vertex((radius +33*noise(i,ameobaNoiseY))*cos(i), (radius +33*noise(i,ameobaNoiseY))*sin(i));
//println("250+(99+80*noise(i,g))*cos(i)=",250+(99+80*noise(i,ameobaNoiseY))*cos(i));
}

endShape(CLOSE);
//ellipse(0, 0, 8, 8);
// rect(0,0,4,4);
ameobaNoiseY+=.01;


}//END AMEOBA 2
  
  
  
  void drawAmeobaOld(){
 
//translate(width/2,height/2);
//smooth();
//fill(4,1);
//stroke(56,34,0,40);
//noFill();
beginShape();
//background(255);

for(float i=0;i<2*PI;i+=PI/64) {
vertex((0+20*noise(i,ameobaNoiseY))*cos(i),(0+20*noise(i,ameobaNoiseY))*sin(i));
 
vertex((20+70*noise(i,ameobaNoiseY))*cos(i), (20+70*noise(i,ameobaNoiseY))*sin(i));
//println("250+(99+80*noise(i,g))*cos(i)=",250+(99+80*noise(i,ameobaNoiseY))*cos(i));
}

endShape(CLOSE);

ameobaNoiseY+=.01;


} //ameobaold

  void drawAmeobaSphere(){
 
//translate(width/2,height/2);
//smooth();
//fill(4,1);
//stroke(56,34,0,40);
//noFill();
beginShape();
//background(255);

for(float i=0;i<2*PI;i+=PI/64) {
vertex((10+8*noise(i,ameobaNoiseY))*cos(i),(10+8*noise(i,ameobaNoiseY))*sin(i));
 
//vertex((20+70*noise(i,ameobaNoiseY))*cos(i), (20+70*noise(i,ameobaNoiseY))*sin(i));
//println("250+(99+80*noise(i,g))*cos(i)=",250+(99+80*noise(i,ameobaNoiseY))*cos(i));
}

endShape(CLOSE);

ameobaNoiseY+=.01;


} //ameobasphere
  
  
  
} // end class