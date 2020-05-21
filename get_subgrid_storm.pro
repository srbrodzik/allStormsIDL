pro get_subgrid_storm,id_storm,npix_str,grid_storm,donde_rtype,ss,$
                      refl_thres,rtype,w_idF,d_lonsFull,nlonsFull,$
                      d_latsFull,nlatsFull,singlestormgrid_Full,$
                      cta_Full,lonsFull_sub,latsFull_sub,$
                      singlestormgridRaintype,pixelsumRT

  ;; NOTE: why do we have nlevels (in constants) and nalts (in ncInfoBlock)?
  
  ;; INPUTS: id_storm,npix_str,grid_storm,donde_rtype,ss,refl_thres,rtype
  ;; OUTPUTS: w_idF,d_lonsFull,nlonsFull,d_latsFull,nlatsFull,singlestormgrid_Full,
  ;;          cta_Full,lonsFull_sub,latsFull_sub,singlestormgridRaintype,
  ;;          pixelsumRT
  ;; INTERNAL: s_idF,cta1,singlestormgrid,total_lonFull,total_latFull,grid_sumRT,dondeRT

  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;;include constants
  @constants.pro
  
  ;; get id_storm
  s_idF=id_storm[donde_rtype[ss]]
  w_idF=where(grid_storm eq s_idF,cta1)
  ;; make sure size of w_idF is same as npix_str for that storm id
  if cta1 ne npix_str[donde_rtype[ss]] then stop  ;; just to check!

  ;; create new array with storm id at appropriate indices
  singlestormgrid=lonarr(nlons,nlats,nlevels)
  singlestormgrid[w_idF]=s_idF

  ;;-------------------------------------------------------------------
  ;; subset the singleFULL storm found to reduce the size of the matrix
  ;;-------------------------------------------------------------------
  ;; find lon indices of storm in singlestormgrid
  total_lonFull=total(total(singlestormgrid,2),2) 
  d_lonsFull=where(total_lonFull gt 0l,nlonsFull)
  ;; find lat indices of storm in singlestormgrid
  total_latFull=total(total(singlestormgrid,1),2) 
  d_latsFull=where(total_latFull gt 0l,nlatsFull)
  ;; create array of actual storm dims containing singlestormgrid values
  singlestormgrid_Full=lonarr(nlonsFull,nlatsFull,nlevels)
  singlestormgrid_Full=singlestormgrid[d_lonsFull,d_latsFull,*]
  w_idF=where(singlestormgrid_Full eq s_idF,cta_Full)
  ;; these are actual lons and lats for singlestormgrid_Full array
  lonsFull_sub=lons[d_lonsFull]
  latsFull_sub=lats[d_latsFull]

  ;; Identify pixels in storm that meet rtype and refl_thres rqmts
  singlestormgridRaintype=singlestormgrid_Full
  singlestormgridRaintype[where(refl_3D[d_lonsFull,d_latsFull,*] lt refl_thres)]=0l
  singlestormgridRaintype[where(rain_type3D[d_lonsFull,d_latsFull,*] ne rtype)]=0l
               
  ;; count number of rtype pixels in each column of storm
  grid_sumRT=total(singlestormgridRaintype,3)
  ;; pixelsumRT is number of rtype pixels in a 2D proj
  dondeRT=where(grid_sumRT gt 0,pixelsumRT)
  
end
