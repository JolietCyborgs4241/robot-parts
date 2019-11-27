$fn = 200;               // facets per circle

use <MCAD/regular_shapes.scad>

// chamfer is from https://github.com/SebiTimeWaster/Chamfers-for-OpenSCAD
include <Chamfers-for-OpenSCAD/Chamfer.scad>;


MMtoIN        = 25.4;

LeftWheel     = 1;              // handle both wheels from one program
RightWheel    = -1;
Direction     = LeftWheel;      // set direction as appropriate

Font1         = "Liberation Sans";
FontSize      = 4;
LabelFontSize = 8.25;

// all dimensions in mm

WheelDiam     = 4.0 * MMtoIN;
WheelWidth    = 2.0 * MMtoIN;
WheelChamfer  = 0.0625 * MMtoIN;

// things get a little itchy when dealing with the hex bore hole
//
// the "radius" passed to the hexagon_prism() routine is the radius
// of the circle circumscribing the polygon (on the outside) but we can also
// consider the polygon to be inscribed on the circle
//
// what we want is to specify the radius of the circle inscribed in the hexagon
// so that we can specify the size of the hole as the distance between two
// opposing flats on the hexagon - just like bolts or nuts are sized
//
// for hexagons, the length of a side is equal to the radius of the circumscribing
// circle - this means if we can calculate the length of the side when the circle
// of our target radius is inscribed in the hexagon, we can use that to calculate
// the radius of the circle circumscribing the hexagon (which is what we need when
// we use the appropriate library routine)
//
// the length of a side based on the inscribed circle is:
//
//      2 * INSCRIBED_RADIUS * tan(PI/NUM_OF_SIDES) - angle in radians
// or
//      2 * INSCRIBED_RADIUS * tan(PI / NUM_OF_SIDES * 180 / PI) - angle in degrees
// or simplifying to:
//      INSCRIBED_DIAMETER * tan(180 / NUM_OF_SIDES)

HexBoreInscribedDiam       = 0.5 * MMtoIN;
HexBoreCircumscribedRadius = HexBoreInscribedDiam * tan(180/6);  //Diam already in MM

NumOfRollers   = 6;
RollerLength   = 2.0 * MMtoIN;
RollerDiam     = 1.1 * MMtoIN;   // slightly larger than 0.5" roller for clearance

// 20% undersized for 1/8" axles so we can drill to the correct size later
RollerAxleDiam = 1.0 / 8.0 * MMtoIN * 0.80;

RollerAngle    = 45;


Extra        = 0.2;         // extra extrusion height to not leave a 0 thickness surface




difference() {
    
    // we mocve to centered on the z axis to make it easier to do the
    // rollers and the axles
    
    //cylinder(h=WheelWidth, d=WheelDiam, center=true);
    translate([0, 0, -WheelWidth / 2]) {
        chamferCylinder(h=WheelWidth, r=WheelDiam / 2, ch=WheelChamfer);
    }
    
    // punch out the hex bore
    translate ([0, 0, -WheelWidth / 2 - Extra]) {
        hexagon_prism(WheelWidth + Extra * 2, HexBoreCircumscribedRadius);
    }
    
    // remove the roller cutouts and the axle holes
    
    // rotate for each roller (we don't need to duplicate the first roller with
    // the last roller so we use 1 degree short of a fulle rotation as our end
    for (rotAngle = [0:360/NumOfRollers:359]) {
        rotate(a=rotAngle, v=[0, 0, 1]) {         // rotate to the roller angle position
            rotate(a=RollerAngle * Direction, v=[0, 1, 0]) {  // rotate 45 degree around the Y axis
                // locate the centerline of the roller
                translate([0, WheelDiam / 2 * 0.80, 0]) { 

                    cylinder(h=RollerLength, d=RollerDiam, center=true);
                    cylinder(h=RollerLength * 2, d=RollerAxleDiam, center=true);
                }
            }
        }
    }    
}