
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path = "/project/s916/davidle/RCE-LND/analysis/ensmean/"

dfile = addfile(path+"/ensmean_daycycle_ALL.nc", "r")
p = dfile->TOT_PREC
PW = dfile->TWATER
mPW = dim_avg_n(PW,0); obtain diurnal mean
statb = stat_dispersion(mPW,False)
median=statb(8)

moist =  where(mPW.gt.median, 1, 0)  

path = "/project/s916/davidle/RCE-LND/RCE_300_3km_1006x1006_ALL_ens0/output/"
cfile = addfile(path+"lffd2011032100c.nc", "r")
fr_land = new((/1, 1000, 1000/), float)
fr_land(0,:,:)  = cfile->FR_LAND(0,3:1002,3:1002)

p@long_name  = ""
p@units      = ""

fr_land@long_name  = ""
fr_land@units      = ""

;convert to mm/day
p=p*24

;==============================================================

res                       = True
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnPaperOrientation   = "portrait"
res@gsnDraw               = False
res@gsnFrame              = False
res@tmXTOn = False
res@tmXBOn = False
res@tmYROn = False 
res@tmYLOn = False 

lres = res
mres = res

;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False

res@lbLabelBarOn           = True 
res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@lbOrientation          = "vertical"
res@gsnSpreadColors        = True

res@cnLevelSelectionMode   = "ExplicitLevels" 
res@cnLevels    = (/1,2,5,10,20,50,100/)

;Define C0ntour Land
;-------------------
lres@cnInfoLabelOn          = False
lres@cnLineLabelsOn         = False

;Contour Moistregion
mres@cnInfoLabelOn          = False
mres@cnLineLabelsOn         = False

mres@cnLevelSelectionMode   = "ExplicitLevels"
mres@cnLevels    = (/0.5/)
mres@cnLineColor  = "Black"
mres@cnLineThicknessF = 8. 

;============================================================

wks_type = "png"
wks = gsn_open_wks("png", "mean_precip" )
gsn_define_colormap(wks,"precip_11lev")

plot_land = gsn_contour(wks, fr_land(0,:,:), lres)
plot = gsn_csm_contour(wks, dim_avg_n(p(:,:,:),0),res)
plot_moist = gsn_csm_contour(wks, moist,mres)
  
overlay(plot,plot_land)
overlay(plot,plot_moist)
draw(plot)
frame(wks)


end

