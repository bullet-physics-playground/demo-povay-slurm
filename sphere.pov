#version 3.7;                                                                   

global_settings { assumed_gamma 1.0 }

camera {
  ultra_wide_angle
  right x*image_width/image_height
  location <1,6,-20>
  rotate <0, (360*clock), 0>
  look_at <0,2,0>
}

light_source {
  <10,15,-20>
  color rgbf <2.0, 2.0, 2.0, 0.0>
}

plane { y, -1
  pigment {checker
    color rgbf <0.0, 0.0, 0.0, 0.0>
    color rgbf <1.0, 1.0, 1.0, 0.0>
  }
  scale 4
}

sphere { <0,2,0>, 3.0
  scale 2

  pigment { color rgbf <1.0, 0.0, 0.0, 0.0> }
  finish {
    phong 0.8
    reflection 0.5
  }
  translate <0, 7*cos(radians(360*clock))-7.0, 0>
}

sphere { <5, 2, -6>, 2.0
  pigment { color rgbf <0.5+clock/24, 0.5 +clock/24, 1.0, 0.9>}
  finish {
    phong 0.8
    reflection 0.1
    refraction 1
    ior 1.3
  }
}
