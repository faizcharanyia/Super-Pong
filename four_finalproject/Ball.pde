class Ball{
  float[] pos;
  float[] vel;
  float[] ace;
  float speed;
  int size;
  float initEnergy;
  boolean walls = false;
  float[] points;
  int waitTime = 0;
  
  Ball(){
    pos = new float[]{width/2,height/2};
    vel = new float[]{5,1};
    ace = new float[]{0,.1};
    initEnergy = sqrt(pow(vel[1],2)+2*ace[1]*(pos[1]-lowBound)*4661/200);
    size = 10;
    newGame();
  }
  
  void compute(){
    checkBall();
    calculate();
    conserveEnergy();
    drawBall();
  }
  
  
  void newGame(){
    
    keys = new boolean[]{false,false,false,false,false};
    pos = new float[]{width/2,height/2};
    vel = new float[]{5,1};
    ace = new float[]{0,.1};
    points = new float[]{0,0};
  }
  
  void resetBall(int side){
    if(waitTime == 15){
       playSound(2);
    }
    if(waitTime<40){
      if(waitTime%8<4){
        ellipse(width/2,height/2,size,size);
      }
    }else{
      pos = new float[]{width/2,height/2};
      vel = new float[]{5,1};
      ace = new float[]{0,.1};
      if(side == 1){
       
        points[0]+=1;
        waitTime = 0;
      }else if(side == 2){
        points[1]+=1;
        waitTime = 0;
      }
    }
  }
  
  void conserveEnergy(){
    if(abs(vel[0])>5){
      vel[0] = (abs(vel[0])-.1)*vel[0]/abs(vel[0]);
    }else if(abs(vel[0])<5){
      vel[0] = (abs(vel[0])+.1)*vel[0]/abs(vel[0]);
    }else if(vel[0] == 0){
      vel[0]+=.1;
    }
    if(pos[1]+size/2+lowBound>height-20){
      if(vel[1]>0 && vel[1]<6.5){
        vel[1] = vel[1]+.1;
      }else if(vel[1]<0 && vel[1]>-6.5){
        vel[1] = vel[1]-.1;
      }else if(vel[1]>7 && vel[1]<12){
        vel[1] = vel[1]-.5;
      }else if(vel[1]<-7 && vel[1]>-12){
        vel[1] = vel[1]+.5;
      }else if(vel[1]>12){
        vel[1] = 12;
      }else if(vel[1]<-12){
        vel[1] = -12;
      }
    }
    
  }
  
  void setVel(float[] inp){
    vel[0] = inp[0];
    vel[1] = inp[1];
  }
  
  void checkBall(){
    if(pos[1]+size/2+lowBound>height){
      playSound(1);
      vel[1] = -abs(vel[1]+.1);
    }else if(pos[1]-size/2-highBound<0){
      playSound(1);
      vel[1] = abs(vel[1]);
    }else if(pos[0]-size/2<0){
      if(walls){
        vel[0] = abs(vel[0]);
      }else{
        waitTime += 1;
        resetBall(2);

      }
    }else if(pos[0]+size/2>width){
      if(walls){
        vel[0] = -abs(vel[0]);
      }else{
        waitTime += 1;
        resetBall(1);

      }
    }
  }
  
  void calculate(){
    vel[1] = vel[1]+ace[1];
    vel[0] = vel[0]+ace[0];
    pos[1] = pos[1]+vel[1];
    pos[0] = pos[0]+vel[0];
  }
  
  void drawBall(){
    ellipseMode(CENTER);
    fill(255);
    ellipse(pos[0],pos[1],size,size);
  }
  
  float[] getParams(){
    return(new float[]{pos[0],pos[1],vel[0],vel[1],size,ace[0],ace[1]});
  }
  float[] getScore(){
    return new float[]{points[0],points[1]};
  }
}
