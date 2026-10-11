include <../config.scad>
include <../lib/basics.scad>
include <../parts/gutter.scad>
include <../parts/teller.scad>
echo(str("VAL;", "ALPHA=",ALPHA,";ROT_Z=",ROT_Z,";BELT_Z=",BELT_Z,";Z_RIM=",Z_RIM,
 ";S_STOP=",S_STOP,";S_GATE=",S_GATE,";S_X2_FRONT=",S_X2_FRONT,";S_CLAMP=",S_CLAMP,";S_FULL=",S_FULL,
 ";S_EXIT=",S_EXIT,";S_T=",S_T,";INLET_S=",INLET_S,";HOU_BOTTOM=",HOU_BOTTOM,
 ";TD_R=",TD_R,";TD_RB=",TD_RB,";TD_RL=",TD_RL,";TD_N=",TD_N,";TD_RPM=",TD_RPM,";TD_INCL=",TD_INCL,
 ";HK_PR=",HK_PR,";HK_RI=",HK_RI,";HK_H=",HK_H,";HK_YR=",HK_YR,";HK_PT=",HK_PT,";RING_RI=",RING_RI,
 ";TD_TOP_ANG=",TD_TOP_ANG,";TD_DROT=",TD_DROT,";HOP_FLOOR=",HOP_FLOOR,
 ";DISC_ZC=",D2w([0,0,0])[2],";DISC_ZBOT=",D2w([0,-TD_R,0])[2],";T_Z=",td2w([TD_RB,0,B_D/2])[2],
 ";FILL_YD=",FILL_D/FILL_N[1]));
