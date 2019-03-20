// VSynthTools
// v0.12
// ludwig.zeller@fhnw.ch
// July 2014
// Basel School of Design


// General ---------------

void initVSynth(){
 initMidi("SLIDER/KNOB"); // default for NanoControl
 initLfos();  
}

void initVSynth(String port){
 initMidi(port);
 initLfos(); 
}

void updateVSynth(){
  updateMidi();
  updateLfos();
}



// MIDI ---------------
import themidibus.*; 

MidiBus bus; 
MidiBuffer midi;

void initMidi(String inputPort) {
  midi = new MidiBuffer();
  MidiBus.list();
  
  bus = new MidiBus(this, inputPort, -1);   
}

void updateMidi(){
  midi.update(); 
}


class MidiBuffer{
  
  int ccAmount = 128;
  float defaultValue = 1;
  boolean useKnobsForEasing = true;  
 
  float[] direct; // last read value
  float[] eased; // current animated value
  float[] easeRate; // easing speed
  

  
  MidiBuffer() {
    // initialize buffers
    direct = new float[ccAmount];
    for( int i = 0; i < ccAmount; i++ ){
      direct[i] = defaultValue; 
    }
    
    eased = new float[ccAmount];
    for( int i = 0; i < ccAmount; i++ ){
      eased[i] = defaultValue; 
    }
    
    easeRate = new float[ccAmount];
    for( int i = 0; i < ccAmount; i++ ){
      easeRate[i] = defaultValue; // default with a very fast ease rate
    }
  }
  
  void update() {
    
    for( int i = 0; i < ccAmount; i++ ){
      float delta = direct[i] - eased[i];
      eased[i] += delta * easeRate[i];
    }
    
    if(useKnobsForEasing) {
      for(int i = 0; i < 8; i++) {
        easeRate[i] = value( i+16, 0.001, 1, 3 ); // 0-7
        easeRate[i+32] = value( i+16, 0.001, 1, 3 ); // 32-39
        easeRate[i+48] = value( i+16, 0.001, 1, 3 ); // 48-55
        easeRate[i+71] = value( i+16, 0.001, 1, 3 ); // 64-71
      } 
    }
  }
  
  float value(int index) {
    return value(index, 0, 1, 1);
  } 
  
  float value(int index, float a, float b) {
    return value(index, a, b, 1);
  }
  
  float value(int index, float a, float b, float linearity) {
    return map(pow(direct[index], linearity), 0, 1, a, b);
  }
  
  float eased(int index) {
    return eased(index, 0, 1, 1);
  } 
  
  float eased(int index, float a, float b) {
    return map(eased[index], 0, 1, a, b); 
  }
  
  float eased(int index, float a, float b, float linearity) {
    return map(pow(eased[index], linearity), 0, 1, a, b);
  }
  

}

public void controllerChange(int channel, int number, int value) {
  if(channel != 0) {
    println("Wrong Midi Channel, should be 1");
  } else {
    println("Number: " + number + ", Value: " + value);
    midi.direct[number] = map(value, 0, 127, 0, 1); // store and normalize incoming value
  }
}





// LFOBuffer ---------------

LFOBuffer lfo;

void initLfos(){
  lfo = new LFOBuffer();
}

void updateLfos(){
  lfo.update();
}



class LFOBuffer {
 
  ArrayList<LFO> lfos;
  int amountLFOs = 8;

  LFOBuffer() {
    lfos = new ArrayList<LFO>(); // create 8 LFOs with frequency 1Hz
    for(int i = 0; i < amountLFOs; i++) {
      lfos.add(new LFO(1));
    }
  }
  
  void update(){
    for(int i = 0; i < lfos.size(); i++){
      lfos.get(i).update();
    }
  }

  void setFrequency(int num, float freq){
    lfos.get(num).setFrequency(freq);
  }  
  
  void setPhaseInvert(int num, boolean phase) {
    lfos.get(num).setPhaseInvert(phase);
  }
  
  float value(int num){
    return lfos.get(num).value(0, 1);
  }
  
  float value(int num, float a, float b){
    return lfos.get(num).value(a, b, 0);
  }
  
  float value(int num, float a, float b, float phase ){
    return lfos.get(num).value(a,b,phase);
  }
  
  
}



// LFO ---------------
class LFO {
  
  boolean phaseInvert = false;
  int timer = 0;
  int lastTime = 0;
  float freq = 1; // Hertz
  
  LFO(float f) {
    this.setFrequency(f);
  }
  
  void update(){
    float diffTime = millis() - lastTime; // time passed
    timer += diffTime * freq; // actual animation
    timer %= 1000; // wrap around
    lastTime = millis(); 
  }
  
  void setFrequency(float f){
    this.freq = f;
  } 
  
  void setPhaseInvert(boolean invert) {
    phaseInvert = invert;
  }
  
  float value(){
    return value(0, 1);
  }
  
  float value(float a, float b){
    return value(a, b, 0);
  }
  
  float value(float a, float b, float phase ){
    if(phaseInvert) {
      return map(cos( map(timer+phase, 0, 1000, 0, TWO_PI ) ), -1, 1, a, b);
    } else {
      return map(sin( map(timer+phase, 0, 1000, 0, TWO_PI ) ), -1, 1, a, b);
    }
  }
  
  void reset() {
    timer = 0;
  }
  
}
