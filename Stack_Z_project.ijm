//Get parameters
endf = nSlices;
Dialog.create("Enter the start frame and end frame for minmum Z project");
Dialog.addNumber("The start frame:", 1);
Dialog.addNumber("The end frame:", endf);
Dialog.addNumber("How many frames to merge:", 2);
Dialog.show();
startf = Dialog.getNumber();
endf = Dialog.getNumber();
nf = Dialog.getNumber();

//Prepare space
rename("source");
run("Duplicate...", "title=target");

//Close display updating
setBatchMode(true);

//Alignment cycle
for(i=startf; i<=endf-nf+1; i++){ //i=startf, i<=endf
selectWindow("source");	
setSlice(i);
 j = i+nf-1;
run("Z Project...", "start="+ i +" stop=" + j + " projection=[Min Intensity]");
run("Copy");
selectWindow("target");
setSlice(i);
run("Paste");
if(i<=endf-nf){
                 run("Add Slice");
                }
}

//Adjust display
run("Set Measurements...", "modal min redirect=None decimal=3");
List.setMeasurements(); 
min=List.getValue("Mode");
maximum=List.getValue("Max");
max=min+2*(maximum-min);
run("Brightness/Contrast...");
setMinAndMax(min, max);

//Start display updating
setBatchMode(false);