import processing.serial.*; // import serial port library
import static javax.swing.JOptionPane.*; // import library for dialog boxes

Serial port; // Serial port object

int maxNumberStores = 40; // maximum number of patterns, limited by Arduino memory

PImage colorwheel; // image of colorwheel 
PImage dodec; // image of exploded dodecahedron
PImage[] imDisp = new PImage[maxNumberStores]; // array of stored patterns to display to user
HScrollbar hs1; // speed scrollbar object

PFont font; // Font Type 1
PFont font2; // Font Type 2
PFont font3; // Font Type 3

PVector[] pent0=new PVector[5]; // pentagon 0 of dodecahedron
PVector[] pent1=new PVector[5]; // pentagon 1 of dodecahedron
PVector[] pent2=new PVector[5]; // pentagon 2 of dodecahedron
PVector[] pent3=new PVector[5]; // pentagon 3 of dodecahedron
PVector[] pent4=new PVector[5]; // pentagon 4 of dodecahedron
PVector[] pent5=new PVector[5]; // pentagon 5 of dodecahedron
PVector[] pent6=new PVector[5]; // pentagon 6 of dodecahedron
PVector[] pent7=new PVector[5]; // pentagon 7 of dodecahedron
PVector[] pent8=new PVector[5]; // pentagon 8 of dodecahedron
PVector[] pent9=new PVector[5]; // pentagon 9 of dodecahedron
PVector[] pent10=new PVector[5]; // pentagon 10 of dodecahedron

PVector[] arrow=new PVector[7]; // vector for arrow on store button

int xPos = 0; // x position for selecting colors
int yPos = 0; // y position for selecting colors
    
int boxSize = 30; // box size of current color box and black box for turning LED off 
    
int figSizeX = 600; // x size of figure
int figSizeY = 750; // y size of figure
int pentState; // Integer from 0-10 that describes which pentagon the mouse is hovering over
color c; // current color clicked
color [] cV = new color[11]; // color stored on dodecahedron
color [] cRecent = new color[10]; // colors stored for recent colors
boolean alreadyStored = false; // Checks if color is already stored in recent colors
int cRind; // current position in recent color display
boolean newColor = true; // Is this a new color that is not stored already in recent color bar

String [] rgb = new String[11]; // String array output for when user saves data
String r; // stores red values 0-255. Amount of values is equal to number of stores X number of pentagons
String g; // stores green values 0-255. Amount of values is equal to number of stores X number of pentagons
String b; // stores blue values 0-255. Amount of values is equal to number of stores X number of pentagons
String fileOut; // filename for exported data

int buttonDiameter = 65;     // Diameter of button type 1
int buttonDiameter2 = 54;    // Diameter of button type 2

int rSend; // red value sent to Arduino
int gSend; // green value sent to Arduino
int bSend; // blue value sent to Arduino

color buttonStoreBaseColor,buttonStoreBaseHighlight,buttonStoreShapeColor, buttonStoreShapeHighlight, buttonRunBaseColor, buttonRunBaseHighlight, buttonRunShapeColor, buttonRunShapeHighlight;
  
int buttonX1, buttonY1;      // Position of STORE button
boolean buttonOver1 = false; // Is mouse over STORE button?

int buttonX2, buttonY2;      // Position of RUN button
boolean buttonOver2 = false; // Is mouse over RUN button?

int buttonX3, buttonY3;      // Position of RESET button
boolean buttonOver3 = false; // Is mouse over RESET button?

int buttonX4, buttonY4;      // Position of SAVE button
boolean buttonOver4 = false; // Is mouse over SAVE button?

boolean[] dispStore = new boolean[maxNumberStores]; // Has an image been saved for that store position?
int whichStore; // Track the store/pattern number
int currentFrame; // One less than whichStore. Useful for displaying all stored patterns
int dispOffset = 0; // How many more patterns are stored than the total number that can be displayed 
int num2Disp; // Which image to display

boolean runStatePrev; // Is the dodecahedron currently running the patterns captured?

int speed; // speed patterns are run
float speedRaw;
float speedPercent;
float minSpeedPosition = 316.614; // position of left side of speed slide bar
float maxSpeedPosition = 414.327-316.614; // position of right side of speed slide bar
float maxSpeed = 100; // maximum speed that patterns can be played
float minSpeed = 1.5;  // minimum speed that patterns can be played

boolean firstRun = true; // Is this the first time that the program has been run?
String COMx, COMlist = ""; // String for holding available serial ports
String portName; // Name of port that Arduino is connected to

void setup() {
  
  if(firstRun){ // RUN this only once, so that if program is restarted user does not have to reselect their Serial port
     
     int i = Serial.list().length; // number of available serial ports
     for (int j = 0; j < i;j++) {         
          COMlist += str(j+1) +"  "+Serial.list()[j] +"\n";     
     } // Collect all serial ports into a string for displaying to user
     
     COMx = showInputDialog("Which COM port is correct? (1,2,..):\n\n"+COMlist); // create dialog box for user to select Serial port
     if (COMx == null) exit();
     if (COMx.isEmpty()) exit();
     i = int(COMx.toLowerCase())-1; // Index of serial port that user selected
     portName = Serial.list()[i]; // serial port name
     firstRun = false; // Flip to false so that port selection only happens once.
     
  }
    
  port = new Serial(this, portName,9600); // establish serial connection with Arduino
  print("CONNECTED TO: "+portName); // Print serial connection to user
  
  colorwheel = loadImage("source/customRGBwheel.jpg"); // load colorwheel image
  dodec = loadImage("source/buckyExploded.jpg"); //  load dodecahedron image 

  size(600,750); // Size of program window
  font = createFont("Gautami Bold",16); // create font Style 1
  font2 = createFont("Gautami Bold",12); // create font Style 2
  font3 = createFont("Gautami Bold",14); // create font Style 3
  
  // CREATE pentagon vectors to make them interactive
  pent0[0]=new PVector(201.5, 131.5); 
  pent0[1]=new PVector(268.5, 181.5);
  pent0[2]=new PVector(243, 261);
  pent0[3]=new PVector(160, 261);
  pent0[4]=new PVector(133.5,181.5);
  
  pent1[0]=new PVector(131,177);
  pent1[1]=new PVector(199,127);
  pent1[2]=new PVector(199,88);
  pent1[3]=new PVector(100.5,66);
  pent1[4]=new PVector(93,166);
  
  pent2[0]=new PVector(272,177);
  pent2[1]=new PVector(204,127);
  pent2[2]=new PVector(204,88);
  pent2[3]=new PVector(300,65);
  pent2[4]=new PVector(309,164);
  
  pent3[0]=new PVector(273.5, 183);
  pent3[1]=new PVector(311, 169);
  pent3[2]=new PVector(362, 253.5);
  pent3[3]=new PVector(271, 293.5);
  pent3[4]=new PVector(247.5, 265);
  
  pent4[0]=new PVector(159, 266);
  pent4[1]=new PVector(243, 266);
  pent4[2]=new PVector(267, 298);
  pent4[3]=new PVector(202, 372);
  pent4[4]=new PVector(136, 298);
  
  pent5[0]=new PVector(129, 182.5);
  pent5[1]=new PVector(90, 171.5);
  pent5[2]=new PVector(40, 258);
  pent5[3]=new PVector(130, 294.5);
  pent5[4]=new PVector(155, 263);
  
  pent6[0]=new PVector(86.5,166);
  pent6[1]=new PVector(96,69.5);
  pent6[2]=new PVector(47,115);
  pent6[3]=new PVector(25,180.5);
  pent6[4]=new PVector(37,252);
  
  pent7[0]=new PVector(105,62);
  pent7[1]=new PVector(163,28);
  pent7[2]=new PVector(236,28);
  pent7[3]=new PVector(296,61);
  pent7[4]=new PVector(200,83);
  
  pent8[0]=new PVector(305,68);
  pent8[1]=new PVector(356,116);
  pent8[2]=new PVector(376,183);
  pent8[3]=new PVector(364,248);
  pent8[4]=new PVector(315,167);
  
  pent9[0]=new PVector(360,260);
  pent9[1]=new PVector(330,324);
  pent9[2]=new PVector(273,363.5);
  pent9[3]=new PVector(207,374);
  pent9[4]=new PVector(274,298);
  
  pent10[0]=new PVector(42,264);
  pent10[1]=new PVector(130,299.5);
  pent10[2]=new PVector(195,374);
  pent10[3]=new PVector(127,366);
  pent10[4]=new PVector(72,324);
  
  
  // CREATE arrow vectors
  arrow[0]=new PVector(95,435);
  arrow[1]=new PVector(109,435);
  arrow[2]=new PVector(109,449);
  arrow[3]=new PVector(117,449);
  arrow[4]=new PVector(102,465);
  arrow[5]=new PVector(87,449);
  arrow[6]=new PVector(95,449);
  
  //BUTTON SETUP
  buttonStoreBaseColor = color(150); // Store button base color
  buttonStoreBaseHighlight = color(255); // Store button base color when mouse hovers over it
  buttonStoreShapeColor = color(200); // Store button arrow color
  buttonStoreShapeHighlight = color(150); // Store button arrow color when mouse hovers over it
    
  buttonRunBaseColor = color(0,150,0); // Run button base color
  buttonRunBaseHighlight = color(250,250,250);  // Run button base color when mouse hovers over it
  buttonRunShapeColor = color(0,220,0); // Run button Play/Stop shape color
  buttonRunShapeHighlight = color(0,150,0); // Run button Play/Stop shape color

  buttonX1 = 102; // x position of store button
  buttonY1 = 450; // y position of store button
  
  buttonX2 = 200; // x position of run button
  buttonY2 = 450; // y position of run button
  
  buttonX3 = 480; // x position of reset button
  buttonY3 = 455; // y position of reset button
  
  buttonX4 = 545; // x position of save button
  buttonY4 = 455; // y position of save button
  
  cRind = 0; // initiate index of recent color storage array
  
  // dispStore Initialize
  for(int d=0; d<maxNumberStores;d++){   
    dispStore[d]=false;
  }
  
  // Set all colors in dodecahedron to black and set all recent colors to white
  for(int d=0; d<11;d++){   
    cV[d]=0;
    if(d<10){
    cRecent[d]=255;
    }
  }
  
  runStatePrev = false; // Dodecahedron is not running pattern sequence
  whichStore = 0; // Set the current store pattern to 0. No patterns are stored yet.
  r=""; // Initialize red string save output
  g=""; // Initialize green string save output
  b=""; // Initialize blue string save output
  
  // Speed scroll bar
  hs1 = new HScrollbar(265, 450, 100, 16, 16); // x position, y position, width of scroll bar, box size X, box size Y
  
}

void draw() {
  
   background(232); // set background color
   image(colorwheel, 0.69*figSizeX,8,figSizeX*0.28,figSizeX*0.28); // display colorwheel
   image(dodec, 0, 0,2*figSizeX/3,2*figSizeX/3); // display dodecahedron
   fill(232); //text colors
   
   noStroke(); 
   stroke(232);
   rect(397, 0, 5, 400); // a little white is on dodecahedron image and this rectangle covers it up
   
   stroke(100); 
   strokeWeight(2);
   line(10, 405, 580, 405); // line that crosses middle of figure
   
   // DISPLAY FONT
   textFont(font);
   fill(0); //text color
   text("SELECTED COLOR",0.73*figSizeX,0.4*figSizeX);
   
   textFont(font2);
   text("TURN LED OFF:",0.725*figSizeX,0.32*figSizeX);

   textFont(font2);
   text("RECENT COLORS:",0.69*figSizeX,0.515*figSizeX);
   
   strokeWeight(1); // Black box to turn off LED
   rect(0.88*figSizeX, 0.298*figSizeX, boxSize*0.5, boxSize*0.5);
   
   // RECENT COLOR DISPLAY /////// 
   for(int d=0; d<10;d++){
     
     fill(cRecent[d]);
     
     if(d<5){         
         rect(415+d*30+d*6, 320,25,25);
       }
       
     else if(d>=5){ 
         rect(415+(d-5)*30+(d-5)*6, 353,25,25);
       } 
   }
   //////////////////////
   
   c = get(xPos,yPos); // Get a pixel, xPos and yPos are set under mousePressed function 
   fill(c); // current color, which is set in Selected color box
   strokeWeight(1.5);
   stroke(0);
   rect(0.81*figSizeX, 0.41*figSizeX, boxSize, boxSize); // Selected color box
   
   pentagonUpdate(); // function for updating colors in dodecahedron display
    
   // STORE POSITIONS - create boxes for 10 boxes displaying stored patterns
   stroke(20,20,20);
   strokeWeight(1);
   fill(255);   
   for(int d=0; d<10;d++){
     
     if(d<5){         
         rect(30+d*100+d*10, 500,100,100);
       }
       
     else if(d>=5){ 
         rect(30+(d-5)*100+(d-5)*10, 610,100,100);
       } 
   }
   //
   
   // CURRENT STORE POSITION - The current store position has a green outline
   stroke(0,255,0);
   strokeWeight(3);
   
    if(whichStore<5){         
         rect(30+whichStore*100+whichStore*10, 500,100,100);
       }
       
     else if(whichStore>=5 & whichStore<10){ 
          rect(30+(whichStore-5)*100+(whichStore-5)*10, 610,100,100);
      }
      else if(whichStore>=10){
        rect(30+(9-5)*100+(9-5)*10, 610,100,100);
      }
   // END CURRENT POSITION BUTTON ////////////////
   
   
   // DISPLAY STORED PATTERNS  
   currentFrame = whichStore-1;
   if(currentFrame>9){ // if there are more saved patterns than there are display positions 
     
       int temp = floor((currentFrame)/10); 
       dispOffset =(currentFrame % (10*temp))+1+(temp-1)*10; // stored position to start on so that most recently saved images are displayed
       
     }
     else{ // number of stored images is less than display positions
       dispOffset=0; 
     }
     
     // number of images to display depends on the number saved. Once there are more images saved than display positions, then set num2Disp to 10 (number of display positions)
     if (whichStore<10){     
       num2Disp = whichStore;      
     }
     else if (whichStore>=10){       
       num2Disp = 10;       
     }
   fill(0);
   
   for(int d=0; d<num2Disp;d++){

     if(dispStore[d]){
       
       if(d<5){         
         image(imDisp[d+dispOffset], 32+d*100+d*10, 502,98,98); // display stored image image
         text(d+dispOffset+1,32+d*100+d*10,595); // Display the store image number in the bottom left corner of image
         
       }
       
       else if(d>=5 & d<10){ 
         image(imDisp[d+dispOffset], 32+(d-5)*100+(d-5)*10, 612,98,98); // display stored image
         text(d+dispOffset+1,32+(d-5)*100+(d-5)*10,703); // Display the store image number in the bottom left corner of image
       }     
     } 
   }
   // END DISPLAY STORED IMAGES

    // BUTTONS /////////////////////////////////////////////////////
     buttonUpdate(); // function for determining whether or not the mouse is hovering over any buttons
      
     // STORE BUTTON    
     if (buttonOver1) { // mouse is over store button
        fill(buttonStoreBaseHighlight);
         if(runStatePrev){ // dodecahedron is running patterns
            fill(255,0,0);
            text("Can't store while running",40,495);       
         }           
     } else {
         fill(buttonStoreBaseColor); // mouse is NOT over store button
     }
     
     if (whichStore>maxNumberStores-1){ // Max number of patterns stored
       fill(255,0,0);
       text("Max patterns stored!",81,481);
     }
     
     stroke(50);
     strokeWeight(2);
     ellipse(buttonX1, buttonY1, buttonDiameter, buttonDiameter); // Store button circle is displayed   
     
     // ARROW inside store button is displayed
         if (buttonOver1) { // mouse is over store button
           fill(buttonStoreShapeHighlight);
         } else { // mouse is not over store button
           fill(buttonStoreShapeColor);
         }
          beginShape();
          for(PVector v : arrow) {
            vertex(v.x,v.y);
          }
          endShape(CLOSE);
     // ARROW end
     // END STORE /////////
     
     
     // RUN BUTTON
     if (buttonOver2) { // mouse is over RUN button
       fill(buttonRunBaseHighlight);
     } else { // mouse is NOT over RUN button
       fill(buttonRunBaseColor);
     } 
     
     ellipse(buttonX2, buttonY2, buttonDiameter, buttonDiameter); // display RUN button circle
     
     if (buttonOver2) { // mouse is over RUN button
       fill(buttonRunShapeHighlight);
     } else { // mouse is NOT over RUN button
       fill(buttonRunShapeColor);
     }
     
     if(runStatePrev == false){ // Dodecahedron is not running pattern
         polygon(buttonX2, buttonY2, 15, 3);  // Triangle is displayed that looks like a play button      
     } 
     else if(runStatePrev == true){ // Dodecahdron is running the stored pattern
         rect(buttonX2-12, buttonY2-12, 25,25);  // Square is displayed over button that looks like a stop button    
     } 
     // END RUN BUTTON ////////////////
     
     
     // RESET BUTTON
     if (buttonOver3) { // mouse is over reset button
        fill(buttonStoreBaseHighlight);     
        
     } else {  // mouse is NOT over reset button
         fill(buttonStoreBaseColor);
     }
     stroke(50);
     strokeWeight(2);
     ellipse(buttonX3, buttonY3, buttonDiameter2, buttonDiameter2); // draw circle for reset button
     textFont(font3);
 
     if (buttonOver3) { // mouse is over reset button
       fill(255,0,0);   
     } else { // mouse is over reset button
       fill(0,0,0);
     }
     
     textFont(font3);
     text("RESET",buttonX3-19, buttonY3+5.5); // display RESET text on reset button and color according to whether or not mouse is over button
     // END RESET BUTTON ////////////////
     
     
     // SAVE BUTTON
     if (buttonOver4) { // mouse is over save button
        fill(buttonStoreBaseHighlight);        
     } else { // mouse is NOT over save button
         fill(buttonStoreBaseColor);
     }
     stroke(50);
     strokeWeight(2);
     ellipse(buttonX4, buttonY4, buttonDiameter2, buttonDiameter2); // display circle for save button
     textFont(font3);
 
     if (buttonOver4) {
       fill(0,0,255);
     } else {
       fill(0,0,0);
     }
     
     textFont(font3);
     text("SAVE",buttonX4-16, buttonY4+5.5);   // display SAVE text on reset button and color according to whether or not mouse is over button 
     // END SAVE BUTTON ////////////////
     
     
     
     // SPEED SCROLL BAR //////
     speedPercent = 100*((hs1.getPos()-minSpeedPosition)/maxSpeedPosition)+1;
     speedRaw = 1/(speedPercent);
     speed=int(speedRaw*8000); // speed pattern is played to send to Arduino if play is clicked. Value from scroll bar needs to be adjusted so that range is between min and max speed
     
     hs1.update();
     hs1.display();
     textFont(font3);
     fill(0);
     text("SPEED: "+int(speedPercent)+"%",274,480); 
     
    // DISPLAY MOUSE POSITION FOR TROUBLE SHOOTING
    //fill(0); 
    //text(mouseX,400,480);
    //text(mouseY,400,500);

}
    
void mousePressed() {

    if(overCircle(500, 93, 168) || overButton(528, 178, 15,15) || overButton(413, 320, 177,60)) // colorZone (color wheel OR blackbox OR recent colors) 
    {
      // Mouse is clicked when over the colorwheel, recent colors, or turn off led box
      xPos = mouseX; // set xPos and yPos
      yPos = mouseY; 
      if (overCircle(500, 93, 168)){ // colorwheel has been clicked
        newColor = true; // A new color has potential been clicked that may be stored. A few other conditions must be met to store in Recent Colors, which are addressed under condition for which dodecahedron is clicked
      }
     }
     
    else if(mouseY>=2*figSizeX/3) // BUTTON ZONE
    {
      // One of the buttons was probably clicked. We are in the button zone
      if(buttonOver1 & runStatePrev==false & whichStore<maxNumberStores){ // STORE BUTTON
        
        // Store button was clicked & the dodecahedron is not running pattern & there is still room to store patterns
        String imageName = "source/temp/capture"+whichStore+".jpg"; // name of image to be saved to computer
        saveFrame(imageName); // take screenshot of frame
        imDisp[whichStore] = loadImage(imageName); // load frame and store in image display array
        imDisp[whichStore] = imDisp[whichStore].get(0,0,400,400); // crop screenshot to include only dodecahdron
        dispStore[whichStore] = true; // Display this stored pattern
        
        // Send info to Arduino
        port.write(0); // 0-live display or 1-play sequence
        port.write(1); // 0-no store or 1-store
        port.write(Integer.toString(whichStore)); // Send current pattern number to Arduino
        // write any charcter that marks the end of a number
        port.write('e'); // Required for function on Arduino that converts String to int
           
        // Send out current dodec display led values to arduino to be stored 
        for (int d=0; d<11;d++){
          
            rSend=(cV[d]>>16)&255; // red value to Arduino
            gSend=(cV[d]>>8)&255; // green value to Arduino
            bSend=cV[d]&255; // blue value to Arduino
            port.write(rSend); 
            port.write(gSend);
            port.write(bSend);
            
            // rgb[d]=str(rSend)+", ";
            r = r+str(rSend)+", "; // Store red value into String with all red values. This string is exported in .txt file if user clicks save button
            g = g+str(gSend)+", "; // Store green value into String with all red values. This string is exported in .txt file if user clicks save button
            b = b+str(bSend)+", "; // Store blue value into String with all red values. This string is exported in .txt file if user clicks save button
        }
        
        whichStore = whichStore+1; // increment current pattern because a pattern was stored
        
      }
      
      else if(buttonOver2){// RUN BUTTON was clicked
        
        if (runStatePrev ==false){ // RUN patterns! Dodecahedron was not running patterns previously
           
           // update RUN button colors
           buttonRunBaseColor = color(220,0,0); 
           buttonRunBaseHighlight = color(250,250,250);
  
           buttonRunShapeColor = color(250,0,0);
           buttonRunShapeHighlight = color(220,0,0);

           port.write(1); // 0-live display or 1-play sequence (Tell Arduino you want to run sequence)
           port.write(Integer.toString(speed)); // Send speed to Arduino
           port.write('e'); // Required for function on Arduino that converts String to int
           runStatePrev = true; // Switch run state because dodecahedron is running patterns
           
           
        }
        
        else if(runStatePrev==true){ // STOP patterns! Dodecahedron was running patterns previously
          
           port.write("n"); // RUN continues until port writes "n".
           
           // update RUN button colors
           buttonRunBaseColor = color(0,150,0);
           buttonRunBaseHighlight = color(250,250,250);
  
           buttonRunShapeColor = color(0,220,0);
           buttonRunShapeHighlight = color(0,150,0);
           
           runStatePrev = false; // Switch run state because dodecahedron is no longer running pattern         
        }
        
      }
      
     else if(buttonOver3){ //RESET BUTTON 

        port.stop(); // kill serial connection 
        setup();   // run setup
        
      }
      
      else if(buttonOver4){ //SAVE BUTTON
      
        int l1 = r.length();
        r = r.substring(0,l1-2); // trim off last common on r string
        l1 = g.length(); 
        g = g.substring(0,l1-2);  // trim off last common on g string
        l1 = b.length();  
        b = b.substring(0,l1-2); // trim off last common on b string
        
        fileOut = showInputDialog("Save file as (.txt file extension is included):\n"); // diolog box so user can write filename for exporting .txt file with rgb values
        
        // Create string that can be copied into Arduino program to play sequence
        String rgb[]={"#define numberOfPatterns " + str(whichStore),"byte r[numLEDS * numberOfPatterns] = {"+r+"};","byte g[numLEDS * numberOfPatterns] = {"+g+"};","byte b[numLEDS * numberOfPatterns] ={"+b+"};"};
        saveStrings(fileOut+".txt",rgb); // save string
        //port.stop();
        //setup();
        
      }
    }
     
     else if(overCircle(200, 200, 400) & runStatePrev==false) 
     
     { // DODECAHEDRON IS CLICKED and patterns are not running   
           
           cV[pentState] =c; // Store current color in pentagon that is clicked. pentState is set in PentagonUpdate function
           alreadyStored = false; // reset alreadyStored
           for(int p=0;p<10;p++){ // Cycle through colors stored in recent color boxes.    
              if(c==cRecent[p]){ // if the color is already stored in recent color boxes
                alreadyStored = true;
              }
            }
           
           if(newColor && alreadyStored == false){ // if it is a new color and it hasn't already been stored in recent colors          
               cRecent[cRind]=c; // add color to array holding colors that in recent color boxes
               cRind = cRind+1; // increment index for color box array
               
               newColor = false; 
             
               if(cRind>9){ // if recent color boxes are filled, reset index so that new colors are stored at first box in recent color boxes
                 cRind = 0;     
             }
           }
           
           int rT=(c>>16)&255;
           int gT=(c>>8)&255;
           int bT=c&255; 
           port.write(0); // 0-live display or 1-play sequence (Live view of dodecahedron)
           port.write(0); // 0-no store or 1-store (Just displaying colors on dodecahedron, not storing the pattern)
           port.write(pentState); // Tell Arduino which pentagon was clicked
           port.write(rT); // send r value for that pentagon
           port.write(gT); // send g value for that pentagon
           port.write(bT); // send b value for that pentagon
           
      }    
      
}
  
  
void buttonUpdate() {
  if (overCircle(buttonX1, buttonY1, buttonDiameter) ) { // Mouse is over STORE
    buttonOver1 = true;
    buttonOver2 = false;
    buttonOver3 = false;
    buttonOver4 = false;
    
  } else if (overCircle(buttonX2, buttonY2, buttonDiameter) ) { // Mouse is over RUN
    buttonOver1 = false;
    buttonOver2 = true;
    buttonOver3 = false;
    buttonOver4 = false;
    
  } 
  else if (overCircle(buttonX3, buttonY3, buttonDiameter2) ) { // Mouse is over RESET
    buttonOver1 = false;
    buttonOver2 = false;
    buttonOver3 = true;  
    buttonOver4 = false;
  } 
  else if (overCircle(buttonX4, buttonY4, buttonDiameter2) ) { // Mouse is over SAVE
    buttonOver1 = false;
    buttonOver2 = false;
    buttonOver3 = false;  
    buttonOver4 = true;
  } 
  else {
    buttonOver1 = buttonOver2 = buttonOver3 = buttonOver4 = false; // Mouse is not on any buttons
  }
}
 
// Taken from: https://processing.org/examples/rollover.html
boolean overButton(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

// Taken from: https://processing.org/examples/rollover.html
boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

  
// taken from: http://hg.postspectacular.com/toxiclibs/src/tip/src.core/toxi/geom/Polygon2D.java
boolean containsPoint(PVector[] verts, float px, float py) {
  int num = verts.length;
  int i, j = num - 1;
  boolean oddNodes = false;
  for (i = 0; i < num; i++) {
    PVector vi = verts[i];
    PVector vj = verts[j];
    if (vi.y < py && vj.y >= py || vj.y < py && vi.y >= py) {
      if (vi.x + (py - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < px) {
        oddNodes = !oddNodes;
      }
    }
    j = i;
  }
  return oddNodes;
}

void pentagonUpdate(){
  strokeWeight(0);
    // PENTAGON 0
  if(containsPoint(pent0,mouseX,mouseY)) {
    pentState = 0;
    fill(c);
    
  } else {
    fill(cV[0]);
  }
  
  beginShape();
  for(PVector v : pent0) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 0 end
   
  
  // PENTAGON 1
  if(containsPoint(pent1,mouseX,mouseY)) {
    pentState = 1;
    fill(c);
    
  } else {
    fill(cV[1]);
  }
  
  beginShape();
  for(PVector v : pent1) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 1 end
  
  
  // PENTAGON 2
  if(containsPoint(pent2,mouseX,mouseY)) {
    pentState = 2;
    fill(c);
    
  } else {
    fill(cV[2]);
  }
  
  beginShape();
  for(PVector v : pent2) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 2 end
  
  
  // PENTAGON 3
  if(containsPoint(pent3,mouseX,mouseY)) {
    pentState = 3;
    fill(c);
    
  } else {
    fill(cV[3]);
  }
  
  beginShape();
  for(PVector v : pent3) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 3 end
  
    // PENTAGON 4
  if(containsPoint(pent4,mouseX,mouseY)) {
    pentState = 4;
    fill(c);
    
  } else {
    fill(cV[4]);
  }
  
  beginShape();
  for(PVector v : pent4) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 4 end
  
  
  
 // PENTAGON 5
  if(containsPoint(pent5,mouseX,mouseY)) {
    pentState = 5;
    fill(c);
    
  } else {
    fill(cV[5]);
  }
  
  beginShape();
  for(PVector v : pent5) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 5 end
  
  
  // PENTAGON 6
  if(containsPoint(pent6,mouseX,mouseY)) {
    pentState = 6;
    fill(c);
    
  } else {
    fill(cV[6]);
  }
  
  beginShape();
  for(PVector v : pent6) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 6 end
   
  
  // PENTAGON 7
  if(containsPoint(pent7,mouseX,mouseY)) {
    pentState = 7;
    fill(c);
    
  } else {
    fill(cV[7]);
  }
  
  beginShape();
  for(PVector v : pent7) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 7 end
  
  
    
  // PENTAGON 8
  if(containsPoint(pent8,mouseX,mouseY)) {
    pentState = 8;
    fill(c);
    
  } else {
    fill(cV[8]);
  }
  
  beginShape();
  for(PVector v : pent8) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 8 end
  
  
   // PENTAGON 9
  if(containsPoint(pent9,mouseX,mouseY)) {
    pentState = 9;
    fill(c);
    
  } else {
    fill(cV[9]);
  }
  
  beginShape();
  for(PVector v : pent9) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 9 end
  
  
  // PENTAGON 10
  if(containsPoint(pent10,mouseX,mouseY)) {
    pentState = 10;
    fill(c);  
  } else {
    fill(cV[10]);
  }
  
  beginShape();
  for(PVector v : pent10) {
    vertex(v.x,v.y);
  }
  endShape(CLOSE);
  // PENTAGON 10 end

}

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}


// TAKEN from: https://processing.org/examples/scrollbar.html
class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }
   void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }
  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    stroke(0);
    strokeWeight(1);
    fill(150);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(220,220, 220);
    } else {
      fill(40,40, 40);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}



//// RECIEVE SERIAL FROM ARDUINO FOR PRINTING AND TROUBLESHOOTING
//void serialEvent(Serial p) {
//  try {
//    // get message till line break (ASCII > 13)
//    String message = p.readStringUntil(13);
//    // just if there is data
//    if (message != null) {
//      println("message received: "+trim(message));
//    }
//  }
//  catch (Exception e) {
//  }
//}
