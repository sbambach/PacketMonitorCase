// This design is parameterized based on holes in a PCB.
// It assumes that the PCB has 4 holes, evenly spaced as
// corners of a rectangle.

// Note: width refers to X axis, depth to Y, height to Z
bottom = true;
top = true;
flash_show = true;
usb = true;
reset= false;
flash = true;
// Edit these parameters for your own board dimensions
wall_thickness = 2;
floor_thickness = 2;
ceiling_thickness = 2;

bottom_wall_height = 6;
top_wall_height = 3;

//window_x = 24.6; // v3
window_x = 31.0; // Bv2
//window_y = 14.4; // v3
window_y = 16.0; // Bv2
window_ridge = 2;
// Total height of box = floor_thickness + ceiling_thickness + bottom_wall_height + top_wall_height

//hole_spacing_x = 52.8; // v3
hole_spacing_x = 59.0; // B v2
hole_spacing_y = 22.8;

hole_diameter = 2.5;
standoff_diameter = 4.4;
standoff_top = true;

// How much the PCB needs to be raised from the bottom
// to leave room for solderings and whatnot
standoff_height = 3;
board_thickness = 1.6;
facets = 6;

// padding between standoff and wall
padding_left = 1;
padding_right = 1;
padding_back = 1;
padding_front = 1;

// ridge where bottom and top off box can overlap
// Make sure this isn't less than top_wall_height
ridge_height = 2;

// flash button
button_diameter = 4.0;
button_spacing = 0.5;
button_thickness = 2.5;
button_height = wall_thickness + standoff_height - button_thickness;
button_holder_diameter = button_diameter + 2.0;
button_holder_spacing = 0.5;
button_holder_height = 1.0;

//-------------------------------------------------------------------

// Calculated globals


module ceilingless_box(width, depth, height) {
    // Floor
    cube([width, depth, floor_thickness]);
    
    // Left wall
    translate([0, 0, floor_thickness])
        cube([
            wall_thickness,
            depth,
            height]);
    
    // Right wall
    translate([width - wall_thickness, 0, floor_thickness])
        cube([
            wall_thickness,
            depth,
            height]);
    
    // Rear wall
    translate([wall_thickness, depth - wall_thickness, floor_thickness])
        cube([
            width - 2 * wall_thickness,
            wall_thickness,
            height]);
    
    // Front wall
    translate([wall_thickness, 0, floor_thickness])
        cube([
            width - 2 * wall_thickness,
            wall_thickness,
            height]);
}

module bottom_case() {
    floor_width = hole_spacing_x + standoff_diameter + padding_left + padding_right + wall_thickness * 2;
    floor_depth = hole_spacing_y + standoff_diameter + padding_front + padding_back + wall_thickness * 2;
    
    module box() {
        ceilingless_box(floor_width, floor_depth, bottom_wall_height);        
        
        // Left Ridge
        translate([
            wall_thickness / 2,
            wall_thickness / 2,
            floor_thickness + bottom_wall_height])
            cube([
                wall_thickness / 2,
                floor_depth - wall_thickness,
                ridge_height]);
        
        
        // Right Ridge
        translate([
            floor_width - wall_thickness,
            wall_thickness / 2,
            floor_thickness + bottom_wall_height])
            cube([
                wall_thickness / 2,
                floor_depth - wall_thickness,
                ridge_height]);
                
        // Rear Ridge
        translate([
            wall_thickness,
            floor_depth - wall_thickness,
            floor_thickness + bottom_wall_height])
            cube([
                floor_width - wall_thickness * 2,
                wall_thickness / 2,
                ridge_height]);
                
        // Front Ridge
        translate([
            wall_thickness,
            wall_thickness / 2,
            floor_thickness + bottom_wall_height])
            cube([
                floor_width - 2 * wall_thickness,
                wall_thickness / 2,
                ridge_height
            ]);
    }
        
    
    // Place the standoffs and through-PCB pins in the box
    module pcb_holder() {        
        base_offset_x = wall_thickness + padding_left + standoff_diameter / 2;
        base_offset_y = wall_thickness + padding_front + standoff_diameter / 2;
        
        module pin() {
            // Standoff
            translate([0, 0,  standoff_height / 2])
                cylinder(
                    r = standoff_diameter / 2,
                    h = standoff_height,
                    center = true,
                    $fn = facets);
            
            // Through-PCB pin
            translate([0, 0, 3.6])
                cylinder(
                    r = (hole_diameter / 2),
                    h = (board_thickness + 0.6),
                    center = true,
                    $fn = facets);
        }
        
        // Front left
        translate([base_offset_x, base_offset_y, floor_thickness])
            pin();
        
        // Front right
        translate([base_offset_x + hole_spacing_x, base_offset_y, floor_thickness])
            pin();
        
        // Rear left
        if (!flash) {
            translate([base_offset_x, base_offset_y + hole_spacing_y, floor_thickness])
                pin(); // pin near flash button
        }
        
        // Rear right
        translate([base_offset_x + hole_spacing_x, base_offset_y + hole_spacing_y, floor_thickness])
            pin();
        
    }
    difference () {
        box();
        if (usb == true) {
            //translate([0, 17, 2.5])  cube([3, 9, 3.8]); // DDv3
            translate([0, 8, 2.5])  cube([3, 9, 3.8]); // DDBv2
        }
        if (flash) {
            // case hole for flash button ; DDBv2
            flash_button_x = wall_thickness + padding_left + 2.5;
            flash_button_y = wall_thickness + padding_front + 21.5;
            translate([flash_button_x, flash_button_y, 0])
                cylinder(
                    d = button_diameter + button_spacing * 2,
                    h = floor_thickness,
                    center = false,
                    $fn=24);
            translate([flash_button_x, flash_button_y, button_height - button_holder_height - button_spacing])
                cylinder(
                    d = button_holder_diameter + button_spacing * 2,
                    h = floor_thickness,
                    center = false,
                    $fn=24);
        }
    }
    pcb_holder();
}

module top_case() {
    floor_width = hole_spacing_x + standoff_diameter + padding_left + padding_right + wall_thickness * 2;
    floor_depth = hole_spacing_y + standoff_diameter + padding_front + padding_back + wall_thickness * 2;
    
    module box() {
        ceilingless_box(floor_width, floor_depth, top_wall_height - ridge_height);
        //translate([7, 10, 2])  cube([window_x+window_ridge, window_y+window_ridge, 2]); // v3
        translate([4, 8.5, 2])  cube([window_x+window_ridge, window_y+window_ridge, 2]); // Bv2

        // Left Ridge
        translate([
            0,
            0,
            floor_thickness + top_wall_height - ridge_height])
            cube([
                wall_thickness / 2,
                floor_depth,
                ridge_height]);
        
        
        // Right Ridge
        translate([
            floor_width - wall_thickness / 2,
            0,
            floor_thickness + top_wall_height - ridge_height])
            cube([
                wall_thickness / 2,
                floor_depth,
                ridge_height]);
                
        // Rear Ridge
        translate([
            wall_thickness / 2,
            floor_depth - wall_thickness / 2,
            floor_thickness + top_wall_height - ridge_height])
            cube([
                floor_width - wall_thickness,
                wall_thickness / 2,
                ridge_height]);
                
        // Front Ridge
        translate([
            wall_thickness / 2,
            0,
            floor_thickness + top_wall_height - ridge_height])
            cube([
                floor_width - wall_thickness,
                wall_thickness / 2,
                ridge_height
            ]);        
    }
    
    module pcb_holder() {
        base_offset_x = wall_thickness + padding_left + standoff_diameter / 2;
        base_offset_y = wall_thickness + padding_back + standoff_diameter / 2;
        
        module pin_receiver() {
           if (standoff_top == true)
           {
               cylinder(
                        r = (standoff_diameter / 2),
                        h = standoff_height,
                        center = false,
                        $fn = facets);
           }
        }
        
        // Keep in mind that this part needs to be turned over to get the correct
        // orientation. In the design, the rear left here looks like the front left.
        
        // Rear left
        translate([base_offset_x, base_offset_y, floor_thickness])
            pin_receiver();
        
        // Rear right
        translate([base_offset_x + hole_spacing_x, base_offset_y, floor_thickness])
            pin_receiver();
        
        // Front left
        translate([base_offset_x, base_offset_y + hole_spacing_y, floor_thickness])
            pin_receiver();
        
        // Front right
        translate([base_offset_x + hole_spacing_x, base_offset_y + hole_spacing_y, floor_thickness])
            pin_receiver();
    }
    
    
    difference () {
        box();
        //translate([8, 11, -5])  cube([window_x, window_y, 10]); // v3
        translate([5, 9.5, -5])  cube([window_x, window_y, 10]); // Bv2
    if (reset==true)
     translate([12, 28,  0])
                cylinder(
                    r = 1.2,
                    h = 4,
                    center = true,
                    $fn = 24);
        
        
        }
    
    pcb_holder();
    
}

module flash_button () {
    union() {
        cylinder(
            d = button_holder_diameter,
            h = button_holder_height,
            center = false,
            $fn = 24);
        cylinder(
            d = button_diameter,
            h = button_height,
            center = false,
            $fn = 24);
    }
}

if (bottom == true) bottom_case();
if (top == true) 
{
translate([
    0,
    15 + hole_spacing_y + standoff_diameter + padding_front + padding_back + wall_thickness * 2,
    0])
    top_case();
}
if (flash_show == true) {
    translate([-20,20,0])
        flash_button();
}
