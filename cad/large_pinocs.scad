$fn=60;

major_r1=19.5;
major_r2=21.5;
minor_r=12;
center_dist=major_r1+minor_r-6;

wall=2.4;
h=20;

theta=atan((major_r1-minor_r)/center_dist);
echo(theta);

module cuff(){
    difference(){
        hull(){
            translate([-center_dist/2,0,0])
                cylinder(r2=major_r1+wall, r1=major_r2+wall,h=h);
            
            translate([center_dist/2-4,1,0])
                cylinder(r=minor_r+wall,h=h);
            
            translate([center_dist/2-2,-1,0])
                cylinder(r=minor_r+wall,h=h);
            
            translate([center_dist/2-9,-major_r1/4-6,0])
                cylinder(r=major_r1+wall-3,h=h);
        }
        
        hull(){
            translate([-center_dist/2,0,-0.1])
                cylinder(r2=major_r1,r1=major_r2,h=h+0.2);
            
            translate([center_dist/2-4,1,-0.1])
                cylinder(r=minor_r,h=h+0.2);
            
            translate([center_dist/2-2,-1,-0.1])
                cylinder(r=minor_r,h=h+0.2);
            
            translate([center_dist/2-9,-major_r1/4-6,-0.1])
                cylinder(r=major_r1-3,h=h+0.2);
        }
        
        translate([-center_dist,-2*major_r1,-0.1])
            cube([major_r1+minor_r+center_dist+2*wall+0.1,
                  major_r1+8,
                  h+0.2]);
    }
}

block_w=12;
block_h=10;
bolt_d=3;

hole_zs=[5, 15];

module block(){
    difference(){
        cube([block_w,block_h,h]);
        translate([0,-1.1*block_h,-0.1])
        rotate([0,0,28])
            cube([2*block_w,block_h,h+0.2]);
    }
}

module block_holes(){
    for(z=hole_zs){
        translate([block_w/2,-0.1,z])
        rotate([-90,0,0])
            cylinder(d=bolt_d,h=block_h+0.2);
    }
}

module assy(){
    translate([0,25,0])
    difference(){
        union(){
            cuff();
            translate([0,18,0])
            rotate([0,0,-45])
                block();
        }
        
            translate([0,18,0])
            rotate([0,0,-45])
        block_holes();
    }
}

module mirrorOfAssy(){
    mirror([0,1,0])
      assy();
}

module button_plate(){
    f=2;
    difference(){
        union(){
            translate([0,-h, 0])
            hull(){
                for(x=[f,2*h-f],
                    y=[f,2*h-f]){
                    translate([x,y,0])
                        cylinder(r=f, h=wall);
                }
            }
            
            translate([h,0,wall])
            hull(){
                translate([0,2,0])
                    cylinder(d=4,h=block_h-wall/2-0.5);
                translate([0,h-2,0])
                    cylinder(d=4,h=block_h-wall/2+1.25);
            }
        }
        
        translate([26.5,h,-wall/2])
        rotate([90,0,0])
            block_holes();
    }
}

//button_plate();
//assy();
mirrorOfAssy();


