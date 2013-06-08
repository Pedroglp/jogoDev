//incluindo as Libs da box2d
//caso nao tenha feito o download, siga os passos:
//skecth -> import library -> Add Library -> Box2d

/*DECLARANDO LIBS USADAS*/
import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
/*FIM DA DECLARACAO DE LIBS*/

PBox2D box2d; //necessario para iniciar a library
Personagem personagem;
//Mover inimigo;
int ncontato = 0; //numero de contatos entre certa shape
Vec2 posAntPerso; //posicao antes do walk
Vec2 posAtuPerso; //posicao pos walk
Vec2 posInicial;
Vec2 distancia = new Vec2(0, 0);
//Vec2 velPerso; //velocidade personagem
boolean primeiroLoop = true;   //necessario para alguns eventos que so devem ocorrer uma vez
//int contadordeloops = 0; //para debug
int fase = 2; //fase começa em 1 por padrao

/*USADAS PARA LEITURA DE TECLAS*/
boolean[]keys = new boolean[5];
final int A = 0;
final int W = 1;
final int S = 2;
final int D = 3;
final int R = 4;
char tecla;


/*USADAS PARA CONSTRUCAO DO CENARIO*/
ArrayList<Boundary> boundaries; //uma array que guardara todos os segmentos de chao do cenario

ArrayList<Plataform> plataforms; //uma array que guardara todos as plataformas do cenario

ArrayList<Inimigo> inimigos; //uma array que guardara todos os inimigos

void setup() {
  size(displayWidth, displayHeight); //tamanho da tela do usuario
  if (frame != null) {
    frame.setResizable(true);
  }
  // iniciando a library e criando um mundo
  box2d = new PBox2D(this); //iniciando box2d
  box2d.createWorld(); //criando um "mundo fisico"
  box2d.listenForCollisions();//inicia o leitor de colisao
  box2d.setGravity(0, -10);//gravidade -10m/s
  frameRate(120);//aumentei a frame rate, nao entendi em que isso mudaria no jogo caso coloca-se < 120, mas de alguma forma acelerou os numeros de acoes que box2d faz em 1 seg.
}

//essa sera a funcao utilizada para desenhar os quadros e dar o step (passo) no universo fisico

void draw() {
  background(255); //colocamos um plano de fundo na cor branca
  box2d.step(); // a cada vez que draw fizer 1 loop, sera feito um loop nas acoes da box2d

  if (primeiroLoop == true) {
    criarCenario(fase); //criamos o cenario da fase que esta na variavel fase
    //cria personagem
    personagem = new Personagem(posInicial.x, posInicial.y);
    posAntPerso = posAtuPerso = new Vec2(posInicial.x, posInicial.y); //personagem inicia em 70,50, logo essa eh sua primeira posicao anterior.
    distancia = new Vec2(0, 0); //reset/setdistancia percorrida igual a zero.
    primeiroLoop = false; //depois disso nao ser mais o primeiro loop
  }
  else
    posAntPerso = personagem.pos; //pegando a posicao do personagem antes de se mover
  personagem.walk(ncontato); //chama a funcao de andar do personagem
  posAtuPerso = personagem.pos; //pegando apos ele se mover
  Vec2 delta = new Vec2((posAtuPerso.x - posAntPerso.x), (posAtuPerso.y - posAntPerso.y));
  //vamos somando a distancia pecorrida do momento a distancia total que devemos transladar a camera
  distancia.x+=delta.x;
  distancia.y+=delta.y;

  personagem.display(); //roda a animacao do personagem

  pushMatrix();
  translate((width/2)-posInicial.x-distancia.x, (height/2)-posInicial.y-distancia.y); //deslocaremos a "camera" em x em 70-distancia.x porque : queremos a camera centrada no personagem,logo -70.
  //Queremos que os objetos sejam "passados" para trás, logo -distancia.x. O mesmo vale para Y. Lembrando que fixamos a camera em 100,200 no personagem.
  for (Boundary wall: boundaries) {
    wall.display();
  }
  for (Plataform plat: plataforms) {
    plat.display();
  }  

  for (Inimigo inimi: inimigos) {
    Vec2 force = personagem.attract(inimi);
    inimi.applyForce(force);
    inimi.display();
  }
  popMatrix();
  /*DEBUG
   contadordeloops++;
   if(contadordeloops==200)
   noLoop();
   println("Posicao mouse x "+mouseX);
   println("Posicao mouse y "+mouseY);*/
}
