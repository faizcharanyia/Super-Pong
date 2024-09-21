class Animation{
  String name;
  int len;
  int Start;
  
  Animation(String name,int len){
    this.name = name;
    this.len = len;
  }
  
  void drawAni(float x, float y,int frame,boolean rotate,float offset){
    pushMatrix();
    
    translate(x,y);
    if(rotate){
      pushMatrix();
      rotate((len-frame+1)/2+offset);
      PImage curFrame = loadImage(name + (len-frame+1) +".png");
      image(curFrame,-curFrame.width/2,-curFrame.height/2);
      popMatrix();
    }else{
      pushMatrix();
      rotate(offset);
      PImage curFrame = loadImage(name + (len-frame+1) +".png");
      image(curFrame,-curFrame.width/2,-curFrame.height/2);
      popMatrix();
    }
    popMatrix();
    
  }
  
}
