use <MCAD/regular_shapes.scad>
use <MCAD/nuts_and_bolts.scad>
use <protoboard-holder.scad>
use <wheel-assembly.scad>

include <arduino.scad>

include <MCAD/units.scad>

$fn=128;
small_fn=64;
ThrottleQuadY=110;
ThrottleQuadX=90;
ThrottleQuadZ=110;
ThrottleQuadLowerZ=36.5;
ThrottleQuadUpperY=25;

module ThrottleQuadrant() {
    cube([HousingX, ThrottleQuadY, ThrottleQuadLowerZ]);
    translate([
        0,
        ThrottleQuadY - ThrottleQuadUpperY,
        0
    ]) cube([HousingX, ThrottleQuadUpperY, ThrottleQuadZ]);

    difference() {
        translate([
            0,
            ThrottleQuadY - ThrottleQuadUpperY,
            ThrottleQuadLowerZ
        ]) rotate([0, 90, 0]) oval_prism(
            HousingX,
            ThrottleQuadY - ThrottleQuadUpperY,
            ThrottleQuadZ - ThrottleQuadLowerZ)
        ;

        translate([0, ThrottleQuadY, -110]) cube([100, 100, 300]);
        translate([0, 0, -120]) cube([100, 300, 120]);
    }
}

MinWallThickness=2.4;
DoubleMinWallThickness=MinWallThickness * 2;
LowerHousingZ=ThrottleQuadLowerZ;
HousingX=ThrottleQuadX + 15;
HousingY=ThrottleQuadY;
HousingZ=ThrottleQuadZ;
HousingInternalX=HousingX - 2 * MinWallThickness;
HousingInternalY=HousingY - 2 * MinWallThickness;
HousingInternalZ=HousingZ - 2 * MinWallThickness;

LCDBoardX=74;
LCDBoardY=26;
LCDBoardZ=1.6;

LCDMountX=68.5;
LCDMountY=20.4;

LCDCharX=62.1;
LCDCharY=15;
LCDCharZ=7.3;

LCDCharXOffset=6.5;
LCDCharYOffset=0;

LCDBoardClearance=2;

working_fit=0.4;
close_fit=0.2;


module LCD(breakThrough = false) {
    cube([LCDBoardX, LCDBoardY, LCDBoardZ]);
    translate([
        breakThrough ? LCDCharXOffset - 1 : LCDCharXOffset,
        breakThrough ? LCDBoardY - LCDCharY - LCDCharYOffset - 1: LCDBoardY - LCDCharY - LCDCharYOffset,
        LCDBoardZ
    ]) cube([
        breakThrough ? LCDCharX + 2 : LCDCharX,
        breakThrough ? LCDCharY + 2 : LCDCharY,
        breakThrough ? LCDCharZ * 4 : LCDCharZ
    ]);
}

module LCDAssembly(printed_parts_only=false, breakThrough=false, bracketOnly=false) {
    translate([
        (LCDBoardX - LCDMountX) / 2,
        (LCDBoardY - LCDMountY) / 2,
        -8.2
    ]) ProtoBoardHolder(
        LCDMountX,
        LCDMountY,
        board_y=LCDBoardY,
        board_y_clearance=LCDBoardClearance,
        only_support=printed_parts_only,
        with_support=!bracketOnly
    );
    if (!bracketOnly) {
        if (!printed_parts_only) LCD(breakThrough);

        if (breakThrough) LCD(breakThrough);
    }
}

module PositionedLCDAssembly(printed_parts_only=false, breakThrough=false) {
    translate([
        (HousingX - LCDBoardX) / 2,
        HousingY - LCDBoardY - MinWallThickness - LCDBoardClearance,
        HousingZ - (LCDBoardZ + LCDCharZ + 1)
    ]) LCDAssembly(printed_parts_only, breakThrough);
}

module PositionedWheelAssembly(printed_parts_only=false) {
    l_bracket_x = 1.75 * inch;
    encoder_diameter = 39;
    wheel_assy_x=MinWallThickness + 10 + 3;
    wheel_assy_y=32;
    wheel_assy_z=60;
    translate([
            wheel_assy_x,
            wheel_assy_y,
            wheel_assy_z
    ]) {
        if(!printed_parts_only) {
            rotate([0, 0, 0]) WheelAssembly(true);
        }
        translate([12.5, -20, -60 + MinWallThickness])
            difference() {
                translate([
                    - l_bracket_x / 4 - working_fit,
                    -encoder_diameter / 5 - working_fit,
                    0
                ]) cube([
                    l_bracket_x * 1.5,
                    encoder_diameter * 1.4,
                    0.2
                ]);
                cube([
                    l_bracket_x + 2 * working_fit,
                    encoder_diameter + 2 * working_fit,
                    0.2
                ]);
            }
    }
}

arduino_standoff_height=5;
arduino_rotation=[0, 90, 180];
arduino_coords=[HousingX - 1, 107, 80];

module ArduinoAssembly(printed_parts_only=false) {
    translate([0, 0, arduino_standoff_height]) {
        if (!printed_parts_only) arduino(LEONARDO);
        translate([0, 0, -arduino_standoff_height]) standoffs(LEONARDO, arduino_standoff_height);

    }
}

module ArduinoCutouts() {
    usb_oversize = 3; // mm per side
    translate([0, 0, arduino_standoff_height]) {
        components(LEONARDO, USB, 10);
        components(LEONARDO, POWER, 10);
        //create an oversized cutout for the USB port
        //arduino.scad:547
        translate([11.5 - usb_oversize, -1.1 - usb_oversize - 15, 0 - 1.5]) cube([7.5 + usb_oversize * 2, 5.9 + usb_oversize * 2 + 10, 3 + usb_oversize * 2]);
    }
}

module PositionedArduinoCutouts() {
    translate(arduino_coords) rotate(arduino_rotation) ArduinoCutouts();
}

module PositionedArduinoAssembly(printed_parts_only=false) {
    translate(arduino_coords) rotate(arduino_rotation) ArduinoAssembly(printed_parts_only);
}

module cylinder_outer(height,radius,_fn=64,center=false){
    fudge = 1/cos(180/_fn);
    cylinder(h=height,r=radius*fudge, center=center);
}

module cylinder_mid(height,radius,_fn=64,center=false){
   fudge = (1+1/cos(180/_fn))/2;
   cylinder(h=height,r=radius*fudge,$fn=_fn,center=center);
}

module cone_outer(height,radius1,radius2,_fn=64,center=false){
   fudge = 1/cos(180/_fn);
   cylinder(h=height,r1=radius1*fudge,r2=radius2*fudge,$fn=_fn,center=center);
}

module ToggleSwitchCutouts() {
    ts_dia=3;
    ts_rad=ts_dia/2;
    ts_hole_spacing=28;
    ts_x=14;
    ts_y=DoubleMinWallThickness * 1.5;
    ts_z=7.5;
    translate([0, ts_y / 2, 0]) {
        translate([0, ts_y / 2, 0]) rotate([90, 0, 0]) cylinder_outer(ts_y);
        translate([ts_hole_spacing, ts_y / 2, 0]) rotate([90, 0, 0]) cylinder_outer(ts_y);
        translate([
            ts_hole_spacing / 2,
            0,
            0
        ]) cube([ts_x, ts_y, ts_z], center=true);
    }
}

module PositionedToggleSwitchCutouts() {
    translate([
        40,
        -0.1,
        LowerHousingZ / 2
    ]) ToggleSwitchCutouts();
}

module ResetButton() {
    rst_button_dia=11.6;
    rst_button_rad=rst_button_dia/2 + close_fit;
    rst_button_len=10;

    translate([
        ThrottleQuadX - rst_button_dia * 1.5,
        0,
        LowerHousingZ / 2
    ]) rotate([270, 0, 0]) cylinder_outer(rst_button_len, rst_button_rad, small_fn);
}

module PositionedResetButton() {
    translate([
        15,
        0,
        0
    ])
    ResetButton();
}

interfaceboard_x=50;
interfaceboard_y=34;

interfaceboard_frame_x=41;
interfaceboard_frame_y=27;

module InterfaceBoard() {
    cube([
        interfaceboard_x,
        interfaceboard_y,
        15
    ]);
}

module InterfaceBoardFrame() {
    io_x=interfaceboard_frame_x;
    io_y=interfaceboard_frame_y;
    ProtoBoardHolder(
        io_x,
        io_y,
        frame_height=1,
        mount_post_height=3,
        with_support=false,
        fixing_tab_location="none"
    );
}

module InterfaceAssembly(printed_parts_only=false) {
    if (!printed_parts_only) translate([0, 0, 4]) InterfaceBoard();
    translate([
        (interfaceboard_x - interfaceboard_frame_x) / 2,
        (interfaceboard_y - interfaceboard_frame_y) / 2,
        0
    ]) InterfaceBoardFrame();
}

m5_nut_width=8.5;
m5_nut_thickness=4.00;


m8_nut_width=15.00;
m8_nut_thickness=6.50;
m8_bolt_cap_diameter=13.0;

clamp_holes_z=[
    ((HousingZ / 3)) * 1,
    ((HousingZ / 3)) * 2,
];

m10_nut_width=19.6;
m10_nut_thickness=8.00;

m5_nut_hole_boss_width=m5_nut_width * 2;
m5_nut_hole_boss_thickness=m5_nut_thickness + DoubleMinWallThickness;

m8_nut_hole_boss_width=m8_nut_width * 2;
m8_nut_hole_boss_thickness=m8_nut_thickness + DoubleMinWallThickness;

m10_nut_hole_boss_width=m10_nut_width * 2;
m10_nut_hole_boss_thickness=m10_nut_thickness + DoubleMinWallThickness;
m10_bolt_cap_diameter=16;
m10_bolt_cap_thickness=6;

module MountingHoles() {
    for(z_pos=clamp_holes_z) {
        translate([
            m8_nut_hole_boss_width / 2,
            m8_nut_hole_boss_thickness,
            z_pos
        ]) {
            translate([0, 10, 0]) rotate([90, 0, 0]) cylinder_outer(20, (5/2) + 0.2);
        }
    }
}

module MountingNutHoles() {
    difference() {
        cube([
            m8_nut_hole_boss_width,
            m8_nut_hole_boss_thickness,
            ((HousingZ / 3) * 2) + m8_nut_width
        ]);

        for(z_pos=clamp_holes_z) {
            translate([
                m8_nut_hole_boss_width / 2,
                m8_nut_thickness,
                z_pos
            ]) {
                rotate([90, 0, 0]) nutHole(8, tolerance=0.1);
                translate([0, 8, 0]) rotate([90, 0, 0]) cylinder_outer(m8_nut_hole_boss_thickness, (8/2) + 0.2);
            }
        }
    }

}

module MountingNutHoleAssembly(boss, punchout) {
    if(punchout) MountingHoles();
    if(boss) MountingNutHoles();
}

module PositionedMountingNutHoleAssembly(boss, punchout) {
    translate([
        (HousingX / 2) - m8_nut_hole_boss_width / 2,
        HousingY - m8_nut_hole_boss_thickness,
        0
    ]) MountingNutHoleAssembly(boss, punchout);
}

ClampY=107;
ClampX=m10_nut_hole_boss_width;

module Clamp() {
    difference() {
        cube([ClampX, 107, HousingY]);
        translate([0, 15, 20]) cube([
            (ClampX),
            (ClampY - 15),
            (HousingY - 20 - 10)
        ]);
        //46
        translate([0, 15, 0]) cube([
            (ClampX - 46) / 2,
            ClampY - 15,
            20
        ]);
        translate([ClampX - (ClampX - 46) / 2, 15, 0]) cube([
            (ClampX - 46) / 2,
            ClampY - 15,
            20
        ]);
        // m10 nut hole
        m10_xy_trans = [(ClampX - m10_nut_width), (ClampY * .75)];
        translate([
            m10_xy_trans.x,
            m10_xy_trans.y,
            20 - m10_nut_thickness
        ]) nutHole(10, tolerance=0.05);

        translate([
            m10_xy_trans.x,
            m10_xy_trans.y,
            0
        ]) cylinder_outer(30, (10/2) + 0.2);

        // m8 bolt hols through side & cap notch out
        cap_depth=7.5;
        for(z_pos=clamp_holes_z) {
            translate([
                ClampX / 2,
                15,
                z_pos
            ]) {
                translate([0, 10, 0]) rotate([90, 0, 0]) cylinder_outer(30, (8/2) + 0.2);
                translate([0, 0, 0]) rotate([90, 0, 0]) cylinder_outer(cap_depth, (m8_bolt_cap_diameter/2) + 2 + 0.2);
            }
        }
    }
}

module ClampScrewHead() {
    translate([0, 0, 20]) rotate([180, 0, 0]) difference() {
        cone_outer(20, m10_nut_hole_boss_width / 2, 25);
        nutHole(10);
        translate([0, 0, 5]) nutHole(10);
        cylinder_mid(20, (10 / 2) + 0.2);
        x_dist=19.6*.75;
        y_dist=-20;
        x_dim=10;
        y_dim=abs(y_dist) * 2;
        z_dim=10;
        translate([-x_dist-x_dim, y_dist, 0]) cube([x_dim, y_dim, z_dim]);
        translate([x_dist, y_dist, 0]) cube([x_dim, y_dim, z_dim]);
    }
}

module ClampScrewHandle() {
    handle_x=100;
    handle_y=m10_bolt_cap_diameter * 2;
    thread_depth=5;
    bolt_cube_dim = [
        10.6 + 0.4,
        10.6 + 0.4,
        6 + 0.2
    ];
    handle_z=m10_bolt_cap_thickness + bolt_cube_dim.z + thread_depth + 5;

    bolt_mushroom_dia=24.00;
    bolt_mushroom_rad=bolt_mushroom_dia/2;
    bolt_mushroom_height=6.0;

    fillet_dim=5;

    module handle_body() {
        difference() {
            cube([handle_x, handle_y, handle_z]);
            translate([
                handle_x / 2,
                handle_y / 2,
                0
            ]) {
                //area for bolt thread
                cylinder_outer(thread_depth, (10 / 2) + 0.2);
                //area for bolt square
                translate([
                    -bolt_cube_dim.x/2,
                    -bolt_cube_dim.y/2,
                    thread_depth
                ]) cube(bolt_cube_dim);
                //area for bolt cap
                translate([
                    0,
                    0,
                    thread_depth + bolt_cube_dim.z
                ]) cylinder_outer(bolt_mushroom_height + 0.2, bolt_mushroom_rad + 0.2);
                // m3 bolts & nuts
                for(x_pos=[20, 80]) {
                    translate([
                        x_pos, 0, handle_z / 2
                    ]) {
                        translate([-handle_x / 2, handle_y / 2, 0]) rotate([90, 0, 00]) cylinder_outer(handle_y, (3/2) + 0.15);
                        translate([-handle_x / 2, handle_y / 2, 0]) rotate([90, 0, 0]) nutHole(3);
                    }
                }

            }

            //lower fillet
            chamfer1_points = [
                [-0.1, -0.1],
                [fillet_dim, fillet_dim],
                [fillet_dim, -0.1],
            ];

            chamfer2_points = [
                [-0.1, fillet_dim],
                [fillet_dim, fillet_dim],
                [fillet_dim, -0.1],
            ];

            translate([0, 0, fillet_dim]) rotate([0, 90, 0]) linear_extrude(handle_x) polygon(points=chamfer1_points);
            translate([0, handle_y - fillet_dim, fillet_dim]) rotate([0, 90, 0]) linear_extrude(handle_x) polygon(points=chamfer2_points);
            translate([handle_x - fillet_dim, handle_y, 0]) rotate([90, 0, 0]) linear_extrude(handle_y) polygon(points=chamfer1_points);
            translate([fillet_dim, handle_y, fillet_dim]) rotate([90, 180, 0]) linear_extrude(handle_y) polygon(points=chamfer2_points);

            translate([0, handle_y, handle_z]) rotate([180, 0, 0]) {
                translate([0, 0, fillet_dim]) rotate([0, 90, 0]) linear_extrude(handle_x) polygon(points=chamfer1_points);
                translate([0, handle_y - fillet_dim, fillet_dim]) rotate([0, 90, 0]) linear_extrude(handle_x) polygon(points=chamfer2_points);
                translate([handle_x - fillet_dim, handle_y, 0]) rotate([90, 0, 0]) linear_extrude(handle_y) polygon(points=chamfer1_points);
                translate([fillet_dim, handle_y, fillet_dim]) rotate([90, 180, 0]) linear_extrude(handle_y) polygon(points=chamfer2_points);
            }


        }
    }

    intersection() {
        handle_body();
        cube([handle_x, handle_y / 2, handle_z]);
    }

    translate([0, handle_y * 3, 0]) intersection() {
        handle_body();
        translate([0, handle_y / 2, 0]) cube([handle_x, handle_y / 2, handle_z]);
    }

}


module EncoderClamp() {
    dx=26;
    dimensions = [
        39,
        m3_fastener_nut_width * 2,
        m3_fastener_nut_thickness * 2
    ];

    offset=(dimensions.x - dx) / 2;

    difference() {
        cube(dimensions);
        translate([offset, dimensions.y / 2, 0 ]) {
            cylinder_outer(dimensions.z, 1.5 + 0.2);
            nutHole(3);
        }
        translate([dimensions.x - offset, dimensions.y / 2, 0 ]) {
            cylinder_outer(dimensions.z, 1.5 + 0.2);
            nutHole(3);
        }
    }
}


module PositionedInterfaceAssembly(printed_parts_only=false) {
    translate([
        35,
        HousingInternalY - 45,
        MinWallThickness
    ]) InterfaceAssembly(printed_parts_only);
}

//base
m3_fastener_nut_width=6.4;
m3_fastener_nut_thickness=2.40;

fastener_z_y_rot = [
    [HousingY - m3_fastener_nut_width - MinWallThickness, HousingZ - DoubleMinWallThickness - m3_fastener_nut_width, []],
    [DoubleMinWallThickness + m3_fastener_nut_width * 2, m3_fastener_nut_width + MinWallThickness, []],
];

module Base(printed_parts_only=false) {
    difference() {
        union() {
            // lower shell
            translate([0, MinWallThickness, 0]) difference() {
                cube([HousingX, HousingY - MinWallThickness, LowerHousingZ]);
                translate([MinWallThickness, 0, MinWallThickness]) cube([HousingInternalX, HousingInternalY, LowerHousingZ - MinWallThickness]);
            }
            //curved sides
            difference() {
                translate([
                    0,
                    ThrottleQuadY - ThrottleQuadUpperY + MinWallThickness,
                    ThrottleQuadLowerZ - MinWallThickness
                ]) rotate([0, 90, 0]) oval_prism(
                    HousingX,
                    ThrottleQuadY - ThrottleQuadUpperY,
                    ThrottleQuadZ - ThrottleQuadLowerZ)
                ;
                // cubes to clean up
                translate([0, HousingY, -HousingZ]) cube([HousingX, HousingY, HousingZ*2]);
                translate([0, 0, -HousingZ]) cube([HousingX, HousingY, HousingZ]);

                translate([
                    MinWallThickness,
                    ThrottleQuadY - ThrottleQuadUpperY + MinWallThickness,
                    ThrottleQuadLowerZ - MinWallThickness
                ]) rotate([0, 90, 0]) oval_prism(
                    HousingX - 2 * MinWallThickness,
                    ThrottleQuadY - ThrottleQuadUpperY,
                    ThrottleQuadZ - ThrottleQuadLowerZ)
                ;
            }
            //sides and rear
            translate([
                0,
                ThrottleQuadY - ThrottleQuadUpperY,
                0
                ]) {
                // sides and rear wall
                difference() {
                    cube([HousingX, ThrottleQuadUpperY, ThrottleQuadZ - MinWallThickness]);
                    // main void
                    translate([
                        MinWallThickness,
                        0,
                        MinWallThickness
                    ]) cube([
                        HousingX - DoubleMinWallThickness,
                        ThrottleQuadUpperY - MinWallThickness,
                        ThrottleQuadZ - MinWallThickness]
                    );
                    // TODO: rear cut out for USB port
                    PositionedArduinoCutouts();
                    // TODO: rear holes for clamp piece
                    // TODO: rear holes for lcd cover
                    // TODO: side holes for lcd cover
                }
            }
        }
        //cut out for usb and power
        PositionedArduinoCutouts();

        //cut out for bracket nuts
        PositionedMountingNutHoleAssembly(false, true);

        //punch outs for fixing screws
        for(z_y_rot = fastener_z_y_rot) {
            translate([HousingX, 0, 0]) rotate([0, 270, 0]) translate([z_y_rot[0], z_y_rot[1], 0]) cylinder_outer(HousingX, 3/2 + working_fit);
        };
    }
    // LCD
    PositionedLCDAssembly(printed_parts_only);
    // Wheel
    PositionedWheelAssembly(printed_parts_only);
    //
    PositionedArduinoAssembly(printed_parts_only);
    // Interface board
    PositionedInterfaceAssembly(printed_parts_only);
    // Boss for bracket nuts
    PositionedMountingNutHoleAssembly(true, false);
}

module QuadrantProfile(width) {
    rotate([0, 90, 0]) linear_extrude(width) projection() rotate([0, 270, 0]) ThrottleQuadrant();
}

module _FastenerTabs() {
    holder_x=m3_fastener_nut_thickness*1.5;
    for(z_y_rot = fastener_z_y_rot) {
        for(x_pos_hole_rot_cube_x_z=[
            [-0.6, 90, m3_fastener_nut_width*1.5, m3_fastener_nut_width*1.5],
            [HousingX-holder_x - DoubleMinWallThickness - 0.6, 270, m3_fastener_nut_width*2, m3_fastener_nut_width*2]
        ]) {
            _y = (z_y_rot[0] < LowerHousingZ) ? 13 : 12;
            _z = (z_y_rot[0] < LowerHousingZ) ? 12 : 13;

            translate([
                DoubleMinWallThickness + x_pos_hole_rot_cube_x_z[0],
                z_y_rot[1],
                z_y_rot[0]
            ]) difference() {
                cube([
                    holder_x,
                    _y,
                    _z
                ], center=true);
                rotate([0, x_pos_hole_rot_cube_x_z[1], 0]) nutHole(3, tolerance = 0.1);
            }
        }
    }
}

module Cover() {
    difference() {
        union() {
            _FastenerTabs();
            difference() {
                ThrottleQuadrant();
                // carves out the main part of the shell
                translate([0, MinWallThickness, -MinWallThickness]) QuadrantProfile(MinWallThickness);
                translate([MinWallThickness, DoubleMinWallThickness, -DoubleMinWallThickness]) QuadrantProfile(MinWallThickness);
                translate([DoubleMinWallThickness, MinWallThickness, -MinWallThickness]) QuadrantProfile(HousingInternalX - DoubleMinWallThickness);
                translate([HousingX - DoubleMinWallThickness, DoubleMinWallThickness, -DoubleMinWallThickness]) QuadrantProfile(MinWallThickness);
                translate([HousingX - MinWallThickness, MinWallThickness, -MinWallThickness]) QuadrantProfile(MinWallThickness+.1);

                // the strips at the top and bottom that make way for the bottom/rear shells
                translate([0, MinWallThickness, 0]) cube([HousingX, MinWallThickness, MinWallThickness]);
                translate([0, ThrottleQuadY - MinWallThickness, ThrottleQuadZ - DoubleMinWallThickness]) cube([HousingX, MinWallThickness, MinWallThickness]);

                // cubes around to clean it up
                translate([0, HousingY, -HousingZ]) cube([HousingX, HousingY, HousingZ*2]);
                translate([0, 0, -HousingZ]) cube([HousingX, HousingY, HousingZ]);
                // carve out the LCD screen
                PositionedLCDAssembly(breakThrough=true);
                // carve out notch for wheel
                PositionedWheelAssembly();
                // punch out for reset button
                PositionedResetButton();
                // punch out for mode switch
                PositionedToggleSwitchCutouts();
            }
        }
        // screw holes
        for(z_y_rot = fastener_z_y_rot) {
            translate([HousingX, 0, 0]) rotate([0, 270, 0]) translate([z_y_rot[0], z_y_rot[1], 0]) cylinder_outer(HousingX, 3/2 + working_fit, center=false);
        };
    }
}

LCDAssembly(bracketOnly=true);

translate([150, 0, 0]) Base(true);

translate([300, 0, 0]) Cover();

translate([450, 0, 0]) Clamp();

translate([550, 0, 0]) ClampScrewHead();

translate([600, 0, 0]) ClampScrewHandle();

translate([0, 50, 0]) EncoderClamp();
