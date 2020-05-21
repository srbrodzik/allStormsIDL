pro get_class_stats,raintypeFULL,SrfRain_FULL,donde,cen_lon,cen_lat,rain_moment,stats

  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D
  
  ;; include constants
  @constants.pro
  
  ;; get type of rain in each 2D pixel that composes the storm
  stratconv=raintypeFULL[donde]
  strats=where(stratconv eq STRA,ctaStr)
  convec=where(stratconv eq CONV,ctaCon)
  others=where(stratconv ge OTHER,ctaOth)
  noRain=where(stratconv eq raintype_noRainValue,ctaNoR)
  missin=where(stratconv eq raintype_fillValue,ctaMis)

  ;; calculate moments of simple rain within storm
  rain=SrfRain_FULL[donde]
  rain_nomiss=where(rain ne SrfRain_fillValue,Rmiss)
  if Rmiss ge 2 then rain_moment=[mean(rain[rain_nomiss]),stdev(rain[rain_nomiss]),$
                                  max(rain[rain_nomiss]),min(rain[rain_nomiss]),float(Rmiss),$
                                  float(ctaStr),float(ctaCon)] $
  else rain_moment=[-9999.,-9999.,-9999.,-9999.,-9999.,-9999.,-9999.]

  ;; calculate rainrate sums [mm/hr]
  if ctaStr ne 0 then RTo_stra=total(rain[strats]) else RTo_stra=0. ;;total stratiform rain
  if ctaCon ne 0 then RTo_conv=total(rain[convec]) else RTo_conv=0. ;;total convective rain
  if ctaOth ne 0 then RTo_othe=total(rain[others]) else RTo_othe=0. ;;total other rain
  if ctaNoR ne 0 then RTo_noRa=total(rain[noRain]) else RTo_noRa=0. ;;total no_rain rain
  total_RainAll=RTo_stra+RTo_conv+RTo_othe+RTo_noRa
  total_RainCSs=RTo_stra+RTo_conv

  ;; calculate mean rainfall of all/stra/conv pixels
  m_RainAll=total_RainAll/(ctaStr+ctaCon+ctaOth+ctaNoR+ctaMis)
  if ctaStr ne 0 then m_RainStrt=RTo_stra/ctaStr else m_RainStrt=0.
  if ctaCon ne 0 then m_RainConv=RTo_conv/ctaCon else m_RainConv=0.
  if ctaStr ne 0 or ctaCon ne 0 then m_RainCSs=total_RainCSs/(ctaStr+ctaCon) $
  else m_RainCSs=-999.

  ;; calculate volumetric values of all/stra/conv rain [1e6*kg/s]
  size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
  vol_Rain_All=total_RainAll*(size_pixels[0]*size_pixels[1])/secsPerHr  
  vol_Rain_Str=RTo_stra*(size_pixels[0]*size_pixels[1])/secsPerHr 
  vol_Rain_Con=RTo_conv*(size_pixels[0]*size_pixels[1])/secsPerHr
  
  ;; mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
  stats=[m_RainAll,m_RainStrt,m_RainConv,vol_Rain_All,vol_Rain_Str,vol_Rain_Con]

  ;; clean up
  undefine,rain
  undefine,rain_nomiss
  undefine,stratconv
  undefine,strats
  undefine,convec
  undefine,others
  undefine,noRain
  undefine,missin

end
