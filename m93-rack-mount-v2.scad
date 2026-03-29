// ============================================================
// Lenovo ThinkCentre M93 Tiny — 10" Rack Mount (1U, 4-post) v2
// Material-optimised: floor slots, wall slots, recessed floor
// centre, open rear between crossbar and side walls
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
gusset_r           = 8.0;

// --- Floor thinning ---
// M93 feet are near the edges — recess the centre of the floor
// Leave a 20mm rib at each end and a 2mm thin skin in the middle
floor_edge_rib     = 20.0;   // solid rib width at faceplate + rear ends
floor_thin_t       = 1.5;    // thinned floor thickness in recessed centre
// full floor thickness = wall_t = 4mm, so recess depth = wall_t - floor_thin_t
floor_recess_d     = wall_t - floor_thin_t;  // 2.5mm recess

// --- Floor lightening slots ---
// 3 rectangular slots cut through thinned floor area, separated by ribs
floor_slot_count   = 3;
floor_slot_margin  = 10.0;   // margin from side walls before first/last slot
floor_rib_w        = 8.0;    // rib width between slots

// --- Side wall slots ---
wall_slot_h        = 24.0;   // slot height (leaves top+bottom structural band)
wall_slot_w        = 28.0;   // individual slot width
wall_slot_rib      = 8.0;    // rib between slots
wall_slot_margin   = 12.0;   // margin from faceplate + rear crossbar
wall_slot_z        = (rack_1u_height - wall_slot_h) / 2;  // centred vertically

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
    // Only the crossbar strip itself — no fill between side walls
    // Left ear portion
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
        // Open the middle between the side walls — cut out everything except the ears
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

module side_wall_slotted(side) {
    x_pos = (side == 0) ? ear_w : rack_width - ear_w - wall_t;
    // How many slots fit in the wall run minus margins?
    slot_run = tray_run - 2 * wall_slot_margin;
    // Number of slots that fit
    n_slots = floor((slot_run + wall_slot_rib) / (wall_slot_w + wall_slot_rib));
    // Total width of slots + ribs, centred in slot_run
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
    // Floor with:
    // 1. Recessed centre (thinned skin)
    // 2. Lightening slots through the thinned region
    floor_x    = ear_w;
    floor_y    = face_t;
    floor_w    = rack_usable_width;
    floor_full = tray_run;

    // Recessed zone runs between the two edge ribs
    recess_y_start = floor_edge_rib;
    recess_y_len   = floor_full - 2 * floor_edge_rib;

    // Slot dimensions within recessed zone
    slot_zone_w  = floor_w - 2 * floor_slot_margin;
    total_slot_w_floor = slot_zone_w
                       - (floor_slot_count - 1) * floor_rib_w;
    slot_w_each  = total_slot_w_floor / floor_slot_count;
    slot_x_start = floor_slot_margin;

    translate([floor_x, floor_y, 0])
    difference() {
        // Full floor solid
        cube([floor_w, floor_full, wall_t]);

        // Centre recess (leaves thin skin at bottom)
        translate([-0.1, recess_y_start, floor_thin_t])
        cube([floor_w + 0.2, recess_y_len, floor_recess_d + 0.1]);

        // Lightening slots — cut fully through the thinned area
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
