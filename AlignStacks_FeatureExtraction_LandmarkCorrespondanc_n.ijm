//run("Extract SIFT Correspondences", "source_image=Drift target_image=Ref initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 filter maximal_alignment_error=25 minimal_inlier_ratio=0.05 minimal_number_of_inliers=7 expected_transformation=Rigid");
//If the first SIFT function didn't find features, using the block matching method for a more coarse extraction or hand picked features using multiple-point tool
//run("Extract Block Matching Correspondences", "source_image=Drift target_image=Ref layer_scale=1 search_radius=50 block_radius=50 resolution=24 minimal_pmcc_r=0.10 maximal_curvature_ratio=1000 maximal_second_best_r/best_r=1 use_local_smoothness_filter approximate_local_transformation=Rigid local_region_sigma=65 maximal_local_displacement=12 maximal_local_displacement=3 export");
//selectWindow("Drift");
//roiManager("Add");
//selectWindow("Ref");
//roiManager("Add");
for(i=1; i<93; i++){
selectWindow("Ref");
roiManager("Select", 1);
selectWindow("062416");
roiManager("Select", 0);
run("Landmark Correspondences", "source_image=062416 template_image=Ref transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
selectWindow("Transformed062416");
run("Copy");
close();
selectWindow("062416");
run("Paste");
run("Next Slice [>]");
}