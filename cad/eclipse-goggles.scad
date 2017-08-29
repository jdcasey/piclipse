$fn=100;

h=50;
w=150;
nose_h=24;
nose_w1=12;
nose_w2=20;
fillet=16;

t=2;
frame=3;

module half_lens_blank(tol=0, ztol=0){
    z=t+ztol;
    zoff=-ztol/2;
    
    translate([-nose_w1/2,0,0])
    hull(){
        translate([-tol,h/2-1-tol, zoff])
            cube([1,1,z]);

        translate([-w/2+fillet+tol,h/2-fillet-tol, zoff])
            cylinder(r=fillet,h=z);
        
        translate([-w/2+fillet+tol,-h/2+fillet+tol,zoff])
            cylinder(r=fillet,h=z);

        translate([-nose_w2/2-fillet-tol,-h/2+fillet+tol,zoff])
            cylinder(r=fillet,h=z);
        
        translate([-tol, -h/2+nose_h+tol, zoff])
            cylinder(r=1,h=z);
    }
}

module full_lens_blank(tol=frame,ztol=0){
    union(){
        half_lens_blank(tol, ztol);
        mirror([1,0,0])
            half_lens_blank(tol,ztol);
    }
}

module full_frame(){
    difference(){
        union(){
            difference(){
                full_lens_blank(0,0);
                full_lens_blank(frame,2);
            }
            
            difference(){
                translate([-w/2-10,-8,0])
                    cube([5,16,t]);
                translate([-w/2-8,-6,-0.1])
                    cube([5,12,t+0.2]);
            }
            
            difference(){
                translate([w/2+5,-8,0])
                    cube([5,16,t]);
                translate([w/2+3,-6,-0.1])
                    cube([5,12,t+0.2]);
            }
            
            translate([-nose_w1/2,-h/2+nose_h,0])
                cube([nose_w1, h-nose_h, t]);
            
            translate([0,0,2])
            difference(){
                full_lens_blank(frame/2,2);
                full_lens_blank(frame,4);
            }
            
            translate([0,0,16])
            difference(){
                full_lens_blank(0,30);
                full_lens_blank(frame/10,35);
                
                translate([0,0,144])
                    sphere(r=150);
            }
            
        }
        
        translate([0,-h/2+nose_h-nose_w1*0.35,-0.1])
            cylinder(d=nose_w1,h=t+0.2);
    }
}

module caps(){
    union(){
        difference(){
            full_lens_blank(frame/4,0);
            full_lens_blank(frame,2);
        }

        translate([0,0,2])
        difference(){
            full_lens_blank(frame/4,2);
            full_lens_blank(1.2,6);
        }
    }
}

module tensioner(){
    tw=10;
    th=16;
    tf=2;
    cw=2;
    
    difference(){
        hull(){
            for(x=[tf,tw-tf],
                y=[tf,th-tf]){
                translate([x,y,0])
                    cylinder(r=tf,h=t);
            }
        }
        
        for(x=[tw/4-cw/2, tw*0.75-cw/2]){
            translate([x,tf,-0.1])
                cube([cw,th-2*tf,t+0.2]);
        }
    }
}

//tensioner();

//translate([0,50,0])
//caps();
full_frame();
