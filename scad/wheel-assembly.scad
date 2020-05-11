include <MCAD/units.scad>

module WheelAssembly(cutout_mask=false) {
    fn=64;
    wheel_diameter = 108;
    encoder_diameter = 39;
    encoder_length = 36.5;
    encoder_wheel_distance = 5;
    wheel_radius  = wheel_diameter / 2;
    outdent_diameter = 8;
    wheel_clearance = 3;
    l_bracket_z = 3 * inch;
    l_bracket_x = 1.75 * inch;
    l_bracket_thickness = 2/32 * inch;

    encoder_x_pos = outdent_diameter + encoder_wheel_distance;


    module CylinderOuter(height,radius,center=false){
        fudge = 1/cos(180/fn);
        cylinder(h=height,r=radius*fudge, center=center);
    }

    rotate([0, 90, 0]) CylinderOuter(outdent_diameter, wheel_radius);

    rotate([0, 90, 0]) CylinderOuter(20, 3);

    translate([
        encoder_x_pos,
        0,
        0
    ]) rotate([0, 90, 0]) CylinderOuter(encoder_length, encoder_diameter / 2);

    translate([
        encoder_x_pos,
        -encoder_diameter / 2,
        -l_bracket_z + encoder_diameter / 2
    ]) cube([l_bracket_thickness, encoder_diameter, (l_bracket_z - encoder_diameter / 2)]);

    translate([
        encoder_x_pos,
        - encoder_diameter / 2,
        - l_bracket_z - l_bracket_thickness + encoder_diameter / 2
    ]) cube([l_bracket_x, encoder_diameter, l_bracket_thickness]);

    if (cutout_mask) translate([-wheel_clearance, 0, 0]) rotate([0, 90, 0]) CylinderOuter(outdent_diameter + 2 * wheel_clearance, wheel_radius + wheel_clearance);
}
