
//Crop and split the concatenated stacks
selectWindow("ImageCluster");
makeRectangle(0, 0, 688, 1038);
run("Duplicate...", "duplicate");
selectWindow("ImageCluster-1");
rename("Green");
selectWindow("ImageCluster");
makeRectangle(688, 0, 688, 1038);
run("Crop");
rename("Red");



//Merge
run("Merge Channels...", "c1=Red c2=Green create");





