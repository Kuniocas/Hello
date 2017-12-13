load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin
pdo = asciiread("/Users/zhangkun/Desktop/Nut/ncl/PDO_ON_NMK/data/PDO_Index.dat",(/1404/),"float")

  pdo_time= asciiread("/Users/zhangkun/Desktop/Nut/ncl/PDO_ON_NMK/data/PDO_Time.dat",(/1404/),"float")
  wks = gsn_open_wks("x11","PDO_run")


; First

   pdo@long_name = "PDO Index"
   Apdo=new((/116,12/),float)
   i = 0
   do while(i.le.115)
     Apdo(i,0:11)=pdo(i*12+7:i*12+18)
     i=i+1
   end do
 Ampdo=dim_avg(Apdo)
 yA = fspan(1901, 2016, 116)


 res   = True
 res@gsnScale = True
 res@gsnFrame              = False
  res@gsnDraw               = False

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

; res@vpXF      = 0.10        ; In page coordinates, where to start
; res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85
 res@gsnMaximize = True

 res@trYMinF   = -2.5        ; min value on y-axis
 res@trYMaxF   =  2.5        ; max value on y-axis
 res@trXMinF   = 1905
 res@trXMaxF   = 2010


 res@tiYAxisString = "PDO Index" ; y-axis label
 res@tiXAxisString = ""
 res@tiMainString  = "Annual PDO (July-June)" ; title

 res@gsnYRefLine           = 0.              ; reference line
 res@gsnXYBarChart         = True            ; create bar chart
 res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
 res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
 plot1 = gsn_csm_xy (wks,yA,Ampdo,res)
 gsres                   = True                        ; poly res
 gsres@gsFillColor       = "dodgerblue1"                 ; color chosen  SlateBlue
 gsres@gsFillIndex= 0
 gsres@gsFillOpacityF=0.04
 xp=(/1944.,1976.5,1976.5,1944/)
 yp=(/-2.5,-2.5,2.5,2.5/)
 dummy1 = gsn_add_polygon (wks,plot1,xp,yp,gsres)

 xp=(/1998.5,2010,2010,1998.5/)
 yp=(/-2.5,-2.5,2.5,2.5/)
 dummy2 = gsn_add_polygon (wks,plot1,xp,yp,gsres)

 gsres@gsFillColor       = "red"                 ; color Firebrick1
 xp=(/1976.5,1998.5,1998.5,1976.5/)
 yp=(/-2.5,-2.5,2.5,2.5/)
 dummy3 = gsn_add_polygon (wks,plot1,xp,yp,gsres)



; Second LOW PASS
  ihp   = 0                             ; low_pass
  sigma = 1.0                           ; Lanczos sigma
  nWgt  = 121                           ; loose 60 months each end
  fca   = 1./120.                       ; decadal
  wgtt  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )


  yplot = new ( (/1,1404/) , float )
;  yplot(0,:)=pdo(:)
  yplot(0,:)=wgt_runave ( pdo, wgtt, 0 )
  yplot(0,:)=runave (pdo, 121, 0)


  xyres= True
  xyres@gsnScale = True
  xyres@gsnFrame              = False
  xyres@gsnDraw               = False

 ;---Get viewport values for bar plot
  getvalues plot1
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
;
; Make sure XY curve is drawn in same viewport space as bar plot
; Note there is no attempt to mathematically map the left and
; right Y axis to each other.
;
  xyres@vpXF      = vpx
  xyres@vpYF      = vpy
  xyres@vpWidthF  = vpw
  xyres@vpHeightF = vph

  res@gsnMaximize = True

 xyres@trYMinF   = -2.5        ; min value on y-axis
 xyres@trYMaxF   =  2.5        ; max value on y-axis
 xyres@trXMinF   = 1905
 xyres@trXMaxF   = 2010

  xyres@xyLineThicknessF = 6
  xyres@xyLineColors     = (/ "gray30" /)
  plot2 = gsn_csm_xy(wks,pdo_time,yplot,xyres)  ;

   anno_id  = gsn_add_annotation(plot1, plot2, False)
   pres             = True
  pres@gsnMaximize = True
  maximize_output(wks,pres)
  ; Clean up.
  ; quit
end
