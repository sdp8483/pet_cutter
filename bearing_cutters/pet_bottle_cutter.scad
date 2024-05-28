/* PET Bottle Cutter
 * Author: Sam Perry
 * January 2024 
 */

// resolution of the curves, higher values give smoother curves but increase render time
$fn = 50; //[10,20,30,50,100]

// general clearance
clearance = 0.2;

/*[Cutter Properites]*/
// pet bottle strip thickness
pet_strip_t = 6;
// cutter overlap
cutter_overlap = 0.5;
// center to center distance of bearings
cutter_center_distance = 15;
// center channel thickness
cutter_channel_t = 4;
//pet bottle diameter
pet_dia = 120;

/*[Measured Bearing Properties]*/
// actual thickness
bearing_measured_t = 4.3;

/*[Nominal Bearing Properties]*/
// nominal outer diameter
bearing_OD = 16;
// nominal inner diameter
bearing_ID = 5;
// nominal thickness
bearing_t = 5;
// chamfer
bearing_chamfer = 0.5;

/*[Coin Properties]*/
// coin diameter
coin_dia = 19.05;
// coin thickness
coin_t = 1.52;
// coin tangent spacing
coin_spacing = 6;

/*[Bolt Properties]*/
// M3 clearance hole diameter
m3_hole = 3.5;
// M5 clearance hole diameter
m5_hole = 5.5;

// end of parameters

module bearing_625zz_nominal() {
    d2 = bearing_OD - (2*bearing_chamfer);
    h = bearing_t - (2*bearing_chamfer);
    
    translate([0,0,bearing_t/2]) {
        difference() {
            union() {
                /* top half of bearing */
                cylinder(h=h/2, d=bearing_OD);
                translate([0,0,h/2]) cylinder(h=bearing_chamfer, d1=bearing_OD, d2=d2);        
                /* bottom half of bearing */
                mirror([0,0,1]) {
                    cylinder(h=h/2, d=bearing_OD);
                    translate([0,0,h/2]) cylinder(h=bearing_chamfer, d1=bearing_OD, d2=d2);
                }
            }
            
            translate([0,0,-(bearing_t/2)-1]) cylinder(h=bearing_t+2, d=bearing_ID);
        }
    }
}

module bearing_625zz_sharp() {
    color("SteelBlue") {
        difference() {
            bearing_625zz_nominal();
            translate([0,0,bearing_measured_t]) {
                cylinder(h=bearing_t, d=bearing_OD+1);
            }
        }
    }
}

module assy_cutter_bearings() {
    /* bottom cutter */
    bottom_y = ((bearing_OD/2)-(cutter_overlap/2));
    bottom_z = pet_strip_t - bearing_measured_t;
    
    translate([0, -bottom_y, bottom_z]) {
        bearing_625zz_sharp();   
    }
    
    /* top cutter */
    top_y = bottom_y;
    top_z = bottom_z + (2 * bearing_measured_t);

    translate([0, top_y, top_z]) {
        mirror([0,0,1]) {
            bearing_625zz_sharp();
        }
    }
}

module coin() {
    color("Gold") {
        cylinder(h=coin_t, d=coin_dia);
    }
}

module assy_coin() {
    x = (coin_dia/2) + (coin_spacing/2);
    
    /* right coin */
    translate([x, 0, -coin_t]) {
        coin();
    }
    
    /* left coin */
    translate([-x, 0, -coin_t]) {
        coin();
    }
}

module coin_cut() {
    cylinder(h=coin_t+1 + clearance, d=(coin_dia + clearance));
}

module base_square() {
    
    difference() {
        base_extra_xy = 5;
        
        /* main body cube */
        base_top_t = pet_strip_t - bearing_measured_t - clearance;
        base_bottom_t = coin_t + clearance;
        base_t = base_top_t + base_bottom_t;
        
        base_x = (2*coin_dia) + coin_spacing + (2*base_extra_xy);
        base_y = (2*bearing_OD) - cutter_overlap + (2*base_extra_xy);
        
        translate([-(base_x/2), -(base_y/2), -base_bottom_t]) {
            cube([base_x, base_y, base_t]);
        }
        
        /* m3 mounting holes */
        m3_t = base_t + 2;
        m3_x = (base_x/2) - 5;
        m3_y = (base_y/2) - 5;
        
        translate([m3_x, m3_y, -base_bottom_t-1]) {
            cylinder(h=m3_t, d=m3_hole);
        }
        translate([-m3_x, m3_y, -base_bottom_t-1]) {
            cylinder(h=m3_t, d=m3_hole);
        }
        translate([m3_x, -m3_y, -base_bottom_t-1]) {
            cylinder(h=m3_t, d=m3_hole);
        }
        translate([-m3_x, -m3_y, -base_bottom_t-1]) {
            cylinder(h=m3_t, d=m3_hole);
        }
        
        /* chamfer */
        chamfer = 2;
        chamfer_h = m3_t;
        chamfer_x = (base_x/2) - chamfer;
        chamfer_y = (base_y/2) - chamfer;
        
        translate([chamfer_x, chamfer_y, -base_bottom_t-1]) {        
            rotate([0, 0, 45]) {
                translate([0, -5, 0]) cube([10, 10, base_t+2]);
            }
        }
        
        mirror([0,1,0]) {
            translate([chamfer_x, chamfer_y, -base_bottom_t-1]) {        
                rotate([0, 0, 45]) {
                    translate([0, -5, 0]) cube([10, 10, base_t+2]);
                }
            }
        }
        
        mirror([1,0,0]) {
            translate([chamfer_x, chamfer_y, -base_bottom_t-1]) {        
                rotate([0, 0, 45]) {
                    translate([0, -5, 0]) cube([10, 10, base_t+2]);
                }
            }
        }
        
        mirror([1,0,0]) {
            mirror([0,1,0]) {
                translate([chamfer_x, chamfer_y, -base_bottom_t-1]) {        
                    rotate([0, 0, 45]) {
                        translate([0, -5, 0]) cube([10, 10, base_t+2]);
                    }
                }
            }
        }
    }
}

module base_coin_cut() {
        difference() {
        base_square();
        
        coin_x = (coin_dia/2) + (coin_spacing/2);
        coin_z = coin_t + clearance + 1;
        
        translate([coin_x, 0, -(coin_z)]) {
            coin_cut();
        }
        
        translate([-coin_x, 0, -(coin_z)]) {
            coin_cut();
        }
    }
}

module base_1() {
    difference() {
        union() {
            base_coin_cut();
            
            /* bottom bearing mount */
            mount_y = (bearing_OD/2) - (cutter_overlap/2);
            mount_z = pet_strip_t - bearing_measured_t - clearance;
            
            translate([0, -mount_y, mount_z]) {
                cylinder(h=0.2, d=7.5);
            }
            
            /* top bearing mount */
            mount_h = bearing_measured_t;
            union() {
                translate([0, mount_y, mount_z]) {
                    cylinder(h=mount_h, d=bearing_OD);
                }
                translate([0, mount_y, mount_z + mount_h]) {
                    cylinder(h=0.2, d=7.5);
                }
            }
        }
        
        /* m5 holes */
        base_top_t = pet_strip_t - bearing_measured_t - clearance;
        base_bottom_t = coin_t + clearance;
        base_t = base_top_t + base_bottom_t;
        
        m5_h = bearing_measured_t + base_t + 2;
        m5_y = (bearing_OD/2) - (cutter_overlap/2);
        m5_z = base_bottom_t + 1;
        
        translate([0, -m5_y, -m5_z]) {
            cylinder(h=m5_h, d=m5_hole);
        }
        
            translate([0, m5_y, -m5_z]) {
            cylinder(h=m5_h, d=m5_hole);
        }
        
        /* pet bottle channel */
        channel_h = pet_strip_t + bearing_measured_t;
        translate([0, -pet_dia/2, 0]) {
            difference() {
                cylinder(h=channel_h, d=pet_dia+(cutter_channel_t/2));
                translate([0,0,-1]) cylinder(h=channel_h+2, d=pet_dia-(cutter_channel_t/2));
            }
        }
        
        /* bottle holder clearance */
        translate([0, -28, -base_bottom_t-1]) {
            cylinder(h=base_t+2, d=26);
        }
    }
}

module assy_base() {
    color("Purple") {
        union() {
            base_1();
            
            /* text */
            text_z = pet_strip_t - bearing_measured_t;
            rotate([0,0,180]) {
                translate([bearing_OD/2 + 8, -bearing_OD/2 - 4, text_z]) {
                    linear_extrude(0.5) {
                        text(str(pet_strip_t), size=10, halign="center");
                    }
                }
            }
        }
    }
}

/* Cutter Assembly */
%assy_cutter_bearings();
%assy_coin();
assy_base();