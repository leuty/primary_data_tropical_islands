#!/bin/bash
#written by David Leutwyler, April 2019, david.leutwyler@@alumni.ethz.ch

#NCO needs filename expansion
set +o noglob

module load daint-gpu
module load CDO
module load NCO

STREAM=("") #List output streams 

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

done
