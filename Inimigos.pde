// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Showing how to use applyForce() with box2d

class Inimigo {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  float x;
  float y;
  int type;
  float limiteMin = 300000;
  float limiteMax = 300000;
  Vec2 pos;

  Inimigo(float r_, float x, float y, int type_){
    r = r_;
    type = type_;
    // Define a body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    // Set its position
    bd.position = box2d.coordPixelsToWorld(x,y);
    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);

    body.setLinearVelocity(new Vec2(random(-5,5),random(-5,-5)));
    body.setAngularVelocity(random(-1,1));
    
    body.setUserData(this);
  }

  void applyForce(Vec2 v) {
    pos = box2d.getBodyPixelCoord(body);
    if(pos.x < limiteMin)
      body.setLinearVelocity(new Vec2(1,0));
    if(pos.x > limiteMax)
      body.setLinearVelocity(new Vec2(-1,0));
    body.applyForce(v, body.getWorldCenter());
  }

  void display() {
    // We look at each body and get its screen position
    pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    fill(255,0,0);
    stroke(0);
    strokeWeight(2);
    ellipse(0,0,r*2,r*2);
    // Let's add a line so we can see the rotation
    line(0,0,r,0);
    popMatrix();
  }
}





