//Aqui guardaremos todas as informacoes para criacao de uma fase
//Nesse arquivo qualquer um pode colocar uma fase nova, e como?
//Siga o exemplo de case 1 e crie o seu proprio case n. Para ficar mais claro, cheque as classes Chao e Plataforma para entender melhor
//como elas funcionam, mas segue aqui o rapido exemplo:
//Boundary eh a funcao(classe?) construtora para paredes e chao
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura
//Plataform eh a funcao(classe?) construtora para plataformas moveis, tanto em x quanto em y
//Respectivamente seus argumentos sao: posicao na tela x, posicao na tela y, comprimento, espessura, Velocidade de movimento, vetor(xmin,ymin), vetor(xmax,ymax)
//>>>OBS PLATAFORMAS COM MOVIMENTO EM Y IMPLEMENTADA E NAO TESTADA<<<<

void criarCenario(int fase){
    switch(fase){
    case 1:
      boundaries = new ArrayList<Boundary>(); //criamos um array que guardara todas as trilhas criadas
      boundaries.add(new Boundary(75, height-5, 150, 10)); //adicionamos a primeira parte do chao antes do seguimento elevado
      boundaries.add(new Boundary(230,350, 100, 10)); //segmento elevado
      boundaries.add(new Boundary(375, height-5, 150, 10)); // segunda parte do chao pos seguimento elevado
      boundaries.add(new Boundary(675, height-5, 150, 10)); // terceira parte
      boundaries.add(new Boundary(5, height/2, 10, height)); //parede atras do personagem
  
      plataforms = new ArrayList<Plataform>();
      plataforms.add(new Plataform(485, height-5, 70,10,new Vec2(2,0),new Vec2(485,150),new Vec2(566,150)));
      plataforms.add(new Plataform(786, height-5, 70,10,new Vec2(0,2),new Vec2(566,150),new Vec2(566,height-5)));
      break;
  }
}
