// POV-Ray 3.6/3.7 Scene File/ 3.7 Scene File "Clockface_00.pov"
// author: Friedrich A. Lohmueller, 15-March-2010/Jan-2011
// email: Friedrich.Lohmueller_at_t-online.de
// homepage: http://www.f-lohmueller.de

// http://www.f-lohmueller.de/pov_tut/animate/anim113e.htm

//--------------------------------------------------------------------------
#version 3.6; // 3.7;
global_settings{ assumed_gamma 1.0 }
#default{ finish{ ambient 0.1 diffuse 0.9 conserve_energy}}
//--------------------------------------------------------------------------
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"
//--------------------------------------------------------------------------------------------------------<<<<
//------------------------------------------------------------- Camera_Position, Camera_look_at, Camera_Angle
#declare Camera_Number = 0 ;
//--------------------------------------------------------------------------------------------------------<<<<
#switch ( Camera_Number ) //----------------------------------------
#case (0)
  #declare Camera_Position = < 0.00, 0.00,-3.50> ;  // front view
  #declare Camera_Look_At  = < 0.00,-0.035+0.035,  0.00> ;
  #declare Camera_Angle    =  25-1 ;
#break
#case (1)
  #declare Camera_Position = < 3.00, 3.00,-3.00> ;  // diagonal view
  #declare Camera_Look_At  = < 0.00, 1.00,  0.00> ;
  #declare Camera_Angle    =  65 ;
#break
#else
  #declare Camera_Position = < 0.00, 1.00, -3.00> ;  // front view
  #declare Camera_Look_At  = < 0.00, 0.00,  0.00> ;
  #declare Camera_Angle    =  65 ;
#break
#end // of "#switch ( Camera_Number )" -----------------------------
//-------------------------------------------------------------------------------------------------------<<<<
camera{ location Camera_Position
        right    x*image_width/image_height
        angle    Camera_Angle
        look_at  Camera_Look_At
      }
//------------------------------------------------------------------------------------------------------<<<<<
//------------------------------------------------------------------------
// sun -------------------------------------------------------------------
light_source{<1500,2500,-2500> color White*0.9}           // sun light
light_source{ Camera_Position  color rgb<0.9,0.9,1>*0.1}  // flash light

// sky -------------------------------------------------------------------
sky_sphere{ pigment{ gradient <0,1,0>
                     color_map{ [0   color rgb<1,1,1>         ]//White
                                [0.4 color rgb<0.14,0.14,0.56>]//~Navy
                                [0.6 color rgb<0.14,0.14,0.56>]//~Navy
                                [1.0 color rgb<1,1,1>         ]//White
                              }
                     scale 2 }
           } // end of sky_sphere
//------------------------------------------------------------------------
plane { <0,0, 1>, 0
        translate<0,0,5>
        texture { pigment{color White*0.5} }
      }
//--------------------------------------------------------------------------
//---------------------------- objects in scene ----------------------------
//--------------------------------------------------------------------------


#declare Frame_Texture =
texture{ pigment{ color rgb< 1.0, 1, 1>*0.1 }
         finish { phong 1 reflection{ 0.40 metallic} }
       } // end of texture

// marks
#declare H_Texture =
texture{ pigment{ color rgb<1,1,1>*0.0 }
         //  finish { phong 1 reflection{ 0.20 metallic} }
       } // end of texture
#declare Min_Texture = texture{H_Texture}

#declare Face_Texture =
texture{ pigment{ color rgb< 1,1,1>*1.10 }
         //   normal { bumps 1.5 scale 0.005 }
         //   finish { phong 0.5 reflection{ 0.30 metallic} }
       } // end of texture
// hands
#declare Hands_Texture =
texture{ pigment{ color rgb< 1.0, 1, 1.0>*0.0 }
                  //  finish { phong 1 reflection{0.30 metallic}}
       } // end of texture

#declare Sec_Hand_Texture =
texture{ pigment{ color rgb< 1.0, 0.0, 0.0>*0.5 }
         //  finish { phong 1 reflection{ 0.30 metallic} }
       } // end of texture
//--------------------------------------------------------------//
//--------------------------------------------------------------//
#declare Sec_Hand_On = 1;
#declare CR = 0.400; // Clockface radius
// test time
              #local H   = 2  ;
              #local Sec = 36 ;
              #local Min = 22 ;
//----------------------------------------- // Clock_Time h   m   s
#declare Clock_Time = clock   +H/(12)+  Min/(720)     + Sec/(43200);
//-----------------------------------------
// rotation angles in degrees ------------- // rotations
#declare Rotate_H   = Clock_Time*360;
#declare Rotate_Min = Clock_Time*360*12;
#declare Rotate_Sec = Clock_Time*360*12*60;
// minutes/seconds jump - Minuten-/Sekundensprung:
 #declare Rotate_Min = int( Rotate_Min/6+0.001)*6;
 #declare Rotate_Sec = int( Rotate_Sec/6+0.001)*6;
//-----------------------------------------

#declare Flat = <1,1,0.025>;

// border radii --------------
#declare Min_Ro = CR *0.92;
#declare Min_Ri = CR *0.82;
#declare H_Ri   = CR *0.65;
// halbe streifen breite
#declare Min_R = CR*0.0200;
#declare H_R   = CR*0.0400;
//-----------------------------------

#declare Face_D = 0.001;
// length of hands -------------
#declare Hand_H_Len   = CR*0.60;
#declare Hand_Min_Len = CR*0.85;
#declare Hand_Sec_Len = CR*0.95;

// radii of the hands ---------
#declare Hand_H_D   = CR*0.055;
#declare Hand_Min_D = CR*0.035;
#declare Hand_Sec_D = CR*0.020;

// position z of hands --------
#declare Hand_H_Z   = CR*0.05;
#declare Hand_Min_Z = CR*0.04;
#declare Hand_Sec_Z = CR*0.03;
//-----------------------------------
//-----------------------------------
union{

// hands //--------------------------
// hours
cylinder{ <0,0,0>,<0,Hand_H_Len,0>,Hand_H_D
          scale Flat
          rotate   <0,0,-Rotate_H>
          translate<0,0,-Hand_H_Z>
          texture{ Hands_Texture }
        } //-------------------------
// minutes
cylinder{ <0,0,0>,<0,Hand_Min_Len,0>,Hand_Min_D
          scale Flat
          rotate   <0,0,-Rotate_Min>
          translate<0,0,-Hand_Min_Z>
          texture{ Hands_Texture }
        } //------------------------
// seconds
 #if ( Sec_Hand_On = 1 )
 cylinder{ <0,0,0>,<0,Hand_Sec_Len,0>,Hand_Sec_D
           scale Flat
           rotate   <0,0,-Rotate_Sec>
           translate<0,0,-Hand_Sec_Z>
           texture{ Sec_Hand_Texture }
         } //-----------------------
 #end
//----------------------------------
// body ----------------------------
// center --------------------------
cylinder{ <0,0,-Hand_H_Z>,<0,0,0>,Hand_H_D*1.5
          texture{ Hands_Texture }
        }

// face
cylinder{ <0,0,0>,<0,0, Face_D>,CR
          texture{ Face_Texture }
        }
//----------------------------------
//----------------------------------
#declare Nr=0;
#while (Nr<60)

 #if(  Nr/5 = int(Nr/5) ) // --- hours
 cylinder{ <0,H_Ri,0>,<0,Min_Ro,0>,H_R
           scale Flat
           rotate <0,0,Nr*360/60>
           texture{ H_Texture }
         }

 #else  //----------------------- minutes
 cylinder{ <0,Min_Ri,0>,<0,Min_Ro,0>,Min_R
           scale Flat
           rotate <0,0,Nr*360/60>
           texture{ Min_Texture }
         }
 #end //-------------------------

#declare Nr=Nr+1;
#end


} // end of union ---------------------------------------
// ------------------------------------------------------
