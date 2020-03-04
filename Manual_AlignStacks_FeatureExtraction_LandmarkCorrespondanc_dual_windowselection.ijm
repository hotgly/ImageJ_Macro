//Put in the start frame and end frame pivot.
Dialog.create("Enter the start frame and end frame for alignment");
Dialog.addNumber("The start frame:", 0);
Dialog.addNumber("The end frame:", 0);
Dialog.addNumber("Average frames:", 100);
Dialog.addString("The channel used for alignment Green/Red:","Green");
Dialog.show();
startf = Dialog.getNumber();
endf = Dialog.getNumber();
averageframes =Dialog.getNumber();
channel=Dialog.getString();

refavrstart=startf-averageframes;
refavrstop=startf-1;
driftavrstart=startf;
driftavrstop=startf+averageframes-1;
//Make a pair of average images for feature extraction and alignment
//Use either Green or Red as references
selectWindow(channel);
run("Z Project...", "start="+refavrstart+" stop="+refavrstop+" projection=[Average Intensity]");
rename("Ref");
selectWindow(channel);
run("Z Project...", "start="+driftavrstart+" stop="+driftavrstop+" projection=[Average Intensity]");
rename("Drift");
//Adjust B/C before feature extraction, 32bit images are not handled properly by the
//plugin and need to manually set B/C for a successful extraction
//If feature extractions all failed, pick features by hand will be the only way,add to ROI and start below.
selectWindow("Drift");
run("Set Measurements...", "area integrated median area_fraction redirect=None decimal=3");
List.setMeasurements(); 
min=List.getValue("Median");
intden=List.getValue("IntDen");
area=List.getValue("Area")*List.getValue("%Area")/100;
max=intden/area;
run("Brightness/Contrast...");
setMinAndMax(min, (max-min)*9*List.getValue("%Area")/100+min);
selectWindow("Ref");
run("Set Measurements...", "area integrated median area_fraction redirect=None decimal=3");
List.setMeasurements(); 
min=List.getValue("Median");
intden=List.getValue("IntDen");
area=List.getValue("Area")*List.getValue("%Area")/100;
max=intden/area;
run("Brightness/Contrast...");
setMinAndMax(min, (max-min)*9*List.getValue("%Area")/100+min);
/******************/// END point///********************/
/******************/// Pick coordinates manually///********************/
/******************/// Start point2///********************/
//Put in the start frame and end frame pivot.
Dialog.create("Enter the start frame and end frame for alignment");
Dialog.addNumber("The start frame:", 0);
Dialog.addNumber("The end frame:", 0);
Dialog.show();
startf = Dialog.getNumber();
endf = Dialog.getNumber();
//Start the transformation cycle according to the feature extaction
roiManager("Reset");
selectWindow("Drift");
roiManager("Add");
selectWindow("Ref");
roiManager("Add");

//Close display updating
setBatchMode(true);

//Alignment cycle
for(i=startf; i<=endf; i++){ //i=startf, i<=endf
selectWindow("Ref");
roiManager("Select", 1);
selectWindow("Red");
setSlice(i);
run("Copy");
newImage("Red_temp", "32-bit black", 266, 512, 1);
selectWindow("Red_temp");
run("Paste");
roiManager("Select", 0);
run("Landmark Correspondences", "source_image=Red_temp template_image=Ref transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
selectWindow("Red_temp");
close();
selectWindow("TransformedRed_temp");
run("Copy");
close();
selectWindow("Red");
setSlice(i);
run("Paste");
selectWindow("Green");
setSlice(i);
run("Copy");
newImage("Green_temp", "32-bit black", 266, 512, 1);
selectWindow("Green_temp");
run("Paste");
roiManager("Select", 0);
run("Landmark Correspondences", "source_image=Green_temp template_image=Ref transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
selectWindow("Green_temp");
close();
selectWindow("TransformedGreen_temp");
run("Copy");
close();
selectWindow("Green");
setSlice(i);
run("Paste");
}

//Start display updating
setBatchMode(false);
//close temperary windows
selectWindow("Ref");
run("Close");
selectWindow("Drift");
run("Close");