// begin macro 
file = File.openDialog("Select the text file to read"); 
allText = File.openAsString(file); 
text = split(allText, "\n"); 
hdr = split(text[0]); 

//these are the column indices 
iX = 0; 
iY = 1; 
iLabel = 2; 

//setForegroundColor(255,255,255); 

//run("Blobs (25K)"); 

for (i = 1; i < (text.length); i++){ 
   line = split(text[i]); 
   drawString(line[iLabel], parseInt(line[iX]), parseInt(line[iY])); 
} 
// end macro 