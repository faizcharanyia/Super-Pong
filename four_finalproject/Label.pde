class Label extends Button{
  String descrip;
  
  Label(String text, float x, float y, int size, String descrip){
    super(text,x,y,size);
    this.descrip = descrip;
  }
  
  void drawDescrip(){
    textAlign(LEFT,CENTER);
    textSize(floor(size*3/4));
    fill(255);
    text(descrip,x+size*text.length(),y);
  }
}
