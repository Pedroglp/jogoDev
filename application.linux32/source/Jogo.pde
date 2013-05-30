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
int ncontato = 0; //numero de contatos entre certa shape
Vec2 posAntPerso; //posicao antes do walk
Vec2 posAtuPerso; //posicao pos walk
Vec2 distancia = new Vec2(0,0);
//Vec2 velPerso; //velocidade personagem
boolean primeiroLoop = true;   //necessario para alguns eventos que so devem ocorrer uma vez
//int contadordeloops = 0; //para debug
int fase = 1; //fase começa em 1 por padrao

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



Mover[] movers = new Mover[25];

void setup() {
  size(displayWidth, displayHeight); //tamanho da tela do usuario
  if (frame != null) {
    frame.setResizable(true);
  }
  // iniciando a library e criando um mundo
  box2d = new PBox2D(this); //iniciando box2d
  box2d.createWorld(); //criando um "mundo fisico"
  box2d.setGravity(0, -20);//gravidade -10m/s
  box2d.listenForCollisions();//inicia o leitor de colisao
  frameRate(80);
}

//essa sera a funcao utilizada para desenhar os quadros e dar o step (passo) no universo fisico

void draw() {
  background(255); //colocamos um plano de fundo na cor branca
  box2d.step(); // a cada vez que draw fizer 1 loop, sera feito um loop nas acoes da box2d
  
  if(primeiroLoop == true){
    //cria personagem
    personagem = new Personagem(70,200);
    posAntPerso = posAtuPerso = new Vec2(70,200); //personagem inicia em 70,50, logo essa eh sua primeira posicao anterior.
    distancia = new Vec2(0,0); //reset/setdistancia percorrida igual a zero.
    criarCenario(fase); //criamos o cenario da fase que esta na variavel fase
    primeiroLoop = false; //depois disso nao ser mais o primeiro loop
  }
  else
    posAntPerso = personagem.pos; //pegando a posicao do personagem antes de se mover
  personagem.walk(ncontato); //chama a funcao de andar do personagem
  posAtuPerso = personagem.pos; //pegando apos ele se mover
  Vec2 delta = new Vec2((posAtuPerso.x - posAntPerso.x),(posAtuPerso.y - posAntPerso.y));
  //vamos somando a distancia pecorrida do momento a distancia total que devemos transladar a camera
  distancia.x+=delta.x;
  distancia.y+=delta.y;
  
  personagem.display(); //roda a animacao do personagem
  
  pushMatrix();
  translate((width/2)-70-distancia.x,(height/2)-200-distancia.y); //deslocaremos a "camera" em x em 70-distancia.x porque : queremos a camera centrada no personagem,logo -70.
  //Queremos que os objetos sejam "passados" para trás, logo -distancia.x. O mesmo vale para Y. Lembrando que fixamos a camera em 100,200 no personagem.
  for (Boundary wall: boundaries) {
    wall.display();
  }
  for (Plataform plat: plataforms) {
    plat.display();
  }  
  
  popMatrix();
  /*DEBUG
  contadordeloops++;
  if(contadordeloops==200)
    noLoop();
  println("Posicao mouse x "+mouseX);
  println("Posicao mouse y "+mouseY);*/
  
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

/*CONTROLE DE TECLAS*/
//Aqui eh importante entender o que foi feito para todo e qualquer jogo que utilize o teclado como captacao de dados
//KeyPressed eh uma funcao/evento do processing que ocorre todo momento que voce aperta uma tecla
//Dentro dela faremos um switch, em que analisaremos qual tecla foi pressionada, caso ela tenha sido pressionada,
//mudaremos na nossa matriz falando que a tecla apertada esta "ON"(true)
//O evento keyRelesead é semelhante ao keyPressed mas acontecera quando a tecla for solta.Nesse momento colocaremos
//em nossa matriz que Key = false(off). 
//Mas porque fazer todo esse processo e nao pegar diretamente "key"? Porque o processing matem na memoria
//a tecla pressionada, e caso tentemos usar um metodo para limpar diferente deste(como por exemplo:
//colocar key='umaTeclaNaoUsadaNoJogo" o tempo de resposta do personagem sera ruim.

void keyPressed() {
    tecla = key;
    
    switch(tecla) {
      case 'A':
      case 'a':
          keys[A] = true;
          //println("a pressionado");
          break;
      case 'W':
      case 'w':
          keys[W] = true;
          //println("w pressionado");
          break;
      case 'S':
      case 's':
          keys[S] = true;
          //println("s pressionado");
          break;
      case 'D':
      case 'd':
          keys[D] = true;
          //println("d pressionado");
          break;
      case 'R':
      case 'r': 
          keys[R] = true;
          //println("r pressionado");
          break;         
    }
}

void keyReleased(){
    tecla = key;
    switch(tecla){
      case 'A':
      case 'a':
          keys[A] = false;
          //println("a solto");
          break;
      case 'W':
      case 'w':
          keys[W] = false;
          //println("w solto");
          break;
      case 'S':
      case 's':
          keys[S] = false;
          //println("s solto");
          break;
      case 'D':
      case 'd': 
          keys[D] = false;
          //println("d solto");
          break;
      case 'R':
      case 'r': 
          keys[R] = false;
          //println("r solto");
          break;   
    }
}    
