frameWidth=200;
frameThickness=10;
frameLength=200;
frameHeight=60;
// 608zz bearing dimensions taken from:
// https://www.skf.com/group/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-608-Z
bearingDiameter=22;
bearingThickness=7;
bearingBoreRadius=8;
bearingBoreInertTolerance=1.01;
bearingInsertTolerance=1.01;

// For the motor mount I've borrowed heavily from "Affordable Rock Tumbler". It
// seems to take different motor sizes with varied mount points. I don't have an
// OpenSCAD file from that so I'm just going off of measurements from a printed
// part.
//
// [x] Top of frame to top of inner screw mount: 21mm
innerScrewMountFromTopOfFrame = 21;
// [x] Inside screw mount from decorative opening: 39.37mm
// [x] Outside screw mount from decorative opening: 62.75mm
// [x] Top of frame to bottom of upper outside screw mount: 7.5mm
outerTopScrewMountFromTopOfFrame = 7.5;
// [x] Top of frame to bottom of bottom outside screw mount: 34.5mm
outerBottomScrewMountFromTopOfFrame = 34.5;
// [x] Outside screw mounts horizontally aligned.
// [x] Screw mount opening width: 11mm
motorScrewMountWidth=11;
// [x] Screw mount opening height: 3.2mm
motorScrewMountHeight=3.2;
// [ ] Large motor shaft opening outside side from decorative opening: 48.40mm
// [x] Large motor shaft opening (inside opening): 15.1mm
motorShaftOpeningLargeRadius=16 / 2;
// [x] Small motor shaft opening (outside opening): 11mm
motorShaftOpeningSmallRadius=12 / 2;
// [x] Motor shaft openings both align on the bottom, and vary by the top.
// [x] Motor shaft top to top of frame: 34.70mm
motorShaftOpeningDistanceY=34.5;
motorShaftOpeningDistanceFromTopOfFrame=7.6;
motorShaftOpeningRadiusDelta=
  motorShaftOpeningLargeRadius -
  motorShaftOpeningSmallRadius;
motorShaftOpeningOuterX=20;
motorShaftOpeningDistanceX=asin(
                                motorShaftOpeningRadiusDelta /
                                (20.75 - motorShaftOpeningRadiusDelta)
                                );
// [ ] Longest distance between motor shaft openings: 20.75mm
//
// [x] Gap of bearings (closest sides): 90mm
// [x] Bearing height from top: 9.31mm
bearingInsertFromTop=9.31;


motorMountShaftRadius=15;

module bearingBoreless() {
  cylinder(h=bearingThickness, r=bearingDiameter / 2, center=true);
}

module bearingBore() {
  cylinder(h=bearingThickness, r=bearingBoreRadius / 2, center=true);
}

module bearingWithBore() {
  difference() {
    bearingBoreless();
    bearingBore();
  }
}

module motorScrewMount() {
  translate([0, frameThickness / 2, 0])
    union() {
      $fn=100;
      rotate([90, 0, 0]) cylinder(
                                  h=frameThickness+1,
                                  r=motorScrewMountHeight / 2,
                                  center=true
                                  );
      translate([0, (frameThickness+1) / -2, -motorScrewMountHeight / 2])
        cube([
              motorScrewMountWidth - motorScrewMountHeight,
              frameThickness+1,
              motorScrewMountHeight,
              ]);
      rotate([90, 0, 0])
        translate([motorScrewMountWidth - motorScrewMountHeight, 0, 0])
        cylinder(
                h=frameThickness+1,
                r=motorScrewMountHeight / 2,
                center=true
                );
    }
}

module motorMountShaftOpeningLarge() {
  rotate([90, 0, 0])
    translate([
               motorShaftOpeningDistanceX + motorShaftOpeningOuterX,
               /* motorShaftOpeningDistanceY + */
               frameHeight - (
                              motorShaftOpeningDistanceFromTopOfFrame +
                              motorShaftOpeningLargeRadius
                              ),
               - frameThickness / 2,
               ])
    cylinder(h=frameThickness+1, r=motorShaftOpeningLargeRadius, center=true);
}

module motorMountShaftOpeningSmall() {
  rotate([90, 0, 0])
    translate([
               motorShaftOpeningOuterX,
               /* motorShaftOpeningDistanceY + */
               /* motorShaftOpeningSmallRadius, */
               motorShaftOpeningSmallRadius +
               frameHeight - (
                              motorShaftOpeningDistanceFromTopOfFrame +
                              motorShaftOpeningLargeRadius * 2
                              ),
               - frameThickness / 2,
               ])
    cylinder(h=frameThickness+1, r=motorShaftOpeningSmallRadius, center=true);
}

module motorMountOpening() {
  outerDistanceFromFrameX = 10;
  innerOuterDistanceX = 62.75 - 39.37;
  innerScrewMountHeight = frameHeight -
    innerScrewMountFromTopOfFrame -
    motorScrewMountHeight;
  translate([
             outerDistanceFromFrameX + innerOuterDistanceX,
             0,
             innerScrewMountHeight,
             ])
    motorScrewMount();
  outerTopScrewMountY = frameHeight - outerTopScrewMountFromTopOfFrame;
  translate([
             outerDistanceFromFrameX,
             0,
             outerTopScrewMountY,
             ])
    motorScrewMount();
  outerBottomScrewMountY = frameHeight - outerBottomScrewMountFromTopOfFrame;
  translate([
             outerDistanceFromFrameX,
             0,
             outerBottomScrewMountY
             ])
    motorScrewMount();
  motorMountShaftOpeningLarge();
  motorMountShaftOpeningSmall();
}

module bearingInsert(x, y) {
  union() {
    rotate([90, 0, 0])
      translate([x, y, -bearingThickness / 2])
      scale([
             bearingInsertTolerance,
             bearingInsertTolerance,
             bearingInsertTolerance,
             ])
      bearingBoreless();
    rotate([90, 0, 0])
      translate([x, y, -frameThickness])
      scale([
             bearingBoreInsertTolerance,
             bearingBoreInsertTolerance,
             // TODO: Extruding the length out here would probably be better
             // described as a relationship between the bearing thickness and
             // the frame thickness.
             5,
             ])
      bearingBore();
  }
}

module gearPanel() {
  bearingGap=90;
  bearingInsertY=frameHeight + (bearingDiameter / 2) - bearingInsertFromTop;
  difference() {
    cube([frameWidth, frameThickness, frameHeight]);
    bearingInsert(bearingInsertY, 30);
    bearingInsert(bearingInsertY + bearingGap, 30);
    motorMountOpening();
  }
}

gearPanel();
