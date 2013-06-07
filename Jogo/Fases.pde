//Aqui guardaremos todas as informacoes para criacao de uma fase
//Nesse arquivo qualquer um pode colocar uma fase nova, e como?
//Siga o exemplo de case 1 e crie o seu proprio case n. Para ficar mais claro, cheque as classes Chao e Plataforma para entender melhor
//como elas funcionam, mas segue aqui o rapido exemplo:
//Boundary eh a funcao(classe?) construtora para paredes e chao
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura
//Plataform eh a funcao(classe?) construtora para plataformas moveis, tanto em x quanto em y
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura, Velocidade de movimento, vetor(xmin,ymin), vetor(xmax,ymax)

void criarCenario(int fase){
    switch(fase){
    case 1:
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
      inimigos.add(new Inimigo(20,520,650,1));
      break;
    }
}
