//Import all image series from the treatment, 
//concatenate in correct sequence and then put in the drift occurance, frame pivots and direction of rotation below;
//First input window, to acquire the drift numbers and imagewindowname
imageName = getTitle();
if(indexOf(imageName,".")!=-1){
	imageName=substring(imageName,0,indexOf(imageName,"."));
	rename(imageName);
}
Dialog.create("How many driftings occur here?");
Dialog.addNumber("The number of drifing occurance", 0);
Dialog.addString("Which image to work on:",imageName);
Dialog.show();
driftnumber = Dialog.getNumber();
imageName = Dialog.getString();
//Second input window, to acquite each point of drift
driftstart=newArray(driftnumber+2);//Add start frame and endframe into the array, 02/26/2020
label=newArray(driftnumber+2);
rotation="direction";
channel="color";
camera="SGLE";
Dialog.create("Put in the values");
label[0]="Image starts at frame:";
Dialog.addNumber(label[0], 1);
for(i=1; i<=driftnumber; i++){
	label[i]="Drifting"+i+" occurs at frame:";
	Dialog.addNumber(label[i], 0);
  }
label[driftnumber+1]="Total frame number:";
Dialog.addNumber(label[driftnumber+1], nSlices);
Dialog.addString("Which camera:",camera);
Dialog.addString("Rotate left or right L/R:",rotation);
Dialog.addString("The channel used for alignment Green/Red:",channel);
Dialog.show();
driftstart[0] = Dialog.getNumber();
Message="Image starts at frame "+driftstart[0]+";";
Message=Message+"The fragments are: ";
for(i=1; i<=driftnumber; i++){
	driftstart[i] = Dialog.getNumber();
	Message=Message+"Drift"+i+" is frame "+driftstart[i]+"; ";
  }
driftstart[driftnumber+1] = nSlices+1;//The imagniery drift next to the last 
camera=Dialog.getString();
rotation=Dialog.getString();
channel=Dialog.getString();
//Show confirmational message
Message=Message+"Stack ends at frame "+nSlices+"; "+channel+" images are used for alignment; Will rotate "+rotation+" to correct direction";
showMessage(Message);
//Channel names swtiched in SGLE1
color1="Green";
color2="Red";
if(camera=="SGLE1"){
	color1="Red";
	color2="Green";
}
//Close display for speed
setBatchMode(true);
//Define the function to find the next junction point of current fragment, the minimum bigger driftstart number
function findnextdrift(indriftnumber){
	index=driftnumber+1;//start from the endframe
		for(j=indriftnumber+1; j<=driftnumber; j++){
			if(driftstart[indriftnumber]<driftstart[j]&&driftstart[index]>driftstart[j]){
				index=j; 						
				}
			}
	return index;
}
//Define the function for moving the current fragment to the tail of the well-arranged leading frames,
//Reindex all the frames affected by the moving, driftstart>currentstart will not be affected
//Close display updating
//Prepare file for output drift history
framename=newArray(driftnumber+1);
//Rearranging from frame #1
for(i=0;i<=driftnumber;i++){
	startframe=1;
	//Keep framename as a history
	setSlice(driftstart[i]);		
	framename[i]=getInfo("image.subtitle");
	//Find the start frame for moving in
	if(i>0){		
		newstart=findnextdrift(i-1);
		startframe=driftstart[newstart];
	}
	//Conditional moving, if the startframe is current position, no moving and go to next drift
	if(startframe!=driftstart[i]) {
		//Find the end for moving out	
		nextdrift = findnextdrift(i);
		steps = driftstart[nextdrift]-driftstart[i];
		//Move frames
		for(j=0;j<steps;j++){
			selectWindow(imageName);
			setSlice(driftstart[i]+j);
			run("Copy");
			run("Delete Slice");
			if(startframe+j-1==0){
				setSlice(1);
				run("Add Slice");
				run("Paste");
				Stack.swap(1,2);					
			}
			else {
				setSlice(startframe+j-1);
				run("Add Slice");	
				run("Paste");
			}		
		}
		//Move affected index forward to accommodate the inserted slices
		for(k=i+1;k<=driftnumber;k++){
			if(driftstart[k]<driftstart[i]){
				driftstart[k]=driftstart[k]+steps;
			}
		}
		//Update index of moved frames
		driftstart[i]=startframe;
	}
}
// chose file name for exporting
fileName = File.openDialog("Select the file for export");
// export as CSV file
for(i=0; i<=driftnumber; i++) {
    setResult("DriftEvent", i, framename[i]);
    setResult("DriftStart", i, driftstart[i]);
    setResult("DriftEnd", i, driftstart[i+1]-1);
}
updateResults();
saveAs("Results", fileName+".csv"); 
//Determine the min gap for B/C adjustment during correspondance guided image transformation
function mingap(indrift,tempmingap){
    pregap = driftstart[indrift]-driftstart[indrift-1];
    postgap = driftstart[indrift+1]-driftstart[indrift];
	if(pregap<postgap) lowgap=pregap;
	else lowgap=postgap;
	if(lowgap<tempmingap) return lowgap;
	return tempmingap;
}
//Crop and split the concatenated stacks, star out this section if doing manual alighment after the image split
selectWindow(imageName);
run("Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
//Open the display to have both Red and Green, and ref and drift windows
setBatchMode(false);
makeRectangle(0, 0, 266, 516);
run("Duplicate...", "duplicate");
selectWindow(imageName + "-1");
rename(color1);
selectWindow(imageName);
makeRectangle(266, 0, 266, 516);
run("Crop");
rename(color2);
//Alignment cycles, from the first drift(not the first frame) to the endframe.
for(i=1; i<=driftnumber; i++){
	//Prepare frame points needed for drift and ref images
	refavrstart=driftstart[i]-mingap(i,100);
	refavrstop=driftstart[i]-1;
	driftavrstart=driftstart[i];
	driftavrstop=driftstart[i]+mingap(i,100)-1;
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
	//Spread the image windows for better visual
	run("Tile");
	selectWindow("Red");
	selectWindow("Green");
	selectWindow("Ref");
	selectWindow("Drift");
	roiManager("Reset");
	selectWindow("Drift");
	roiManager("Add");
	selectWindow("Ref");
	roiManager("Add");
	//Close display to save memoty and time.
	setBatchMode(true);
	for(j=driftstart[i]; j<=(driftstart[i+1]-1); j++){
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
	setBatchMode(false);
	//close temperary windows
	selectWindow("Ref");
	run("Close");
	selectWindow("Drift");
	run("Close");
}
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