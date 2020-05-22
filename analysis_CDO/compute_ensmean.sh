#!/bin/bash
#written by David Leutwyler, April 2019, david.leutwyler@@alumni.ethz.ch

#NCO needs filename expansion
set +o noglob

module load daint-gpu
module load CDO
module load NCO

STREAM=("" _3D) #List output streams 

#2D Domain-mean values
llon=$( echo $exp | cut -dx -f2 )
llon=$(($llon-4))
llat=$( echo $exp | cut -dx -f1 )
llat=$(($llat-4))

#Consider last 50 days
ncea -h -O -d rlat,3,1000 -d rlon,3,1000 -d srlat,3,1000 ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output/lffd20110{7,8}????.nc ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output/lffd201106{29,30}??.nc $ODIR/ensmean_${LND}.nc

for HH in $(seq -w 0 23); do
  ncea -h -O -d rlat,3,1000 -d rlon,3,1000 -d srlat,3,1000 ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output/lffd20110{7,8}??${HH}.nc ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output/lffd201106{29,30}${HH}.nc $WDIR/ensmean_${HH}_${LND}.nc
done
cdo -s mergetime $WDIR/ensmean_??_${LND}.nc $ODIR/ensmean_daycycle_${LND}.nc

#3D Domain-mean values
#for var  in T P RELHUM QV THHR_RAD SOHR_RAD TINC_LH;do
for var  in QV THHR_RAD SOHR_RAD TINC_LH;do
#for var  in QC;do
#for var  in W;do
  llon=$( echo $exp | cut -dx -f2 )
  llon=$(($llon-4))
  llat=$( echo $exp | cut -dx -f1 )
  llat=$(($llat-4))
  
  #Consider last 50 days
  ncea -h -O -v $var -d rlat,3,1000 -d rlon,3,1000 -d srlat,3,1000 ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output_3D/lffd20110{7,8}????.nc ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output_3D/lffd201106{29,30}??.nc $ODIR/ensmean_${LND}_3D_${var}.nc
  
  for HH in $(seq -w 0 23); do
    ncea -h -O -v $var -d rlat,3,1000 -d rlon,3,1000 -d srlat,3,1000 ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output_3D/lffd20110{7,8}??${HH}.nc ${IDIR}/RCE_300_3km_1006x1006_${LND}_ens?/output_3D/lffd201106{29,30}${HH}.nc $WDIR/ensmean_${HH}_${LND}_3D_${var}.nc
  done
  cdo -s mergetime $WDIR/ensmean_??_${LND}_3D_${var}.nc $ODIR/ensmean_daycycle_${LND}_3D_${var}.nc
done
