pro get_storm_info,pixelsumRT,singlestormgridRaintype,lonsFull_sub,$
                   latsFull_sub,area_RT,dim_hgtRT,dim_topRT,dim_botRT

  ;; INPUTS: pixelsumRT,singlestormgridRaintype,lonsFull_sub,latsFull_sub
  ;; OUTPUTS: area_RT,dim_hgtRT,dim_topRT,dim_botRT
  ;; INTERNAL: lonRT,lonC_RT,latRT,latC_RT,size_pixels,hgt_sumRT
  
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants_ocean.pro

  if pixelsumRT ge 2 then begin ;;this is to avoid possible events with zero convective pixels

     lonRT=total(total(singlestormgridRaintype,2),2) 
     lonC_RT=(max(lonsFull_sub[where(lonRT gt 0l)])+min(lonsFull_sub[where(lonRT gt 0l)]))/2.

     latRT=total(total(singlestormgridRaintype,1),2) 
     latC_RT=(max(latsFull_sub[where(latRT gt 0l)])+min(latsFull_sub[where(latRT gt 0l)]))/2.

     size_pixels=deg2km(pixDeg,lonC_RT,latC_RT)
     area_RT=pixelsumRT*(size_pixels[0]*size_pixels[1]) ;;Convective area in km2  

     hgt_sumRT=total(total(singlestormgridRaintype,2),1)
     dim_hgtRT=max(hgts[where(hgt_sumRT gt 0l)])-min(hgts[where(hgt_sumRT gt 0l)])
     dim_topRT=max(hgts[where(hgt_sumRT gt 0l)])
     dim_botRT=min(hgts[where(hgt_sumRT gt 0l)])
     
  endif else begin
     
     area_RT=0.
     dim_hgtRT=0.
     dim_topRT=0.
     
  endelse

end
