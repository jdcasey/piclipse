$fn=100;

side=25.5;
cuff_wall=4.25;

post_r=0.75;
post_shoulder_r=1.5;
post_shoulder_h=2.5;

posts_x=[2+post_r, 14.5+post_r];
posts_y=[2+post_r, 22.5+post_r];

wall=0.8;
conn_shoulder=2.5;
fillet=2;

base_carve_side=29;
base_carve_h=5.5;

cam_lens_d=8.25;
cam_lens_xoff=wall+16.5;
cam_lens_yoff=wall+base_carve_side/2;

cam_carve_h=3.5-wall;
cam_carve_y=11;
cam_carve_x=22.5;

chip_carve_yoff=9.5;
chip_carve_h=1.75;
chip_carve_y=14;
chip_carve_x=11.25;

sm_filter_id=30.5;
sm_filter_h=10;
sm_filter_flare=7.6;
sm_cuff_id=33;
sm_cuff_h=9.75;
sm_cuff_wall=0.8;

lg_cuff_id=44;
lg_cuff_h=18;
lg_filter_id=63.75;
lg_filter_h=12;
lg_filter_flare=16;
lg_cuff_wall=1.2;

module front(ymax=base_carve_side+2*wall, yoff=0){
    difference(){
        hull(){
            for(x=[fillet,base_carve_side+2*wall-fillet], 
                y=[fillet,ymax-fillet]){
                translate([x,y,0])
                    cylinder(r=fillet,h=cuff_wall+chip_carve_h+cam_carve_h+2*wall);
            }
        }
        
        translate([0,yoff,0])
        union(){
            carve_off=(base_carve_side-1.01*side)/2;
            translate([carve_off, carve_off, chip_carve_h+cam_carve_h])
            scale([1.01, 1.01, 1.25])
                back_blank();

            translate([base_carve_side-0.1, 
                       1.25*wall+carve_off+conn_shoulder, 
                       chip_carve_h+cam_carve_h+wall])
                cube([2*carve_off, side-2*conn_shoulder, cuff_wall+2*wall+0.2]);
            
            translate([wall, chip_carve_yoff, cam_carve_h])
                cube([cam_carve_x, chip_carve_y, chip_carve_h+.2]);
            
            translate([wall, chip_carve_yoff, wall])
                cube([cam_carve_x, cam_carve_y, cam_carve_h]);
            
            translate([cam_lens_xoff, cam_lens_yoff, -0.1])
                cylinder(d=cam_lens_d, h=wall+0.2);
        }
    }
}

module back_blank(){
    hull(){
        for(x=[fillet,side], y=[fillet,side]){
            translate([x,y,0])
                cylinder(r=fillet,h=cuff_wall+wall+0.2);
        }
    }
}

module back(){
    union(){
        difference(){
            back_blank();
            translate([wall, wall, wall+0.1])
                cube([side, side, cuff_wall+0.2]);
            translate([side+wall-0.1, wall+conn_shoulder, 2*wall])
                cube([wall+0.2, side-2*conn_shoulder, cuff_wall+0.2]);
        }
        
        for(x=posts_x, y=posts_y){
            translate([wall+x, wall+y, wall])
            union(){
                cylinder(r1=1.5*post_shoulder_r, r2=post_shoulder_r, h=post_shoulder_h);
                translate([0,0,post_shoulder_h])
                    cylinder(r=post_r, h=cuff_wall-post_shoulder_h);
            }
        }
    }
}

module pinocs_cuff(id=sm_cuff_id, cuff_h=sm_cuff_h, cuff_wall=sm_cuff_wall){
    ymax=base_carve_side+2*wall;
    yoff=0;
    
    cuff_zoff=cuff_h+4.75;
    
    union(){
        difference(){
            union(){
                hull(){
                    for(x=[fillet,base_carve_side+2*wall-fillet], 
                        y=[fillet,ymax-fillet]){
                        translate([x,y,0])
                            cylinder(r=fillet,h=cuff_wall+chip_carve_h+cam_carve_h+2*wall);
                    }
                    
                    translate([cam_lens_xoff, cam_lens_yoff, -5.5])
                        cylinder(d=id+2*cuff_wall,h=5.75);
                }
                
                translate([cam_lens_xoff, cam_lens_yoff, -cuff_zoff])
                    cylinder(d=id+2*cuff_wall,h=cuff_h);
            }
            
            translate([0,yoff,0])
            union(){
                carve_off=(base_carve_side-1.01*side)/2;
                translate([carve_off, carve_off, chip_carve_h+cam_carve_h])
                scale([1.01, 1.01, 1.25])
                    back_blank();

                translate([base_carve_side-0.1, 
                           1.25*wall+carve_off+conn_shoulder, 
                           chip_carve_h+cam_carve_h+wall])
                    cube([3*carve_off, side-2*conn_shoulder, cuff_wall+2*wall+0.2]);
                
                translate([wall, chip_carve_yoff, cam_carve_h])
                    cube([cam_carve_x, chip_carve_y, chip_carve_h+.2]);
                
                translate([wall, chip_carve_yoff, wall])
                    cube([cam_carve_x, cam_carve_y, cam_carve_h]);
                
                translate([cam_lens_xoff, cam_lens_yoff, -0.1])
                    cylinder(d=cam_lens_d, h=wall+0.2);
            }
            
            translate([cam_lens_xoff, cam_lens_yoff,-cuff_zoff-0.1])
            union(){
                cylinder(d=id,h=cuff_zoff+0.2);
                cylinder(d=cam_lens_d, h=cuff_zoff+2.5);
            }
        }
        
        translate([cam_lens_xoff, cam_lens_yoff, -cuff_zoff-0.1])
        intersection(){
            cylinder(d=id-2*cuff_wall,h=cuff_zoff+0.5);
            
            translate([-id/2-cuff_wall, -id/2-cuff_wall, 0])
            for(n=[0:100]){
                translate([n*3.5-2,0,0])
                    cube([cuff_wall,id+cuff_wall,cuff_zoff+0.25]);
                translate([0,n*3.5-2,0])
                    cube([id+1,cuff_wall,1]);
            }
        }
    }
}

module pinoc_filter(id=sm_filter_id, cuff_h=sm_filter_h, cuff_wall=sm_cuff_wall, filter_flare=sm_filter_flare){
    filter_d=id+filter_flare;
    
    difference(){
        union(){
            hull(){
                cylinder(d=filter_d,h=2);
                translate([0,0,2])
                    cylinder(d=id+2*cuff_wall,h=2);
            }
            translate([0,0,4])
            cylinder(d=id+2*cuff_wall,h=cuff_h);
        }
        translate([0,0,-0.1])
        union(){
            cylinder(d=id-2,h=7);
            translate([0,0,4.2])
                cylinder(d=id,h=cuff_h+0.2);
        }
    }
}

module pinoc_filter_ring(id=sm_filter_id, cuff_wall=sm_cuff_wall, filter_flare=sm_filter_flare){
    difference(){
        cylinder(d=id+filter_flare+2*cuff_wall, h=6);
        translate([0,0,-0.1])
            cylinder(d=id, h=6.2);
        translate([0,0,2-0.1])
            cylinder(d=id+filter_flare, h=6.2);
    }
}

//back();
//front();

pinocs_cuff();
//pinocs_cuff(lg_cuff_id, lg_cuff_h, lg_cuff_wall);
//pinoc_filter();
//pinoc_filter_ring();

//pinoc_filter(lg_filter_id, lg_filter_h, lg_cuff_wall, lg_filter_flare);
//pinoc_filter_ring(lg_filter_id, lg_cuff_wall, lg_filter_flare);
