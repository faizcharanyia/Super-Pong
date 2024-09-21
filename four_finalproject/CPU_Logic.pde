class CPU_Logic{
  boolean[] CPUkeys; //w,a,s,d, ,
  float[] ballParams;
  int curFrame;
  boolean[] move; //Jump
  int curFrame2;
  int curFrame3;
  
  CPU_Logic(){
    CPUkeys = new boolean[5];
  }
  
  boolean[] getKey(){
    return CPUkeys;
  }
  
  void predict(float[] ballParams,float[] paddleParams){
    this.ballParams = ballParams;
    float predictedX = getBallXFloor(kinematic());
    determineMovement(predictedX, paddleParams);
  }
  
  float kinematic() {
    float yi = ballParams[1];
    float yf = height-lowBound-ballParams[4]*2-1;
    float y = (yf-yi);
    float vi = -ballParams[3];
    float a = -ballParams[6]/2;
    float t = (-vi-sqrt(vi*vi-4*a*y))/(2*a);
    curFrame = frameCount + ceil(t);
    return(t);
  }
  
  float getBallXFloor(float t){
    float newX = ballParams[0]+ballParams[2]*t;
    return(newX);
  }
  
  
  
  void predictUp(){
    
  }
  
  void predictBack(float preX, float[] paddleParams){
    if(curFrame2<frameCount){
      if(paddleParams[0]-ballParams[0]<100){
        if(preX>width){
          CPUkeys[0] = true;
          curFrame2 = frameCount+15;
          if(random(0,5)<1 && frameCount>curFrame3  && ballParams[0]<paddleParams[0]){
            CPUkeys[0] = true;
            CPUkeys[2] = true;
            CPUkeys[4] = true;
          }
        }else{
          CPUkeys[0] = false;
        }
      }else if(paddleParams[0]<preX-200 && paddleParams[0]<3*width/4){
        CPUkeys[1] = true;
        CPUkeys[4] = true;
        curFrame2 = frameCount+20;
      }else if(paddleParams[0]-100<preX && paddleParams[0]-50>preX && ballParams[1]>height-ballParams[4]*4-lowBound){
        if(random(0,5)<1){
          curFrame2 = frameCount+20;
          CPUkeys[3] = true;
          CPUkeys[4] = true;
        }
      }else if(abs(preX-paddleParams[0])<20 && paddleParams[0]-ballParams[0]<250){
        float ran = random(0,100);
        if(ran<1){
          curFrame2 = frameCount+60;
          CPUkeys[0] = true;
          CPUkeys[4] = true;
        }
      }
    }else{
      CPUkeys[0] = false;
      CPUkeys[1] = false;
      CPUkeys[2] = false;
      CPUkeys[3] = false;
      CPUkeys[4] = false;
    }
  }
  
  void determineMovement(float preX, float[] paddleParams){
    
    predictBack(preX,paddleParams);
    if(CPUkeys[4] != true){
      if(abs(paddleParams[0]-preX)>5 && preX>width/2){
        if(paddleParams[0]>preX){
          CPUkeys[1] = true;
          CPUkeys[3] = false;
        }else{
          CPUkeys[3] = true;
          CPUkeys[1] = false;
        }
      }else{
        CPUkeys[1] = false;
        CPUkeys[3] = false;
      }
    }
  }
}
