pro get_core_dims,id_RT,npix_RT,grid_RT,donde_rtype,ssRT,$
                  nlonsFull,nlatsFull,lonsFull_sub,latsFull_sub,$
                  w_idRT,cta_RT,dondeRT_RT,pixelsumRT_RT,$
                  lonRT,lonC_RT,latRT,latC_RT,area_RT,dim_hgtRT,$
                  dim_topRT,dim_botRT
  
  ;; INPUTS: id_RT,npix_RT,grid_RT,donde_rtype,ssRT,nlonsFull,nlatsFull,
  ;;         lonsFull_sub,latsFull_sub                  
  ;; OUTPUTS: w_idRT,cta_RT,dondeRT_RT,pixelsumRT_RT,lonRT,lonC_RT,latRT,
  ;;          latC_RT,area_RT,dim_hgtRT,dim_topRT,dim_botRT
  ;; INTERNAL: s_idRT,singlestormgrid_RT,grid_sum_RT_RT,size_pixels

  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants_ocean.pro

  ;; maybe assign donde_rtype[ssRT] to a separate variable
  s_idRT=id_RT[donde_rtype[ssRT]]
  w_idRT=where(grid_RT eq s_idRT,cta_RT)
  ;; make sure size of w_idRT is same as npix_RT for that storm id
  if cta_RT ne npix_RT[donde_rtype[ssRT]] then stop  ;; just to check!

  ;; create new array with storm id at appropriate indices
  singlestormgrid_RT=lonarr(nlonsFull,nlatsFull,nlevels)
  singlestormgrid_RT[w_idRT]=s_idRT

  ;; count number of RT pixels within each column of storm
  grid_sum_RT_RT=total(singlestormgrid_RT,3) 
  ;; pixelsumRT_RT is number of pixels in a 2D proj
  dondeRT_RT=where(grid_sum_RT_RT gt 0,pixelsumRT_RT)

  ;; find center of RT area
  lonRT=total(total(singlestormgrid_RT,2),2) 
  lonC_RT=(max(lonsFull_sub[where(lonRT gt 0l)])+min(lonsFull_sub[where(lonRT gt 0l)]))/2.
  latRT=total(total(singlestormgrid_RT,1),2) 
  latC_RT=(max(latsFull_sub[where(latRT gt 0l)])+min(latsFull_sub[where(latRT gt 0l)]))/2.

  ;; find RT area in km 
  size_pixels=deg2km(pixDeg,lonC_RT,latC_RT)
  area_RT=pixelsumRT_RT*(size_pixels[0]*size_pixels[1]) ;;Convective area in km  

  ;; find depth, top and bottom of RT
  hgt_sumRT=total(total(singlestormgrid_RT,2),1)
  dim_hgtRT=max(hgts[where(hgt_sumRT gt 0l)])-min(hgts[where(hgt_sumRT gt 0l)])
  dim_topRT=max(hgts[where(hgt_sumRT gt 0l)])
  dim_botRT=min(hgts[where(hgt_sumRT gt 0l)])
  
end
