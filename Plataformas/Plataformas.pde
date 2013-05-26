class Plataform {

  // A boundary is a simple rectangle with x,y,width,and height
  //Uma fronteira eh um simples retangulo com x,y,lagura e altura
  float x;   //posicao
  float y;  //poicao
  float w; //largura
  float h; //altura
  Vec2 v;
  //limites de movimento da plataforma
  Vec2 max;  //maximo valor para posicao (x,y)
  Vec2 min; //minimo valor para posicao (x,y)
  
  // Criando um variavel do tipo Body para guardar as informacoes
  Body b;

  Plataform(float x_,float y_, float w_, float h_, Vec2 v_,Vec2 min_,Vec2 max_) {
    x = x_; //posicao na tela x
    y = y_; //posicao na tela y
    w = w_; //largura
    h = h_; //altura
    v = v_; //velocidade
    min = min_; //posicao minima para a barra voltar
    max = max_; //posicao maxima que obriga a barra a voltar

    // novo poligono
    PolygonShape sd = new PolygonShape();
    // Convertando para coordenadas da box 2d, lembrando que dividimos por 2 pois a box2 mede do centro geometrico as pontas
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // agora setando a shape como uma caixa
    sd.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.friction = 0.8; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
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
  
  // Desenhando
  void display(Vec2 posAntPerso, Vec2 posAtuPerso, boolean naPlataforma) {
    Vec2 delta = new Vec2((posAtuPerso.x - posAntPerso.x),(posAtuPerso.y - posAntPerso.y));; //vetor que recebera a variacao da distancia do personagem em x e y
    max.x-=delta.x; //ajustando o max apos deslocamento do personagem
    min.x-=delta.x; //ajustando o min apos deslocamento do personagem
    max.y-=delta.y;
    min.y-=delta.y;
    Vec2 pos = box2d.getBodyPixelCoord(b);
    Vec2 velAtual = b.getLinearVelocity();
    
    if(pos.x >= max.x)
      b.setLinearVelocity(new Vec2(-v.x,velAtual.y));
    if(pos.x <= min.x)
      b.setLinearVelocity(new Vec2(v.x,velAtual.y));
    
    //para os limites de y preste atencao no sistema de coordenadas de pixels!
    if(pos.y <= max.y)
      b.setLinearVelocity(new Vec2(velAtual.x,+v.y));
    if(pos.y >= min.y)
      b.setLinearVelocity(new Vec2(velAtual.x,-v.y));
    if(naPlataforma) //essa booleana foi adicionada pois se o personagem estiver em cima da plataforma seu deslocamento em relacao a ela deve ser 0!
      b.setTransform(new Vec2(box2d.coordPixelsToWorld(pos.x+0,pos.y-delta.y)),0);
      
    else
      b.setTransform(new Vec2(box2d.coordPixelsToWorld(pos.x-delta.x,pos.y-delta.y)),0); //isso é necessario para posicionar o desenho em relacao ao personagem, como objeto se move
      //nao pode ser em x, se não fixara ele a todo momento na posicao inicial.
    pos = box2d.getBodyPixelCoord(b);
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(pos.x,pos.y,w,h);
  }

}
