class bird {
  int base = 0, div = 500;
  float mass, at = .9, ct =.23, st = .28, limit = 10;

  //create pastel color
  color c;
  PVector pos, vel = new PVector(), acc = new PVector(), sum = new PVector();
  ArrayList<bird> neighbors;

  //constructors
  bird() {
    pos = new PVector(random(0, width), random(0, height));
    mass = 2;
    //mass = random(1, 3);
    vel = PVector.random2D();
    vel.setMag(limit);
  }
  bird(PVector pos) {
    this.pos = pos;
    mass = 2;
    vel = PVector.random2D();
  }

  //utility
  public float dist(bird b) {
    return this.pos.dist(b.pos);
  }
  
  public float distsq(bird b) {
    return (b.pos.x-this.pos.x)*(b.pos.x-this.pos.x) + (b.pos.y-this.pos.y)*(b.pos.y-this.pos.y) ;
  }

  void applyForce(PVector f) {
    PVector nf = PVector.div(f, mass/2);
    acc.add(nf);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the location to the target
    desired.setMag(limit);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(limit);
    return steer;
  }  

  PVector avoid(PVector target) {
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the location to the target
    desired.setMag(limit);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(limit);
    steer.mult(-1);
    return steer;
  }

  void show() {
    noStroke();
    fill(c);
    float theta = vel.heading() + radians(90);

    //ellipse(pos.x, pos.y, mass*5, mass*5);

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -mass*4);
    vertex(-2*mass, mass*4);
    vertex(2*mass, mass*4);
    endShape();
    popMatrix();
  }

  //core
  void update(float frame) {
    c = color(255*noise(pos.x/div, pos.y/div, frame/div), 
      255*noise(pos.x/div+1000, pos.y/div+1000, frame/div), 
      255*noise(pos.x/div-1000, pos.y/div-1000, frame/div));

    hardEdges();

    //physics
    vel.add(acc);
    vel.limit(limit);
    pos.add(vel);

    //clear acceleration
    acc.mult(0);
  }

  //forces
  //bounces bird to other side of screen
  private void hardEdges() {
    if (pos.x < -2*mass) pos.x = width+2*mass;
    if (pos.y < -2*mass) pos.y = height+2*mass;
    if (pos.x > width+2*mass) pos.x = -2*mass;
    if (pos.y > height+2*mass) pos.y = -2*mass;
  }


  PVector alignment() {
    sum.mult(0);
    for (bird b : neighbors) {
      sum.add(b.vel);
    }
    if (neighbors.size() > 0) {
      sum.setMag(limit);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(limit);
      return steer;
    } else
      return sum;
  }

  PVector cohesion() {
    sum.mult(0);
    for (bird c : neighbors) {
      sum.add(c.pos);
    }
    if (neighbors.size() > 0) {
      sum.div(neighbors.size());
      return seek(sum);
    } else
      return sum;
  }

  PVector seperation() {
    PVector result = new PVector(0, 0);
    sum.mult(0);
    for (bird c : neighbors) {
      sum = PVector.sub(pos, c.pos);
      sum.normalize();
      sum.div(this.dist(c)*2);
      result.add(sum);
    }
    if (neighbors.size() > 0) {
      result.div(neighbors.size());
    }

    if (result.mag() > 0) {
      result.setMag(limit);
      result.sub(vel);
      result.limit(limit);
    }

    return result;
  }
}
