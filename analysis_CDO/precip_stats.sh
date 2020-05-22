#!/bin/bash -l
#written by David Leutwyler, April 2019, david.leutwyler@@alumni.ethz.ch

module load daint-gpu
module load CDO
module load NCO

ODIR=$ODIR/precip_stats

llon=$( echo $exp | cut -dx -f2 )
llon=$(($llon-4))
llat=$( echo $exp | cut -dx -f1 )
llat=$(($llat-4))

#Cat files
if [ ! -f ${WDIR}/timeseries.nc ]; then
 ncrcat -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d srlat,3,${llat}  -d srlon,3,${llon} $IDIR/output/lffd??????????.nc ${WDIR}/timeseries_tmp.nc
 ncks -h ${WDIR}/timeseries_tmp.nc ${WDIR}/timeseries.nc
 rm ${WDIR}/timeseries_tmp.nc
fi

#Create Landmask
if [ ! -f $WDIR/fr_land.nc ]; then
  ncks -O -h -d rlat,3,${llat} -d rlon,3,${llon} -d rlat,3,${llat}  -d rlon,3,${llon} $CNST $WDIR/fr_land.nc
fi

#Domain mean timeseries
#======================

#Daily precipitation
cdo -s daymean -fldmean -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_daymean.nc
cdo -s daymean -fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_daymean_lnd.nc
cdo -s daymean -fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_daymean_ocean.nc

#Wet-Hour Frequency
cdo -s fldmean -gtc,0.01 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/wh_freq.nc
cdo -s fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -gtc,0.01 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/wh_freq_lnd.nc
cdo -s fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -gtc,0.01 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/wh_freq_ocean.nc

#Wet-Day Frequency
cdo -s fldmean -gtc,1.0 -daysum $WDIR/precip.nc $ODIR/wd_freq.nc
cdo -s fldmean -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -gtc,1.0 -daysum -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/wd_freq_lnd.nc
cdo -s fldmean -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -gtc,1.0 -daysum -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/wd_freq_ocean.nc

#All_hour p90
cdo -s fldpctl,90 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p90.nc
cdo -s fldpctl,90 -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p90_lnd.nc
cdo -s fldpctl,90 -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p90_ocean.nc

#All_hour p95
cdo -s fldpctl,95 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p95.nc
cdo -s fldpctl,95 -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p95_lnd.nc
cdo -s fldpctl,95 -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p95_ocean.nc

#All_hour p99
cdo -s fldpctl,99 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p99.nc
cdo -s fldpctl,99 -ifthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p99_lnd.nc
cdo -s fldpctl,99 -ifnotthen -selvar,FR_LAND $WDIR/fr_land.nc -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/p99_ocean.nc

#Spatial Distributuin
#===================

cdo -s timmean -seltimestep,2400/3600 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_timmean_2D_eq.nc
cdo -s timmean -gtc,0.1 -seltimestep,2400/3600 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_wh_freq_2D_eq.nc
cdo -s timmean -gtc,1 -daysum -seltimestep,2400/3600 -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_wd_freq_2D_eq.nc
cdo -s timpctl,99 -selvar,TOT_PREC ${WDIR}/timeseries.nc -timmin -selvar,TOT_PREC ${WDIR}/timeseries.nc -timmax -selvar,TOT_PREC ${WDIR}/timeseries.nc $ODIR/precip_p99_2D_eq.nc

