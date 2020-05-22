#!/bin/bash
#written by David Leutwyler, April 2019, david.leutwyler@@alumni.ethz.ch

#NCO needs filename expansion
set +o noglob

module load daint-gpu
module load CDO
module load NCO

STREAM=("" _3D) #List output streams 

#Domain-mean values
for stream  in "${STREAM[@]}";do
  llon=$( echo $exp | cut -dx -f2 )
  llon=$(($llon-4))
  llat=$( echo $exp | cut -dx -f1 )
  llat=$(($llat-4))

  #Cat files
  if [ ! -f ${WDIR}/timeseries${stream}.nc ]; then
   ncrcat -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d srlat,3,${llat}  -d srlon,3,${llon} $IDIR/output${stream}/lffd??????????.nc ${WDIR}/timeseries${stream}_tmp.nc
   ncks -h ${WDIR}/timeseries${stream}_tmp.nc ${WDIR}/timeseries${stream}.nc
   rm ${WDIR}/timeseries${stream}_tmp.nc
  fi

  #Create Landmask
  if [ ! -f $WDIR/fr_land.nc ]; then
    ncks -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d rlat,3,${llat}  -d rlon,3,${llon} $CNST $WDIR/fr_land.nc
  fi

  for HH in $(seq -w 0 23); do
    #cdo -s -timmean -selhour,$HH -seltimestep,1440/2400 $WDIR/timeseries${stream}.nc $WDIR/dhourmean${stream}_${HH}.nc 
    nces -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d srlat,3,${llat}  -d srlon,3,${llon} ${IDIR}/output${stream}/lffd20110{7,8}??${HH}.nc ${IDIR}/output${stream}/lffd201106{29,30}${HH}.nc $WDIR/dhourmean${stream}_${HH}.nc
  done
  ncrcat -h $WDIR/dhourmean${stream}_??.nc -O $WDIR/dhourmean${stream}_tmp.nc

  ncks -h -O $WDIR/dhourmean${stream}_tmp.nc $ODIR/dhourmean${stream}.nc

  rm $WDIR/dhourmean${stream}_??.nc $WDIR/dhourmean${stream}_tmp.nc

  #Domain Mean
  cdo -s fldmean $ODIR/dhourmean${stream}.nc $ODIR/dhourmean_fldmean${stream}.nc
  cdo -s fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc $ODIR/dhourmean${stream}.nc $ODIR/dhourmean_fldmean_lnd${stream}.nc
  cdo -s fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc $ODIR/dhourmean${stream}.nc $ODIR/dhourmean_fldmean_ocean${stream}.nc

done
