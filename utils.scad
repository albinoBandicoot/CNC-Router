PRINTER="Watermelon";

/* BASIC SHAPES */

module ring (od, id) {
	difference () {
		circle (r = od/2);
		circle (r = id/2);
	}
}

module tube (od, id, ht, center=false) {
	linear_extrude (height = ht, center=center, convexity=2) ring (od, id);
}

/* Cube centered on x/y axes but not along z */
module cubexy (size) {
	translate ([0,0,size[2]/2]) cube (size, true);
}

module L (leg1, leg2, th1, th2) {
	difference () {
		square ([leg1, leg2]);
		translate ([th2, th1]) square ([leg1*2, leg2*2]);
	}
}

module C (base, leg1, leg2, baseth, th1, th2) {
	L (base, leg1, baseth, th1);
	translate ([base-th2, 0]) square ([th2, leg2]);
}

module C_sym (base, leg, th) {
	difference () {
		square ([base, leg]);
		translate ([th, th]) square ([base - 2 * th, leg*2]);
	}
}

module trapezoid (b1, b2, h, center=true) {
	shift = center ? [0,0,0] : [b1/2,0,0];
	translate (shift) polygon (points=[	[-b1/2,0], 
											[-b2/2,h], 
											[b2/2,h],
											[b1/2,0] ]);
}

/* Slot with circle center-center distance = len, width = d */
module slot2D (d, len) {
	translate ([-len/2,0]) circle (d/2);
	square ([len, d], true);
	translate ([len/2,0]) circle (d/2);
}

module slot (d, len, h=500, center=true) {
	translate ([0,0, center ? -h/2 : 0]) linear_extrude (height = h) slot2D (d, len);
}

module roundedRect2D (size, r=3) {
	square ([size[0]-2*r, size[1]], true);
	square ([size[0], size[1]-2*r], true);
	for (x=[-1,1]*(size[0]/2 - r), y=[-1,1]*(size[1]/2 - r)) {
		translate ([x,y]) circle (r);
	}
}

module roundedRect (size, r=3, h=10) {
	linear_extrude (height = h) roundedRect2D (size, r);
}

module chamferedRect2D (size, r=2, center=true) {
	shift = center ? -size/2 : [0,0,0];
	translate (shift) 
		polygon (points = [	[r,0],
								[0,r],
								[0,size[1]-r],
								[r,size[1]],
								[size[0]-r, size[1]],
								[size[0], size[1]-r],
								[size[0], r],
								[size[0]-r, 0]]);
}

/* points is a vector of 2D vectors; the first elements are Z positions, the
   second elements are radii. This will make a revolved object (cones & cylinders)
   that corresponds. */
module multicone (points) {
	for (i=[0:len(points)-2]) {
		if (points[i+1][0] >= points[i][0]) {
			translate ([0,0,points[i][0]]) cylinder (r = points[i][1], r2 = points[i+1][1], h = points[i+1][0] - points[i][0]);
		}
	}
}

/* PATTERNS */

module linear_pattern (n=2, axis=[1,0,0], center=false) {
	tr = center ? axis * (-(n-1)/2) : [0,0,0];
	translate (tr) 
		for (i=[0:n-1]) {
			translate (axis*i) children();
		}
}

module grid_pattern (n1=2, n2=3, axis1=[1,0,0], axis2=[0,1,0], center=false) {
	tr = center ? axis1*((n1-1)/2) + axis2*((n2-1)/2) : [0,0,0];
	translate (tr) linear_pattern (n1, axis1) linear_pattern (n2, axis2) children();
}

module circular_pattern (n=6, r=10, theta=0) {
	for (i=[0:n-1]) {
		rotate (i * 360 / n + theta) translate ([r, 0, 0]) children();
	}
}

module dup (axis=[1,0,0], center=[0,0,0]) {
	translate (center-axis/2) children();
	translate (center+axis/2) children();
}

module dupm (axis=[1,0,0], center=[0,0,0], adj=[0,0,0]) {
	translate (center-axis/2 - adj) children();
	translate (center+axis/2 + adj) mirror (axis) children();
}


/* THINGS FOR HOLES, NUTS, AND BOLTS */

// empirical values for size of printed hexagonal holes. 
// first value is real (measured) size, second is CAD value that produced it.
taz_hexagonsizes = [	[2.25, 2.5],
						[2.9, 3],
						[3.9, 4],
						[4.9, 5],
						[5.9, 6],
						[7.7, 8],
						[9.75, 10],
						[14.7, 15] ];

watermelon_hexagonsizes = [	
						[2.5, 2.5],
						[3, 3],
						[4, 4],
						[5, 5],
						[6, 6],
						[8, 8],
						[10, 10],
						[15, 15] ];


hexagonsizes = [["Taz", taz_hexagonsizes], ["Watermelon", watermelon_hexagonsizes]];

module hexagon (size) {	// this is SIDE TO SIDE distance!!!
//	echo ("Making hexagon with size ", size);
	circle (r = (size/2) * 1.1544, $fn=6);
}

module hexagonC (size) {	// only difference here is that we use the empirical sizes
	sizes = hexagonsizes[search([PRINTER], hexagonsizes)[0]][1];
	largediff = sizes[len(sizes)-1][1] - sizes[len(sizes)-1][0];
	if (size < sizes[0][0]) {
		echo (str("Warning! Hexagon smaller (", size, ") than smallest calibration entry (", sizes[0][0], ") - using size as is."));
		hexagon (size);
	} else if (size > sizes[len(sizes)-1][0]) {
		echo (str("Warning! Hexagon larger (", size, ") than largest calibration entry (", sizes[len(sizes)-1], ") - applying same difference (", largediff, ") as largest entry; making hexagon with size ", (size + largediff)));
		hexagon (size + largediff);	// assume that the difference between real and CAD is the same as it is for the largest test case
	} else {
		hexagon (lookup (size, sizes));
	}
}

/* Eventually do something based on empirical hole size measurements, so
passing X to this actually gives you a hole that's very close to X in diameter */

taz_holesizes = [	
				[1.75, 2],
				[2.85, 3],
				[3.75, 4],
				[4.73, 5],
				[5.6, 6],
				[7.55, 8],
				[9.65, 10],
				[14.65, 15] ];	// first entry: real size. second entry: CAD value.

watermelon_holesizes = [	
				[2, 2],
				[3, 3],
				[4, 4],
				[5, 5],
				[6, 6],
				[8, 8],
				[10, 10],
				[14, 15] ];

holesizes = [["Taz", taz_holesizes], ["Watermelon", watermelon_holesizes]];
/*
module hole (d, ht=500, center=true) {
	module h (d) {
		cylinder (r = d/2, h = ht, center=center);
	}
	sizes = holesizes[search([PRINTER], holesizes)[0]][1];
	largediff =  sizes[len(sizes)-1][1] - sizes[len(sizes)-1][0];
	if (d < sizes[0][0]) {
		echo (str("Warning! Hole smaller (", d, ") than smallest calibration entry (", sizes[0][0], ") - using size as is."));

		h (d);
	} else if (d > sizes[len(sizes)-1][0]) {
		echo (str("Warning! Hole larger (", d, ") than largest calibration entry (", sizes[len(sizes)-1], ") - applying same difference (", largediff, ") as largest entry; making hole with size ", (d + largediff)));

		h (d +  largediff);	// assume that the difference between real and CAD is the same as it is for the largest test case
	} else {
		h (lookup (d, sizes));
	}
}
*/
module hole (d) {
	cylinder (r=d/2, h=1000, center=true);
}

nutsizes = [	[2.5, 5],
				[3, 5.5], 
				[4, 7], 
				[5, 8], 
				[6, 10],
				[8, 13],
				[10, 16]];	

nutheights = [	[2.5, 2],
				[3, 2.4], 
				[4, 3.2], 
				[5, 4.7], 
				[6, 5.2],
				[8, 6.8],
				[10, 8.4]];

module nut (size) {
	linear_extrude (height = lookup (size, nutheights)) hexagonC (lookup (size, nutsizes));
}

/* CALIBRATION BLOCK */
module calibration_block() {

	module test_hole (size) {
		cylinder (r = size/2, h=500, center=true);
	}

	function sumholesize (i) = i == 0 ? 0 : holesizes[i][1] + sumholesize(i-1);
	function sumhexsize (i) = i == 0 ? 0 : hexagonsizes[i][1] + sumhexsize(i-1);

	$fn=24;
	wd = 25;
	len = 70;
	difference () {
		cube ([len,wd,4]);
		for (i=[0:len(holesizes)-1]) {
			translate ([sumholesize(i)+i+3, wd - 2 - holesizes[i][1]/2, 0]) test_hole (holesizes[i][1]);	
		}
		for (i=[0:len(hexagonsizes)-1]) {
			translate ([68 - sumhexsize(i)-i,  2+ hexagonsizes[i][1]/2, 0]) linear_extrude (h=200, center=true) hexagon (hexagonsizes[i][1]);
		}
	}
}

//calibration_block();