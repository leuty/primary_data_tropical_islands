#!/bin/bash 
#Submit analysis to node

#Module load 
export USERGRP=s916
export BINDIR=/users/${USER}/analysis_RCE_LND_new
export SHDIR=/users/${USER}/analysis_RCE_LND/ncl

#CDO Options
export CDO_PCTL_NBINS=1000
export CDO_HISTORY_INFO=0

for exp in 1006x1006; do
  for SST in 300; do
    for ens in {0..5} ; do
      for lnd in ALL SMALL BIG; do

        export exp=$exp
        export SST=$SST
        export logfiles=${BINDIR}/logfiles_$exp
    
        export IDIR=$SCRATCH/RCE-LND_new/RCE_${SST}_3km_${exp}_${lnd}_ens$ens
        export WDIR=$SCRATCH/RCE-LND_new/workdirs/RCE_3km_${exp}_${SST}_${lnd}_ens$ens
        export ODIR=$SCRATCH/RCE-LND_new/analysis/RCE_${SST}_3km_${exp}_${lnd}_ens$ens
        export CNST=$SCRATCH/RCE-LND_new/RCE_${SST}_3km_${exp}_${lnd}_ens$ens/output/lffd2011032100c.nc 
  
        if [ ! -d $WDIR   ]; then mkdir -p $WDIR ; fi
        if [ ! -d $WDIR/p_fmse ]; then mkdir -p $WDIR/p_fmse; fi
        if [ ! -d $ODIR   ]; then mkdir -p $ODIR ; fi
        if [ ! -d $ODIR/precip_stats   ]; then mkdir -p $ODIR/precip_stats ; fi
        if [ ! -d $logfiles   ]; then mkdir -p $logfiles ; fi
    
        jobid_merge=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/merge_${SST}_${ens}_${lnd}.err -o ${logfiles}/merge_${SST}_${ens}_${lnd}.out --job-name="RCE_merge" --wrap='./merge.sh' | cut -d' ' -f4`
        jobid_merge_3D=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/merge_3D_${SST}_${ens}_${lnd}.err -o ${logfiles}/merge_3D_${SST}_${ens}_${lnd}.out --job-name="RCE_merge_3D" --wrap='./merge_3D.sh' | cut -d' ' -f4`

        jobid_means=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/fldmean_${SST}_${ens}_${lnd}.err -o ${logfiles}/fldmean_${SST}_${ens}_${lnd}.out --job-name="RCE_fldmean" --wrap='./compute_fldmean.sh' | cut -d' ' -f4`
        jobid_means_lnd=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/fldmean_lnd_${SST}_${ens}_${lnd}.err -o ${logfiles}/fldmean_lnd_${SST}_${ens}_${lnd}.out --job-name="RCE_fldmean_lnd" --wrap='./compute_fldmean_lnd.sh' | cut -d' ' -f4`
        jobid_dhourstat=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/dhourstat_${SST}_${ens}_${lnd}.err -o ${logfiles}/dhourstat_${SST}_${ens}_${lnd}.out --job-name="RCE_dhourstat" --wrap='./compute_dhourstat.sh' | cut -d' ' -f4`
  
        jobid_precip=`sbatch -C gpu --time=6:00:00 --account=$USERGRP -e ${logfiles}/precip_${SST}_${ens}_${lnd}.err -o ${logfiles}/precip_${SST}_${ens}_${lnd}.out --job-name="RCE_precip" --wrap='./precip_stats.sh' | cut -d' ' -f4`
        jobid_cf=`sbatch -C gpu --time=12:00:00 --account=$USERGRP -e ${logfiles}/cf_${SST}_${ens}_${lnd}.err -o ${logfiles}/cf_${SST}_${ens}_${lnd}.out --job-name="RCE_cf" --wrap='./compute_cloud_fraction.sh' | cut -d' ' -f4`
        jobid_profiles=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/profiles_${SST}_${ens}_${lnd}.err -o ${logfiles}/profiles_${SST}_${ens}_${lnd}.out --job-name="RCE_profiles" --wrap='./compute_quartile_profiles.sh' | cut -d' ' -f4`

      done
    done
  done
done



for exp in 1006x1006; do
  for SST in 300; do
    for lnd in ALL BIG SMALL; do

        export exp=$exp
        export SST=$SST
        export logfiles=${BINDIR}/logfiles_$exp
        export LND=$lnd

        export IDIR=$SCRATCH/RCE-LND_new
        export WDIR=$SCRATCH/RCE-LND_new/workdirs
        export ODIR=$SCRATCH/RCE-LND_new/analysis/ensmean
        export CNST=$SCRATCH/RCE-LND_new/RCE_${SST}_3km_${exp}_${lnd}_ens0/output/lffd2011032100c.nc

        if [ ! -d $WDIR   ]; then mkdir -p $WDIR ; fi
        if [ ! -d $WDIR/p_fmse ]; then mkdir -p $WDIR/p_fmse; fi
        if [ ! -d $ODIR   ]; then mkdir -p $ODIR ; fi
        if [ ! -d $ODIR/precip_stats   ]; then mkdir -p $ODIR/precip_stats ; fi
        if [ ! -d $logfiles   ]; then mkdir -p $logfiles ; fi

        jobid_ensmean=`sbatch -C gpu --time=24:00:00 --account=$USERGRP -e ${logfiles}/ensmean_${SST}.err -o ${logfiles}/ensmean_${SST}.out --job-name="RCE_ensmean" --wrap='./compute_ensmean.sh' | cut -d' ' -f4`

    done
  done
done


