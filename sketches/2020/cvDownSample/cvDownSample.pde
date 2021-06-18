import gab.opencv.*;
import johnnoonan.sketchFrameExporter.*;
import processing.video.*;

PImage edges, pixelated;
int pixelSize = 12;

Movie sourceVid;
ArrayList<String> sourceFrames;
int frameNum = 0;
String vidPath;
int fps;
//color bg = color(46,51,36);
//color hi = color(141,158,109);


color bg = #C06C84; 
color hi = #FFBC0A;

color[] colors = { #F8B195, #F67280, #C06C84, #6C5B7B, #355C7D };
int bgIndex = 0;
int hiIndex = 0;
int saved = 0;

SketchFrameExporter exporter;

PImage[] animation;

String[] filenames;


OpenCV opencv;

void settings(){
	if (args != null && args.length == 4){
		// get video path
		vidPath = args[0];		
		// get dimensions and fps
		int vidWidth = Integer.parseInt(args[1]);
		int vidHeight = Integer.parseInt(args[2]);
		fps = Integer.parseInt(args[3]);
		println(String.format("video is %dx%d at %d fps", vidWidth, vidHeight, fps));
		size(vidWidth, vidHeight);
	}
	else {
		println("Required command line arguments not supplied: videopath width height fps");
		exit();
	}

}

void setup() {
	// create frame renderer
	exporter = new SketchFrameExporter(this, "data/renders");
	exporter.setExtension(SketchFrameExporter.FileType.TIF);
	// load video
	println("load video: "+ vidPath);
	sourceFrames = new ArrayList<String>();
	File[] files = listFiles(vidPath);
	for (int i = 0; i < files.length; i++) {
		File f = files[i];    
		sourceFrames.add(vidPath + f.getName());
	}
	// sourceVid = new Movie(this, vidPath);
	frameRate(fps);
	
	exporter.startRender();
}

void draw() {
	// while (!sourceVid.available()){
	// 	delay(200);
	// }
	// sourceVid.read();
	// sourceVid.play();
	try {
		PImage currentFrame = getVideoFrame();
	} catch (Exception e) {
		exit();
	}
	
	// sourceVid.pause();
	// image(sourceVid, 0, 0);
	// set color
	
	pixelateImage(pixelSize, currentFrame);
	// image(animation[frame],0,0);
	PImage pixelated = get();
	
	opencv = new OpenCV(this, pixelated);
	opencv.findCannyEdges(20,75);
	edges = opencv.getSnapshot();
	setColorsFromSource(edges, currentFrame);
	// adjustColors(edges);
	image(edges,0,0);

	exporter.renderFrame();
	frameNum++;
}

PImage getVideoFrame(){
	if (frameNum >= sourceFrames.size()){
		exit();
	}
	return loadImage(sourceFrames.get(frameNum));


	// if (sourceVid.available()){
	// 	sourceVid.read();
	// 	return;
	// }
	// else {
	// 	delay(16);
	// 	getVideoFrame();
	// }
}

void setColor(){
	if (hiIndex == (colors.length - 1) && bgIndex == (colors.length -1)){
		exit();
	}
	hiIndex++;
	if (hiIndex >= colors.length){
		hiIndex = 0;
		bgIndex++;
	}
	hi = colors[hiIndex];
	if (bgIndex >= colors.length){
		exit();
		return;
	}
	bg = colors[bgIndex];
	if (hi == bg){
		setColor();
	}
}

void pixelateImage(int pxSize, PImage p) {
	float ratio;
	if (width < height) {
		ratio = height/width;
	}
	else {
		ratio = width/height;
	}
	
	// ... to set pixel height
	int pxH = int(pxSize * ratio);
	
	noStroke();
	for (int x=0; x<width; x+=pxSize) {
		for (int y=0; y<height; y+=pxH) {
			fill(p.get(x, y));
			rect(x, y, pxSize, pxH);
		}
	}
}

void adjustColors(PImage img){
	img.loadPixels();
	for (int x = 0; x < img.width; x++){
		for (int y = 0; y < img.height; y++){
			int loc = x + img.width*y;
			color c = img.pixels[loc];
			if (c == color(0)){
				img.pixels[loc] = bg;
			}
			else{
				img.pixels[loc] = hi;
			}
		}
	}
	img.updatePixels();
}

void setColorsFromSource(PImage bwImg, PImage source){
	source.loadPixels();
	bwImg.loadPixels();
	for (int x = 0; x < bwImg.width; x++){
		for (int y = 0; y < bwImg.height; y++){
			int loc = x + bwImg.width*y;
			color bw = bwImg.pixels[loc];

			if (bw == color(0)){
				// bwImg.pixels[loc] = bg;
			}
			else{
				// bwImg.pixels[loc] = hi;
				float luma = brightness(source.pixels[loc]);
				float perc = luma/255.0;
				bwImg.pixels[loc] = int(hi * perc);
				// bwImg.pixels[loc] = source.pixels[loc];
			}
		}
	}
	bwImg.updatePixels();
}

// void movieEvent(Movie m) {
// 	m.read();
// }


//void makeImage(){
//  // draw image to screen and access it's pixel values
//  image(p, 0, 0);

//  pixelateImage(pixelSize);    // argument is resulting pixel size
	
//  //save("Pixelated" + filename);
	
//  //pixelated = loadImage("Pixelated" + filename);
	
//  PImage pixelated = get();
	
	
//  opencv = new OpenCV(this, pixelated);
//  opencv.findCannyEdges(20,75);
//  edges = opencv.getSnapshot();
//  adjustColors(edges);
//  //colorMode(HSB, 255);          

//  save("./finalVid/pixalated" + filename);
//  image(edges, 0,0);
//}
