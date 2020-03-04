
newImage("Green", "16-bit black", 60, 60, 1000);
newImage("Red", "16-bit black", 60, 60, 1000);
selectWindow("ImageCluster_00");
for (i=0; i<1001; i++) {
makeRectangle(280, 300, 60, 60);
run("Copy");
selectWindow("Green");
run("Paste");
run("Next Slice [>]");
selectWindow("ImageCluster_00");
makeRectangle(920, 300, 60, 60);
run("Copy");
selectWindow("Red");
run("Paste");
run("Next Slice [>]");
selectWindow("ImageCluster_00");
run("Next Slice [>]");
}


