for(i=1; i<4; i++){
run("Landmark Correspondences", "source_image=062816 template_image=062716con0004.tif transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Rigid interpolate show_matrix");
selectWindow("Transformed062816");
run("Copy");
close();
selectWindow("output");
run("Paste");
run("Next Slice [>]");
selectWindow("062816");
run("Next Slice [>]");}