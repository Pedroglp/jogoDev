import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import pbox2d.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.joints.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.collision.shapes.Shape; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.contacts.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Jogo extends PApplet {

//incluindo as Libs da box2d
//caso nao tenha feito o download, siga os passos:
//skecth -> import library -> Add Library -> Box2d

/*DECLARANDO LIBS USADAS*/








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
int fase = 1; //fase come\u00e7a em 1 por padrao

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

public void setup() {
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

public void draw() {
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
  //Queremos que os objetos sejam "passados" para tr\u00e1s, logo -distancia.x. O mesmo vale para Y. Lembrando que fixamos a camera em 100,200 no personagem.
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


  public void beginContact(Contact cp) {
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
  
public void endContact(Contact cp) {
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
//O evento keyRelesead \u00e9 semelhante ao keyPressed mas acontecera quando a tecla for solta.Nesse momento colocaremos
//em nossa matriz que Key = false(off). 
//Mas porque fazer todo esse processo e nao pegar diretamente "key"? Porque o processing matem na memoria
//a tecla pressionada, e caso tentemos usar um metodo para limpar diferente deste(como por exemplo:
//colocar key='umaTeclaNaoUsadaNoJogo" o tempo de resposta do personagem sera ruim.

public void keyPressed() {
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

public void keyReleased(){
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
    fd.friction = 0.9f; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
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
  public void display() {
    //b.setTransform(new Vec2(box2d.coordPixelsToWorld(x,y)),0); //isso \u00e9 necessario para posicionar o desenho em relacao ao personagem
    fill(0);
    stroke(0);
    rectMode(CENTER);
    rect(x,y,w,h);
  }
}
//Aqui guardaremos todas as informacoes para criacao de uma fase
//Nesse arquivo qualquer um pode colocar uma fase nova, e como?
//Siga o exemplo de case 1 e crie o seu proprio case n. Para ficar mais claro, cheque as classes Chao e Plataforma para entender melhor
//como elas funcionam, mas segue aqui o rapido exemplo:
//Boundary eh a funcao(classe?) construtora para paredes e chao
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura
//Plataform eh a funcao(classe?) construtora para plataformas moveis, tanto em x quanto em y
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura, Velocidade de movimento, vetor(xmin,ymin), vetor(xmax,ymax)

public void criarCenario(int fase){
    switch(fase){
    case 1:
      boundaries = new ArrayList<Boundary>(); //criamos um array que guardara todas as trilhas criadas
      boundaries.add(new Boundary(250+50,height-10, 500, 20)); //adicionamos a primeira parte do chao antes da plataforma
      boundaries.add(new Boundary(1200+75, height-10, 500, 20)); //segundo segmento pos plataforma
      boundaries.add(new Boundary(1600+100, height-10-60, 300, 20)); //segmento elevado
      boundaries.add(new Boundary(2075+50,height-10,500,20)); //pos segmento elevado
      boundaries.add(new Boundary(2695,height-195,500,20));
  
      plataforms = new ArrayList<Plataform>();
      plataforms.add(new Plataform(625, height-10, 150,20,new Vec2(4,0),new Vec2(625,150),new Vec2(950,150)));//primeira plataforma
      plataforms.add(new Plataform(2410, height-10, 70,20,new Vec2(0,4),new Vec2(566,550),new Vec2(566,height-10)));//segunda plataforma
   
      break;
  }
}
// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Showing how to use applyForce() with box2d

class Mover {

  // We need to keep track of a Body and a radius
  Body body;
  float r;

  Mover(float r_, float x, float y) {
    r = r_;
    // Define a body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    // Set its position
    bd.position = box2d.coordPixelsToWorld(x,y);
    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3f;
    fd.restitution = 0.5f;

    body.createFixture(fd);

    body.setLinearVelocity(new Vec2(random(-5,5),random(-5,-5)));
    body.setAngularVelocity(random(-1,1));
  }

  public void applyForce(Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }


  public void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    fill(127);
    stroke(0);
    strokeWeight(2);
    ellipse(0,0,r*2,r*2);
    // Let's add a line so we can see the rotation
    line(0,0,r,0);
    popMatrix();
  }
}





class Personagem {
  Body body;
  float altura, largura;
  Vec2 pos;
  Vec2 vel;
  boolean delete = false;

  Personagem(float x, float y){
    altura = 40;
    largura = 40;
    
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
    ps.setAsBox(box2dAltura, box2dLargura); //setamos como um caixa com as dimensoes dadas entre parenteses
    
    FixtureDef fd = new FixtureDef(); //Entao, definimos o tipo de corpo, o tipo geometrico agora faltam as especificacoes fisicas deste.
    //Nao encontrei uma traducao para fixture, mas creio que seriam como "propriedades" algo do tipo.
    fd.shape = ps; //Informamos que o formato do corpo sera o formato ps criado. Isso porque, a box2d ira utilizar este para calular informacoes
    //uteis como: Massa, centro de massa, momento angular e etc.
    fd.density = 1; // definindo a densidade, veja, nao damos uma massa e sim a densidade, a massa sera calculada usando as dimensoes e densidade
    fd.friction = 0.6f; //coeficiente de atrito
    fd.restitution = 0.1f; //coeficiente de restituicao
    
    body.createFixture(fd); //agora passamos as qualidades "fixture" criada para o nosso corpo
    body.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();
  }
  
    public void display(){ //aqui sera a parte em que pegaremos os dados que a box2d nos da e desenharemos na tela
      float angulo = body.getAngle(); //angulo do corpo
      pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
      
      if(pos.y >= height*2 || delete){ //se a altura que x esta for maior do que o maximo de morte ou delete verdadeiro.
        box2d.destroyBody(body);
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
      rect(0,0,altura,largura);//criando retangulo
      popMatrix();
   
    }
    
    public void walk(int ncontato){
       
       vel = body.getLinearVelocity();
       pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
       
      if(keys[A] == true/*(key == 'a' || key == 'A')*/ && vel.x > -15){ //limito a velocidade maxima
        body.applyForce(new Vec2 (-1500,0), body.getWorldCenter()); //a for\u00e7a aplicada so servira para sair da inercia, quanto maior mais rapido ele ganhara aceleracao
      }
      if(keys[D] == true /*(key == 'd' || key == 'D')*/ && vel.x < 15){
        body.applyForce(new Vec2(1500,0), body.getWorldCenter());
      }
      if(keys[S] == true/*(key == 's' || key == 'S')*/){
        if(ncontato != 0) //so pode frear se estiver no chao
          body.setLinearVelocity(new Vec2(0,vel.y));
      }
      if(keys[W] == true /*(key == 'w' || key == 'W')*/ && ncontato >= 1 && vel.y < 5){ //se estiver encostando em algo no chao
        body.applyLinearImpulse(new Vec2(vel.x,300), body.getWorldCenter());
      }
      
      if(keys[R] == true/*key == 'r' || key =='R'*/){
         delete=true;
      }
    }
    
  public Vec2 attract(Mover m) {
    float G = 100; // Strength of force
    // clone() makes us a copy
    Vec2 pos = body.getWorldCenter();    
    Vec2 moverPos = m.body.getWorldCenter();
    // Vector pointing from mover to attractor
    Vec2 force = pos.sub(moverPos);
    float distance = force.length();
    // Keep force within bounds
    distance = constrain(distance,1,5);
    force.normalize();
    // Note the attractor's mass is 0 because it's fixed so can't use that
    float strength = (G * 1 * m.body.m_mass) / (distance * distance); // Calculate gravitional force magnitude
    force.mulLocal(strength);         // Get force vector --> magnitude * direction
    return force;
  }
}
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
    fd.friction = 0.8f; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
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
  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(b);
    Vec2 velAtual = b.getLinearVelocity();
    
    if(pos.x >= max.x)
      b.setLinearVelocity(new Vec2(-v.x,velAtual.y));
    if(pos.x <= min.x)
      b.setLinearVelocity(new Vec2(v.x,velAtual.y));
    
    //para os limites de y preste atencao no sistema de coordenadas de pixels!
    if(pos.y >= max.y)
      b.setLinearVelocity(new Vec2(velAtual.x,v.y));
    if(pos.y <= min.y)
      b.setLinearVelocity(new Vec2(velAtual.x,-v.y));
      
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(pos.x,pos.y,w,h);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Jogo" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
