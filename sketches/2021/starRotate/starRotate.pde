import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;


int bg = 15;
int fg = 255;
float alpha = 13;
int numStars = 250;
Star[] points;
PGraphics fbo;
// animation
float rot = 0;
float prevRot = 0;
PVector rotCenter;
float duration = 3;
int fps = 60;
float t = 0;
// render info
String outFolder;
boolean render = false;
int outFrameNum = 0;


void setup() {
	size(1000, 1000);
	rotCenter = new PVector(width/3, height * 2/3);
	points = new Star[numStars];
	// make fbo
	fbo = createGraphics(1500, 1500);
	fbo.beginDraw();
	noStroke();
	
	fbo.noStroke();
	for (int i = 0; i < numStars; i++){
		points[i] = new Star(random(1500), random(1500), random(3,15), rotCenter);
		fbo.fill(random(230, 255), random(180, 255));
		// fbo.strokeWeight(points[i].rad/2);
		fbo.circle(points[i].pos.x, points[i].pos.y, points[i].rad);
	}
	fbo.endDraw();
	// stroke(255);
	Ani.init(this);
	smooth();
	frameRate(fps);
}

void update(){
	if (t >= duration*fps){
		return;
	}
	rot = Ani.SINE_IN_OUT.calcEasing(t/(duration*fps), 0, 2*PI, 1);
	t++;
}

void draw() {
	if (render){
		update();
	}
	// draw stars
	fill(255);
	drawFbo();
	// draw faded rectangle
	fill(bg, alpha);
	rect(0,0,width,height);

	prevRot = rot;

	if (render){
		saveFrame("renders/" + outFolder +"/frame" + nf(outFrameNum, 5) + ".tiff");
		outFrameNum++;
	}
}

void drawFbo(){
	int num = 15;
	for (int i =0; i < num; i++){
		pushMatrix();
			translate(rotCenter.x, rotCenter.y);
			float rotVal = lerp(prevRot, rot, float(i)/num);
			// println("rotVal: "+rotVal);
			rotate(rotVal);
			translate(-rotCenter.x, -rotCenter.y);
			image(fbo, 0, 0);
			// rect(100, 100, 100, 100);
		popMatrix();
	}

}

void drawArcs(){
	for (int i = 0; i < numStars; i++){
		// noStroke();
		fill(fg);
		noFill();
		stroke(fg);
		strokeWeight(3);
		// pushMatrix();
		// translate(rotCenter.x, rotCenter.y);
		for (int j = 0; j < 20; j++){
			pushMatrix();
			translate(rotCenter.x, rotCenter.y);
			rotate(lerp(prevRot, rot, i/19));
			translate(-rotCenter.x, -rotCenter.y);
			// circle(points[i].pos.x, points[i].pos.y, points[i].rad);
			// strokeWeight(points[i].rad);
			arc(rotCenter.x, rotCenter.y, points[i].arcRad, points[i].arcRad, prevRot, rot);
			popMatrix();
		}
		// rotate(rot);
		// translate(-rotCenter.x, -rotCenter.y);
		// circle(points[i].pos.x, points[i].pos.y, points[i].rad);
		// popMatrix();
		// noFill();

		// float baseAngle = points[i].origAngle;
		// strokeWeight(points[i].rad/2);
		// stroke(fg);
		// arc(rotCenter.x, rotCenter.y, points[i].arcRad, points[i].arcRad, baseAngle + rot, baseAngle + prevRot + 1);
	} 
}

void mouseReleased(){
	// Ani.to(this, duration, "rot", rot + 2* PI, Ani.SINE_IN_OUT);
	outFolder = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
	render = !render;
	if (render){
		outFrameNum = 0;
		// t = 0;
	}
	// fg = fg == 255 ? bg : 255;
}

class Star{
	PVector pos;
	float rad;
	float origAngle;
	float arcRad;

	Star(float x, float y, float _rad, PVector center){
		pos = new PVector(x,y);
		rad = _rad;
		origAngle = acos(pos.dot(center) / (pos.mag() * center.mag()));
		if (x < center.x) {
			origAngle -= PI;
		}
		if (y < center.y){
			origAngle -= PI/2;
		}

		// println(origAngle);
		arcRad = pos.dist(center) * 2;
	}

}