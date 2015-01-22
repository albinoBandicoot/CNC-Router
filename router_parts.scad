in=25.4;
include <utils.scad>

gusset_len = 135;
module angle_gusset () {
	scale([1,1,-1]) translate ([0,0,-6]) import ("angle_gusset.stl");
}

module t_gusset () {
	translate ([0,0,6]) import ("t_gusset.stl");
}

module extrusion (len, center=false) {
	scale([1,1, len/(24*in)]) translate([0,0, center ? 0 : 12*in]) import ("extrusion.stl");
}

module ballnut_holes () {
	for (i=[-1:1], j=[-1,1]) {
		rotate (i*45) translate ([19*j,0]) children();
	}
}

module ballnut () {
	color ("grey") {
		linear_extrude (height=10.36) {
			difference () {
				intersection () {
					circle (48.2/2);
					square ([100,40], center=true);
				}
				ballnut_holes () circle (r=5.6/2);
				circle (8);
			}
		}
		tube (ht=42.5, od=28, id=16);
	}
}

module ballnut_mount_bracket (len=75, screw_offset = 27) {
	difference () {
		translate ([0,-0.188*in, screw_offset]) rotate ([0,90,0]) linear_extrude (height=len, center=true, convexity=4) {
			L (2*in, 2*in, 0.188*in, 0.188*in);
		}
		rotate ([90,0,0]) {
			ballnut_holes() hole (5);
				hole (20);
		}
		dup ([len-15, 0,0]) {
			translate ([0,10,0]) linear_pattern (n=2, axis=[0,30,0]) hole (5);
		}
		
	}
}
//ballnut_mount_bracket(len=50, screw_offset=27);
module ballscrew (len) {
	bearing_len = 11;
	lg_nonthread_len = 25;
	thr_len = 13.6;
	sm_nonthread_len = 14.4;
	screw_len = len - bearing_len - lg_nonthread_len - thr_len - sm_nonthread_len;
	
	color ("lightgrey") {
		cylinder (r=5, h = sm_nonthread_len);
		translate ([0,0,sm_nonthread_len]) cylinder (r=6, h=thr_len + lg_nonthread_len);
		translate ([0,0,sm_nonthread_len + thr_len + lg_nonthread_len])
			linear_extrude (height=screw_len, twist=15*screw_len, convexity=4) {
				circle(r=8, $fn=3);
			}//cylinder (r=8, h=screw_len);
		translate ([0,0,sm_nonthread_len + thr_len + lg_nonthread_len + screw_len])
			cylinder (r=5, bearing_len);
	}
}

module stepper_holes () {
	circular_pattern (n=4, r=67/2, theta=45) hole(5);
}

module shaft_adapter () {
	difference () {
		tube (od=25, id=6.35, ht=30, center=true);
		cylinder (r=10/2, h=16);
	}
}

stepper_screw_offset = 22;	// distance between stepper plate and end of ballscrew.
stepper_wd = 56.2;
stepper_len = 40;
module stepper () {
	module sbody (h) {
		difference () {
			cubexy ([56.2, 56.2, h]);
			circular_pattern (n=4, r=sqrt(2)*56.2/2, theta=45) translate([0,0,-0.25]) cylinder (h=h+0.5, r=11);
		}
	}
	color ("lightgrey") {
		difference () {
			cubexy ([56.2, 56.2, 5.2]);
			stepper_holes();
		}
		scale(-1) cylinder (h=1.5, r=38.1/2);
	}
	color ("grey") scale(-1) cylinder (h=21.5, r=0.125*in);	// shaft
	

	translate ([0,0,5.2]) color ("lightgrey") sbody(6);
	translate ([0,0,5.2+6]) color ([0.2,0.2,0.2]) sbody (32.3);
	translate ([0,0,5.2+6+32.3]) color("lightgrey") sbody (11.4);

	color ([0.5, 0.5, 0.7, 0.5]) translate ([0,0,-21.5]) scale ([1,1,-1]) shaft_adapter();	
}


module yzrail_profile () {
	translate ([-15,0]) square ([30,4]);
	translate ([-12.25/2,4]) square([12.25, 7.6]);
	polygon (points=[[-12.25/2, 11.6],
					   [-5.8/2, 17],
					   [0, 16],
					   [5.8/2, 17],
					   [12.25/2, 11.6]]);
	translate ([0, 22.3]) circle (r = 12/2);
}

yzrail_center_ht = 22.3;

module yrail () {
	color ("grey") translate ([0,-300,0]) rotate([90,0,180]) linear_extrude (height=600) {
		yzrail_profile();
	}
}

module zrail () {
	color ("grey") 
	difference () {
		linear_extrude (height=250, convexity=4) {
			yzrail_profile();
		}
		translate ([-21.8/2, 0,25]) {
			grid_pattern (n1=2, n2=3, axis1=[21.8,0,0], axis2=[0,0,100]) {
				rotate([90,0,0]) hole (4.4);
			}
		}
	}
}

yzrail_block_center = 26.6-5.9-10.35;
yzrail_block_len = 39;
yzrail_block_OFFSET = (yzrail_center_ht - yzrail_block_center) + 26.6 + 1.2;
echo (yzrail_block_OFFSET);
module yzrail_block () {
	module halfblock () {
		square ([19, 26.6]);
		translate ([(19-14.5)+1, (26.6-10)+1.2]) square ([14.5, 10]);
	}
	module block () {
		halfblock();
		mirror ([1,0,0]) halfblock();
	}
	color ("lightgrey") 
	difference () {
		translate ([0,39,0]) rotate([90,0,0]) linear_extrude (height=39, convexity=4) {
			difference () {
				block();
				translate ([0, 26.6 - 5.9 - 10.35]) circle (10.35);
				translate ([0, -9]) rotate(45) square (18 * sqrt(2)/2);
			}
		}
		translate ([-14,(39-26)/2,0]) grid_pattern (n1=2, n2=2, axis1=[28,0,0], axis2=[0,26,0], center=false) {
			translate ([0,0,28.8-12]) cylinder (h=12, r=5/2);
		}
	}
}

module zblock_spacer () {
	difference () {
		translate ([-20, 0, 27.8]) cube ([40, 39, 15.35]);
		translate ([-14, (39-26)/2, 0]) grid_pattern (n1=2, n2=2, axis1=[28,0,0], axis2=[0,26,0], center=false) {
			hole (5.5);
		}
		translate ([0, 39/2,0]) cube ([50, 15, 80], true);
		translate ([0,20,0]) cube ([15,50,80], true);
	}
}

xrail_len = 585;
module xrail () {
	module cborehole () {
		hole(3.5);
		translate ([0,0,12.5-5]) cylinder (r = 6/2, h=100);
	}
	color("lightgrey") 
	difference () {
		translate ([0,-12.5,-7.5]) cube([585,12.5,15]);
		translate ([22.5,0,0]) linear_pattern (n=10, axis=[60,0,0]) {
			rotate ([90,0,0]) cborehole();
		}
	}
}

xblock_len = 34;
xblock_ht = 24;
module xrail_block() {
	color ([0.35, 0.35, 0.35]) 
	difference () {
		translate ([0,-24,-34/2]) cube([37, 19.5,34]);
		translate([37/2,0,0]) dup ([0,0,26]) rotate([90,0,0]) hole(3.3);	// M4 tapped
	}
}

module spindle_motor () {
	rad = 2.25*in/2;
	color ("lightgrey") 
	difference () {
		cylinder (r=rad, h=0.25*in);	// base plate
		circular_pattern (n=4, r=39/2) {
			hole (3.3);	// M4 tapped
		}
	}
	color ([0.3,0.3,0.3]) translate([0,0,0.25*in]) cylinder (r=rad, h=4.75*in); // main section
	color ("lightgrey") translate ([0,0,5*in]) cylinder (r=rad, h=0.93*in); // top plate
	color ("lightgrey") translate ([0,0,5.93*in]) cylinder (r=1.85*in/2, h=0.07*in); // smaller ring at top
	color ([0.1,0.1,0.1]) translate ([0,0, 6.03*in]) cylinder (r=rad, h=1*in);	// fan
	
	color ("lightgrey") translate ([0,0,-3/32*in]) cylinder (r=0.5*in, h=3/32*in);	// flange
	color ("grey") translate ([0,0,-39 - 3/32*in]) cylinder (r=8, h=37);	// shaft
	color ("grey") cylinder (r=3.5, h=10, center=true);
	color ([0.1,0.1,0.1]) translate ([0,0,-43.5-3/32*in]) {	// collet
		cylinder (r=9.5, h=6, $fn=6);
		translate ([0,0,6]) cylinder (r=9.5, h=6.5);
	}
}

motor_axis_offset = 5.9 + 2.25*in/2;

module motor_mount_bottom_bracket () {
	len = 60;
	difference () {
		rotate ([90,0,-90]) linear_extrude (height=len, convexity=3, center=true) {
			L (th1=0.188*in, th2=0.188*in, leg1 = 2*in, leg2=2*in);
		}

		// motor mount holes
		translate ([0,-motor_axis_offset,0]) {
			circular_pattern (n=4, r=39/2) {
				hole (4);
			}
			hole (15);
		}
		// holes for attachment to spindle plate
		dup ([len-15, 0, 0], center=[0,0,12]) {
			linear_pattern (n=2, axis = [0,0,30]) rotate ([90, 0, 0]) hole (6);
		}
	}
}

//motor_mount_bottom_bracket();


module motor_mount_bracket () {
	color ("lightgrey") difference () {
		linear_extrude (height=36.6, convexity=2) {
			difference () {
				union () {
					translate ([-44,2.2]) square ([88, 51.3]);
					translate ([0,53.5]) trapezoid (b1=53.5, b2=27, h=14);
					translate ([0,2.2]) scale ([1,-1]) trapezoid (b1=20, b2=16, h=2.2);
					translate ([0,10]) dup ([88 - (23 - 1.35*2),0]) {
						chamferedRect2D ([23, 20], 2.2);
					}
				}
				translate ([0, 5.9 + 2.25*in/2]) circle (2.25*in/2);
				translate ([0, 33.8]) square ([50, 3.7]);
			}
		}
		dup ([70,0,0]) {
			linear_pattern (n=2, axis=[0,0,18]) {
				translate ([0,0,4.8 + 3.5]) rotate ([90,0,0]) hole (7);
			}
		}
			
				
	}
}

module zbearing_block () {
	rotate ([0,0,-90]) difference () {
		rotate ([90,90,0]) linear_extrude (height=45, convexity=3, center=true) {
			L (th1=5, th2=10, leg1=45, leg2=48);
		}
		translate ([28,0,0]) hole (15);	// clearance for screw
		translate ([28,0,-21]) cylinder (r=30.6/2, h=20);	// bearing hole
		// holes to keep bearing in place
		translate ([20,16,0]) hole (3.5);
		translate ([20,-16,0]) hole (3.5);
		// mount holes
		translate ([0,-30/2,-38]) linear_pattern (n=2, axis=[0,30,20]) {
			rotate ([0,90,0]) hole (6);
		}
	}
}

module zstepper_mount () {
	th=4;
	ht=25;
	hole_spacing = 95;
	fudge = 0.5;
	stepwd = stepper_wd + fudge;
	rotate ([0,0,180]) translate ([0,-stepwd/2,ht/2-th]) {
		difference () {
			linear_extrude (height=ht, convexity=3, center=true) {
				dupm ([-stepwd,0,0]) {
					L (th1=th, th2=th, leg1=30, leg2=stepwd+th);
				}
				translate ([0,stepwd+th/2]) square ([stepwd,4], true);
			}
			// holes for mounting to Z plate
			dup ([hole_spacing, 0, 0]) {
				rotate ([90,0,0]) hole (6.3);	// M6; prints vertically so hole size can be smalle	r
			}
		}
	
		// faceplate blocks
		translate ([0,0,-ht/2]) {
			difference () {
				dup ([-stepwd+8,0,0]) {
					translate ([-8,0,0]) cube ([16, stepwd, th]);
				}
				translate ([0, stepwd/2, 0]) {
					cylinder (r=20, h=100, center=true);
					stepper_holes();
				}
			}
		}
	}
}

module xstepper_mount (offset) {
	th=5;
	tablen = 20;
	wd = stepper_wd + 4;
	union () {
	linear_extrude (height=5) {
		difference () {
			union () {
				square ([wd, stepper_wd], true);
				circular_pattern (n=4, r=67/2, theta=45) circle (d=15);
				translate ([offset,0,0]) {
					difference () {
						square ([stepper_wd/2, stepper_wd + 2*tablen], true);
						dup ([0, stepper_wd + 2*tablen - 12, 0]) circle (d=5);
					}
				}
			}
			translate ([10,0]) circle (14);
			circular_pattern (n=4, r=67/2, theta=45) circle (d=6);
		}
	}
	translate ([offset - 22.5 - th/2,0,0]) {
		difference () {
			linear_extrude (height = 33) {
				square ([th, stepper_wd/2],true);
			}
			translate ([0,0,22.5+th]) rotate ([0,90,0]) hole (5);
		}
		dupm ([0,stepper_wd/2 - th*2,0], center=[-th/2,0,th-0.5]) rotate ([90,0,0]) linear_extrude (height=th) polygon ([[0,0],[0,25],[-15,0]]);
	}
	}
}

module xbearing_block (xpos, offset=15) {
	//offset = 15;
	bh_th = 10.5;
	th=4;
	module crossbrace (sy, ey, th) {
		polygon ([[0, sy], [0, sy+th], [xpos+bh_th, ey+th], [xpos+bh_th, ey]]);
	}
	translate ([0, -(20-offset), -20]) {
		difference () {
			translate ([0,-7.5,0]) cube ([5, 47.5, 60]);
			translate ([0, 22.5 + 5 - 7.5, 52]) holex (4.8);
		}
		difference () {
			translate ([0, -7.5, 0]) cube ([40, 5, 40]);
			translate ([22.5 + 5, 0, 8]) holey (4.8);
			translate ([22.5 + 5, 0, 32]) holey(4.8);
		}
	

		translate ([xpos,-offset,0]) difference () {
			cube ([bh_th, 40,40]);
			rotate ([0,90,0]) {
				translate ([-20, 20, -11.5]) cylinder (r=15.2, h=20);
				translate ([-20, 20, 0]) hole (15);
			}
		}
		
		linear_extrude (height=40, convexity=6) {
			crossbrace (-7.5, -offset, th);
			crossbrace (-7.5, 40-offset-5, 5);
			crossbrace (40-th, 40-offset-th, th);
		}
	}
}

module ystepper_mount () {
	hspace = 67*sqrt(2)/2;
	difference () {
		union () {
			translate ([0,2.5,-10]) cube ([60, 5, 80], true);
			translate ([0,20,-12.5]) cube ([60, 40, 5], true);
			dup ([55,0,0], center=[0,10,-5]) rotate ([90,0,90]) cylinder (r=10, h=5, center=true);
		}
		dup ([hspace, 0, 0], center=[0,0,hspace/2]) holey(4.8);
		dup ([hspace, 0, 0], center=[0,0,-hspace/2]) holey(3);
		holey(28);
		dup ([48, 0, 0], center=[0,27.5,0]) hole (5);
		dup ([48, 0, 0], center=[0, 0, -22.5-15]) holey (5);
		translate ([0,0,-33]) holey (23);
	}
}

//rotate ([90,0,0])ystepper_mount();
module ybearing_block() {
	
}

xbearing_block (-25);