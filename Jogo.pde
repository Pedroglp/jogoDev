//incluindo as Libs da box2d
//caso nao tenha feita o download, siga os passos:
//skecth -> import library -> Add Library -> Box2d

import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

PBox2D box2d; //necessario para iniciar a library
Personagem personagem;
int ncontato = 0; //numero de contatos entre certa shape
Vec2 posAntPerso; //posicao antes do walk
Vec2 posAtuPerso; //posicao pos walk
Vec2 velPerso; //velocidade personagem
boolean primeiroLoop = true;
//int contadordeloops = 0;

ArrayList<Boundary> boundaries;

ArrayList<Plataform> plataforms;

void setup() {
  size(800, 200);
  // iniciando a library e criando um mundo
  box2d = new PBox2D(this);  
  box2d.createWorld();
  box2d.setGravity(0, -20);
  // inicia o leitor de colisao
  box2d.listenForCollisions();
  // criacao de personagem
  personagem = new Personagem(20,20);
  
  // criacao de cenario
  boundaries = new ArrayList<Boundary>();
  boundaries.add(new Boundary(75, height-5, 150, 10)); //primeira parte do chao antes do seguimento elevado
  boundaries.add(new Boundary(230,175, 100, 10)); //segmento elevado
  boundaries.add(new Boundary(375, height-5, 150, 10)); // segunda parte do chao pos seguimento elevado
  boundaries.add(new Boundary(675, height-5, 150, 10)); // terceira parte
  //boundaries.add(new Boundary(width/2, 5, width, 10));
  //boundaries.add(new Boundary(width-5, height/2, 10, height));
  boundaries.add(new Boundary(5, height/2, 10, height));
  
  plataforms = new ArrayList<Plataform>();
  plataforms.add(new Plataform(485, height-5, 70,10,new Vec2(2,0),485,566));
  
}

//essa sera a funcao utilizada para desenhar os quadros e dar o step (passo) no universo fisico

void draw() {
  background(255); //colocamos um plano de fundo na cor branca
  box2d.step(); // a cada vez que draw fizer 1 loop, sera feito um loop nas acoes da box2d
  
  if(primeiroLoop == true){
    posAntPerso = new Vec2(20,20);
    primeiroLoop = false;
  }
  else
    posAntPerso = personagem.pos; //pegando a posicao do personagem antes de se mover
  //println(posAntPerso);
  personagem.display();
  personagem.walk(ncontato);
  posAtuPerso = personagem.pos; //pegando pos ele se mover
  velPerso = personagem.vel;
  
  //println(posAtuPerso);
  
  for (Boundary wall: boundaries) {
    wall.x -= (posAtuPerso.x - posAntPerso.x);  //isso faz a camera se manter centrada no eixo x do personagem
    //wall.y -= (posAtuPerso.y - posAntPerso.y);  //isso faz a camera se manter centrada no eixo y do personagem
    wall.display();
  }
  for (Plataform plat: plataforms) {
    //plat.y -= (posAtuPerso.y - posAntPerso.y);  //isso faz a camera se manter centrada no eixo y do personagem
    plat.x -= (posAtuPerso.x - posAntPerso.x);  //isso faz a camera se manter centrada no eixo x do personagem
    //plat.move(velPerso);
    plat.display((posAtuPerso.x - posAntPerso.x));
  }
  
  /*DEBUG
  contadordeloops++;
  if(contadordeloops==2)
    noLoop();
  print('x');
  println(mouseX);
  print('y');
  println(mouseY);
  */
}


  void beginContact(Contact cp) {
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
                                          || ((o2.getClass() == Boundary.class || o2.getClass() == Plataform.class) && o1.getClass() == Personagem.class)){
    ncontato+=1; //se ele encostar numa parede ou a parede nele aumentamos o numero de objetos em contato com o personagem
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
                                          || ((o2.getClass() == Boundary.class || o2.getClass() == Plataform.class) && o1.getClass() == Personagem.class)){
    ncontato-=1; //se a contato entre o chao/plataforma eo personagem acabou, tiramos 1 numero de contatos
  }
}
