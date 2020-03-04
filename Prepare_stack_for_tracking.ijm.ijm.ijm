treatmentstop=569
stop1=treatmentstop-47
stop2=treatmentstop+1
stop3=treatmentstop+48
//makeRectangle(0, 0, 266, 516);
//run("Duplicate...", "duplicate");
//selectWindow("Concatenated Stacks");
//selectWindow("Concatenated Stacks-1");
//rename("Red");
//selectWindow("Concatenated Stacks");
//makeRectangle(266, 0, 266, 516);
//run("Crop");
//rename("Green");
selectWindow("Green")
run("Z Project...", "start="+stop1+" stop="+treatmentstop+" projection=[Average Intensity]");
rename("Ref");
selectWindow("Green");
run("Z Project...", "start="+stop2+" stop="+stop3+" projection=[Average Intensity]");
rename("Drift");
