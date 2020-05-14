use <MCAD/nuts_and_bolts.scad>
use <MCAD/regular_shapes.scad>

/* [ Basic ] */
WHEEL_DIAMETER=125;
HUB_DIAMETER=40;
HUB_THICKNESS=4;
ENCODER_SHAFT_DIAMETER=6;

/* [ Handle ] */
HANDLE_THICKNESS=6;
OUTDENT_COUNT=24;
OUTDENT_DIAMETER=8;

/* [ Spokes ] */
SPOKE_COUNT=3;
SPOKE_ANGLE_SPAN=60;

/* [ Bolt ] */
BOLT_DIAMETER=3;
BOLT_HEAD_DIAMETER=5.6;
NUT_WIDTH=5.4;
NUT_THICKNESS=1.7;
NUT_CLEARANCE=0.2;


/* [ Hidden ] */
BRIM_WIDTH=15;
CLEARANCE_TIGHT=0.2;
CLEARANCE_LOOSE=0.4;

HANDLE_OUTDENT_RADIUS=OUTDENT_DIAMETER / 2;
WHEEL_RADIUS=WHEEL_DIAMETER / 2;
HUB_RADIUS=HUB_DIAMETER / 2;
$fn=64;
ENCODER_SHAFT_RADIUS=ENCODER_SHAFT_DIAMETER/2 + CLEARANCE_LOOSE;
BOLT_RADIUS=BOLT_DIAMETER/2 + CLEARANCE_LOOSE;
BOLT_HEAD_RADIUS=BOLT_HEAD_DIAMETER/2;

BOLT_SHAFT_LENGTH=max(BOLT_HEAD_DIAMETER, NUT_WIDTH) * 1.5;
echo("Bolt shaft length: ", BOLT_SHAFT_LENGTH, "mm");
echo("Total object length: ", BOLT_SHAFT_LENGTH + HUB_THICKNESS, "mm");

TOTAL_D_CUTOUT_HEIGHT=BOLT_SHAFT_LENGTH+HUB_THICKNESS;


module cylinder_outer(height,radius,fn) {
   fudge = 1/cos(180/fn);
   cylinder(h=height,r=radius*fudge,$fn=fn);
}

module Handle() {
    // handle
    translate([0,0,HANDLE_THICKNESS/2]) torus2(WHEEL_RADIUS, HANDLE_THICKNESS/2);
    // outdents
    outdent_degrees = 360 / OUTDENT_COUNT;
    for(sector = [1 : OUTDENT_COUNT]) {
        angle = outdent_degrees * sector;
        x_pos = WHEEL_RADIUS * sin(angle);
        y_pos = WHEEL_RADIUS * cos(angle);
        translate([x_pos,y_pos,HANDLE_OUTDENT_RADIUS]){
            sphere(HANDLE_OUTDENT_RADIUS, center=true);
        }
    }
}

module HandleBrim() {
    _fn=72*4;
    // handle
    translate([0,0,HANDLE_THICKNESS/2]) difference() {
        cylinder_outer(0.3, WHEEL_RADIUS + BRIM_WIDTH, _fn);
        cylinder_outer(0.3, WHEEL_RADIUS - BRIM_WIDTH, _fn);
    }
}

module Spokes() {
    // spokes
    spoke_angle_half_span=SPOKE_ANGLE_SPAN/2;
    spoke_degrees = 360 / SPOKE_COUNT;
    for(sector = [1 : SPOKE_COUNT]) {
        angle_mid = spoke_degrees * sector;
        angle_min = angle_mid - spoke_angle_half_span;
        angle_max = angle_mid + spoke_angle_half_span;

        angle_q1 = angle_min + (spoke_angle_half_span * .5);
        angle_q3 = angle_mid + (spoke_angle_half_span * .5);
        // points near handle bar
        x1_pos = WHEEL_RADIUS * sin(angle_min);
        y1_pos = WHEEL_RADIUS * cos(angle_min);
        x2_pos = WHEEL_RADIUS * sin(angle_q1);
        y2_pos = WHEEL_RADIUS * cos(angle_q1);
        x3_pos = WHEEL_RADIUS * sin(angle_mid);
        y3_pos = WHEEL_RADIUS * cos(angle_mid);
        x4_pos = WHEEL_RADIUS * sin(angle_q3);
        y4_pos = WHEEL_RADIUS * cos(angle_q3);
        x5_pos = WHEEL_RADIUS * sin(angle_max);
        y5_pos = WHEEL_RADIUS * cos(angle_max);
        // points at hub
        x6_pos = HUB_RADIUS * sin(angle_max);
        y6_pos = HUB_RADIUS * cos(angle_max);
        x7_pos = HUB_RADIUS * sin(angle_min);
        y7_pos = HUB_RADIUS * cos(angle_min);

        translate([0,0,0]) linear_extrude(HUB_THICKNESS) polygon(points=[
            [x1_pos, y1_pos],
            [x2_pos, y2_pos],
            [x3_pos, y3_pos],
            [x4_pos, y4_pos],
            [x5_pos, y5_pos],
            [x6_pos, y6_pos],
            [x7_pos, y7_pos],
        ]);
    }
}


// hub
module _Shaft() {
    cylinder_outer(TOTAL_D_CUTOUT_HEIGHT, ENCODER_SHAFT_RADIUS, 64);
}

module Hub(use_nyloc=false) {
    m3_nyloc_nut_thicknes=4.00;
    m3_nut_thickness=2.4;
    actual_m3_nut_thickness=use_nyloc ? m3_nyloc_nut_thicknes : m3_nut_thickness;
    nut_z_scale=actual_m3_nut_thickness/m3_nut_thickness;

    // HUB
    difference() {
        cylinder_outer(HUB_THICKNESS, HUB_RADIUS, $fn);
        //D cutout
        _Shaft();
    }

    // BOLT SHAFT
    BOLT_SHAFT_RADIUS=ENCODER_SHAFT_RADIUS + 3 * actual_m3_nut_thickness;

    echo("Bolt shaft radius:", BOLT_SHAFT_RADIUS, " mm");

    difference() {
        translate([0, 0, HUB_THICKNESS]) difference() {
            cylinder_outer(BOLT_SHAFT_LENGTH, BOLT_SHAFT_RADIUS, $fn);
            // bolt hole
            translate([1, 0, BOLT_SHAFT_LENGTH / 2]) rotate([0, 90, 0]) cylinder_outer(BOLT_SHAFT_RADIUS, BOLT_RADIUS, $fn);
            // nut holes
            translate([ENCODER_SHAFT_RADIUS, 0, BOLT_SHAFT_LENGTH / 2]) rotate([0, 90, 0]) scale([1, 1, nut_z_scale]) nutHole(3);
            translate([0.1, 0, BOLT_SHAFT_LENGTH / 2]) rotate([0, 90, 0]) scale([1, 1, 1.4]) nutHole(3);
        }
        _Shaft();
    }
}

Handle();
Spokes();
Hub();

translate([200, 0, 0]) HandleBrim();
