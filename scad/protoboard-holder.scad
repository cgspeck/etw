/* [Hidden] */
$fn=72;

ProtoBoardHolder(136, 76);

module ProtoBoardHolder(
    dx,
    dy,
    frame_width=2,
    frame_height=6,
    fixing_tab_location="inside", // [none, inside, outside]
    tab_count=1,
    tab_hole_diameter=3, // Defaults are based on a #4 screw
    tab_head_diameter=6,
    tab_height=1.2,
    mount_hole_diameter=2.5, // Defaults are based on a #4 screw
    mount_post_diameter=2.8,
    mount_post_height=2.2,
    mount_1_type="hole", // [hole, post]
    mount_2_type="hole",
    mount_3_type="hole",
    mount_4_type="hole",
    pillar_height=3,
    with_support=true,
    board_y=20,
    board_y_clearance=2,
    support_hole_dia=2.5, // #4 screw
    only_support=false
) {
    inner_fn=32;
    mount_hole_rad=mount_hole_diameter / 2;
    mount_post_rad=mount_post_diameter / 2;

    pillar_radius=max([mount_hole_diameter, mount_post_diameter]);
    actual_pillar_height=frame_height + pillar_height;

    positions=[
        [0, dy, 0],
        [dx, dy, 0],
        [dx, 0, 0],
        [0, 0, 0]
    ];

    position_types=[
        [positions[0], mount_1_type],
        [positions[1], mount_2_type],
        [positions[2], mount_3_type],
        [positions[3], mount_4_type]
    ];

    half_frame_width = frame_width / 2;

    // EXT LIB
    module cylinder_outer(height,radius,center=false){
        fudge = 1/cos(180/inner_fn);
        cylinder(h=height,r=radius*fudge, center=center);
    }

    // Pillars first
    module Pillar() {
        cylinder(actual_pillar_height, pillar_radius, pillar_radius);
    }

    if (!only_support) {
        for(position_type=position_types) {
            if(position_type[1] == "hole") {
                difference() {
                    translate(position_type[0]) Pillar();
                    translate(position_type[0]) cylinder_outer(actual_pillar_height, mount_hole_rad);
                }
            } else {
                union() {
                    translate(position_type[0]) Pillar();
                    translate(position_type[0]) cylinder_outer(actual_pillar_height + mount_post_height, mount_post_rad);
                }
            }
        }
    }

    // Frame
    outer_rect_x_len = positions[1].x + frame_width;
    outer_rect_y_len = positions[1].y + frame_width;
    outer_rect_x_pos = positions[0].x - half_frame_width;
    outer_rect_y_pos = positions[3].y - half_frame_width;

    inner_rect_x_len = outer_rect_x_len - frame_width * 2;
    inner_rect_y_len = outer_rect_y_len - frame_width * 2;
    inner_rect_x_pos = outer_rect_x_pos + frame_width;
    inner_rect_y_pos = outer_rect_y_pos + frame_width;

    if (!only_support) {
        difference() {
            translate([outer_rect_x_pos, outer_rect_y_pos, 0]) cube([outer_rect_x_len, outer_rect_y_len, frame_height]);
            translate([inner_rect_x_pos, inner_rect_y_pos, 0]) cube([inner_rect_x_len, inner_rect_y_len, frame_height]);

            // holes through the frame where needed
            for(position_type=position_types) {
                if(position_type[1] == "hole") {
                    translate(position_type[0]) cylinder_outer(actual_pillar_height, mount_hole_rad);
                }
            }
        }
    }

    tab_hole_rad=tab_hole_diameter/2;
    tab_head_rad=tab_head_diameter/2;
    tab_x_len=tab_head_diameter * 2;
    tab_y_len=tab_x_len;

    tab_y_positions=[
        (positions[0].y / 3) * 1,
        (positions[0].y / 3) * 2,
    ];

    tab_x_positions=[
        positions[0].x,
        positions[1].x
    ];

    module FixingTab() {
        difference() {
            cube([tab_x_len, tab_y_len, tab_height]);
            translate([tab_x_len / 2, tab_y_len / 2, 0]) cylinder_outer(tab_hole_rad, tab_height);
        }
    }
    // tabs
    if (!only_support) {
        if (fixing_tab_location != "none") {
            for (i=[1:tab_count]) {
                tab_y_position = (positions[0].y / (tab_count + 1)) * i;
                if(fixing_tab_location == "inside") {
                    translate([frame_width / 2, tab_y_position - tab_y_len / 2, 0]) FixingTab();
                    translate([inner_rect_x_len - tab_x_len + frame_width /2, tab_y_position - tab_y_len / 2, 0]) FixingTab();
                } else  {
                    translate([-tab_x_len - frame_width / 2, tab_y_position - tab_y_len / 2, 0]) FixingTab();
                    translate([outer_rect_x_len - frame_width / 2, tab_y_position - tab_y_len / 2, 0]) FixingTab();
                }
            }
        }
    }

    if (with_support) {
        ShelfPoints = [
            [0, 0],
            [0, board_y + board_y_clearance],
            [board_y + board_y_clearance, board_y + board_y_clearance]
        ];
        hole_len = ShelfPoints[1][1] / 4;
        support_hole_rad = support_hole_dia / 2;
        difference() {

            union() {
                translate([
                    frame_width,
                    -(board_y - dy) / 2,
                    0]) {
                    rotate([90, 90, 90]) linear_extrude(tab_x_len) polygon(ShelfPoints);
                }

                translate([
                    dx - tab_x_len - frame_width,
                    -(board_y - dy) / 2,
                    0]) {
                    rotate([90, 90, 90]) linear_extrude(tab_x_len) polygon(ShelfPoints);
                }
            }
            for (i=[1:tab_count]) {
                tab_y_position = (positions[0].y / (tab_count + 1)) * i;
                translate([
                    tab_x_len / 2 + frame_width / 2,
                    tab_y_position,
                    -hole_len
                ]) cylinder_outer(hole_len, support_hole_rad);

                translate([
                    inner_rect_x_len - tab_x_len / 2 + frame_width /2,
                    tab_y_position,
                    -hole_len
                ]) cylinder_outer(hole_len, support_hole_rad);
            }
        }
    }
}
