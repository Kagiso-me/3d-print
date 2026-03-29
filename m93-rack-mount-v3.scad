// ============================================================
// Lenovo ThinkCentre M93 Tiny — 10" Rack Mount (1U, 4-post) v3
// v2 + retention wall behind M93 with large central cutout
// Single print, no supports required (print faceplate-face-down)
// ============================================================

// --- Rack dimensions ---
rack_width         = 254.0;
rack_usable_width  = 222.25;
rack_1u_height     = 44.45;
post_depth         = 200.0;

// --- M93 Tiny dimensions (on its side) ---
m93_w              = 177.8;
m93_h              = 34.3;
m93_d              = 182.0;

// --- Wall / structure thicknesses ---
wall_t             = 4.0;
face_t             = 5.0;
rear_t             = 5.0;
ret_t              = 3.0;    // retention wall thickness
gusset_r           = 8.0;

// --- Retention wall position ---
// M93 rear face is at: face_t + m93_d = 5 + 182 = 187mm
// Add 2mm gap → retention wall front face at 189mm
ret_gap            = 2.0;
ret_y              = face_t + m93_d + ret_gap;  // 189mm from origin

// --- Retention wall cutout (large central rectangle, 15mm border) ---
ret_border         = 15.0;
// Cutout is relative to the M93 footprint projected onto the wall
// M93 is centred left-right within usable width
m93_x_centre       = rack_width / 2;
m93_x_left         = m93_x_centre - m93_w / 2;   // left edge of M93
// Cutout: inset ret_border from each side of M93 footprint
ret_cut_x          = m93_x_left + ret_border;
ret_cut_w          = m93_w - 2 * ret_border;
// Vertically: M93 sits on floor (wall_t from bottom), height = m93_h
ret_cut_z          = wall_t + ret_border;
ret_cut_h          = m93_h - 2 * ret_border;

// --- Floor thinning ---
floor_edge_rib     = 20.0;
floor_thin_t       = 1.5;
floor_recess_d     = wall_t - floor_thin_t;  // 2.5mm

// --- Floor lightening slots ---
floor_slot_count   = 3;
floor_slot_margin  = 10.0;
floor_rib_w        = 8.0;

// --- Side wall slots ---
wall_slot_h        = 24.0;
wall_slot_w        = 28.0;
wall_slot_rib      = 8.0;
wall_slot_margin   = 12.0;
wall_slot_z        = (rack_1u_height - wall_slot_h) / 2;

// --- Mounting holes ---
m6_hole_d          = 6.5;
ear_w              = (rack_width - rack_usable_width) / 2;  // 15.875
hole_x             = ear_w / 2;
hole_y             = rack_1u_height / 2;

// --- Derived ---
inner_w            = rack_usable_width - 2 * wall_t;
tray_run           = post_depth - face_t - rear_t;  // 190mm

// ============================================================
// MODULES
// ============================================================

module rack_ear(side) {
    translate([side == 1 ? rack_width - ear_w : 0, 0, 0])
    difference() {
        cube([ear_w, face_t, rack_1u_height]);
        translate([hole_x, face_t / 2, hole_y])
        rotate([90, 0, 0])
        cylinder(d = m6_hole_d, h = face_t + 1, center = true, $fn = 32);
    }
}

module rear_crossbar() {
    translate([0, post_depth - rear_t, 0])
    difference() {
        cube([rack_width, rear_t, rack_1u_height]);
        // Left M6 hole
        translate([hole_x, rear_t / 2, hole_y])
        rotate([90, 0, 0])
        cylinder(d = m6_hole_d, h = rear_t + 1, center = true, $fn = 32);
        // Right M6 hole
        translate([rack_width - hole_x, rear_t / 2, hole_y])
        rotate([90, 0, 0])
        cylinder(d = m6_hole_d, h = rear_t + 1, center = true, $fn = 32);
        // Open middle between side walls
        translate([ear_w + wall_t, -0.1, wall_t])
        cube([
            rack_usable_width - 2 * wall_t,
            rear_t + 0.2,
            rack_1u_height - wall_t + 0.1
        ]);
    }
}

module faceplate() {
    cutout_w = m93_w + 0.4;
    cutout_h = m93_h + 0.4;
    cutout_x = (rack_width - cutout_w) / 2;
    cutout_z = (rack_1u_height - cutout_h) / 2;

    difference() {
        cube([rack_width, face_t, rack_1u_height]);
        translate([cutout_x, -0.1, cutout_z])
        cube([cutout_w, face_t + 0.2, cutout_h]);
    }
}

module retention_wall() {
    // Spans between the two side walls (usable width), full 1U height
    // Has a large central cutout leaving a 15mm border around the M93 rear face
    translate([ear_w, ret_y, 0])
    difference() {
        cube([rack_usable_width, ret_t, rack_1u_height]);
        // Large central cutout — coords relative to this translate
        translate([ret_cut_x - ear_w, -0.1, ret_cut_z])
        cube([ret_cut_w, ret_t + 0.2, ret_cut_h]);
    }
}

module side_wall_slotted(side) {
    x_pos = (side == 0) ? ear_w : rack_width - ear_w - wall_t;
    slot_run = tray_run - 2 * wall_slot_margin;
    n_slots = floor((slot_run + wall_slot_rib) / (wall_slot_w + wall_slot_rib));
    total_slot_w = n_slots * wall_slot_w + (n_slots - 1) * wall_slot_rib;
    slot_start_y = face_t + wall_slot_margin + (slot_run - total_slot_w) / 2;

    translate([x_pos, face_t, 0])
    difference() {
        cube([wall_t, tray_run, rack_1u_height]);
        for (i = [0 : n_slots - 1]) {
            translate([
                -0.1,
                slot_start_y - face_t + i * (wall_slot_w + wall_slot_rib),
                wall_slot_z
            ])
            cube([wall_t + 0.2, wall_slot_w, wall_slot_h]);
        }
    }
}

module floor_panel_optimised() {
    floor_x    = ear_w;
    floor_y    = face_t;
    floor_w    = rack_usable_width;
    floor_full = tray_run;

    recess_y_start = floor_edge_rib;
    recess_y_len   = floor_full - 2 * floor_edge_rib;

    slot_zone_w         = floor_w - 2 * floor_slot_margin;
    total_slot_w_floor  = slot_zone_w - (floor_slot_count - 1) * floor_rib_w;
    slot_w_each         = total_slot_w_floor / floor_slot_count;
    slot_x_start        = floor_slot_margin;

    translate([floor_x, floor_y, 0])
    difference() {
        cube([floor_w, floor_full, wall_t]);

        // Centre recess
        translate([-0.1, recess_y_start, floor_thin_t])
        cube([floor_w + 0.2, recess_y_len, floor_recess_d + 0.1]);

        // Lightening slots
        for (i = [0 : floor_slot_count - 1]) {
            slot_x = slot_x_start + i * (slot_w_each + floor_rib_w);
            translate([slot_x, recess_y_start + 10, -0.1])
            cube([slot_w_each, recess_y_len - 20, wall_t + 0.2]);
        }
    }
}

module gussets() {
    // Floor-to-left-wall
    translate([ear_w + wall_t, face_t, wall_t])
    rotate([0, -90, 0])
    rotate([0, 0, 90])
    linear_extrude(height = tray_run)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Floor-to-right-wall
    translate([rack_width - ear_w, face_t, wall_t])
    rotate([0, 0, 90])
    rotate([0, 90, 0])
    linear_extrude(height = tray_run)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-floor
    translate([ear_w, face_t, wall_t])
    rotate([90, 0, 0])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Rear-to-floor
    translate([ear_w, post_depth - rear_t, wall_t])
    rotate([-90, 0, 0])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-left-wall
    translate([ear_w + wall_t, face_t, 0])
    rotate([90, 0, -90])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-right-wall
    translate([rack_width - ear_w - wall_t, face_t, 0])
    rotate([90, 0, 90])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);
}

// ============================================================
// ASSEMBLY
// ============================================================

union() {
    faceplate();
    rack_ear(0);
    rack_ear(1);
    rear_crossbar();
    retention_wall();
    side_wall_slotted(0);
    side_wall_slotted(1);
    floor_panel_optimised();
    gussets();
}

// ============================================================
// PREVIEW GHOST: M93 unit position
// ============================================================
/*
%translate([
    ear_w + wall_t + (inner_w - m93_w) / 2,
    face_t,
    wall_t
])
cube([m93_w, m93_d, m93_h]);
*/
