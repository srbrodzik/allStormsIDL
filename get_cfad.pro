pro get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_id,cta,npix,$
             donde,iEvent,cfad

  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants.pro

  refl_SingleStorm=fltarr(nlonsFull,nlatsFull,nlevels)
  refl_SingleStorm[*,*,*]=refl_3D_fillValue
  refl_SingleStorm[w_id]=refl_3D_FULL[w_id]
  if cta ne npix[donde[iEvent]] then stop
           
  ;; count reflectivity for each pixel in the storm into a CFAD matrix
  for i=0l,cta-1l do begin  
     col_Refl=where(refl_CFAD eq round(refl_3D_FULL[w_id[i]]),ctaZ) 
     row_hgts=where(alts_CFAD eq hgts_3D_FULL[w_id[i]],ctaH)
     if ctaH ne 0 and ctaZ ne 0 then $
        cfad[col_Refl,row_hgts]=cfad[col_Refl,row_hgts]+1l  else stop 
  endfor

  ;; clean up
  ;;undefine,col_Refl
  ;;undefine,row_hgts
  ;;undefine,refl_SingleStorm

end
