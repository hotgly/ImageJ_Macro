//Remove crosstalk, especially for images with high-ratio green cells like NMS
tormcr = "No";
Dialog.create("Remove green-to-red crosstalk ?");
Dialog.addString("Yes/No", tormcr);
Dialog.addNumber("Background vale:",600);
Dialog.addNumber("Crosstalk ratio (SGLE3=0.14, SGLE2=0.2):",0.2);
Dialog.show();
tormcr = Dialog.getString();
Bg = Dialog.getNumber();
Cr = Dialog.getNumber();

if(tormcr=="Yes"){
Message= "Background is " + Bg + "; Crosstalk ratio is " + Cr ;
showMessage(Message);
//Image calculation
selectWindow("Green");
run("Duplicate...", "duplicate");
selectWindow("Green-1");
run("Subtract...", "value="+Bg+" stack");
run("Multiply...", "value="+Cr+" stack");
imageCalculator("Subtract 32-bit stack", "Red","Green-1");
selectWindow("Green-1");
close();
}

//Read rotaion information
rotation="No Change";
Dialog.create("Put in the values");
Dialog.addString("Rotate left or right L/R:",rotation);
Dialog.show();
  rotation=Dialog.getString();
  Message="The rotation will be(L/R):"+rotation;
showMessage(Message);


//Make 96frame running average, fill 95frames to the end of RunAv
selectWindow("Green");
run("Running ZProjector", "running=96 projection=[Average Intensity]");
setSlice(nSlices);
run("Copy");
for(k=1; k<=95; k++){
run("Add Slice");
run("Paste");
}
selectWindow("Red");
run("Running ZProjector", "running=96 projection=[Average Intensity]");
setSlice(nSlices);
run("Copy");
for(k=1; k<=95; k++){
run("Add Slice");
run("Paste");
}

//Rotate 
if(rotation=="R"){
selectWindow("Red-RunAv(96)");
run("Rotate 90 Degrees Right");
selectWindow("Red");
run("Rotate 90 Degrees Right");
selectWindow("Green-RunAv(96)");
run("Rotate 90 Degrees Right");
selectWindow("Green");
run("Rotate 90 Degrees Right");
}
if(rotation=="L"){
selectWindow("Red-RunAv(96)");
run("Rotate 90 Degrees Left");
selectWindow("Red");
run("Rotate 90 Degrees Left");
selectWindow("Green-RunAv(96)");
run("Rotate 90 Degrees Left");
selectWindow("Green");
run("Rotate 90 Degrees Left");
}

//Merge
run("Merge Channels...", "c1=Red-RunAv(96) c2=Red c3=Green-RunAv(96) c4=Green create");

