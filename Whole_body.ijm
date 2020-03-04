makeRectangle(0, 0, 347, 519);
run("Duplicate...", "title=Liver_green duplicate");
selectWindow("Concatenated Stacks");
makeRectangle(347, 0, 347, 519);
run("Crop");
rename("Red_body");
run("Merge Channels...", "c1=Red_body c2=Liver_green create");


