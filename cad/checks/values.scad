include <../config.scad>
include <../parts/stair.scad>
include <../sheets.scad>
echo(str("VAL;", "ALPHA=",ALPHA,";ROT_Z=",ROT_Z,";BELT_Z=",BELT_Z,";C_S=",C_S,";ZT=",ZT,";XT=",XT,
 ";X_BACK=",X_BACK,";APRON_X=",APRON_X,";APRON_Z=",APRON_Z,";FLOOR_SLOPE=",FLOOR_SLOPE,";Z_RIM=",Z_RIM,
 ";SIDE_IN=",SIDE_IN,";ST_H=",ST_H,";ST_N=",ST_N,";ST_STROKE=",ST_STROKE,";ST_L=",ST_L,";ST_P=",ST_P,
 ";CAM_E=",CAM_E,";CAM_R=",CAM_R,";ROLL_R=",ROLL_R,";S_STOP=",S_STOP,";S_GATE=",S_GATE,";S_X2_FRONT=",S_X2_FRONT,
 ";S_CLAMP=",S_CLAMP,";S_FULL=",S_FULL,";S_EXIT=",S_EXIT,";INLET_S=",INLET_S,";HOU_BOTTOM=",HOU_BOTTOM,
 ";SIDE_X1=",SIDE_X1,";ZRIM_NEG=",z_rim(-SIDE_IN),";ZRIM_POS=",z_rim(SIDE_IN),";TR_ZLIP=",TR_ZLIP));
