import netP5.*;
import oscP5.*;

OscP5 osc;
NetAddress sc;
float amp1 = 0.0;
float amp2 = 0.0;
float amp3 = 0.0;

void setup() {
  size(500, 500);
  
  osc = new OscP5(this, 12000); 
  // it takes arguments of its context which is "this" which is everything,it's the sketch;  then a port
  
  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */
   
  sc= new NetAddress("127.0.0.1",58945); 
  //  send messages to a destination
  osc.plug(this, "newamp", "/amp1"); //function name, receving message name.   ( forwarding server. or can use oscEvent )
}


void draw() {  // send message every phrame
  background(0);
  OscMessage msg = new OscMessage("/getamp");
  osc.send(msg, sc); // the message, the address
 
 stroke(153, 255, 0);
 strokeWeight(10);
 line(20, height/2.0 - 30, 30 + amp1, height/2.0 -30);
 line(20, height/2.0, 30 + amp2, height/2.0);
 line(20, height/2.0 + 30, 30 + amp3, height/2.0 + 30);
}

void newamp(float rms){
  
 amp1 = map(rms, 0.0, 1.0, 0.0, 350.0);
 amp2 = map(rms, 0.0, 1.0, 50.0, 350.0);
 amp3 = map(rms, 0.0, 1.0, 10.0, 350.0);

}
