
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path = "/project/s916/davidle/RCE-LND/analysis/ensmean/"

dfile = addfile(path+"/ensmean_daycycle_ALL.nc", "r")
p = dfile->TOT_PREC

path = "/project/s916/davidle/RCE-LND/RCE_300_3km_1006x1006_ALL_ens0/output/"
cfile = addfile(path+"lffd2011032100c.nc", "r")
fr_land = cfile->FR_LAND(0,3:1000,3:1000)

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

wks_type = "png"
wks = gsn_open_wks("png", "mean_daycycle" )
gsn_define_colormap(wks,"precip_11lev")

;plot land
plot_land = gsn_contour(wks, fr_land, lres)


delete_VarAtts(p, -1)
p!0=""
p!1=""
p!2=""
cp = new((/998, 998/), float)

do hh=0,23
cp(:,:) = p(hh,:,:)


;=============================================================
plot = gsn_csm_contour(wks,cp,res)
;============================================================
  
overlay(plot,plot_land)
draw(plot)
frame(wks)
end do

end

