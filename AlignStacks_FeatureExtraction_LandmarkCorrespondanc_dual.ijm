//run("Extract MOPS Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=16 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid");
//run("Extract SIFT Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 filter maximal_alignment_error=25 minimal_inlier_ratio=0.05 minimal_number_of_inliers=7 expected_transformation=Rigid");
//If the first SIFT function didn't find features, or the image is very weak for discrete features using the block matching method for a more coarse extraction or hand picked features using multiple-point tool
//run("Extract Block Matching Correspondences", "source_image=Drift target_image=Ref layer_scale=1 search_radius=50 block_radius=50 resolution=24 minimal_pmcc_r=0.10 maximal_curvature_ratio=1000 maximal_second_best_r/best_r=1 use_local_smoothness_filter approximate_local_transformation=Rigid local_region_sigma=65 maximal_local_displacement=12 maximal_local_displacement=3 export");
//selectWindow("Drift");
//roiManager("Add");
//selectWindow("Ref");
//roiManager("Add");
//If feature extractions all failed, pick features by hand will be the only way,add to ROI and start below.
for(i=1818; i<=1819; i++){ //i=startf, i<=endf
selectWindow("Ref");
roiManager("Select", 1);
//selectWindow("Red_520x774");
//setSlice(i+2);
//roiManager("Select", 0);
//run("Landmark Correspondences", "source_image=Red_520x774 template_image=Ref transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
//selectWindow("TransformedRed_520x774");
//run("Copy");
//close();
//selectWindow("Red_520x774");
//run("Paste");
//run("Next Slice [>]");
selectWindow("Green_520x774");
setSlice(i);
roiManager("Select", 0);
run("Landmark Correspondences", "source_image=Green_520x774 template_image=Ref transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
selectWindow("TransformedGreen_520x774");
run("Copy");
close();
selectWindow("Green_520x774");
run("Paste");
run("Next Slice [>]");

}