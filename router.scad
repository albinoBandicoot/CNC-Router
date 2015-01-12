include <router_parts.scad>

/* Here are parameters that actuate the various axes */
XPOS = 0;
YPOS = 150;
ZPOS = 20;

/* Colors */
xstage_col = [1, 0.7, 0.2];
ystage_col = [0.9, 0.45, 0.7];
zstage_col = [0.5, 0.5, 0.9];
pillar_col = [0.7, 1, 0.4];

/* Base frame */
y_crossbar_len = 500;
y_crossbar_spacing = 550;

module y_crossbars () {
	module side() {
		translate ([22.5, 0, 22.5]) rotate ([0,90,90]) extrusion (y_crossbar_len, true);
		dupm ([0, y_crossbar_len, 0], adj=[0,45,0]) {
			scale([1,1,-1]) angle_gusset();
		}
	}
	dupm ([y_crossbar_spacing,0,0], adj=[45,0,0]) 
		side();
}

module longbars () {
	module bar(){
		translate ([0, 0, 22.5]) rotate([0,90,0]) extrusion (y_crossbar_spacing + 90, true);
	}
	dup ([0,y_crossbar_spacing,0]) {
		bar();
	}
}


/* Y-AXIS rails, ballscrew and motor */

yrail_spacing = 450;
yaxis_block_spacing = yzrail_block_len + 130;
yrail_bias = 0;
module yguides () {
	module block() {
		translate ([0,0,45 + (yzrail_center_ht - yzrail_block_center)]) yzrail_block();
	}
	dup([yrail_spacing,0,0]) {
		translate ([0,yrail_bias,45]) yrail();
		translate ([0,-300 + YPOS, 0]) {
			block();
			translate ([0, yaxis_block_spacing, 0]) block();
		}
	}
}

ystepper_mountpos = -299;
module yscrew () {
	module ballnut_mount_bracket () {
		len = 75;
		difference () {
			translate ([0,-0.188*in, 27]) rotate ([0,90,0]) linear_extrude (height=len, center=true, convexity=4) {
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
			
	translate ([0,ystepper_mountpos + 1*stepper_screw_offset,45]) rotate ([-90,0,0]) ballscrew (500);
	translate ([0,ystepper_mountpos + stepper_screw_offset + 55 + YPOS,45]) {
		rotate ([-90,0,0]) ballnut();
		color (ystage_col) ballnut_mount_bracket();
	}

			
	translate ([0,ystepper_mountpos,45]) rotate ([0,-90,90]) stepper();
}

/* PILLARS and their supports */

pillar_ypos = 40;
pillar_ht = 475;
module pillars () {
	module pillar () {
		translate ([0,pillar_ypos,45]) extrusion (pillar_ht);
		translate ([-22.5,pillar_ypos,0]) rotate([90,0,-90]) t_gusset();
	}
	dupm ([y_crossbar_spacing+45,0,0]) pillar();
}


/* X-AXIS bars */

xbar_len = y_crossbar_spacing;
xbar_top_ht = 45 + pillar_ht;
xbar_spacing = 12*in - 45;
xbar_bot_ht = xbar_top_ht - xbar_spacing;

module xbars () {
	module bar() {
		translate ([0,0,-22.5]) rotate ([0,90,0]) extrusion (xbar_len, true);
	}
	module xbar () {
		bar();
		dupm ([xbar_len+90,0,0], adj=[0,0,0]) {
			translate ([0,22.5,0]) rotate ([-90,0,0]) angle_gusset();
		}
	}
	translate ([0, pillar_ypos, xbar_top_ht]) linear_pattern (n=2, axis = [0,0,-xbar_spacing]) xbar();
}

/* X-AXIS guides, screw and motor */

xrail_bias = 0;
xaxis_block_spacing = 6*in - 6*2;	// want the holes to be say 6mm in from edges of blue plate
module xguides () {
	translate ([-585/2 + xrail_bias, pillar_ypos-22.5, xbar_bot_ht-22.5]) {
		linear_pattern (n=2, axis=[0,0,xbar_spacing]) {
			xrail();
			translate ([XPOS,0,0]) {
				xrail_block();
				translate ([xaxis_block_spacing,0,0]) xrail_block();
			}
		}
	}
}

xstepper_mountpos = -300;
xscrew_z = xbar_bot_ht + xbar_spacing/2;
xscrew_xoffset = 0;
xscrew_yoffset = -50 + pillar_ypos;
module xscrew () {
	translate ([xstepper_mountpos + stepper_screw_offset, xscrew_yoffset, xscrew_z]) rotate ([0,90,0]) ballscrew(500);
	translate ([xstepper_mountpos + stepper_screw_offset + 55 +XPOS, xscrew_yoffset, xscrew_z]) rotate ([0,90,0]) ballnut ();
	translate ([xstepper_mountpos,xscrew_yoffset,xscrew_z]) rotate([0,-90,0]) stepper();
}

/* Z-AXIS plate, guides, screw, and motor */


zplate_offset = -80 + pillar_ypos;
zplate_surface_y = zplate_offset - 0.25*in;
module zplate () {
	translate ([-3*in, -0.25*in + zplate_offset, xbar_top_ht - 12*in]) cube ([6*in, 0.25*in, 12*in]);
}
zplate_bot = xbar_top_ht - 12*in;

zrail_sep = 100;
zrail_bias = 0;
zaxis_block_spacing = yzrail_block_len + 70;
module zguides () {
	module block() {
		translate ([0,-(yzrail_center_ht - yzrail_block_center),0]) rotate ([90,0,0]) yzrail_block();
	}
	translate ([0, zplate_surface_y, zplate_bot + (12*in-250)/2 + zrail_bias]) {
		dup ([zrail_sep,0,0]) {
			rotate ([0,0,180]) zrail();
			translate ([0,0,ZPOS]) {
				block();
				translate ([0,0,zaxis_block_spacing]) block();
			}
		}
	}
}

zscrew_ht = 28;	// how far off the plate the axis of the Z ballscrew lies
zscrew_bias = 0;
module zscrew () {
	translate ([0, zplate_surface_y - zscrew_ht, xbar_top_ht - (12*in-200)/2 + zscrew_bias]) {
		rotate([0,180,0]) ballscrew (200);
		translate ([0,0,-145+ZPOS]) rotate([0,180,0]) ballnut();
		translate ([0,0,30]) stepper();
	}
}

/* SPINDLE and mounting plates */
	
module spindle_plate () {
	translate ([-3*in,0,0]) cube ([6*in, 0.25*in, 6*in]);
}

mmount_bias = 0;
spindle_bias = 0;
module spindle_carriage () {
	translate ([0,-110, 250+ZPOS]) {
		color ([0.65, 0.8, 1]) spindle_plate();
		translate ([0, -motor_axis_offset, spindle_bias]) spindle_motor();
		translate ([0, 0, 36.6/2 + 3*in + mmount_bias]) rotate ([180,0,0]) motor_mount_bracket();
	}
}

// whole Z carriage + spindle assembly
module zcarriage () {
	translate ([-xrail_len/2 + xblock_len/2 + 3*in + XPOS,0,0]) {
		zguides();
		zscrew();
		color (zstage_col) zplate();
		spindle_carriage();
	}
}



/* Calls to all the modules */
color (ystage_col) y_crossbars();
yguides();
yscrew();
color (ystage_col) longbars();
color (pillar_col) pillars();
color (xstage_col) xbars();
xguides();
xscrew();
zcarriage();