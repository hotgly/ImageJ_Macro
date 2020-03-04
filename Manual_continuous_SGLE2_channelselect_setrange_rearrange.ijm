//First input window, to acquite initial condition
Dialog.create("How many driftings occur here?");
Dialog.addNumber("The number of drifing occurance", 0);
Dialog.show();
driftnumber = Dialog.getNumber();
//Second input window, to acquite each point of drift
driftstart=newArray(driftnumber+2);//Add start frame and endframe into the array, 02/26/2020
label=newArray(driftnumber+2);
rotation="direction";
channel="color";
camera="SGLE";
Dialog.create("Put in the values");
label[0]="Previous drift starts at frame:";
Dialog.addNumber(label[0], 1);
for(i=1; i<=driftnumber; i++){
	label[i]="Drifting"+i+" occurs at frame:";
	Dialog.addNumber(label[i], 0);
  }
label[driftnumber+1]="Total frame number:";
selectWindow("Green");
Dialog.addNumber(label[driftnumber+1], nSlices);
Dialog.addString("Rotate left or right L/R:",rotation);
Dialog.addString("The channel used for alignment Green/Red:",channel);
Dialog.show();
driftstart[0] = Dialog.getNumber();
Message="Previous drift starts at frame "+driftstart[0]+";";
Message=Message+"The fragments are: ";
for(i=1; i<=driftnumber; i++){
	driftstart[i] = Dialog.getNumber();
	Message=Message+"Drift"+i+" is frame "+driftstart[i]+"; ";
  }
driftstart[driftnumber+1] = nSlices+1;//The imagniery drift next to the last 
rotation=Dialog.getString();
channel=Dialog.getString();
//Show confirmational message
Message=Message+"Stack ends at frame "+nSlices+"; "+channel+" images are used for alignment; Will rotate "+rotation+" to correct direction";
showMessage(Message);
//Determine the minimum gap for B/C adjustment during correspondance guided image transformation
function mingap(indrift,tempmingap){
    pregap = driftstart[indrift]-driftstart[indrift-1];
    postgap = driftstart[indrift+1]-driftstart[indrift];
	if(pregap<postgap) lowgap=pregap;
	else lowgap=postgap;
	if(lowgap<tempmingap) return lowgap;
	return tempmingap;
}
//Alignment cycles, from the first drift(not the first frame) to the endframe.
for(i=1; i<=driftnumber; i++){
	//start with continuing from the image windows left by the previous unsuccessful automatic alighment
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
	//Open display updating.
	setBatchMode(false);
	//close temperary windows
	selectWindow("Ref");
	run("Close");
	selectWindow("Drift");
	run("Close");
	//Break the loop if reaching the last drift to avoid overflowing endframe
	if(i==driftnumber) break;
	//Prepare frame points needed for drift and ref images
	refavrstart=driftstart[i+1]-mingap(i+1,100);
	refavrstop=driftstart[i+1]-1;
	driftavrstart=driftstart[i+1];
	driftavrstop=driftstart[i+1]+mingap(i+1,100)-1;
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





