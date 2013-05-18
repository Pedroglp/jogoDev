class Plataform {

  // A boundary is a simple rectangle with x,y,width,and height
  //Uma fronteira eh um simples retangulo com x,y,lagura e altura
  float x;
  float y;
  float w;
  float h;
  Vec2 v;
  float max;
  float min;
  
  // Criando um variavel do tipo Body para guardar as informacoes
  Body b;

  Plataform(float x_,float y_, float w_, float h_, Vec2 v_,float min_,float max_) {
    x = x_; //posicao na tela x
    y = y_; //posicao na tela y
    w = w_; //largura
    h = h_; //altura
    v = v_; //velocidade
    min = min_;
    max = max_;

    // novo poligono
    PolygonShape sd = new PolygonShape();
    // Convertando para coordenadas da box 2d, lembrando que dividimos por 2 pois a box2 mede do centro geometrico as pontas
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // agora setando a shape como uma caixa
    sd.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.friction = 0.3; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
    fd.density = 1; //densidade
    fd.shape=sd; //definido a shape para fixture


    // Definindo o tipo de corpo
    BodyDef bd = new BodyDef();
    // Estatico, nao se movimenta
    bd.type = BodyType.KINEMATIC;
    //Criando na posicaox x,y definida
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    
    // atribuindo ao corpo as qualidades da shape
    b.createFixture(fd);
    
    b.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();
  }
  
  /*void move(Vec2 velPerso){
    Vec2 velPlat = b.getLinearVelocity();
    Vec2 velRelativa = velPerso;
    //b.setTransform(new Vec2(box2d.coordPixelsToWorld(x,y)),0); //isso é necessario para posicionar o desenho em relacao ao personagem
    b.setLinearVelocity(new Vec2(velPlat.x + velPerso.x,0));
    
  }*/

  // Desenhando
  void display(float deslocPerso) {
    max-=deslocPerso;
    min-=deslocPerso;
    Vec2 pos = box2d.getBodyPixelCoord(b);
    if(pos.x > max)
      b.setLinearVelocity(new Vec2(-v.x,0));
    if(pos.x <= min)
      b.setLinearVelocity(v);
    println(pos.x);
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(pos.x,pos.y,w,h);
  }

}
