import johnnoonan.sketchFrameExporter.*;

PImage img;
int sX = 200;
int sY = sX;//(int)(.75*sX);
int boxSize;
ArrayList<Chunk> chunks;

float scaleFactor = 1;//.9;
float startPos = PI/45;
float scl = .005;
float noiseSpeed = .01;

boolean drawBars = false;
boolean useNoise = true;

SketchFrameExporter exporter;
boolean startRender = false;
int renderLength = -1;

void settings(){
	if (args != null){
		// get image path
		String imagepath = args[0];
		
		img = loadImage(imagepath);
		println("load image: "+ imagepath + " " + img.width + "x" + img.height);
		size(img.width, img.height);
		if (args.length > 1){
			startRender = Integer.parseInt(args[1]) == 1;
			if (args.length > 2){
				renderLength = (int) (Integer.parseInt(args[2]) * frameRate);
				println("Render " + renderLength + " frames");
			}
		}
	}
	else {
		img = loadImage("flcl1.jpg");
		size(800,600);
	}
}

void setup(){	
	exporter = new SketchFrameExporter(this, "data/renders");
	exporter.setExtension(SketchFrameExporter.FileType.TIF);
	
	boxSize = width/sX;
	
	chunks = new ArrayList<Chunk>();
	for (int x = 0; x < sX; x++){
		for (int y= 0; y < sY; y++){
				chunks.add(new Chunk(boxSize,x,y, startPos));
		}
	}
	noStroke();
	if (startRender){
		exporter.startRender();
	}
	
}


void draw(){
	pushStyle();
	fill(255);
	noStroke();
	rect(0,0,width,height);
	popStyle();
	for (Chunk c : chunks){
		color refColor = img.get(c.x, c.y);
		float b = brightness(refColor);

		c.update(b);
		if (useNoise){
			c.vel = startPos * noise(c.x * scl,c.y * scl, millis()*noiseSpeed);
		}   
		if (b < 10){
			refColor = color(109,139,38);
		}
		fill(refColor);
		c.draw(); 
	}

	exporter.renderFrame();
	if (renderLength > 0 && frameCount > renderLength){
		exit();
	}
}


class Chunk {
	int size;
	int x, y;
	float theta;
	float vel;
	float rad;
	
	Chunk(int _size, int _x, int _y, float _vel){
		this.size = _size;
		this.x = _x*this.size;
		this.y = _y*this.size;
		this.theta = 0;
		this.vel = _vel;
	}
	
	void update(float b){
		this.theta += this.vel;
		this.rad = ((255-b)/255)*this.size* scaleFactor;
	}
	
	void draw(){
		pushMatrix();
		translate(this.x + this.size/2, this.y + this.size/2);
		rotate(this.theta);


		// draw rotating bars about pivot
		if (drawBars){
			rect(-this.rad/2,-this.size/2,this.rad,this.size * scaleFactor);
		}
		else{
			//draw full rect which will pop on full circle
			rect(-this.size, -this.size, this.size*this.rad, this.size);
		}

		
		popMatrix();
	}
}
