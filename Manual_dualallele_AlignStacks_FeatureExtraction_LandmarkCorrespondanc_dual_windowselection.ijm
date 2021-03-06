//run("Extract MOPS Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=16 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid");
//run("Extract SIFT Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 filter maximal_alignment_error=25 minimal_inlier_ratio=0.05 minimal_number_of_inliers=7 expected_transformation=Rigid");
//If the first SIFT function didn't find features, or the image is very weak for discrete features using the block matching method for a more coarse extraction or hand picked features using multiple-point tool
//run("Extract Block Matching Correspondences", "source_image=Drift target_image=Ref layer_scale=1 search_radius=50 block_radius=50 resolution=24 minimal_pmcc_r=0.10 maximal_curvature_ratio=1000 maximal_second_best_r/best_r=1 use_local_smoothness_filter approximate_local_transformation=Rigid local_region_sigma=65 maximal_local_displacement=12 maximal_local_displacement=3 export");


//Start the transformation cycle according to the feature extaction
roiManager("Reset");
selectWindow("Drift");
roiManager("Add");
selectWindow("Ref");
roiManager("Add");

//Put in the start frame and end frame pivot.
Dialog.create("Red/Green Correction");
Dialog.addNumber("The start frame:", 0);
Dialog.addNumber("The end frame:", 0);
Dialog.show();
startf = Dialog.getNumber();
endf = Dialog.getNumber();


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




//Put in the start frame and end frame pivot.
Dialog.create("Enter the start frame and end frame for alignment");
Dialog.addNumber("The start frame:", 0);
Dialog.addNumber("The end frame:", 0);
Dialog.show();
startf = Dialog.getNumber();
endf = Dialog.getNumber();

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