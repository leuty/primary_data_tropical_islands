#!/bin/bash
#written by David Leutwyler, April 2019, david.leutwyler@@alumni.ethz.ch

#NCO needs filename expansion
set +o noglob

module load daint-gpu
module load CDO
module load NCO

#STREAM=("" _3D) #List output streams 
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

  #Create Landmask
  if [ ! -f $WDIR/fr_land.nc ]; then
    ncks -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d rlat,3,${llat}  -d rlon,3,${llon} $CNST $WDIR/fr_land.nc
  fi

  #Domain Mean
  cdo -s fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc $ODIR/fldmean${stream}_lnd.nc
  cdo -s fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc $ODIR/fldmean${stream}_ocean.nc #Ifnotthen is buggy

  #Domain variance
  cdo -s fldvar -ifthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc  $ODIR/fldvar${stream}_lnd.nc
  cdo -s fldvar -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc  $ODIR/fldvar${stream}_ocean.nc

  #Domain max
  cdo -s fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -abs $WDIR/timeseries${stream}.nc $ODIR/fldabs${stream}_lnd.nc
  cdo -s fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -abs $WDIR/timeseries${stream}.nc $ODIR/fldabs${stream}_ocean.nc

  #Domain Max
  cdo -s fldmax -ifthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc $ODIR/fldmax${stream}_lnd.nc
  cdo -s fldmax -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc $WDIR/timeseries${stream}.nc $ODIR/fldmax${stream}_ocean.nc

  wait

done
