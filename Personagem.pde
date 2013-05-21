class Personagem {
  Body body;
  float altura, largura;
  Vec2 pos;
  Vec2 vel;

  Personagem(float x, float y){
    altura = 16;
    largura = 16;
    
    BodyDef bd = new BodyDef(); //criando as caracteristicas de um corpo do nosso personagem
    bd.type = BodyType.DYNAMIC; //Sera um corpo dinamico (com movimento)
    //if(!criado)
      bd.position.set(box2d.coordPixelsToWorld(x,y)); //essa sera a posicao do nosso corpo. Perceba que ha uma conversao do espaco fisico
    // para o espaco "pixelar". Isso se deve ao padrao de cada lib. Na box 2d, centro do sistema cartesiano eh dado no centro da tela (x=0,y=0)
    //ja no sistema grafico da processing eh dado no canto superior esquerdo.
    body = box2d.createBody(bd); // atribuimos ao corpo do personagem, as definicoes do corpo criado.
    
    PolygonShape ps = new PolygonShape(); //criando as caractericas geometricas de um corpo
    float box2dLargura = box2d.scalarPixelsToWorld(largura/2); //convertendo as dimensoes de pixels para "metro"
    float box2dAltura = box2d.scalarPixelsToWorld(altura/2); //o mesmo que acima
    //Porque dividido por 2? Simples, para o box2d as dimensoes dos objetos sao dadas do seu centro espacial ate a seu fim. Logo, seria
    //a metade do que nos normalmente adotamos como largura e altura
    ps.setAsBox(box2dLargura, box2dAltura); //setamos como um caixa com as dimensoes dadas entre parenteses
    
    FixtureDef fd = new FixtureDef(); //Entao, definimos o tipo de corpo, o tipo geometrico agora faltam as especificacoes fisicas deste.
    //Nao encontrei uma traducao para fixture, mas creio que seriam como "propriedades" algo do tipo.
    fd.shape = ps; //Informamos que o formato do corpo sera o formato ps criado. Isso porque, a box2d ira utilizar este para calular informacoes
    //uteis como: Massa, centro de massa, momento angular e etc.
    fd.density = 1; // definindo a densidade, veja, nao damos uma massa e sim a densidade, a massa sera calculada usando as dimensoes e densidade
    fd.friction = 0.3; //coeficiente de atrito
    fd.restitution = 0.1; //coeficiente de restituicao
    
    body.createFixture(fd); //agora passamos as qualidades "fixture" criada para o nosso corpo
    body.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();
  }
  
    void display(){ //aqui sera a parte em que pegaremos os dados que a box2d nos da e desenharemos na tela
    float angulo = body.getAngle(); //angulo do corpo
    pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
    
    pushMatrix();
    translate(pos.x,pos.y); //imagem sera deslocada
    rotate(-angulo); //rodaremos no angulo dado pela box2d
    fill(127); //colorindo
    stroke(0);//borda
    strokeWeight(2);//espesura da borda
    rectMode(CENTER);
    rect(0,0,altura,largura);//criando retangulo
    popMatrix();
   
    }
    
    void walk(int ncontato){
       vel = body.getLinearVelocity();

      if((key == 'a' || key == 'A') && vel.x > -4.5){
        body.applyForce(new Vec2 (-70,0), body.getWorldCenter());
      }
      if((key == 'd' || key == 'D') && vel.x < 4.5){
        body.applyForce(new Vec2(70,0), body.getWorldCenter());
      }
      if((key == 's' || key == 'S')){
        if(ncontato != 0) //so pode frear se estiver no chao
          body.setLinearVelocity(new Vec2(0,vel.y));
      }
      if((key == 'w' || key == 'W') && ncontato >= 1 && vel.y < 5){ //se estiver encostando em algo no chao
        body.applyLinearImpulse(new Vec2(vel.x,25), body.getWorldCenter());
      }
      
      if(key == 'r' || key =='R'){
        body.setTransform(new Vec2(box2d.coordPixelsToWorld(20,20)),0);
        body.setLinearVelocity(new Vec2(0,0));
        //body.position.set(box2d.coordPixelsToWorld(20,20));
      }
      key = '^';//limpando a tecla, nao achei modo melhor
    }
}
