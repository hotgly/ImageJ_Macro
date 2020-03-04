//Draw 120x32 square for time stamp below and another for Titile.
//Font 32, 0.25hrs. Title font 30.
start= 2 ;// treatment Slice(n)//
end = 610 ;// end treatment Slice(n)//

for (i=start;i<=end;i++) { 
	setSlice(i);
         run("Draw", "slice");        
}