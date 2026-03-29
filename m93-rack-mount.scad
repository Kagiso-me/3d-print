// ============================================================
// Lenovo ThinkCentre M93 Tiny — 10" Rack Mount (1U, 4-post)
// Single print, no supports required (print faceplate-face-down)
// ============================================================

// --- Rack dimensions ---
rack_width         = 254.0;   // 10" rack total panel width
rack_usable_width  = 222.25;  // usable width between posts
rack_1u_height     = 44.45;   // 1U panel height
post_depth         = 200.0;   // front post face to rear post face

// --- M93 Tiny dimensions (on its side) ---
m93_w              = 177.8;   // width of unit
m93_h              = 34.3;    // height of unit (sitting on side)
m93_d              = 182.0;   // depth of unit

// --- Wall / structure thicknesses ---
wall_t             = 4.0;     // general wall / floor thickness
face_t             = 5.0;     // faceplate thickness
rear_t             = 5.0;     // rear crossbar thickness
gusset_r           = 8.0;     // corner gusset radius

// --- Mounting holes ---
m6_hole_d          = 6.5;     // M6 clearance hole diameter
// Rack ear width = (rack_width - rack_usable_width) / 2 = 15.875mm each side
ear_w              = (rack_width - rack_usable_width) / 2;  // 15.875
// Hole centred in ear, centred vertically in 1U
hole_x             = ear_w / 2;                             // 7.94 from panel edge
hole_y             = rack_1u_height / 2;                    // 22.23 from bottom

// --- Derived inner cavity ---
// Inner cavity sits centred left-right within usable width
// Side walls sit on the floor, floor spans usable width
inner_w            = rack_usable_width - 2 * wall_t;        // 214.25
inner_h            = rack_1u_height - wall_t;               // 40.45 (open top)
// Tray depth from back of faceplate to back of rear crossbar
tray_d             = post_depth - face_t - rear_t;          // 190mm inner run

// M93 sits centred left-right, on the floor
m93_offset_x       = (inner_w - m93_w) / 2;                // side gap each side
m93_offset_z       = 0;                                     // sits on floor
// M93 front face flush with back of faceplate
m93_offset_y       = 0;

// ============================================================
// MODULES
// ============================================================

module gusset_fillet(length, r) {
    // 45-degree triangular gusset along Y axis
    // Place at corner, will be differenced out to round internal corners
    translate([0, 0, 0])
    rotate([90, 0, 0])
    linear_extrude(height = length)
    polygon(points = [[0, 0], [r, 0], [0, r]]);
}

module rack_ear(side) {
    // side: 0 = left, 1 = right
    mirror_x = (side == 1) ? -1 : 1;
    translate([side == 1 ? rack_width - ear_w : 0, 0, 0])
    difference() {
        cube([ear_w, face_t, rack_1u_height]);
        // M6 mounting hole
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
    }
}

module faceplate() {
    // Faceplate spans full rack width, sits at Y=0
    // Cutout: tight rectangle for M93 front face, centred left-right and vertically
    cutout_w = m93_w + 0.4;  // 0.4mm clearance each side
    cutout_h = m93_h + 0.4;
    cutout_x = (rack_width - cutout_w) / 2;
    cutout_z = (rack_1u_height - cutout_h) / 2;

    difference() {
        // Solid faceplate
        cube([rack_width, face_t, rack_1u_height]);
        // M93 front I/O cutout
        translate([cutout_x, -0.1, cutout_z])
        cube([cutout_w, face_t + 0.2, cutout_h]);
        // Left ear hole (already in rack_ear but faceplate is separate solid here
        // — holes handled in rack_ear module which is unioned)
    }
}

module side_wall(side) {
    // side: 0 = left, 1 = right
    // Walls run from back of faceplate to front of rear crossbar
    wall_run = post_depth - face_t - rear_t;  // 190mm
    x_pos = (side == 0) ? ear_w : rack_width - ear_w - wall_t;
    translate([x_pos, face_t, 0])
    cube([wall_t, wall_run, rack_1u_height]);
}

module floor_panel() {
    // Floor spans usable width, runs full tray depth (faceplate back to rear crossbar front)
    floor_run = post_depth - face_t - rear_t;
    translate([ear_w, face_t, 0])
    cube([rack_usable_width, floor_run, wall_t]);
}

module gussets() {
    gusset_run = post_depth - face_t - rear_t;

    // Floor-to-left-wall gusset (internal, along Y)
    translate([ear_w + wall_t, face_t, wall_t])
    rotate([0, -90, 0])
    rotate([0, 0, 90])
    linear_extrude(height = gusset_run)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Floor-to-right-wall gusset
    translate([rack_width - ear_w, face_t, wall_t])
    rotate([0, 0, 90])
    rotate([0, 90, 0])
    linear_extrude(height = gusset_run)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-floor gusset (across full usable width)
    translate([ear_w, face_t, wall_t])
    rotate([90, 0, 0])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Rear crossbar-to-floor gusset
    translate([ear_w, post_depth - rear_t, wall_t])
    rotate([-90, 0, 0])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-left-wall gusset
    translate([ear_w + wall_t, face_t, 0])
    rotate([90, 0, -90])
    linear_extrude(height = gusset_r)
    polygon(points = [[0,0],[gusset_r,0],[0,gusset_r]]);

    // Faceplate-to-right-wall gusset
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
    side_wall(0);
    side_wall(1);
    floor_panel();
    gussets();
}

// ============================================================
// PREVIEW GHOST: M93 unit position (comment out before export)
// ============================================================
// Uncomment to visualise M93 placement:
/*
%translate([
    ear_w + wall_t + m93_offset_x,
    face_t,
    wall_t
])
cube([m93_w, m93_d, m93_h]);
*/
