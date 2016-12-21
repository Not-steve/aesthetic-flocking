int flockSize = 500;
float tooCloseX, tooCloseY, frame = 0;
float [] close = new float[3];
PVector mouse = new PVector();
ArrayList<bird> flock, nearby;

void setup() {
  fullScreen();
  close[0] = 50;
  close[1] = 50;
  close[2] = 30;
  tooCloseX = width/15;
  tooCloseY = height/15;

  flock = new ArrayList();
  for (int i = 0; i< flockSize; i++) {
    flock.add(new bird());
  }
}

void mouseClicked() {
  flock.add(new bird(new PVector(mouseX, mouseY)));
};

void draw() {
  if (key != 'p') {
    background(35, 43, 43);

    frame+=1;

    for (bird b : flock) {    
      if (key == ' ') {
        mouse.x = mouseX;
        mouse.y = mouseY;
        b.applyForce(b.avoid(mouse).mult(.1));
      }

      b.neighbors = neighbors(b, 0, close[0], flock);
      b.applyForce(b.alignment().mult(b.at));

      b.neighbors = neighbors(b, 0, close[1], b.neighbors);
      b.applyForce(b.cohesion().mult(b.ct));

      b.neighbors = neighbors(b, 0, close[2], b.neighbors);
      b.applyForce(b.seperation().mult(b.st));

      b.update();
      b.show();
    }
  }
}

ArrayList<bird> neighbors(bird b, float distance, ArrayList<bird> a) {
  ArrayList<bird> friends = new ArrayList();
  for (bird c : a) {
    if (b.dist(c) < distance && b != c) {
      friends.add(c);
    }
  }
  return friends;
}

ArrayList<bird> neighbors(bird b, float close, float distance, ArrayList<bird> a) {
  ArrayList<bird> friends = new ArrayList();
  for (bird c : a) {
    if (b.dist(c) < distance && b.dist(c) > close && b != c) {
      friends.add(c);
    }
  }
  return friends;
}