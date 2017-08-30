// how smooth you want curves to be in the
// model
$fn=100;

// how tall on your face these goggles should be
// (cheek to forehead, basically)
h=50;

// overall width of the goggles. Making these
// wider gives some room to accommodate glasses
// underneath
w=150;

// how deep into the goggles to cut out the
// nose opening
nose_h=24;

// dist across the top (edge) of your nose, 
// where the goggles hit. Make it a bit bigger
// than you need...
nose_w1=12;

// dist across the base of your nose, to
// ensure the goggles don't pinch your nostrils
// Again, make it a little big...
nose_w2=20;

// deterines how squared off the goggles look
fillet=16;

// thickness (front to back) of the frames, caps, etc
t=2;

// width of frames (dist from lens to outer edge)
frame=3;

// The basic shape of a lens.
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

// Basic shape of both lenses together.
module full_lens_blank(tol=frame,ztol=0){
    union(){
        half_lens_blank(tol, ztol);
        mirror([1,0,0])
            half_lens_blank(tol,ztol);
    }
}

// This is what you would expect. They print flat,
// which means you have to fit them to your face
// before use. To do this, use a heat gun or other
// heat source to soften the plastic over the bridge
// of the nose. Once it's a little bit pliable, push
// the goggles onto your face and hold them for about
// 20-30 seconds until that plastic cools into the
// new shape.
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

// These caps are used to hold the solar filter film
// against the frames' eye holes. They are press-fit,
// but a bit of hot glue is a nice addition to hold
// it all together.
//
// I've also found that you can hot glue the film to
// the caps, then hot glue the caps to the frame to
// really keep it all together.
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

// This is the tensioner that adjusts the fit when an
// elastic band is used to hold the goggles on your face. 
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
