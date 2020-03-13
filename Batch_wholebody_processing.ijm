// This Macro opens a directory, and also reaches all levels subdirectory,import data stamp and image sequence and output the signal and date records.
importDir = getDirectory("Choose the Parent Directory containing all but images for this experiment:");
importDirName = File.getName(importDir);
//Input the device parameter
Dialog.create("Select the imaging device:");
Dialog.addString("Which imaging device is used? ","Piper1");
Dialog.show();
deviceName = Dialog.getString();
//Get ready for record data
run("Close All");
if(isOpen("Results")) run("Clear Results");
run("Set Measurements...", "mean integrated redirect=None decimal=3");
//start the processing piperline
setBatchMode(true);
processFolder(importDir, 0);
setBatchMode("exit and display");
//Select file for saving the records
csvName = File.openDialog("Select the file for export");
saveAs("Results", csvName+".csv");
//Select file for saving images
run("Merge Channels...", "c1="+importDirName+"_Red"+" c2="+importDirName+"_Green create");
stackName = File.openDialog("Select the file for export");
selectWindow("Composite");
saveAs("Tiff", stackName+".tif");
//Recursive function to scan all sub-directories
function processFolder(imageDir, inframe) {
	frame = inframe;
    //IJ.log("processing directory " + imageDir);
    imageList = getFileList(imageDir);    
    for (i = 0; i < imageList.length; i++) {
		if(File.isDirectory(imageDir + imageList[i]))   //if it's a directory, go to subfolder
		frame = processFolder(imageDir + imageList[i], frame);            
		else if(endsWith(imageDir + imageList[i], ".tiff") || endsWith(imageDir + imageList[i], ".tif") || 
		        endsWith(imageDir + imageList[i], ".FIT") || endsWith(imageDir + imageList[i], ".TIF"))   //if it's an expected image type, process it
		frame = processFile(imageDir, imageList[i], frame);
    }
    return frame;
}
//Get file name and time stamp
function processFile(imageDir, imageFile, inframe) {
	frame = inframe;	
	//IJ.log("processing file " + imageFile);
	open(imageDir + imageFile);
	frame ++;
	//Split image and record the signal
	setResult("Frame", frame-1, frame);
	setResult("FrameName", frame-1, imageFile); 
	setResult("DateModified", frame-1, File.dateLastModified(imageDir+imageFile)); 
	processImage(imageFile, frame);
	updateResults();		
	return frame;
}	
//Crop and split the concatenated stacks
function processImage(imageFile, inframe){
	frame = inframe;
	Channel1 = "_Green";
	Channel2 = "_Red";
	if(deviceName == "Piper2") {
		Channel1 = "_Red";
		Channel2 = "_Green";

	}
    //Crop and copy left channel into image series
	selectWindow(imageFile);
	makeRectangle(0, 0, 320, 512);
	List.setMeasurements()
	greenSignal = List.getValue("Mean"); 
	run("Copy");
	if(!isOpen(importDirName + Channel1)){
		newImage(importDirName + Channel1, "16-bit black", 320, 512, 1);
		run("Paste");
	}
	else {
		selectWindow(importDirName + Channel1);
		run("Add Slice");
		run("Paste");
	}
    //Crop and copy right channel into image series
	selectWindow(imageFile);
	makeRectangle(320, 0, 320, 512);
	List.setMeasurements();
	redSignal = List.getValue("Mean");
	run("Copy");
	if(!isOpen(importDirName + Channel2)){
		newImage(importDirName + Channel2, "16-bit black", 320, 512, 1);
		run("Paste");
	}
	else {
		selectWindow(importDirName + Channel2);
		run("Add Slice");
		run("Paste");
	}
	//Close original image to save memory
	selectWindow(imageFile);
	close();
	//Record brightness signal
	if(deviceName == "Piper2") {
		temp = greenSignal;
		greenSignal = redSignal;
		redSignal = temp;
	}
	setResult("Green signal", frame-1, greenSignal);
	setResult("Red signal", frame-1, redSignal);
}

