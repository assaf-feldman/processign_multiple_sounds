/**
 * Load Sample
 * by Damien Di Fede.
 *  
 * This sketch demonstrates how to use the <code>loadSample</code> 
 * method of <code>Minim</code>. The <code>loadSample</code> 
 * method allows you to specify the sample you want to load with 
 * a <code>String</code> and optionally specify what you 
 * want the buffer size of the returned <code>AudioSample</code> 
 * to be. If you don't specify a buffer size, the returned sample 
 * will have a buffer size of 1024. Minim is able to load wav files, 
 * au files, aif files, snd files, and mp3 files. When you call 
 * <code>loadSample</code>, if you just specify the filename it will 
 * try to load the sample from the data folder of your sketch. However, 
 * you can also specify an absolute path (such as "C:\foo\bar\thing.wav") 
 * and the file will be loaded from that location (keep in mind that 
 * won't work from an applet). You can also specify a URL (such as 
 * "http://www.mysite.com/mp3/song.mp3") but keep in mind that if you 
 * run the sketch as an applet you may run in to security restrictions 
 * if the applet is not on the same domain as the file you want to load. 
 * You can get around the restriction by signing the applet. Before you 
 * exit your sketch make sure you call the <code>close</code> method 
 * of any <code>AudioSamples</code>'s you have received from 
 * <code>loadSample</code>.
 *
 * An <code>AudioSample</code> is a special kind of file playback that 
 * allows you to repeatedly <i>trigger</i> an audio file. It does this 
 * by keeping the entire file in an internal buffer and then keeping a 
 * list of trigger points. <code>AudioSample</code> supports up to 20 
 * overlapping triggers, which should be plenty for short sounds. It is 
 * not advised that you use this class for long sounds (like entire songs, 
 * for example) because the entire file is kept in memory.
 * 
 * Press 'k' to trigger the sample.
 */

import ddf.minim.*;
import processing.serial.*;     // import the Processing serial library
Serial myPort;                  // The serial port

Minim minim;

String files[] = {"effect-2.wav", "effect-3.wav", "effect-5.wav", "beats-1.wav",  "beats-2.wav",  "beats-4.wav",  "melodies-2.wav", "melodies-3.wav", "melodies-5.wav", "chorus-1.wav",  "chorus-3.wav",  "voice.wav"}; //the file should be in the 'data' folder with the sketch.
                                                           //in this case i use the same file for all the samples
int sounds_amount = files.length;
boolean switches[] = new boolean[sounds_amount];

AudioPlayer[] sound = new AudioPlayer[sounds_amount];
int rect_width = 50;
int rows = 3;

void setup()
{
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino module, so I open Serial.list()[0].
  // Change the 0 to the appropriate number of the serial port
  // that your microcontroller is attached to.
  myPort = new Serial(this, Serial.list()[0], 9600);

  // read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');

  size(rect_width*sounds_amount/rows,rect_width*rows, P2D);
  // always start Minim before you do anything with it
  minim = new Minim(this);
  
  println("Starded with " + sounds_amount+ "sounds");

  for(int i=0; i<sounds_amount; i++){// into each "sound" sample
    // load BD.mp3 from the data folder, with a 512 sample buffer
    sound[i] = minim.loadFile(files[i], 2048);
  }
}

void draw()
{
  background(0);
  stroke(255);
  // use the mix buffer to draw the waveforms.
  // because these are MONO files, we could have used the left or right buffers and got the same data
  int cols = sounds_amount/rows;
  for(int col=0; col < cols; col++) {
    for (int row=0; row < rows; row++){
      if (switches[col + (row * cols) ]){
        stroke(255);
        fill(0);
      }else{
        stroke(0);
        fill(255);
      }
      rect(rect_width*col,rect_width * row,rect_width,rect_width);
    }
  }
}

// serialEvent  method is run automatically by the Processing applet
// whenever the buffer reaches the  byte value set in the bufferUntil() 
// method in the setup():
void serialEvent(Serial myPort) { 
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  // if you got any bytes other than the linefeed:
  myString = trim(myString);
 
  // split the string at the commas
  // and convert the sections into integers:
  int sensors[] = int(split(myString, ','));

  // print out the values you got:
  for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
    
    if (sensorNum > 12){
      println();
      println(door sensor " + sensors[sensorNum]);
    }else{
      print(sensorNum + ": " + sensors[sensorNum] + ",");
      if (sensors[sensorNum] == 1){
        switches[sensorNum] = true;
      }else{
        switches[sensorNum] = false;
      }
    }
  }
  
  // send a byte to ask for more data:
  myPort.write("A");
}
  
void mouseClicked(){
  int cols = sounds_amount/rows;  
  int col = mouseX/rect_width;
  int row = mouseY/rect_width;
  int soundIndex = col + (row * cols);
  switches[soundIndex] = !switches[soundIndex];
  if (switches[soundIndex]){
    sound[soundIndex].play();
  }else{
    stopSound(soundIndex);
  }
}

void keyPressed() // the stuff in this block happends every time a key is pressed.
{

  int key_pressed = 0;
  if(key>='1' && key<='9')  key_pressed = int(key)-int('0');
   if(key == 'q') key_pressed = 10;
   if(key =='w') key_pressed = 11;
    if(key =='e') key_pressed = 12;
    
  if(key_pressed <= sounds_amount && key_pressed != 0 ) {
      int sound_2_trigger = key_pressed - 1;// the last 4 line r to determin what sound to trigger acording to the key that was pressed
      // now, play the sound
      //sound[sound_2_trigger.play();
      switches[sound_2_trigger] = true;
    }

  if(key=='d') {
    for(int i=0; i < sounds_amount; i++){
      if(switches[i] == true){
        sound[i].play();
      }
    }
  }
   for(int i=0; i < sounds_amount; i++){
      if(switches[i] == true){
        print(i + ", ");
      }
    }
    println("key " + key);
  
}


void keyReleased() // the stuff in this block happends every time a key is pressed.
{
  int key_released  = 0 ;
  if(key>='1' && key<='9')  key_released = int(key)-int('0');
  if(key == 'q') key_released = 10;
   if(key == 'w') key_released = 11;
    if(key == 'e') key_released = 12;
    
    if(key_released <= sounds_amount && key_released!=0 ) {
      int sound_2_trigger = key_released - 1;// the last 4 line r to determin what sound to trigger acording to the key that was pressed
      // now, stop the sound
      //sound[sound_2_trigger].pause();
      //sound[sound_2_trigger].rewind();
       switches[sound_2_trigger] = false;
    }
  
  if(key=='d') {
    for(int i=0; i < sounds_amount; i++){
      stopSound(i);
    }
  
  }  
}

void stopSound(int i){
  sound[i].pause();
  sound[i].rewind();
}

void startSound(int i){
  sound[i].pause();
  sound[i].rewind();
}



void stop()
{
  // always close Minim audio classes when you are done with them
  sound[0].close();
  minim.stop();
  
  super.stop();
}
