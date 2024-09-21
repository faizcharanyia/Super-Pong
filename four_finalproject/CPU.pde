class CPU {
  float[] pos;
  float[] vel;
  float[] ace;
  float speed;
  boolean[] move;
  float size;
  float rotation = 0;
  float angularVelocity = 0;
  boolean stopX = false;
  boolean stopY = false;
  boolean airbourne = false;
  boolean airbourne2 = false;
  boolean airStrafe = false;
  boolean drawBarrier = false;
  boolean curMove = false;
  int curFrame;
  int curFrame2;
  int curFrame3;
  int dashTime;
  int slamTime;
  int blastTime;
  int forceTime;
  int jumpTime;
  int fireTime;
  Animation Sword;
  Animation Blast;
  Animation Fire;
  float[] blastPos;
  float[] firePos;
  int multiplierX;
  int multiplierY;
  



  CPU() {
    move = new boolean[]{false,false,false,false};//dashBack,slamDown,forceWall,jumpSmash
    pos = new float[]{5*width/6, 31*height/33-lowBound};
    vel = new float[]{0, 0};
    ace = new float[]{0, 0};
    speed = 3;
    size = height/33;
  }
  
  
  
  float[] getCPU(){
    return(new float[]{pos[0],pos[1],vel[0],vel[1],ace[0],ace[1],size});
  }


  float kinematic() {
    float yi = pos[1];
    float yf = height-lowBound-size*2-1;
    float y = (yf-yi);
    float vi = -vel[1];
    float a = -ace[1]/2;
    float t = (-vi-sqrt(vi*vi-4*a*y))/(2*a);
    curFrame2 = frameCount + ceil(t);
    return(t);
  }



  void angularVelocity(float t) {
    float diff = 180-degrees(rotation)%180;
    if (t!=0) {
      angularVelocity = radians(diff/t);
      if(vel[0]<0){
        angularVelocity = -angularVelocity;
      }
    } else {
      angularVelocity = 0;
    }
  }



  void compute(boolean[] keys) {
    boolean proceed = true;
    if(keys[4]){
      stopX = true;
      stopY = true;
      proceed = false;
      if(keys[1]){
        dashBack();
        keys[4] = false;
      }else if(keys[2]){
        slamDown();
        jump();
        keys[2] = false;
        keys[4] = false;
      }else if(keys[3]){
        forceWall();
        keys[3] = true;
        keys[4] = false;
      }else if(keys[0]){
        jumpSmash();
        keys[0] = false;
        keys[4] = false;
      }else{
        proceed = true;
        keys[4] = false;
      }
      
    }if (proceed){
      //Vertical
      if(!move[3]){
        stopY = false;
      }
      if (keys[0]) {
        if (!airbourne) {//Currently Single jump
          curFrame = frameCount;
          jump();
        } else if (!airbourne2 && frameCount-curFrame>15) {//Currently Double Jump
          airStrafe = true;
          doubleJump();
        }
      }
  
      //Lateral
      stopX = false;
      if (keys[1]) {
        ace[0] = -speed;
        if (airbourne && !airStrafe) {
          ace[0] = 0;
        }
      } else if (keys[3]) {
        ace[0] = speed;
        if (airbourne && !airStrafe) {
          ace[0] = 0;
        }
      } else if (!airbourne) {
        ace[0] = 0;
        ace[1] = 0;
        stopX = true;
      }//Lateral
    }
    //Primary Functions
    calculate();
    drawPaddle();
  }



  void calculate() {
    if(pos[0]>width){
      pos[0] = width-size/2;
    }
    //Checks to see if a move is happening
    curMove = false;
    for (int i = 0; i <move.length; i++) {
      if (move[i] == true) {
        curMove = true;
      }
    }

    //If no move then use WASD normally
    if (!curMove) {
      //Move Horizontally
      if (!stopX) {
        //Compute X Velocity
        vel[0] = vel[0]+ace[0];
      } else {//Bring X to a stop
        if (vel[0]!=0) {
          if (abs(vel[1])<1) {
            vel[0] = 0;
          } else {
            vel[0] = (abs(vel[0])-speed/10)*vel[0]/abs(vel[0]);
          }
        }
      }

      //Contrain Velocity
      if (abs(vel[0])>5) {
        vel[0] = 5*vel[0]/abs(vel[0]);
      }

      //Right Wall
      if (pos[0]+size/2>width) {
        vel[0] = 0;
        ace[0] = 0;
        pos[0]-= 1;
      }

      //Left Wall
      if (pos[0]-size/2<width/2) {
        vel[0] = abs(vel[0]);
        drawBarrier = true;
        curFrame = frameCount+30;
      }
      if (drawBarrier) {
        drawBarrier();
      }

      pos[0] = pos[0]+vel[0];
      if(!stopY){
        //Vertical Movement
        vel[1] = vel[1]+ace[1];
        pos[1] = pos[1]+vel[1];
        if (pos[1]+size*2>height-lowBound) {
          ace[1]=0;
          vel[1]=0;
          pos[1]=31*height/33-lowBound;
          airbourne  = false;
          airbourne2 = false;
          angularVelocity = 0;
          rotation = 0;
        }
      }
    }
    //DashBack
    else if(move[0]){
      if(dashTime>frameCount){
        pos[0] = pos[0]+15;
        angularVelocity = -72;
        if (pos[0]+size/2>width) {
          
          pos[0] = width-size/2;
          
        }
      }else{
        move[0] = false;
        angularVelocity = 0;
      }
    }
    //SlamDown
    else if(move[1]){
      if(slamTime>frameCount){
        
        Sword.drawAni(pos[0],pos[1],floor((slamTime-frameCount+2)/3),true,-PI);
        pos[0] += multiplierX*15;
        pos[1] += multiplierY*15;
        if (pos[0]+size/2<width/2){
          curFrame = frameCount+30;
          multiplierX = 1;
          ace[0] = 5;
          drawBarrier();
        }if (pos[1]+size*2>height-lowBound){
          multiplierY = -1;
        }
        
      }else{
        move[1] = false;
      }
      if(blastTime>frameCount){
        Blast.drawAni(blastPos[0],blastPos[1],floor((blastTime-frameCount+2)/3),false,3*PI/4);
      }
      
    }
    //ForceWall
    else if(move[2]){
      if(forceTime>frameCount){
        fill(255,255,0,float(forceTime-frameCount)/15*255);
        rect(pos[0]+(forceTime-frameCount-15)*15,pos[1],size,size*4);
      }else{
        if(airbourne){
          jump();
        }
        move[2] = false;
      }
    }
    //JumpSmash
    else if(move[3]){
      if(jumpTime>frameCount){
        if(jumpTime-frameCount>45){
          angularVelocity +=.01;
        }else if(jumpTime-frameCount>35){
          if(jumpTime-frameCount == 36){
            playSound(5);
          }
          if(fireTime+34>frameCount){

            Fire.drawAni(firePos[0],firePos[1],floor((fireTime+20-frameCount+1)/2),false,0);
          }
          pos[1] = highBound+size*2;
          angularVelocity -= .025/2;
        }else{
          
          if (pos[1]+size*2<height-lowBound){
            vel[1] += 7;
            pos[1] += vel[1];
          }else{
            vel[1] = -2*vel[1]/3;
            pos[1] += vel[1];
          }
          angularVelocity = 0;
        }
      }else{
        move[3] = false;
        keys[4] = false;
        keys[0] = false;
        jump();
      }
    }
    
    airStrafe = false;
  }



  void jump() {
    playSound(7);
    airbourne = true;
    vel[1] = -height/30;
    ace[1] = 540/height;
    angularVelocity(kinematic());
  }



  void doubleJump() {
    playSound(8);
    airbourne2 = true;
    vel[1] = vel[1]-height/20;
    vel[0] = vel[0]*1.5*540/height;
    ace[1] = 1.5*540/height;
    angularVelocity(kinematic());
  }
  
  
  
  void dashBack(){
    playSound(9);
    dashTime = frameCount+10;
    move[0] = true;
  }
  
  void slamDown(){
    playSound(5);
    playSound(4);
    slamTime = frameCount+6*3;
    blastTime = frameCount+4*3;
    Sword = new Animation("S",6);
    Blast = new Animation("B",4);
    blastPos = new float[]{pos[0],pos[1]};
    move[1] = true;
    multiplierX = -1;
    multiplierY = 1;
  }
  
  
  
  void forceWall(){
    playSound(10);
    move[2] = true;
    stopX = true;
    forceTime = frameCount+15;
  }
  
  
  
  void jumpSmash(){
    fireTime = frameCount+5*3;
    Fire = new Animation("F",5);
    firePos = new float[]{pos[0],pos[1]};
    move[3] = true;
    stopX = true;
    stopY = true;
    jumpTime = frameCount + 70;
  }



  void drawBarrier() {
    playSound(11);
    if (curFrame>frameCount) {
      for (int i =0; i<floor(width/30); i++) {
        fill(255, 255, 0, (float(floor(width/30)-i-1))/floor(width/30)*255*(curFrame-frameCount)/10);
        rectMode(CORNERS);
        noStroke();
        rect(width/2-i, height-lowBound, width/2-i-1, highBound);
      }
      fill(255);
    } else {
      drawBarrier = false;
    }
  }


  
  float[] collision(float[] ballParams){
    float distance=sqrt(pow(ballParams[0]-pos[0],2)+pow(ballParams[1]-pos[1],2))-size/2;
    float angle = -atan2(ballParams[1]-pos[1],(ballParams[0]-pos[0]));
    
    float maxAngle = atan(4);
    float maxHypo = sqrt(pow(size/2,2)+pow(size*2,2))+ballParams[4];
    if(move[3]){
      if(jumpTime-frameCount>30){
          if(abs(distance)<maxHypo){
            return(new float[]{-abs(ballParams[2]),-abs(ballParams[3])});
          }else{
            return(new float[]{ballParams[2],ballParams[3]});
          }
        }else{
          if(ballParams[0]>pos[0]-size*3/2 && ballParams[0]<pos[0]+size*3/2){
            if(ballParams[1]>pos[1]-size*9 && ballParams[1]<pos[1]+size*9){
              if(vel[1]<0){
                return(new float[]{-abs(ballParams[2]),abs(ballParams[3])});
              }else{
                return(new float[]{-abs(ballParams[2]),abs(ballParams[3])*4});
                //return(new float[]{ballParams[2],ballParams[3]});
              }
            }else{
              return(new float[]{ballParams[2],ballParams[3]});
            }
          }else{
            return(new float[]{ballParams[2],ballParams[3]});
          }
        }
      
    }else if(move[2]){
      if(ballParams[1]>pos[1]-size/2 && ballParams[1]<pos[1]+size/2){
        if(ballParams[0]<pos[0]+(forceTime-frameCount-15)*15+size*2 && ballParams[0]>pos[0]+(forceTime-frameCount-15)*15-size*2){
          return(new float[]{-abs(ballParams[2])-2,ballParams[3]});
        }else{
          return(new float[]{ballParams[2],ballParams[3]});
        }
      }else{
        return(new float[]{ballParams[2],ballParams[3]});
      }
    }else if(move[1] && abs(distance)+5<maxHypo){
      return(new float[]{-15,15});
    }else if(curFrame3<frameCount){
      if(!airbourne){
        if((distance*cos(angle)+1<maxHypo*cos(maxAngle) && abs(angle)<maxAngle) || (abs(distance*cos(angle))+1<maxHypo*cos(maxAngle) && angle<maxAngle)||(distance<size)){
          curFrame3 = frameCount+15;
          playSound(0);
          return(new float[]{cos(angle)/abs(cos(angle))*abs(ballParams[2]),ballParams[3]});
          
        }else if(abs(distance)+5<maxHypo && abs(ballParams[0]-pos[0])<size){
          curFrame3 = frameCount+15;
          playSound(0);
          return(new float[]{-abs(ballParams[2]),-ballParams[3]});
        }else{
          return(new float[]{ballParams[2],ballParams[3]});
        }  
      }else if(airbourne){
        angle = angle +(PI-abs(rotation));
        if((abs(distance*cos(angle))<maxHypo*cos(maxAngle) && abs(angle)<maxAngle && distance<maxHypo) || (abs(distance*cos(angle))<maxHypo*cos(maxAngle) && angle<maxAngle && distance<maxHypo)){
          curFrame3 = frameCount+15;
          playSound(0);
          return(new float[]{(-abs(vel[0])-abs(ballParams[2]))*cos(abs(rotation)%(PI/2)),abs(ballParams[3])/ballParams[3]*(abs(vel[1])+abs(ballParams[3]))*sin(abs(rotation)%(PI/2))});
        }else if(abs(distance)+5<maxHypo && abs(ballParams[0]-pos[0])<size){
          curFrame3 = frameCount+15;
          playSound(0);
          return(new float[]{-abs(ballParams[2]),-ballParams[3]});
        }else{
          return(new float[]{ballParams[2],ballParams[3]});
        }  
      }else{
        return(new float[]{ballParams[2],ballParams[3]});
      }
    }else{
      return(new float[]{ballParams[2],ballParams[3]});
    }
  }
  
  
  
  
  void drawPaddle() {
    rectMode(CENTER);
    
    pushMatrix();
    pushMatrix();
    translate(pos[0], pos[1]);
    if(!curMove){
      rotation = (frameCount-curFrame2)*angularVelocity;
    }else if(move[0]){
      rotation = (frameCount-dashTime)*angularVelocity;
    }else if(move[3]){
      if(angularVelocity != 0){
        rotation = (frameCount-jumpTime)*angularVelocity;
      }else{
        rotation = PI/2;
      }
    }else{
      if(!airbourne){
        rotation = 0;
      }
    }
    rotate(rotation);
    fill(255);
    rect(0, 0, size, size*4);
    popMatrix();
    popMatrix();
    
  }
}
