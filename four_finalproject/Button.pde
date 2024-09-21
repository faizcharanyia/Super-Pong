class Button{
  String text;
  float x;
  float y;
  float size;
  
  Button(String text, float x, float y, int size){
    this.text = text;
    this.x = x;
    this.y = y;
    this.size = size;
  }


  void drawButton() {
    if(mute && text == "Mute"){
      fill(0, 155, 0);
    }else{
      fill(0, 255, 0);
    }
    rectMode(CORNERS);
    rect(x - size*3*text.length()/4, y - size*4/3, x+ size*3*text.length()/4, y+ size*4/3, 20);
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(size); // Text size for button text
    text(text, x, y);
  }
  
  
  boolean overButton(float mx, float my) {
    return mx > x - size*3*text.length()/4 && mx < x+ size*3*text.length()/4 && my > y - size*4/3 && my < y+ size*4/3;
  }
}
