
//Import all image series from the treatment, 
//concatenate in correct sequence and then put in the drift occurance, frame pivots and direction of rotation below;
imageName = getTitle();
Dialog.create("How many driftings occur here?");
Dialog.addNumber("The number of drifing occurance", 0);
Dialog.addString("Which image to work on:",imageName);
Dialog.show();
driftnumber = Dialog.getNumber();
imageName = Dialog.getString();
endnumber=driftnumber+1;

driftstart=newArray(endnumber);
label=newArray(endnumber);
rotation="direction";
channel="color";
camera="SGLE";
Dialog.create("Put in the values");
for(i=1; i<=driftnumber; i++){
	label[i-1]="Drifting"+i+" occurs at frame:";
	Dialog.addNumber(label[i-1], 0);
  }
label[driftnumber]="Total frame number:";
Dialog.addNumber(label[driftnumber], 0);
Dialog.addString("Which camera:",camera);
Dialog.addString("Rotate left or right L/R:",rotation);
Dialog.addString("The channel used for alignment Green/Red:",channel);
Dialog.show();

Message="The fragments are: ";
for(i=1; i<=driftnumber; i++){
	driftstart[i-1] = Dialog.getNumber();
	Message=Message+"Drift"+i+" is frame "+driftstart[i-1]+"; ";
  }
  driftstart[driftnumber] = Dialog.getNumber()+1;
  camera=Dialog.getString();
  rotation=Dialog.getString();
  channel=Dialog.getString();
  Message=Message+"Stack ends at frame "+(driftstart[driftnumber]-1)+"; "+channel+" images are used for alignment; Will rotate "+rotation+" to correct direction";
showMessage(Message);

//Channel names swtiched in SGLE1
color1="Green";
color2="Red";
if(camera=="SGLE1"){
	color1="Red";
	color2="Green";
}

//TODO sort the images based on driftstart sequence, sort driftstart to segmentate the series, and then reorganize the segements based on the drift number
//Using a priotity queue
/*while(switch==true){
	switch=false;
	for(i=0; i<driftnumber-1; i++){
		if(driftstart[i] > diftsart[i+1]){
			temp = driftstart[i];
			driftstart[i] = diftstart[i+1];
			driftstart[i+1] = temp;
			switch=true;
		}
	}
}
*/

for(i=0, i<driftnumber-1;i++){
	if(driftstart[i]>driftstart[i+1]){
		//Look for the end of drift start[i]
		next = findnext(i);
		}
		driftstart[i]=driftstart[i+1];
		for(k=driftstart[i+1]-1;k<next-1;k++){
			selectWindow(imageName);
			setSlice(next);
			run("Copy");
			run("Delete Slice");
			setSlice(k);
			run("Add Slice");	
			run("Paste");
		}//move segment over
		for(l=i+1;i<driftnumber;l++){
			driftstart[l]+=next-driftstart[i+1];
		}		
	}
}

function findnext(indriftnumber){
	tempnext=driftstart[driftnumber];// start with the endframe
		for(j=indriftnumber+2; j<driftnumber; j++){
			if(dirftstart[indriftnumber]<driftstart[j]&&next>driftstart[j]){
				tempnext=driftstart[j];//find the end/junction point				
				}
			}
	return tempnext;
}

//Crop and split the concatenated stacks, star out this section if doing manual alighment after the image split
selectWindow(imageName);
run("Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
makeRectangle(0, 0, 266, 516);
run("Duplicate...", "duplicate");
selectWindow(imageName + "-1");
rename(color1);
selectWindow(imageName);
makeRectangle(266, 0, 266, 516);
run("Crop");
rename(color2);



//Close display updating
setBatchMode(true);

//Alignment cycles
for(i=1; i<=driftnumber; i++){
	
//Prepare frame points needed for drift and ref images
//48-frame average or 60-frame average
refavrstart=driftstart[i-1]-100;
refavrstop=driftstart[i-1]-1;
driftavrstart=driftstart[i-1];
driftavrstop=driftstart[i-1]+100;

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

run("Extract SIFT Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 filter maximal_alignment_error=25 minimal_inlier_ratio=0.05 minimal_number_of_inliers=7 expected_transformation=Rigid");
//If the first SIFT function didn't find features, or the image is very weak for discrete features using the block matching method for a more coarse extraction or hand picked features using multiple-point tool
//MOPS works badly and output some wrong coordinates sometimes, neglect this and use next step if SIFT doesn't work// run("Extract MOPS Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=16 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid");
//Better to switch to manual pick here// run("Extract Block Matching Correspondences", "source_image=Drift target_image=Ref layer_scale=1 search_radius=50 block_radius=50 resolution=24 minimal_pmcc_r=0.10 maximal_curvature_ratio=1000 maximal_second_best_r/best_r=1 use_local_smoothness_filter approximate_local_transformation=Rigid local_region_sigma=65 maximal_local_displacement=12 maximal_local_displacement=3 export");


//Start the transformation cycle according to the feature extaction
roiManager("Reset");
selectWindow("Drift");
roiManager("Add");
selectWindow("Ref");
roiManager("Add");

for(j=driftstart[i-1]; j<=(driftstart[i]-1); j++){
selectWindow("Ref");
roiManager("Select", 1);
selectWindow("Red");
setSlice(j);
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
setSlice(j);
run("Paste");
selectWindow("Green");
setSlice(j);
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
setSlice(j);
run("Paste");
}

//close temperary windows
selectWindow("Ref");
run("Close");
selectWindow("Drift");
run("Close");
}

//Open display updating.
setBatchMode(false);

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
selectWindow("Green-RunAv(96)");
run("Rotate 90 Degrees Right");
selectWindow("Green");
run("Rotate 90 Degrees Right");
selectWindow("Red-RunAv(96)");
run("Rotate 90 Degrees Right");
selectWindow("Red");
run("Rotate 90 Degrees Right");
}
if(rotation=="L"){
selectWindow("Green-RunAv(96)");
run("Rotate 90 Degrees Left");
selectWindow("Green");
run("Rotate 90 Degrees Left");
selectWindow("Red-RunAv(96)");
run("Rotate 90 Degrees Left");
selectWindow("Red");
run("Rotate 90 Degrees Left");
}

//Merge
run("Merge Channels...", "c1=Red-RunAv(96) c2=Red c3=Green-RunAv(96) c4=Green create");





