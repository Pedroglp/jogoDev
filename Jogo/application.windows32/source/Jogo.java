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
//Mover inimigo;
int ncontato = 0; //numero de contatos entre certa shape
Vec2 posAntPerso; //posicao antes do walk
Vec2 posAtuPerso; //posicao pos walk
Vec2 posInicial;
Vec2 distancia = new Vec2(0, 0);
//Vec2 velPerso; //velocidade personagem
boolean primeiroLoop = true;   //necessario para alguns eventos que so devem ocorrer uma vez
//int contadordeloops = 0; //para debug
int fase = 2; //fase come\u00e7a em 1 por padrao
PImage imgBackground;

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

public void setup() {
  size(displayWidth, displayHeight); //tamanho da tela do usuario
  if (frame != null) {
    frame.setResizable(true);
  }
  // iniciando a library e criando um mundo
  box2d = new PBox2D(this); //iniciando box2d
  box2d.createWorld(); //criando um "mundo fisico"
  box2d.listenForCollisions();//inicia o leitor de colisao
  box2d.setGravity(0, -10);//gravidade -10m/s
  frameRate(60);//aumentei a frame rate, nao entendi em que isso mudaria no jogo caso coloca-se < 120, mas de alguma forma acelerou os numeros de acoes que box2d faz em 1 seg.
}

//essa sera a funcao utilizada para desenhar os quadros e dar o step (passo) no universo fisico

public void draw() {
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
  
  //Checando Condicao de existencia do personagem
  if(personagem.pos.y >= height*2 || personagem.delete){ //se a altura que x esta for maior do que o maximo de morte ou delete verdadeiro.
    box2d.destroyBody(personagem.body);//deletando corpo fisico do personagem
    for(Inimigo inimi: inimigos){
    box2d.destroyBody(inimi.body);
    }
    primeiroLoop = true;
  }

  pushMatrix();
  translate((width/2)-posInicial.x-distancia.x, (height/2)-posInicial.y-distancia.y); //deslocaremos a "camera" em x em 70-distancia.x porque : queremos a camera centrada no personagem,logo -70.
  //Queremos que os objetos sejam "passados" para tr\u00e1s, logo -distancia.x. O mesmo vale para Y. Lembrando que fixamos a camera em 100,200 no personagem.
  image(imgBackground, 0, 0);
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
  personagem.display(); //roda a animacao do personagem
  /*DEBUG
   contadordeloops++;
   if(contadordeloops==200)
   noLoop();
   println("Posicao mouse x "+mouseX);
   println("Posicao mouse y "+mouseY);*/
}
class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  //Uma fronteira eh um simples retangulo com x,y,lagura e altura
  float x;
  float y;
  float w;
  float h;
  float angle;
  
  // Criando um variavel do tipo Body para guardar as informacoes
  Body b;

  Boundary(float x_,float y_, float w_, float h_,float angle_) {
    x = x_; //posicao na tela x
    y = y_; //posicao na tela y
    w = w_; //largura
    h = h_; //altura
    angle = angle_; //angulo de inclinacao

    // novo poligono
    PolygonShape sd = new PolygonShape();
    // Convertando para coordenadas da box 2d, lembrando que dividimos por 2 pois a box2 mede do centro geometrico as pontas
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // agora setando a shape como uma caixa
    sd.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.friction = 0.30f; //se nao colocarmos friction o corpo nao ira se aderir a plataforma
    fd.density = 1; //densidade
    fd.shape=sd; //definido a shape para fixture



    // Definindo o tipo de corpo
    BodyDef bd = new BodyDef();
    // Estatico, nao se movimenta
    bd.type = BodyType.STATIC;
    //Criando na posicaox x,y definida
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    b.setTransform(box2d.coordPixelsToWorld(x,y),angle);
    
    // atribuindo ao corpo as qualidades de fixtureR
    b.createFixture(fd);
    
    b.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();
  }

  // Desenhando
  public void display() {
    pushMatrix();
    translate(x,y);
    fill(0);
    stroke(0);
    rectMode(CENTER);
    rotate(-angle);
    rect(0,0,w,h);
    popMatrix();
  }
}
//CONTROLE DE CHOQUES

public void beginContact(Contact cp){
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
    || ((o2.getClass() == Boundary.class || o2.getClass() == Plataform.class) && o1.getClass() == Personagem.class)) {
    ncontato-=1; //se a contato entre o chao/plataforma eo personagem acabou, tiramos 1 numero de contatos
  }
}

//FIM DO CONTROLE DE CHOQUES
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
      posInicial = new Vec2 (70,550);//setamos posicao inicial
      boundaries = new ArrayList<Boundary>(); //criamos um array que guardara todas as trilhas criadas
      boundaries.add(new Boundary(250+50,height+100, 500, 400,0)); //adicionamos a primeira parte do chao antes da plataforma
      boundaries.add(new Boundary(1200+75, height+100, 500, 400,0)); //segundo segmento pos plataforma
      boundaries.add(new Boundary(1600+75, height+90, 300, 500,0)); //segmento elevado
      boundaries.add(new Boundary(2075,height+100,500,400,0)); //pos segmento elevado
      boundaries.add(new Boundary(2645,height-100,500,400,0)); //pos plataforma em y
  
      plataforms = new ArrayList<Plataform>();
      plataforms.add(new Plataform(625, height-90, 150,20,new Vec2(6,0),new Vec2(625,150),new Vec2(950,150)));//primeira plataforma
      plataforms.add(new Plataform(2360, height-10, 70,20,new Vec2(0,4),new Vec2(566,480),new Vec2(566,height-90)));//segunda plataforma
      
      inimigos = new ArrayList<Inimigo>();
      inimigos.add(new Inimigo(20,520,height-120,1));
      break;
    case 2: //aqui usarei tudo em relacao ao tamanho da tela para tornar o codigo mais portatil.
      imgBackground = loadImage("Cenario1.jpg");
      posInicial = new Vec2 (0.1f*width,0.6595f*height); //nao estranhe o valor, fui ajustando visualmente.
      
      boundaries = new ArrayList<Boundary>();
      boundaries.add(new Boundary(0.1f*width,0.8f*height,0.6f*width,0.2f*height,0));
      boundaries.add(new Boundary(1.075f*width, 0.8f*height, 0.6f*width, 0.2f*height,0));
      boundaries.add(new Boundary(1.375f*width, 0.8f*height, 0.6f*width, 0.2f*height, 60));
      boundaries.add(new Boundary(1.74518f*width, 0.6415f*height, 0.2f*width, 0.2f*height,0));
      boundaries.add(new Boundary(2.115f*width, 0.8f*height, 0.6f*width, 0.2f*height, -60));
      
      plataforms = new ArrayList<Plataform>();
      plataforms.add(new Plataform(0.475f*width,0.725f*height,0.15f*width, 0.05f*height, new Vec2(5,0), new Vec2(0.475f*width,0.725f*height), new Vec2(0.7f*width,0.725f*height)));
      
      inimigos = new ArrayList<Inimigo>();
      inimigos.add(new Inimigo(20,1120,0.7f*height,1));
      break;
    }
}
// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Showing how to use applyForce() with box2d

class Inimigo {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  float x;
  float y;
  int type;
  float limiteMin = 300000;
  float limiteMax = 300000;
  Vec2 pos;

  Inimigo(float r_, float x, float y, int type_){
    r = r_;
    type = type_;
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
    
    body.setUserData(this);
  }

  public void applyForce(Vec2 v) {
    pos = box2d.getBodyPixelCoord(body);
    if(pos.x < limiteMin)
      body.setLinearVelocity(new Vec2(1,0));
    if(pos.x > limiteMax)
      body.setLinearVelocity(new Vec2(-1,0));
    if(type == 1)//tipo terrestre n\u00e3o segue no ar
      body.applyForce(new Vec2(v.x,0), body.getWorldCenter());
    else
    body.applyForce(v, body.getWorldCenter());
  }

  public void display() {
    // We look at each body and get its screen position
    pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    fill(255,0,0);
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
    altura = 75;
    largura = 50;
    
    BodyDef bd = new BodyDef(); //criando as caracteristicas de um corpo do nosso personagem
    bd.type = BodyType.DYNAMIC; //Sera um corpo dinamico (com movimento)
    //bd.fixedRotation = true;//sem rota\u00e7\u00e3o
    bd.linearDamping = 0.03f;//arrasto no ar.
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
    fd.density = 2.0f; // definindo a densidade, veja, nao damos uma massa e sim a densidade, a massa sera calculada usando as dimensoes e densidade
    fd.friction = 0.45f; //coeficiente de atrito
    fd.restitution = 0.1f; //coeficiente de restituicao
    
    body.createFixture(fd); //agora passamos as qualidades "fixture" criada para o nosso corpo
    body.setUserData(this); //atribuimos isso para a linha Object o1 = b1.getUserData();, ou seja utilizar para identificar no contato.
  }
  
    public void display(){ //aqui sera a parte em que pegaremos os dados que a box2d nos da e desenharemos na tela
      float angulo = body.getAngle(); //angulo do corpo
      pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
      
    
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
    
    public void walk(int ncontato){
       
       vel = body.getLinearVelocity();
       pos = box2d.getBodyPixelCoord(body);  //o vetor posicao (Vec2 = vetor de duas dimensoes) sera dado pela conversao da posicao do corpo body para o sistema pixel
       
      if(keys[A] == true && vel.x > -15){ //limito a velocidade maxima
        if(ncontato == 0)// no ar estarei limitando a velocidade de movimento
          body.applyForce(new Vec2 (-450,0), body.getWorldCenter());
        else
          body.applyForce(new Vec2 (-950,0), body.getWorldCenter()); //a for\u00e7a aplicada so servira para sair da inercia, quanto maior mais rapido ele ganhara aceleracao
      }
      if(keys[D] == true && vel.x < 15){
        if(ncontato == 0)// no ar estarei limitando a velocidade de movimento
          body.applyForce(new Vec2 (450,0), body.getWorldCenter());
        else
          body.applyForce(new Vec2 (900,0), body.getWorldCenter()); //a for\u00e7a aplicada so servira para sair da inercia, quanto maior mais rapido ele ganhara aceleracao
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
    
  public Vec2 attract(Inimigo m) {
    float G = 350; //intensidade da forca
    
    Vec2 pos = body.getWorldCenter();  //pegamos a posicao do centro de massa do personagem  
    Vec2 moverPos = m.body.getWorldCenter(); //pegamos a posicao do centro de massa do inimigo
    
    
    Vec2 force = pos.sub(moverPos); //essa pos.sub fara o calculo do vetor da direcao entre eles
    float distance = force.length(); //length calcular\u00e1 o modulo do vetor(distancia)
    
    distance = constrain(distance,1,5);//constrain far\u00e1 um hash do tamanho total da distancia em 5
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
    break;
  case 'W':
  case 'w':
    keys[W] = true;
    break;
  case 'S':
  case 's':
    keys[S] = true;
    break;
  case 'D':
  case 'd':
    keys[D] = true;
    break;
  case 'R':
  case 'r': 
    keys[R] = true;
    break;
  }
}

public void keyReleased() {
  tecla = key;
  switch(tecla) {
  case 'A':
  case 'a':
    keys[A] = false;
    break;
  case 'W':
  case 'w':
    keys[W] = false;
    break;
  case 'S':
  case 's':
    keys[S] = false;
    break;
  case 'D':
  case 'd': 
    keys[D] = false;
    break;
  case 'R':
  case 'r': 
    keys[R] = false;
    break;
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
