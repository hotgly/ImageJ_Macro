setBatchMode(true);
for(i=1336; i<=2078; i++){
selectWindow("Red-1");
setSlice(2+i-1336);
run("Select All");
run("Copy");
selectWindow("Red");
setSlice(i);
run("Paste");
selectWindow("Green-1");
setSlice(2+i-1336);
run("Select All");
run("Copy");
selectWindow("Green");
setSlice(i);
run("Paste");
}


