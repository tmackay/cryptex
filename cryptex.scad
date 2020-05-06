// OpenSCAD Print in Place Large Format Cryptex
// (c) 2020, tmackay
//
// Licensed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license, http://creativecommons.org/licenses/by-sa/4.0.

// Which one would you like to see?
part = undef; // [shell:Shell,core:Core,codex:Codex]

// emboss codex on rings (otherwise add your own later)
codex = 1; // [1:Yes , 0:No]

// notches on rings
notches = 1; // [1:Yes , 0:No]

// raised dials beyond cylinder diameter
raised_dials = 0; // [1:Yes , 0:No]

// Array of characters, first character in each row is key, rest is filler in no particular order
// watch out the seams don't give it away... (onlinerandomtools.com/shuffle-letters)
charinput="325614,643152,514263,236541,451326,162435"; // 6x6 Sudoku

// Font used for all rows
font = "Liberation Mono:style=Bold";

// Overall scale (to avoid small numbers, internal faces or non-manifold edges)
s = 1000;

// height of ring/collars
h_ = 12.5;
h=s*h_;

// thickness of spacers
sp_ = 0;
sp=s*sp_;

// Depth of embossed characters
char_thickness_ = 0.5;
char_thickness = s*char_thickness_;

// outer diameter of box
d_ = 30;
d=s*d_;

// clearance
tol_=0.4; //[0:0.1:1.0]
tol=s*tol_/2;

// Thickness of wall at thinnest point
wall_thickness = 2; // [0:0.1:5]
// Tooth overlap - how much grab the ring teeth have on the core teeth
tooth_overlap = 2; // [0:0.1:5]

// calculate wall and teeth depth from above requirements
t = s*(wall_thickness+tooth_overlap+2*tol_);
w = s*(wall_thickness+tooth_overlap+1.5*tol_-tooth_overlap/2);

// Outer teeth
outer_t = 3; //[0:1:24]
// Outer teeth
outer_t2 = 5; //[0:1:24]
// Width of outer teeth
outer_w_=2.6; //[0:0.1:10]
outer_w=s*outer_w_;
// Taper top teeth (not sure if this helps resist shimming or makes it easier to get a loop of floss around the core)
taper = 1; // [1:Yes , 0:No]
// Twist teeth angle
twist = 0; // [0:720]

// embedded magnets, open with a sudden stop
magnets = 0; // [1:Yes , 0:No]
// Magnet diameter
magnet_d_ = 6; //[0:0.1:10]
magnet_d = s*magnet_d_;
// Magnet height
magnet_h_ = 3; //[0:0.1:10]
magnet_h = s*magnet_h_;

// Layer height (for ring horizontal split)
layer_h_ = 0.2; //[0:0.01:1]
layer_h = s*layer_h_;

// section for demonstration and debugging
section = 0; // [1:Yes , 0:No]

$fn=96;

chars = split(",",charinput); // workaround for customizer
n = len(chars)-2;
box_h=(n-1)*sp+(n+2)*h;
echo(str("total box height: ",box_h));
echo(str("internal diameter: ",d-6*w-4*tol));
echo(str("internal height: ",box_h-2*w-2*layer_h));

// find gaps to insert magnets/false teeth
a=quicksort([for(j = [0:outer_t/2])j*180/outer_t,for(j = [0:outer_t2/2])(-j*180/outer_t2+90)%180]);
delta=[for(i=[1:len(a)-1])a[i]-a[i-1]]*PI*(d/2-2*w)/180;
gaps=[for(i=[0:len(a)-2])a[i+1]+a[i]];

// Shell
if(part=="shell"||part==undef){
    difference(){
        // main body
        union(){
            cylinder(d=d,h=box_h);
            // raised dials
            if(raised_dials)for(i=[0:n+1])
                translate([0,0,i*(h+sp)-(i>0?(i>n?2*sp:sp):0)])rotate_extrude()
                    polygon(points=[[d/2,h-tol],[d/2+h/5,h-h/5],[d/2+h/5,h/5],[d/2,tol]]);
        }
        // internal void
        translate([0,0,w])cylinder(d=d-4*w,h=box_h);
        // top taper
        translate([0,0,box_h-s])cylinder(d=d-4*w+8*tol+2*t,h=s);
        translate([0,0,box_h-s-t])cylinder(d1=d-4*w,d2=d-4*w+8*tol+2*t,h=t);
        // code wheel cutout
        for (i=[0:n-1])translate([0,0,h+i*(h+sp)])rotate_extrude()
            polygon(points=[[d/2,h],[d/2-3*tol,h],[d/2-t-2*tol,h-t],[d/2-t-2*tol,t],[d/2-3*tol,0],[d/2,0],
             [d/2,layer_h],[d/2-layer_h-tol,layer_h],[d/2-t,t],[d/2-t,h-t],[d/2-tol-layer_h,h-layer_h],[d/2,h-layer_h]]);
        // outer teeth
        intersection(){
            translate([0,0,w])rotate_extrude()
                polygon(points=[[0,2*layer_h],[d/2-2*w,2*layer_h],[d/2-2*w+t,t+2*layer_h],[d/2-2*w+t,box_h],[0,box_h]]);
            for(i=[0:len(a)-1])linear_extrude(box_h,twist=twist)mir()rotate([0,0,a[i]*2])
                translate([d/2-2*w+t/2,0,0])
                    square([t+4*tol,outer_w+4*tol],center=true);
        }
        // false teeth
        if(max([for(i=[0:len(a)-1])(3*delta[i]>4*outer_w)?1:0]))intersection(){
            translate([0,0,w])rotate_extrude()
                polygon(points=[[0,h+(n-1)*(h+sp)+h/2],[d/2-2*w,h+(n-1)*(h+sp)+h/2],[d/2-2*w+t,t+h+(n-1)*(h+sp)+h/2],[d/2-2*w+t,box_h],[0,box_h]]);
            for(i=[0:len(gaps)-1])if(3*delta[i]>4*outer_w)
                let(de=(delta[i]-outer_w)/outer_w/2,def=floor(de))for(j=[-def/2:def/2])
                    linear_extrude(box_h,twist=twist)
                        mir()rotate([0,0,gaps[i]+j*outer_w/PI/(d/2-2*w)*360*(def?de/def:1)])
                            translate([d/2-2*w+t/2,0,0])
                                square([t+4*tol,outer_w+4*tol],center=true);
        }
        // false gates
        intersection(){
            translate([0,0,w])rotate_extrude()
                polygon(points=[[0,0],[d/2-2*w,0],[d/2-2*w+t,t],[d/2-2*w+t,box_h],[0,box_h]]);
            for (i=[0:n-1])translate([0,0,h+i*(h+sp)])rotate_extrude()
                polygon(points=[
                    [d/2-t-2*tol,t],[d/2-3*tol,0],[d/2,0],
                    [d/2,3*layer_h],[d/2-layer_h-tol,3*layer_h],[d/2-t,t+2*layer_h]
                ]);
            if(outer_t2>0)for(i=[1:outer_t-1],j=[0:outer_t2-1])
                linear_extrude(box_h,twist=twist)
                    rotate([0,0,i*360/outer_t+j*360/outer_t2-180])translate([d/2-2*w+t/2,0,0])
                        square([t+4*tol,outer_w+4*tol],center=true);
        }
        // codex
        if(codex)rotate([0,0,-60])difference(){
            for (i=[0:n+1],j=[0:len(chars[i])-1])rotate([0,0,j*360/len(chars[i])])
                translate([-d/2-tol-(raised_dials?h/5:0),0,h/2+i*(h+sp)-(i>0?(i>n?2*sp:sp):0)])mirror([1,0,-1])
                    linear_extrude(2*char_thickness+tol)scale(min(0.8*PI*d/len(chars[i]),3*h/5)/10)text(
                        chars[i][j],font=font,
                        size=10,$fn=4,
                        valign="center",halign="center"
                    );
            cylinder(d=(raised_dials?d+2*h/5:d)-2*char_thickness,h=box_h);
        }
        // notches
        if(notches)rotate([0,0,-60])
            for (i=[0:n+1],j=[0:len(chars[i])-1])rotate([0,0,j*360/len(chars[i])-180/len(chars[i])])
                translate([-d/2-tol-(raised_dials?h/5:0),0,h/2+i*(h+sp)-(i>0?(i>n?2*sp:sp):0)])
                    translate([0,-tol,-h/2])cube([char_thickness+tol,2*tol,h]);
        // magnets 
        if(magnets)for(i=[0:len(gaps)-1])if(delta[i]>magnet_d)
            let(de=(delta[i]-magnet_d/2)/magnet_d/2,def=floor(de))for(j=[-def/2:def/2])
                rotate([0,0,-twist*(w+layer_h+magnet_d/2)/box_h])
                    mir()rotate([0,0,gaps[i]+j*magnet_d/PI/(d/2-2*w)*360*(def?de/def:1)])
                        translate([d/2-2*w+magnet_h+tol,0,w+magnet_d/2+tol])
                            mirror([1,0,1])cylinder(d=magnet_d+2*tol,h=magnet_h+s+2*tol,$fn=24);
        // temporary sections
        if(section){
            cube(box_h);
            mirror([1,1,0])rotate([0,0,gaps[0]])cube(box_h);
            cylinder(d=tol,h=box_h);
        }
    }
}

// if trouble with non-manifold geometry, generate text separately and subtract using TinkerCad
if(part=="codex"){
    rotate([0,0,-60])difference(){
        for (i=[0:n+1],j=[0:len(chars[i])-1])rotate([0,0,j*360/len(chars[i])])
            translate([-d/2-tol-(raised_dials?h/5:0),0,h/2+i*(h+sp)-(i>0?(i>n?2*sp:sp):0)])mirror([1,0,-1])
                linear_extrude(2*char_thickness+tol)scale(min(0.8*PI*d/len(chars[i]),3*h/5)/10)text(
                    chars[i][j],font=font,
                    size=10,$fn=4,
                    valign="center",halign="center"
                );
        cylinder(d=(raised_dials?d+2*h/5:d)-2*char_thickness,h=box_h);
    }
}

// Core
if(part=="core"||part==undef){
    translate([0,0,part=="core"?box_h:0])rotate([part=="core"?180:0,0,-twist*(w+layer_h)/box_h])difference(){
        translate([0,0,w+layer_h]){
            // cylinder
            cylinder(d=d-4*w-4*tol,h=box_h-w-layer_h);
            // top taper
            translate([0,0,box_h-w-layer_h-s])cylinder(d=d-4*w+2*t+4*tol,h=s);
            translate([0,0,box_h-w-layer_h-s-t])cylinder(d1=d-4*w-4*tol,d2=d-4*w+2*t+4*tol,h=t);
            // outer teeth
            intersection(){
                rotate_extrude()
                    polygon(points=[[0,2*layer_h],[d/2-2*w-2*tol,2*layer_h],[d/2-2*w-2*tol+t,t+2*layer_h],
                [d/2-2*w-2*tol+t,box_h-taper*(w+3*layer_h+s+2*t)],[d/2-2*w-2*tol,box_h-taper*(w+3*layer_h+s+t)],[0,box_h-taper*(w+3*layer_h+s+t)]]);
                for(i=[0:len(a)-1])linear_extrude(box_h,twist=twist)
                    mir()rotate([0,0,a[i]*2])translate([d/2-2*w-2*tol+t/2,0,0])
                        square([t+2*tol,outer_w],center=true);
            }
            // false teeth
            if(max([for(i=[0:len(a)-1])(3*delta[i]>4*outer_w)?1:0]))intersection(){
                rotate_extrude()
                    polygon(points=[[0,h+(n-1)*(h+sp)+h/2],[d/2-2*w-2*tol,h+(n-1)*(h+sp)+h/2],[d/2-2*w-2*tol+t,t+h+(n-1)*(h+sp)+h/2],
                        [d/2-2*w-2*tol+t,box_h-w-layer_h],[d/2-2*w-2*tol,box_h-w-layer_h],[0,box_h-w-layer_h]]);
                for(i=[0:len(a)-1])if(3*delta[i]>4*outer_w)
                    let(de=(delta[i]-outer_w)/outer_w/2,def=floor(de))for(j=[-def/2:def/2])
                        linear_extrude(box_h,twist=twist)mir()
                            rotate([0,0,gaps[i]+j*outer_w/PI/(d/2-2*w)*360*(def?de/def:1)])
                                translate([d/2-2*w-2*tol+t/2,0,0])
                                    square([t+2*tol,outer_w],center=true);
            }
        }
        // code wheel cutout - more clearance than shell otherwise we can feel the change in friction
        for (i=[0:n-1])translate([0,0,h+i*(h+sp)])rotate_extrude()
            polygon(points=[[d/2,h],[d/2-4*tol,h],[d/2-t-3*tol,h-t],[d/2-t-3*tol,t],[d/2-4*tol,0],[d/2,0]]);
        // payload
        cylinder(d=d-4*w-4*tol-2*wall_thickness*s,h=box_h-w);
        // magnets 
        if(magnets)for(i=[0:len(gaps)-1])if(delta[i]>magnet_d)
            let(de=(delta[i]-magnet_d/2)/magnet_d/2,def=floor(de))for(j=[-def/2:def/2])
                rotate([0,0,-twist*magnet_d/2/box_h])
                    mir()rotate([0,0,gaps[i]+j*magnet_d/PI/(d/2-2*w)*360*(def?de/def:1)])
                        translate([d/2-2.5*w-tol,0,w+magnet_d/2+tol+4*layer_h])
                            mirror([1,0,1])cylinder(d=magnet_d+2*tol,h=magnet_h+s+2*tol,$fn=24);
        // temporary sections
        if(section){
            cube(box_h);
            mirror([1,1,0])rotate([0,0,gaps[0]])cube(box_h);
            cylinder(d=tol,h=box_h);
        }
    }    
}

module mir(){
    children();
    mirror([0,1,0])children();
}

function quicksort(arr) = !(len(arr)>0)?[]:
    let(pivot = arr[floor(len(arr)/2)],
        lesser = [for (y = arr) if(y < pivot) y],
        equal = [for (y = arr) if(y == pivot) y],
        greater = [for (y = arr) if(y > pivot) y]
    )concat(quicksort(lesser),equal,quicksort(greater));

function substr(s,st,en,p="") = (st>=en||st>=len(s))?p:substr(s,st+1,en,str(p,s[st]));

function split(h,s,p=[]) = let(x=search(h,s))x==[]?concat(p,s):
    let(i=x[0],l=substr(s,0,i),r=substr(s,i+1,len(s)))split(h,r,concat(p,l));
