// Note: screw rendering is slow. So disable it when experimenting.
renderAdjusterScrews=true;
renderTabletHolder=true;
renderWallHolder=true;

// Diameter of the axel. It has to match the threaded rod you want to put through.
// It should be smaller than wallHolderArmsStrength.
axelDiameter=4.2;
// Defines the size of a small gap between the tablet holder and the wall holder.
hingeGap=2;

// You can split the model if your printer is not big enough.
// If it is splitted, new holes are added where you can screw the parts together
// with additional threaded rods.
split=false;
splitRodDiameter=axelDiameter;
splitWidth=split ? 10 : 0;

// Thickness of the wall, the tabletholder hangs over.
wallThickness=135;
// Height of the tablet itself.
tabletHeight=200;

// Width of the tablet itself. 
// Note: The total width of the tabletholder consits of tabletWidth + (2 * hingeGap) + (2 * wallHolderArmsStrength)
tabletWidth=257;
// This has to be at least the thickness of the tablet itself.
tabletThickness=20;
// Thickness of the tablet holder backplate.
tabletHolderStrength=8;


// Defines the size of the holes in the backplate (for less plastic usage).
tabletHolderHolesDiameter=30;
// Gap between the holes in the backplate.
tabletHolderHolesGap=10;

// Defines the thickness of the part at the bottom where the tablet lays.
tabletSecureStrength=10;
// Defines the height of the front which stops the tablet.
tabletSecureHeight=7;

// Thickness of the wall holder arms.
wallHolderArmsStrength=10;
// Length of the arms at the back.
wallHolderBackLength=70;
// Length of the arms at the front.
wallHolderFrontLength=70;

// Adjuster screw diameter.
adjusterScrew=13;
// Adjuster screw hole diameter. (Should be a bit bigger than the screw).
// You may have to experiment a bit with this.
adjusterScrewHole=13.3;
// Length of the adjuster screw.
adjusterMax=80;

adjusterKnobDiameter=adjusterScrew / 100 * 150;
adjusterKnobHeight=adjusterScrew / 100 * 50;
adjusterOuterDiameter=adjusterScrew + 10;

axelOuterDiameter=wallHolderArmsStrength;

halfTableWidth=tabletWidth / 2;
halfhingeGap=hingeGap / 2;

PI=0 + 3.141592;

// topWallHolderArmLength: wallThickness + the back which hangs over the wall
// On the front there will be a round hinge with hole. Therefore only half of wallHolderArmsStrength is added to cover the half of the cylinder.
topWallHolderArmLength=wallThickness + wallHolderArmsStrength + (axelOuterDiameter/2);

fullTabletHolderHeight=tabletHeight+wallHolderArmsStrength/2;
tabletHolderXOffset=wallHolderArmsStrength / 2  - axelOuterDiameter / 2;
tabletPlateZOffset=wallHolderArmsStrength / 2 - fullTabletHolderHeight;

module WallHolder() {
    module WallArm() {
                
        module ArmWithoutHole() {
            cube([topWallHolderArmLength, wallHolderArmsStrength, wallHolderArmsStrength]);
                
            // The arm at the back of the wall.
            translate([0, 0, -wallHolderBackLength])
                cube([wallHolderArmsStrength, wallHolderArmsStrength, wallHolderBackLength]);
            
            // The hinge to the tablet part with a hole, to be able to connect both parts with a rod.
            translate([topWallHolderArmLength, wallHolderArmsStrength, wallHolderArmsStrength/2])
                rotate([90, 0, 0])
                    cylinder(h=wallHolderArmsStrength, d=wallHolderArmsStrength, center=false);
            
            // Front arm.
            translate([topWallHolderArmLength-(wallHolderArmsStrength/2), 0, -wallHolderFrontLength])
                cube([wallHolderArmsStrength, wallHolderArmsStrength, wallHolderFrontLength + wallHolderArmsStrength/2]);
        }
        
        // Hinge
        difference() {
            ArmWithoutHole();
            translate([topWallHolderArmLength, wallHolderArmsStrength, wallHolderArmsStrength/2])
                rotate([90, 0, 0])
                    translate([0, 0, -1])
                        cylinder(h=wallHolderArmsStrength+2, d=axelDiameter, center=false);
        }
        
        
    }
    
    module WallHolderHalf() {
        difference() {
            union() {
                translate([0, halfTableWidth+halfhingeGap, 0])
                    WallArm();
                
                cube([wallHolderArmsStrength, halfTableWidth+halfhingeGap, wallHolderArmsStrength]);
                
                translate([wallThickness-hingeGap, 0, 0])
                    cube([wallHolderArmsStrength, halfTableWidth+halfhingeGap, wallHolderArmsStrength]);
            }
            
            // Holes for threaded rods if splitted:
            if (split) {
                translate([wallHolderArmsStrength/2, halfTableWidth + wallHolderArmsStrength + halfhingeGap + 1, wallHolderArmsStrength/2])
                    rotate([90, 0, 0])
                        cylinder(h=halfTableWidth + wallHolderArmsStrength + halfhingeGap + 2, d=splitRodDiameter, center=false);
                translate([wallThickness-hingeGap + wallHolderArmsStrength/2, halfTableWidth + wallHolderArmsStrength + halfhingeGap + 1, wallHolderArmsStrength/2])
                    rotate([90, 0, 0])
                        cylinder(h=halfTableWidth + wallHolderArmsStrength + halfhingeGap + 2, d=splitRodDiameter, center=false);
            }
        }
    }
    
    if (renderWallHolder) {
        mirror([0, 1, 0]) {
            translate([0, splitWidth, 0])
                WallHolderHalf();
        }
            
        WallHolderHalf();
    }
}

module Adjuster() {
    offsetY=adjusterOuterDiameter/2;
    offsetZ= tabletHolderStrength/2-tabletHeight-tabletHolderStrength/2-adjusterOuterDiameter/2;
    
    module Screw(size, length, countersinkStyle) {
        translate([0, offsetY, offsetZ])
            rotate([0, 90, 0])
               screw_thread(size, 4, 55, length, PI/3, countersinkStyle);
    }
    
    module Base() {
        translate([0, offsetY, offsetZ])
            rotate([0, 90, 0])
                cylinder(h=tabletHolderStrength, d=adjusterOuterDiameter);
    
        translate([0, 0, offsetZ])
            cube([tabletHolderStrength, adjusterOuterDiameter, adjusterOuterDiameter/2]);
    }
    
    if (renderTabletHolder) {
        difference() {
            Base();
            Screw(adjusterScrewHole, tabletHolderStrength, -2);
        }
    }
    
    if (renderAdjusterScrews) {
        Screw(adjusterScrew, tabletHolderStrength + adjusterMax, -1);
        translate([tabletHolderStrength+adjusterMax, offsetY, offsetZ])
            rotate([0, 90 ,0])
                knurled_cyl( adjusterKnobHeight, adjusterKnobDiameter, 4, 4, 1, 2, 1);
    }
}

module TabletHolder() {
    module TabletHolderHalf() {
        module HingeRod() {
            translate([wallHolderArmsStrength / 2, 0, wallHolderArmsStrength / 2])
                rotate([90, 0, 0])
                    cylinder(h=halfTableWidth, d=axelOuterDiameter, center=false);
        }

        module HingeRodHole() {
            translate([wallHolderArmsStrength / 2, 0, wallHolderArmsStrength / 2])
                rotate([90, 0, 0])
                    translate([0, 0, -1 - tabletHolderHolesGap])
                        cylinder(h=halfTableWidth+2+tabletHolderHolesGap, d=axelDiameter, center=false);
        }
    
        // Some helper variables for the holes.
        holeOffset=tabletHolderHolesDiameter + tabletHolderHolesGap;
        allHolesOffset=tabletHolderHolesDiameter/2 + tabletHolderHolesGap;
        
        holeCountHorizontal=(halfTableWidth + tabletHolderHolesDiameter - tabletHolderHolesGap) / holeOffset;

        holeCountVertical=(fullTabletHolderHeight + tabletHolderHolesDiameter - tabletHolderHolesGap) / holeOffset;
        
        module SplitRods() {
            // If splitted, add holes in between for threaded rods.
            if (split) {
                for(vNum=[0:holeCountVertical-2]) {                        
                    translate([tabletHolderStrength/2, 1+halfTableWidth, vNum *  holeOffset + tabletHolderHolesDiameter + tabletHolderHolesGap + tabletHolderHolesGap/2])
                        rotate([90, 0, 0])
                            cylinder(h=halfTableWidth + 2, d=splitRodDiameter, center=false);
                }
            }
        }
        
        module TabletPlate() {
            
             // The tablet holder plate.
            translate([tabletHolderXOffset, -halfTableWidth, tabletPlateZOffset])
                difference() {
                    cube([tabletHolderStrength, halfTableWidth, fullTabletHolderHeight]);

                    // Holes in the tablet plate to save plastic and make it lighter.
                   
                    
                    for(hNum=[0:holeCountHorizontal-1]) {
                        for(vNum=[0:holeCountVertical-1]) {                        
                            translate([-1, hNum * holeOffset + allHolesOffset, vNum *  holeOffset + allHolesOffset])
                                rotate([0, 90, 0])
                                    cylinder(h=tabletHolderStrength + 2, d=tabletHolderHolesDiameter);
                        }
                    }
                    SplitRods();
                };
            
             translate([tabletHolderXOffset, -tabletHolderHolesGap/2, tabletPlateZOffset])
                 difference() {
                    // Add a bar in the middle to always maintain a gap between the holes also in the middle
                    // where the two halves are combined.
                        cube([tabletHolderStrength, tabletHolderHolesGap/2, fullTabletHolderHeight]);
                    SplitRods();
                 };
             
             // Add a bar at the top to always maintain a gap between top and the holes.
            translate([tabletHolderXOffset, -halfTableWidth, -tabletHolderHolesGap+axelOuterDiameter/2])
                cube([tabletHolderStrength, halfTableWidth, tabletHolderHolesGap]);
                
            HingeRod();
        }
        
        module TabletSecure() {
            translate([tabletHolderXOffset+tabletHolderStrength, -halfTableWidth, tabletPlateZOffset])
                cube([tabletThickness + tabletSecureStrength, halfTableWidth, tabletSecureStrength]);
            translate([tabletHolderXOffset+tabletHolderStrength+tabletThickness, -halfTableWidth, tabletPlateZOffset+tabletSecureStrength])
                cube([tabletSecureStrength, halfTableWidth, tabletSecureHeight]);
        }
        
        difference() {
            TabletPlate();
            HingeRodHole();
        }
        
        TabletSecure();
    }

    if (renderTabletHolder) {    
        mirror([0, 1, 0]) {
            TabletHolderHalf();
        }
        translate([0, -splitWidth, 0])
            TabletHolderHalf();   
    }
    
    // Do not mirror them, as the screws should not be mirrored.
    translate([tabletHolderXOffset, halfTableWidth-adjusterOuterDiameter, 0])
        Adjuster();
    translate([tabletHolderXOffset, -halfTableWidth - splitWidth, 0])
        Adjuster();
}

WallHolder();
translate([topWallHolderArmLength-axelOuterDiameter/2 - tabletHolderXOffset, 0, 0]) {
    TabletHolder();
}


/*
 *    polyScrewThread_r1.scad    by aubenc @ Thingiverse
 *
 * This script contains the library modules that can be used to generate
 * threaded rods, screws and nuts.
 *
 * http://www.thingiverse.com/thing:8796
 *
 * CC Public Domain
 */

module screw_thread(od,st,lf0,lt,rs,cs)
{
    or=od/2;
    ir=or-st/2*cos(lf0)/sin(lf0);
    pf=2*PI*or;
    sn=floor(pf/rs);
    lfxy=360/sn;
    ttn=round(lt/st+1);
    zt=st/sn;

    intersection()
    {
        if (cs >= -1)
        {
           thread_shape(cs,lt,or,ir,sn,st);
        }

        full_thread(ttn,st,sn,zt,lfxy,or,ir);
    }
}

module hex_nut(df,hg,sth,clf,cod,crs)
{

    difference()
    {
        hex_head(hg,df);

        hex_countersink_ends(sth/2,cod,clf,crs,hg);

        screw_thread(cod,sth,clf,hg,crs,-2);
    }
}


module hex_screw(od,st,lf0,lt,rs,cs,df,hg,ntl,ntd)
{
    ntr=od/2-(st/2)*cos(lf0)/sin(lf0);

    union()
    {
        hex_head(hg,df);

        translate([0,0,hg])
        if ( ntl == 0 )
        {
            cylinder(h=0.01, r=ntr, center=true);
        }
        else
        {
            if ( ntd == -1 )
            {
                cylinder(h=ntl+0.01, r=ntr, $fn=floor(od*PI/rs), center=false);
            }
            else if ( ntd == 0 )
            {
                union()
                {
                    cylinder(h=ntl-st/2,
                             r=od/2, $fn=floor(od*PI/rs), center=false);

                    translate([0,0,ntl-st/2])
                    cylinder(h=st/2,
                             r1=od/2, r2=ntr, 
                             $fn=floor(od*PI/rs), center=false);
                }
            }
            else
            {
                cylinder(h=ntl, r=ntd/2, $fn=ntd*PI/rs, center=false);
            }
        }

        translate([0,0,ntl+hg]) screw_thread(od,st,lf0,lt,rs,cs);
    }
}

module hex_screw_0(od,st,lf0,lt,rs,cs,df,hg,ntl,ntd)
{
    ntr=od/2-(st/2)*cos(lf0)/sin(lf0);

    union()
    {
        hex_head_0(hg,df);

        translate([0,0,hg])
        if ( ntl == 0 )
        {
            cylinder(h=0.01, r=ntr, center=true);
        }
        else
        {
            if ( ntd == -1 )
            {
                cylinder(h=ntl+0.01, r=ntr, $fn=floor(od*PI/rs), center=false);
            }
            else if ( ntd == 0 )
            {
                union()
                {
                    cylinder(h=ntl-st/2,
                             r=od/2, $fn=floor(od*PI/rs), center=false);

                    translate([0,0,ntl-st/2])
                    cylinder(h=st/2,
                             r1=od/2, r2=ntr, 
                             $fn=floor(od*PI/rs), center=false);
                }
            }
            else
            {
                cylinder(h=ntl, r=ntd/2, $fn=ntd*PI/rs, center=false);
            }
        }

        translate([0,0,ntl+hg]) screw_thread(od,st,lf0,lt,rs,cs);
    }
}

module thread_shape(cs,lt,or,ir,sn,st)
{
    if ( cs == 0 )
    {
        cylinder(h=lt, r=or, $fn=sn, center=false);
    }
    else
    {
        union()
        {
            translate([0,0,st/2])
              cylinder(h=lt-st+0.005, r=or, $fn=sn, center=false);

            if ( cs == -1 || cs == 2 )
            {
                cylinder(h=st/2, r1=ir, r2=or, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }

            translate([0,0,lt-st/2])
            if ( cs == 1 || cs == 2 )
            {
                  cylinder(h=st/2, r1=or, r2=ir, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }
        }
    }
}

module full_thread(ttn,st,sn,zt,lfxy,or,ir)
{
  if(ir >= 0.2)
  {
    for(i=[0:ttn-1])
    {
        for(j=[0:sn-1])
        {
            pt = [	[0,                  0,                  i*st-st            ],
                    [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt-st       ],
                    [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt-st   ],
                            [0,0,i*st],
                    [or*cos(j*lfxy),     or*sin(j*lfxy),     i*st+j*zt-st/2     ],
                    [or*cos((j+1)*lfxy), or*sin((j+1)*lfxy), i*st+(j+1)*zt-st/2 ],
                    [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt          ],
                    [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt      ],
                    [0,                  0,                  i*st+st            ]	];
            
            polyhedron(points=pt,
              		  faces=[	[1,0,3],[1,3,6],[6,3,8],[1,6,4],
											[0,1,2],[1,4,2],[2,4,5],[5,4,6],[5,6,7],[7,6,8],
											[7,8,3],[0,2,3],[3,2,7],[7,2,5]	]);
        }
    }
  }
  else
  {
    echo("Step Degrees too agresive, the thread will not be made!!");
    echo("Try to increase de value for the degrees and/or...");
    echo(" decrease the pitch value and/or...");
    echo(" increase the outer diameter value.");
  }
}

module hex_head(hg,df)
{
	rd0=df/2/sin(60);
	x0=0;	x1=df/2;	x2=x1+hg/2;
	y0=0;	y1=hg/2;	y2=hg;

	intersection()
	{
	   cylinder(h=hg, r=rd0, $fn=6, center=false);

		rotate_extrude(convexity=10, $fn=6*round(df*PI/6/0.5))
		polygon([ [x0,y0],[x1,y0],[x2,y1],[x1,y2],[x0,y2] ]);
	}
}

module hex_head_0(hg,df)
{
    cylinder(h=hg, r=df/2/sin(60), $fn=6, center=false);
}

module hex_countersink_ends(chg,cod,clf,crs,hg)
{
    translate([0,0,-0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2, 
             r2=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             $fn=floor(cod*PI/crs), center=false);

    translate([0,0,hg-chg+0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             r2=cod/2, 
             $fn=floor(cod*PI/crs), center=false);
}

/*
 * knurledFinishLib.scad
 * 
 * Written by aubenc @ Thingiverse
 *
 * This script is licensed under the Public Domain license.
 *
 * http://www.thingiverse.com/thing:9095
 *
 * Usage:
 *
 *    knurled_cyl( Knurled cylinder height,
 *                 Knurled cylinder outer diameter,
 *                 Knurl polyhedron width,
 *                 Knurl polyhedron height,
 *                 Knurl polyhedron depth,
 *                 Cylinder ends smoothed height,
 *                 Knurled surface smoothing amount );
 */
module knurled_cyl(chg, cod, cwd, csh, cdp, fsh, smt)
{
    cord=(cod+cdp+cdp*smt/100)/2;
    cird=cord-cdp;
    cfn=round(2*cird*PI/cwd);
    clf=360/cfn;
    crn=ceil(chg/csh);

    intersection()
    {
        shape(fsh, cird, cord-cdp*smt/100, cfn*4, chg);

        translate([0,0,-(crn*csh-chg)/2])
          knurled_finish(cord, cird, clf, csh, cfn, crn);
    }
}

module shape(hsh, ird, ord, fn4, hg)
{
        union()
        {
            cylinder(h=hsh, r1=ird, r2=ord, $fn=fn4, center=false);

            translate([0,0,hsh-0.002])
              cylinder(h=hg-2*hsh+0.004, r=ord, $fn=fn4, center=false);

            translate([0,0,hg-hsh])
              cylinder(h=hsh, r1=ord, r2=ird, $fn=fn4, center=false);
        }

}

module knurled_finish(ord, ird, lf, sh, fn, rn)
{
    for(j=[0:rn-1])
    {
        h0=sh*j;
        h1=sh*(j+1/2);
        h2=sh*(j+1);
        
        for(i=[0:fn-1])
        {
            lf0=lf*i; 
            lf1=lf*(i+1/2);
            lf2=lf*(i+1);
            
            polyhedron(
                points=[
                     [ 0,0,h0],
                     [ ord*cos(lf0), ord*sin(lf0), h0],
                     [ ird*cos(lf1), ird*sin(lf1), h0],
                     [ ord*cos(lf2), ord*sin(lf2), h0],

                     [ ird*cos(lf0), ird*sin(lf0), h1],
                     [ ord*cos(lf1), ord*sin(lf1), h1],
                     [ ird*cos(lf2), ird*sin(lf2), h1],

                     [ 0,0,h2],
                     [ ord*cos(lf0), ord*sin(lf0), h2],
                     [ ird*cos(lf1), ird*sin(lf1), h2],
                     [ ord*cos(lf2), ord*sin(lf2), h2]
                    ],
                faces=[
                     [0,1,2],[2,3,0],
                     [1,0,4],[4,0,7],[7,8,4],
                     [8,7,9],[10,9,7],
                     [10,7,6],[6,7,0],[3,6,0],
                     [2,1,4],[3,2,6],[10,6,9],[8,9,4],
                     [4,5,2],[2,5,6],[6,5,9],[9,5,4]
                    ],
                convexity=5);
         }
    }
}

