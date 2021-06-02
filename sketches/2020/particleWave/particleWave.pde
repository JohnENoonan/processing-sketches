import johnnoonan.sketchFrameExporter.*;

// particle data
final int particleNum = 3000;
final float maxParticleSpeed = 1.2;
//maxdistance determined by image size
final int imgSize = 1080;
final float maxDistance = sqrt(2 * imgSize*imgSize);

// noise data
final float minNoiseIncrement = 0.004;
final float maxNoiseIncrement = 0.01;
// value noise cannot go above
final float maxNoiseValue = .02;
//'root' of the noise
float noiseXY;
// value used to increment the noise
float noiseInc;
//noise coefficent to boost values (small # -> less jitter, less random)
float noiseCoef;

// mouse data
final float MAX_DIST_MOUSE_SQUARE = 1000;
final float MAX_DIST_MOUSE = sqrt(MAX_DIST_MOUSE_SQUARE);
Boolean mouseRepels = false;//allows the mouse to repel the maxNoiseValue

// particle container
Vector particles[];

// color and alpha values
float strokeWtCoef = 5; // value used to affect strokeWeight (bigger # -> thicker)
// rectAlph controls ammount of particle trails, smaller alpha -> more visible trails
float rectAlph = 15;

// color offsets
int rOff, gOff, bOff;
PVector baseColor;
int colorOffset = 100;

// render
SketchFrameExporter exporter;
boolean autoSwitch = true;



void setup(){
	size(1080, 1080, P3D);
	background(0);
	initialize();
	exporter = new SketchFrameExporter(this, "data/rawRenders");
	exporter.setExtension(SketchFrameExporter.FileType.TIF);
}

void initialize(){
	// noise used for initial color
	float n; 
	noiseSeed(System.currentTimeMillis());
	// establish continuous random values
	noiseInc = random(-1*maxNoiseValue, maxNoiseValue);
	noiseCoef = random(minNoiseIncrement, maxNoiseIncrement);
	particles = new Vector[particleNum];
	baseColor = new PVector(random(255-colorOffset), random(255-colorOffset), random(255-colorOffset));
	// fill with particles
	for (int i = 0; i < particleNum; i++){
		// assign values
		particles[i] = new Vector();
		// create particle specific noise for color
		n = noise(noiseXY+particles[i].x*noiseCoef, noiseXY+particles[i].y*noiseCoef);
		particles[i].myColor = getColor(n);
	}
}

color getColor(float n){
	PVector out = new PVector(random(colorOffset), random(colorOffset), random(colorOffset)).add(baseColor);
	return color(out.x, out.y, out.z);
}

void draw(){
	// clear screen
	pseudoClear();
	// increment noise
	noiseXY += noiseInc;
	float n; 
	float distMouse;
	float dx;
	float dy;
	
	// animate color trails
	for (int i = 0; i < particleNum; i++){
		// update previous values that came from last run of draw loop to be current
		particles[i].prevUpdate();
		n = noise(noiseXY + particles[i].x*noiseCoef, noiseXY + particles[i].y*noiseCoef);
		// update particle velocities with new noise
		particles[i].updateVelocity(n);
		if (mouseRepels){
			if (distanceSquared(particles[i].x, particles[i].y, mouseX, mouseY) < MAX_DIST_MOUSE_SQUARE) {
				particles[i].repel();
			}
		}
		particles[i].move();

		// check whether particle is inbounds or needs to be redirected
		particles[i].inBounds(n);
		particles[i].display(n);
	}
	exporter.renderFrame();
	if (frameCount % 300 == 0 && autoSwitch){
		// pushStyle();
		// fill(0);
		// noStroke(); 
		// rect(0, 0, width, height);
		// popStyle();
		initialize();
	}
}

// function to clear screen but leave enough for the trails to be visible
void pseudoClear(){
	// clear screen with rectangle to leave particle trails
	pushStyle();
	fill(0, rectAlph);
	noStroke(); 
	rect(0, 0, width, height);
	popStyle();
}

// temporary mouse interaction
void mousePressed(){
	// if left mouse ( someone walks in, re-randomize noise field
	if (mouseButton == LEFT){
		initialize();
	}
	// if someone exits place a disrupting force somewhere
	else if (mouseButton == RIGHT){
		mouseRepels = true;
	}
}

void keyPressed(){
	if (key == ' '){
		if (exporter.isRendering()){
			exporter.stopRender();
		}
		else {
			exporter.startRender();
		}		
	}
}

void mouseReleased() {  
	mouseRepels = false;
}

float distanceSquared(float x1, float y1, float x2, float y2){
	return pow((x2 - x1), 2) + pow((y2 - y1), 2);
}

// class to store particle info. Child of PVector
class Vector extends PVector{
	/* Vector will inherit a PVector used to store x,y coord. Also stores color and
	 prev value in case an illegal movement is made and must be corrected
	 as well as to create motion line */
	color myColor;
	PVector vel, prev;
	
	// constructor funtion
	Vector (){
		// init PVector in parent class
		super(random(width), random(height));
		// assign original arbitrary velocity values
		vel = new PVector(0,0);
		// init previous values to be original incase the first movement goes out of bounds
		prev = new PVector(x,y);
	}
	
	// assign current value to stored previous values
	void prevUpdate(){
		prev.x = x;
		prev.y = y;
	}
	
	// update velocity given the newly created noise value from the draw loop
	void updateVelocity(float noise){
		noise *= .5;
		vel.x = (noise * TWO_PI)*maxParticleSpeed;//-.8*cos(noise * TWO_PI)*maxParticleSpeed;
		vel.y = (noise * TWO_PI)*maxParticleSpeed;//2*sin(noise * TWO_PI)*maxParticleSpeed;
	}
	
	// add velocity to position
	void move(){
		x += vel.x;
		y += vel.y;
	}
	
	// check whether particle is inbounds of screen
	void inBounds(float n){
		// if the particle is out of bounds
		if ((x < 0) || (x >= width) || (y < 0) || (y >= height)){
			//prevents from reappearing inside the mouse influence
			float theta = random(TWO_PI);
			// reset coordinates to before they were moved in the current draw loop
			x = prev.x = random(width) - random(0, maxDistance)*cos(theta);
			y = prev.y = random(height) - random(0, maxDistance)*sin(theta);
			n = noise(noiseXY + x*noiseCoef, noiseXY + y*noiseCoef);
			myColor = getColor(n);
		}
	}

	void repel(){
		PVector newvel = new PVector(x - mouseX, y - mouseY);
		newvel.normalize();
		newvel.mult(vel.mag());
		vel = newvel;
		x = mouseX + vel.x * MAX_DIST_MOUSE_SQUARE;
		y = mouseY + vel.y * MAX_DIST_MOUSE_SQUARE;
		this.prevUpdate();
	}
	
	// limit randomness to stay within bounds.
	void constrainVelocity(){
		vel.x = constrain(vel.x, -1*maxParticleSpeed, maxParticleSpeed);
		vel.y = constrain(vel.y, -1*maxParticleSpeed, maxParticleSpeed);
	}
	
	// draw line that will create motion given noise
	void display(float noise){
		// color each particle individually 
		pushStyle();
		fill(myColor);
		// storke weight is determined by average velocity
		strokeWeight(((pow(vel.x, 2) + pow(vel.y, 2))/2)*noise*strokeWtCoef);
		stroke(myColor, 50);
		line(prev.x, prev.y, x, y);
		popStyle();
	}
}
