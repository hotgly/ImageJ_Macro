// This Macro opens a directory, gets the dateand time of modification of each image and then save into a CSV file.

myDir = getDirectory("Choose a Directory");
listCSV(myDir);

function listCSV(imageDir){
	imageList = getFileList(imageDir);
	j = 0;
	for (i=0; i<imageList.length; i++) {
		        if (endsWith(imageList[i], ".tiff") || endsWith(imageList[i], ".tif") || endsWith(imageList[i], ".FIT")){
		        	setResult("Frame", i, i+1);
		        	setResult("DateModified", i, File.dateLastModified(imageDir+imageList[i])); 
		        	j++;
		        }
  	}
  	if(j == 0) exit("There is no image in this directory");
  	updateResults();
  	fileName = File.openDialog("Select the file for export");
  	saveAs("Results", fileName+".csv");	
}
