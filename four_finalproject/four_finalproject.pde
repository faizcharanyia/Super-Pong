//Imports
import java.io.*;
import java.util.Arrays;
import java.util.Collections;

//Game Logic
Ball ball;
Ball fakeBall;
Ball fakeBall2;
Paddle player;
CPU cpu;
CPU_Logic core;

//Game State
boolean requestingName = false;
boolean[] keys;
boolean gamePaused = false;
boolean gamePaused2 = false;
boolean gameOver = false;
boolean gameStarted = false;
boolean showStartMenu = true;
boolean showHelpMenu = false;
boolean gameMode = true;
boolean showScores = false;
boolean mute = false;
boolean stopPlay = false;
String gameState = "SuperPong Default";
String playerName = "";
String inputName = "";
String errorMessage = ""; 
float winScore = 3;
float playerScore = 0;

//Sound
import processing.sound.*;
SoundFile hit;
SoundFile wall;
SoundFile score;
SoundFile slash;
SoundFile music;
SoundFile explo;
SoundFile eplos;
SoundFile woosh1;
SoundFile woosh2;
SoundFile woosh3;
SoundFile burst;
SoundFile elec;
SoundFile mario;


//Buttons
Button ret;
Button vs;
Button end;
Button set;
Button rec;
Button pau;
Button mut;

//Display
float lowBound = 30;
float highBound = 60;
PFont arcadeFont;

//Output
PrintWriter output;

//Moves
String[] moveSet = new String[]{"W+Space","A+Space","S+Space","D+Space"};
String[] moveDes = new String[]{"Jump Smash","Dash Back","Slam Down","Force Wall"};
String[] bMoveSet = new String[]{"W  ","W+W","A  ","D  "};
String[] bMoveDes = new String[]{"Jump","Double-Jump","Left","Right"};


void setup(){
  size(960,540);
  hit = new SoundFile(this,"Hit.mp3");
  wall = new SoundFile(this,"Wall.mp3");
  score = new SoundFile(this,"Score.mp3");
  music = new SoundFile(this,"smash.mp3");
  slash = new SoundFile(this,"Slash.mp3");
  explo = new SoundFile(this,"Eplos.mp3");
  eplos = new SoundFile(this,"Explo.mp3");
  woosh1 = new SoundFile(this,"Woosh1.mp3");
  woosh2 = new SoundFile(this,"Woosh2.mp3");
  woosh3 = new SoundFile(this,"Woosh3.mp3");
  burst = new SoundFile(this,"burst.mp3");
  elec = new SoundFile(this,"Elec.mp3");
  mario = new SoundFile(this,"mario.mp3");
  player = new Paddle();
  cpu = new CPU();
  core = new CPU_Logic();
  ball = new Ball();
  keys = new boolean[5];
  vs = new Button("VS",float(width / 2), float(height/2),32);
  end = new Button("Endless",float(width / 2), float(height/2+100),32);
  set = new Button("Settings",float(width/2),float(height/2+200),32);
  ret = new Button("Return to Main Menu",width / 2,height / 2 + 150,24);
  pau = new Button("Back",width / 2,height / 2 + 150,24);
  rec = new Button("High Scores",5*width/6,9*height/10,12);
  mut = new Button("Mute",width/12,height/6.7,12);
  output = createWriter("scores.txt");
  arcadeFont = createFont("ArcadeClassic.ttf", 32);
  textFont(arcadeFont);
  fakeBall = new Ball();
  fakeBall2 = new Ball();
  fakeBall.vel[0] = -random(2,7);
  fakeBall.vel[1] = random(.1,2);
  fakeBall.walls =true;
  fakeBall2.walls =true;
}

void draw(){
  background(0);
  noStroke();
  rectMode(CORNERS);
  fill(150, 150, 150);
  float[] score = {0, 0};
  if(gameOver){
    if(music.isPlaying()){
      music.pause();
    }
  }
  if (gameStarted && !requestingName){
    rect(0, 0, width, highBound);
    score = ball.getScore();
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Player 1 Score: " + floor(score[0]), width / 4, (highBound / 2) + 20);
    text("Player 2 Score: " + floor(score[1]), 3 * width / 4, (highBound / 2) + 20);
  }

  if (showStartMenu) {
    set.y = float(height/2+200);
    vs.drawButton();
    end.drawButton();
    set.drawButton();
    rec.drawButton();
    fill(255);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("SuperPong", width / 2, highBound + 60);
    fakeBall.compute();
    fakeBall2.compute();
  }

  if(showHelpMenu){
    if(!gamePaused2){
      ret.drawButton();
    }else{
      pau.drawButton();
    }
    mut.drawButton();
    for(int i = 0; i<moveSet.length; i++){
      Label lab = new Label(moveSet[i],3*width/5,height/4*(1+float(i)/2),18,moveDes[i]);
      lab.drawButton();
      lab.drawDescrip();
    }
    for(int i = 0; i<bMoveSet.length; i++){
      Label lab = new Label(bMoveSet[i],width/5,height/4*(1+float(i)/2),18,bMoveDes[i]);
      lab.drawButton();
      lab.drawDescrip();
    }
  }

  if (showScores) {
    textSize(24);
    text("Endless High Scores", width / 2, highBound/2);
    textSize(12);
    String[] lines = loadStrings("scores.txt");
    for (int i = 0; i < Math.min(lines.length, 10); i++) {
      text((i+1) + ": " + lines[i], width/5, i*height/20 + height/5);
    }
    ret.drawButton();
  }

  if (gameStarted && !gamePaused && !gameOver && !gamePaused2 && !requestingName) {
    player.compute(keys);
    core.predict(ball.getParams(), cpu.getCPU());
    cpu.compute(core.getKey());
    ball.setVel(player.collision(ball.getParams()));
    ball.setVel(cpu.collision(ball.getParams()));
    ball.compute();
  }

  if (gameOver || gamePaused) {
    fill(255, 255, 0);
    text(gameState, width / 2, height / 2 - 100);
    if(gamePaused){
      set.y = height/2+50;
      set.drawButton();
    }
    if(gameOver){
      playSound(12);
    }
    if (!requestingName) {
      ret.drawButton();
    }
  }

  if(gameMode){
    if (gameStarted && (score[0] >= winScore || score[1] >= winScore)) {
      gameOver = true;
      gameState = score[0] >= winScore ? "Player 1 Wins\nPress Enter to Restart" : "Player 2 Wins\nPress Enter to Restart";
    }
  }else{
    if(gameStarted && (score[1]>0)){
      gameOver = true;
      gameState = "You scored " +floor(score[0]) + " Points!";
      endGameAndRequestName(score[0]);
    }
  }

  if (requestingName) {
    fill(255);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Enter Name: " + inputName, width / 2, height / 2);
    text("Press enter after entering your name", width / 2, height / 2 + 30);
    if (!errorMessage.isEmpty()) {
      fill(255, 0, 0);  // Red color for error messages
      text(errorMessage, width / 2, height / 2 + 90);
    }
  }
}


  void playSound(int sound){
    if(!mute){
      if(sound == 0){
        hit.play();
      }
      if(sound == 1){
        wall.play();
      }
      if(sound == 2){
        score.play();
      }
      if(sound == 3){
        music.play();
        music.jump(0);
      }
      if(sound == 4){
        slash.play();
      }
      if(sound == 5){
        explo.play();
      }
      if(sound == 6){
        eplos.play(1,.5);
      }
      if(sound == 7){
        woosh1.play();
      }
      if(sound == 8){
        woosh2.play();
      }
      if(sound == 9){
        woosh3.play();
      }
      if(sound == 10){
        burst.play();
      }
      if(sound == 11){
        elec.play();
      }
      if(sound ==12){
        if(!mario.isPlaying() && !stopPlay){
          mario.play();
          mario.jump(0);
          stopPlay = true;
        }
      }
    }
  }

void mousePressed() {
  
  if (showStartMenu) {
    if(vs.overButton(mouseX, mouseY)){
      gameMode = true;
      gameStarted = true;
      playSound(3);
      showStartMenu = false;
      textSize(5);
      gameState = "Game Paused.\nPress P to Resume \nor R or to Restart.";
      ball.newGame(); // Reset the game state
    }
    else if(end.overButton(mouseX,mouseY)){
      gameMode = false;
      gameStarted = true;
      playSound(3);
      showStartMenu = false;
      textSize(5);
      gameState = "Game Paused.\nPress P to Resume \nor R or to Restart.";
      ball.newGame(); // Reset the game state
    }
    else if(set.overButton(mouseX,mouseY)){
      showStartMenu = false;
      showHelpMenu = true;
    }
    else if(rec.overButton(mouseX,mouseY)){
      showStartMenu = false;
      showScores = true;
    }
  } else if ((gamePaused || gameOver) && ret.overButton(mouseX, mouseY) && !gamePaused2) {
    
    gameStarted = false;
    gameOver = false;
    gamePaused = false;
    showStartMenu = true;
    gameState = "SuperPong Default";
    mario.pause();
    
  } else if(gamePaused){
    if(set.overButton(mouseX,mouseY)){
      showStartMenu = false;
      showHelpMenu = true;
      gamePaused = false;
      gamePaused2 = true;
    }
  } else if (showHelpMenu){
    if(!gamePaused2){
      if(ret.overButton(mouseX,mouseY)){
        showHelpMenu = false;
        showStartMenu = true;
      }
    if(mut.overButton(mouseX,mouseY)){
      if(mute){
        mute = false;
      }else{
        mute = true;
      }
    }
    }else if(gamePaused2){
      if(pau.overButton(mouseX,mouseY)){
        gamePaused2 = false;
        showHelpMenu = false;
        gamePaused = true;
      }
      if(mut.overButton(mouseX,mouseY)){
        if(mute){
          mute = false;
        }else{
          mute = true;
        }
        if(mute){
          music.pause();
        }else{
          music.play();
        }
      }
    }
  } else if(showScores){
    if(ret.overButton(mouseX,mouseY)){
      showScores = false;
      showStartMenu = true;
    }
  } 
}









void keyPressed() {
    if (requestingName) {
        if (key == ENTER || key == RETURN) {
            if (inputName.trim().length() > 0) {  // Check if inputName is not just empty spaces
                playerName = inputName.trim();
                saveEndlessScores(playerScore);
                requestingName = false;  
                showStartMenu = true;  
                gameState = "SuperPong default";  
                gameOver = false;  
                errorMessage = ""; 
            } else {
                errorMessage = "Please enter at least one letter or number.\nPress enter to continue.";
            }
            inputName = "";  // Clear the input field for retry
        } else if ((key >= 'a' && key <= 'z') || (key >= 'A' && key <= 'Z') || (key >= '0' && key <= '9') || key == ' ') {
            inputName += key;  
            errorMessage = "";  
        } else if (key == BACKSPACE && inputName.length() > 0) {
            inputName = inputName.substring(0, inputName.length() - 1);  // Remove last character
        }
        return;  
    }

    if (!requestingName) {
        if (!gameStarted || gameOver) {
            if (key == ENTER || key == RETURN) {
                gameStarted = true;
                showStartMenu = false;
                gameOver = false;
                gameState = "Game Paused.\nPress P to Resume \nor R to Restart.";
                ball.newGame();  
            }
        } else if (key == 'P' || key == 'p') {
            if (gameStarted && !gameOver) {
                gamePaused = !gamePaused;
            }
        } else if (key == 'R' || key == 'r') {
            if (gamePaused || gameOver) {
                gamePaused = false;
                gameOver = false;
                gameStarted = true;
                ball.newGame();
            }
        } else {
            handlePlayerKeyPress();
        }
    }
}


void keyReleased() {
  if (!gamePaused && gameStarted && !gameOver) {
    handlePlayerKeyRelease();
  }
}

void handlePlayerKeyPress() {
  switch (keyCode) {
    case 65: keys[1] = true; break; // A
    case 68: keys[3] = true; break; // D
    case 83: keys[2] = true; break; // S
    case 87: keys[0] = true; break; // W
    case 32: keys[4] = true; break; // Space
  }
}

void handlePlayerKeyRelease() {
  switch (keyCode) {
    case 65: keys[1] = false; break; // A
    case 68: keys[3] = false; break; // D
    case 83: keys[2] = false; break; // S
    case 87: keys[0] = false; break; // W
    case 32: keys[4] = false; break; // Space
  }
}

void saveEndlessScores(float score) {
  File scoreFile = new File(dataPath("scores.txt"));
  ArrayList<String> scoreEntries = new ArrayList<String>();

  if (scoreFile.exists()) {
    String[] lines = loadStrings("scores.txt");
    scoreEntries.addAll(Arrays.asList(lines));
  }
  
  scoreEntries.add(playerName + " : " + score);
  
  Collections.sort(scoreEntries, (a, b) -> {
    float scoreA = Float.parseFloat(a.split(" : ")[1]);
    float scoreB = Float.parseFloat(b.split(" : ")[1]);
    return Float.compare(scoreB, scoreA);
  });

  // Write only top 10 scores
  try {
    PrintWriter writer = new PrintWriter(scoreFile);
    for (int i = 0; i < Math.min(10, scoreEntries.size()); i++) {
      writer.println(scoreEntries.get(i));
    }
    writer.close();
  } catch (FileNotFoundException e) {
    e.printStackTrace();
  }
}


void endGameAndRequestName(float score) {
    inputName = ""; 
    requestingName = true;
    playerScore = score; 
    gameOver = true;
    gamePaused = false;
    gameStarted = false;  
    errorMessage = ""; 
}
