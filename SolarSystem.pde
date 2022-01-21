Planet[] planetPool = new Planet[3];

void setup() {
  size(800,600);
  frameRate(60);
  planetPool[0] = new Planet(width/2,height/2,9,0,0,0){ // Add the middle planet. Override its step so it doesn't move.
    @Override public void step(Planet[] pp) {
      ellipse((int)this.getX(),(int)this.getY(),10,10);
    }
  };
  // Add two planets that do move. This configuration gives a stable orbit for both.
  planetPool[1] = new Planet(width/2,200,2,2,0,100);
  planetPool[2] = new Planet(width/3,400,1,1,1,100);
}



void draw() {
    background(255);
    drawGravity(planetPool);
    for(Planet p : planetPool) {
      p.step(planetPool);
    }
}

// Draws the gravity field directly to the framebuffer.
// The more blue the pixel, the greater the force of gravity at that point.
public void drawGravity(Planet[] pp) {
  loadPixels();
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      int v = 0;
      for(Planet p : pp) {
        double relxpos = x-p.xpos;
        double relypos = y-p.ypos;
        double dist = Math.sqrt((relxpos * relxpos) + (relypos * relypos));
        
        v += dist* 0.3;
      }
      pixels[x + (y * width)] = color(0,0,255 - v);
    }
  }
  updatePixels();
}

public class Planet {
  
  private int speed = 1;
  
  public void setSpeed(int v) {speed = v;}
  
  private double xpos = 0;
  private double ypos = 0;
  
  private double mass;
  
  private double xspeed = 0;
  private double yspeed = 0;
  
  private double G = -50; // Arbitrary constant. No necessarily the same of our universe.
  
  private int trailIndex = 0;
  private PVector[] trailArray;
  
  public double getX() {return xpos;}
  public double getY() {return ypos;}
  
  public Planet(int x, int y, int mass, int xsp, int ysp, int trailn) {
    xpos = x;
    ypos = y;
    this.mass = mass;
    xspeed = xsp;
    yspeed = ysp;
    trailArray = new PVector[trailn];
  }
  
  public void step(Planet[] planetPool) {
    if(speed <= 0) {
      speed = 1;
    }
    for(int i = 0; i < speed; i++) {
      for(Planet p : planetPool) {
        if(p != this) // Only calculate physics relative to other planets.
          physics(p);
      }
    }
    // Add current position to the trail
    trailArray[trailIndex >= trailArray.length ? trailIndex = 0 : trailIndex++] = new PVector((float)xpos,(float)ypos);
    fill(0);
    for(PVector p : trailArray) {
      if(p != null)
        ellipse(p.x,p.y,3,3);
    }
    fill(255);
    ellipse((int)xpos,(int)ypos,10,10);
  }
  
  // Updates the speed and position of this planet relative to planet t
  // using the universal formula for gravity.
  private void physics(Planet t) {
    double relPosX = xpos - t.xpos;
    double relPosY = ypos - t.ypos;
    double distance = Math.sqrt( (relPosX*relPosX) + (relPosY * relPosY) );
    double angle = Math.atan2(relPosY,relPosX);
    double force = G * ( (mass * t.mass) / (distance * distance) );
    double xforce = force*Math.cos(angle);
    double yforce = force*Math.sin(angle);
    xspeed += xforce;
    yspeed += yforce;
    xpos += xspeed;
    ypos += yspeed;
    
  }
  
}
