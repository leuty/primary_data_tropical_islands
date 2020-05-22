
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dfile = addfile("/project/s916/davidle/RCE-LND/RCE_300_3km_1006x1006_ALL_ens0/output/lffd2011032100c.nc", "r")
fr_land = dfile->FR_LAND(0,:,:)
fr_land@long_name  = ""
fr_land@units      = ""


;==============================================================

res                       = True
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnDraw               = False
res@gsnFrame              = False

res@pmTickMarkDisplayMode  = "never"

lres = res

;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False

res@cnLineLabelsOn        = False
res@cnInfoLabelOn          = False
res@lbLabelBarOn           = True  
res@gsnSpreadColors        = True

res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = 110 
res@cnMaxLevelValF         = 330 
res@cnLevelSpacingF        = 5 


;Define LND
;----------------

lres@cnInfoLabelOn         = False
lres@cnLineLabelsOn        = False
lres@cnLineColor           = "White"
lres@cnLineThicknessF      = 3

lres@cnLevelSelectionMode   = "ManualLevels"
lres@cnMinLevelValF         = 0.9
lres@cnMaxLevelValF         = 1
lres@cnLevelSpacingF        = 0.1



wks_type = "png"
wks_type@wkWidth = 1300
wks_type@wkHeight = 1300



plotdir = "./"

do i = 0,0,1
   dfile = addfile("/project/s916/davidle/RCE-LND/RCE_300_3km_1006x1006_ALL_ens"+i+"/output/lffd2011081717.nc", "r")
   p = dfile->ATHB_T(0,:,:)
   
   p@long_name  = ""
   p@units      = ""
   
	   wks = gsn_open_wks(wks_type, plotdir + "OLR_ens"+i+"_zoom" )
   gsn_define_colormap(wks,"MPL_Greys")
   
   dim = dimsizes(p)
   
   ;Loop over all files
   ;=============================================================
   plot = gsn_contour(wks, abs(p(200:600, 200:600)) , res)
   plot_lnd = gsn_contour(wks, fr_land(203:603,203:603), lres)
   ;============================================================

overlay(plot,plot_lnd)
draw(plot)
frame(wks)

end do




end

