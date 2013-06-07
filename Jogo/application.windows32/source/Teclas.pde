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

void keyReleased() {
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

