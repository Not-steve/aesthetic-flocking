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

  void applyForce(PVector f) {
    PVector nf = PVector.div(f, mass/2);
    acc.add(nf);
  }

  void bounce() {
    vel.mult(-1);
    applyForce(acc.mult(-1));
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
  void update() {
    c = color(255*noise(pos.x/div, pos.y/div, frame/div), 
      255*noise(pos.x/div+1000, pos.y/div+1000, frame/div), 
      255*noise(pos.x/div-1000, pos.y/div-1000, frame/div));

    //softEdges();
    hardEdges();
    //bounceEdge();

    //physics
    vel.add(acc);
    vel.limit(limit);
    pos.add(vel);

    //clear acceleration
    acc.mult(0);
  }

  //forces

  //applies a force to have them turn the away from the edge
  private void softEdges() {
    if (pos.x<tooCloseX) {
      applyForce(new PVector(limit/6, 0));
    }
    if (pos.x>(width-tooCloseX)) {
      applyForce(new PVector(-limit/6, 0));
    }
    if (pos.y<(tooCloseY)) {
      applyForce(new PVector(0, limit/6));
    }
    if (pos.y>(height-tooCloseY)) {
      applyForce(new PVector(0, -limit/6));
    }
  }

  //bounces bird to other side of screen
  private void hardEdges() {
    if (pos.x < -2*mass) pos.x = width+2*mass;
    if (pos.y < -2*mass) pos.y = height+2*mass;
    if (pos.x > width+2*mass) pos.x = -2*mass;
    if (pos.y > height+2*mass) pos.y = -2*mass;
  }

  private void bounceEdge() {
    if (pos.x < 3) {
      bounce();
    }
    if (pos.x>(width-3)) {
      bounce();
    }
    if (pos.y<(3)) {
      bounce();
    }
    if (pos.y>(height-3)) {
      bounce();
    }
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