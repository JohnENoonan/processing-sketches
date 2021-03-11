import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;


int bg = 15;
int fg = 255;
float alpha = 20;
int numStars = 200;
Star[] points;
float rot = 0;
float prevRot = 0;
PVector rotCenter;
float duration = 3;


void setup() {
	size(1005, 1005);
	rotCenter = new PVector(width/3 * 2, height/3);
	points = new Star[numStars];
	for (int i = 0; i < numStars; i++){
		points[i] = new Star(random(1500), random(1500), random(3,15), rotCenter);
	}
	
	// noStroke();
	stroke(255);
	Ani.init(this);
	smooth();
}

void draw() {
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
	fill(bg, alpha);
	rect(0,0,width,height);
	// println(rot, prevRot);
	prevRot = rot;
	// strokeWeight(points[0].rad);
	// arc(rotCenter.x, rotCenter.y, points[0].arcRad, points[0].arcRad, points[0].origAngle, points[0].origAngle + 1);
}

void mouseReleased(){
	Ani.to(this, duration, "rot", rot + 2* PI, Ani.SINE_IN_OUT);
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

		println(origAngle);
		arcRad = pos.dist(center) * 2;
	}

}