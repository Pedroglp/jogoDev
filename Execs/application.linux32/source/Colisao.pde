//CONTROLE DE CHOQUES

void beginContact(Contact cp){
  // Pega as duas fixtures do que se chocou. Observe, o contato acontece entre fixtures e nao entre bodies
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Pegando os corpos para sabermos o que esta se chocando
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Pega o "tipo" do objeto do que se chocou
  Object o1 = b1.getUserData(); //o tipo (classe) Objeto de o21 sera o user Data do Body no qual houve contato
  Object o2 = b2.getUserData(); //o tipo (classe) Objeto de o2 sera o user Data do Body no qual houve contato

  //ANALISE DE COLISAO ENVOLVENDO PERSONAGEM 
  if (((o1.getClass() == Boundary.class || o1.getClass() == Plataform.class) && o2.getClass() == Personagem.class) 
    || ((o2.getClass() == Boundary.class || o2.getClass() == Plataform.class) && o1.getClass() == Personagem.class)) {
    ncontato+=1; //se ele encostar numa parede ou a parede nele aumentamos o numero de objetos em contato com o personagem
  }
  
 //FIM DA ANALISE DE COLISAO DO PERSONAGEM 
  
  if (o1.getClass() == Boundary.class && o2.getClass() == Inimigo.class) { //obtendo contato entre inimigos e chao
    Inimigo inimigo = (Inimigo) o2; //atribuindo as classes devidamente
    Boundary chao = (Boundary) o1;
    inimigo.limiteMax = chao.x+(chao.w/2) - inimigo.r;//atribuindo limite do movimento para que o inimigo nao caia da plataforma
    inimigo.limiteMin = chao.x-(chao.w/2) + inimigo.r;
  }
  if (o1.getClass() == Inimigo.class && o2.getClass() == Boundary.class) {
    Inimigo inimigo = (Inimigo) o1;
    Boundary chao = (Boundary) o2;
    inimigo.limiteMax = chao.x+(chao.w/2) - inimigo.r;
    inimigo.limiteMin = chao.x-(chao.w/2) + inimigo.r;
  }
}

void endContact(Contact cp) {
  // Pega as duas fixtures do que se chocou. Observe, o contato acontece entre fixtures e nao entre bodies
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Pegando os corpos para sabermos o que esta se chocando
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Pega o "tipo" do objeto do que se chocou
  Object o1 = b1.getUserData(); //o tipo (classe) Objeto de o21 sera o user Data do Body no qual houve contato
  Object o2 = b2.getUserData(); //o tipo (classe) Objeto de o2 sera o user Data do Body no qual houve contato

  if (((o1.getClass() == Boundary.class || o1.getClass() == Plataform.class) && o2.getClass() == Personagem.class) 
    || ((o2.getClass() == Boundary.class || o2.getClass() == Plataform.class) && o1.getClass() == Personagem.class)) {
    ncontato-=1; //se a contato entre o chao/plataforma eo personagem acabou, tiramos 1 numero de contatos
  }
}

//FIM DO CONTROLE DE CHOQUES
