class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  //Uma fronteira eh um simples retangulo com x,y,lagura e altura
  float x;
  float y;
  float w;
  float h;
  
  // Criando um variavel do tipo Body para guardar as informacoes
  Body b;

  Boundary(float x_,float y_, float w_, float h_) {
    x = x_; //posicao na tela x
    y = y_; //posicao na tela y
    w = w_; //largura
    h = h_; //altura

    // novo poligono
    PolygonShape sd = new PolygonShape();
    // Convertando para coordenadas da box 2d, lembrando que dividimos por 2 pois a box2 mede do centro geometrico as pontas
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // agora setando a shape como uma caixa
    sd.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.friction = 0.4; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
    fd.density = 1; //densidade
    fd.shape=sd; //definido a shape para fixture



    // Definindo o tipo de corpo
    BodyDef bd = new BodyDef();
    // Estatico, nao se movimenta
    bd.type = BodyType.STATIC;
    //Criando na posicaox x,y definida
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    
    // atribuindo ao corpo as qualidades de fixture
    b.createFixture(fd);
    
    b.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();
  }

  // Desenhando
  void display() {
    b.setTransform(new Vec2(box2d.coordPixelsToWorld(x,y)),0); //isso é necessario para posicionar o desenho em relacao ao personagem
    fill(0);
    stroke(0);
    rectMode(CENTER);
    rect(x,y,w,h);
  }

}
