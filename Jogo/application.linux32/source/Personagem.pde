class Personagem {
  Body body;
  float altura, largura;
  Vec2 pos;
  Vec2 vel;
  boolean delete = false;

  Personagem(float x, float y){
    altura = 50;
    largura = 50;
    
    BodyDef bd = new BodyDef(); //criando as caracteristicas de um corpo do nosso personagem
    bd.type = BodyType.DYNAMIC; //Sera um corpo dinamico (com movimento)
    //bd.fixedRotation = true;//sem rotação
    bd.linearDamping = 0.03;//arrasto no ar.
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
    fd.density = 3.0; // definindo a densidade, veja, nao damos uma massa e sim a densidade, a massa sera calculada usando as dimensoes e densidade
    fd.friction = 0.45; //coeficiente de atrito
    fd.restitution = 0.1; //coeficiente de restituicao
    
    body.createFixture(fd); //agora passamos as qualidades "fixture" criada para o nosso corpo
    body.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();, ou seja utilizar para identificar no contato.
  }
  
    void display(){ //aqui sera a parte em que pegaremos os dados que a box2d nos da e desenharemos na tela
      float angulo = body.getAngle(); //angulo do corpo
      pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
      
      if(pos.y >= height*2 || delete){ //se a altura que x esta for maior do que o maximo de morte ou delete verdadeiro.
        box2d.destroyBody(body);//deletando corpo fisico do personagem
        for(Inimigo inimi: inimigos){
          box2d.destroyBody(inimi.body);
        }
        //delay(2000);
        primeiroLoop = true;
      }
    
      pushMatrix();
      translate(width/2,height/2); //imagem sera deslocada0);
      rotate(-angulo); //rodaremos no angulo dado pela box2d
      fill(127); //colorindo
      stroke(0);//borda
      strokeWeight(2);//espesura da borda
      rectMode(CENTER);
      rect(0,0,largura,altura);//criando retangulo
      popMatrix();
   
    }
    
    void walk(int ncontato){
       
       vel = body.getLinearVelocity();
       pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
       
      if(keys[A] == true && vel.x > -15){ //limito a velocidade maxima
        if(ncontato == 0)// no ar estarei limitando a velocidade de movimento
          body.applyForce(new Vec2 (-450,0), body.getWorldCenter());
        else
          body.applyForce(new Vec2 (-950,0), body.getWorldCenter()); //a força aplicada so servira para sair da inercia, quanto maior mais rapido ele ganhara aceleracao
      }
      if(keys[D] == true && vel.x < 15){
        if(ncontato == 0)// no ar estarei limitando a velocidade de movimento
          body.applyForce(new Vec2 (450,0), body.getWorldCenter());
        else
          body.applyForce(new Vec2 (900,0), body.getWorldCenter()); //a força aplicada so servira para sair da inercia, quanto maior mais rapido ele ganhara aceleracao
      }
      if(keys[S] == true){
        if(ncontato != 0) //so pode frear se estiver no chao
          body.setLinearVelocity(new Vec2(0,vel.y));
      }
      if(keys[W] == true && ncontato >= 1 && vel.y < 5){ //se estiver encostando em algo no chao
        body.applyLinearImpulse(new Vec2(vel.x,900), body.getWorldCenter());
      }
      
      if(keys[R] == true){
         delete=true;
      }
    }
    
  Vec2 attract(Inimigo m) {
    float G = 350; //intensidade da forca
    
    Vec2 pos = body.getWorldCenter();  //pegamos a posicao do centro de massa do personagem  
    Vec2 moverPos = m.body.getWorldCenter(); //pegamos a posicao do centro de massa do inimigo
    
    
    Vec2 force = pos.sub(moverPos); //essa pos.sub fara o calculo do vetor da direcao entre eles
    float distance = force.length(); //length calculará o modulo do vetor(distancia)
    
    distance = constrain(distance,1,5);//constrain fará um hash do tamanho total da distancia em 5
    force.normalize(); //calculara a normal
    
    float strength = (G * 1 * m.body.m_mass) / (distance * distance); // Criaremos uma intensidade da forca relacionada a massa do inimigo
    //println(pos.sub(moverPos));//para debug
    force.mulLocal(strength);//Get force vector --> magnitude * direction
    if(pos.sub(moverPos).x > 50 || pos.sub(moverPos).x < -50)//limite de visao mudarei para caso o monstre voe.
      return new Vec2(0,0);
    else
      return force;
  }
}
