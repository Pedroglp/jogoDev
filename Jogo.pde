//incluindo as Libs da box2d
//caso nao tenha feito o download, siga os passos:
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
//Vec2 velPerso; //velocidade personagem
boolean primeiroLoop = true;   //necessario para alguns eventos que so devem ocorrer uma vez
boolean naPlataforma = false; //necessario para tratar o movimento do personagem em cima da plataforma
//int contadordeloops = 0; //para debug
int fase = 1; //fase começa em 1 por padrao

ArrayList<Boundary> boundaries; //uma array que guardara todos os segmentos de chao do cenario

ArrayList<Plataform> plataforms; //uma array que guardara todos as plataformas do cenario

void setup() {
  size(1000, 400);
  // iniciando a library e criando um mundo
  box2d = new PBox2D(this); //iniciando box2d
  box2d.createWorld(); //criando um "mundo fisico"
  box2d.setGravity(0, -20); //gravidade -20m/s, antes era 10 mas falaram que estava muito lunar
  // inicia o leitor de colisao
  box2d.listenForCollisions();
  // criacao de personagem
  personagem = new Personagem(20,20);
  
}

//essa sera a funcao utilizada para desenhar os quadros e dar o step (passo) no universo fisico

void draw() {
  background(255); //colocamos um plano de fundo na cor branca
  box2d.step(); // a cada vez que draw fizer 1 loop, sera feito um loop nas acoes da box2d
  
  if(primeiroLoop == true){
    posAntPerso = new Vec2(20,20); //personagem inicia em 20,20, logo essa eh sua primeira posicao anterior
    criarCenario(fase); //criamos o cenario da fase que esta na variavel fase
    primeiroLoop = false; //depois disso nao ser mais o primeiro loop
  }
  else
    posAntPerso = personagem.pos; //pegando a posicao do personagem antes de se mover
    personagem.display(); //roda a animacao do personagem
    personagem.walk(ncontato); //chama a funcao de andar do personagem
    posAtuPerso = personagem.pos; //pegando pos ele se mover
  
  //println(posAtuPerso);
  
  for (Boundary wall: boundaries) {
    wall.x -= (posAtuPerso.x - posAntPerso.x);  //isso faz a camera se manter centrada no eixo x do personagem
    wall.y -= (posAtuPerso.y - posAntPerso.y);  //isso faz a camera se manter centrada no eixo y do personagem
    wall.display();
  }
  for (Plataform plat: plataforms) {
      plat.display(posAntPerso,posAtuPerso,naPlataforma);
  }
  
  /*DEBUG
  contadordeloops++;
  if(contadordeloops==2)
    noLoop();
  print('x');
  println(mouseX);
  print('y');
  println(mouseY);*/
  
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
    if(o1.getClass() == Plataform.class || o2.getClass() == Plataform.class){
      naPlataforma = true; //entro na plataforma
    }
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
     if(o1.getClass() == Plataform.class || o2.getClass() == Plataform.class){
      naPlataforma = false; //saiu da plataforma
    }
  }
}
