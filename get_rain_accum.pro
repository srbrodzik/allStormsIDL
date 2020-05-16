pro get_rain_accum,pixsum,don,nlonsFull,SrfRain_FULL,raintypeFULL,$
                   grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                   RTo_stra,RTo_conv,RTo_othe,RTo_noRa,$
                   ctaStra,ctaConv,ctaOthe,ctaNoRa,$
                   freqArray,rainArray,nRaiArray

  ;; TO DO
  ;; Check why nlatsFull is not required for calculating 'col' and 'row'
  ;; Rename 'pila' to something more logical
  
  COMMON topoBlock,topo_lat,topo_lon,DEM
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants_ocean.pro

  ;; Initialize rain rates and counts and temp arrays
  RTo_conv=0. & ctaConv=0l
  RTo_stra=0. & ctaStra=0l
  RTo_othe=0. & ctaOthe=0l
  RTo_noRa=0. & ctaNoRa=0l

  ;; go through each ??? pixel in storm
  for i=0l,pixsum-1l do begin

     ;; identify col and row ids of pixel
     col=don[i] mod nlonsFull
     row=long(fix(don[i]/float(nlonsFull)))
                 
     nearSrfR_Org=SrfRain_FULL[col,row]

     ;; count the ??? pixels
     t_col=where(lonsC le lonsFull_sub[col],ctaC)
     t_row=where(latsC le latsFull_sub[row],ctaR)
                       
     ;; if pixel located within boundaries
     if ctaC ne 0 and ctaR ne 0 then begin

        ;; ???
        colBS=(reverse(t_col))[0] 
        rowBS=(reverse(t_row))[0] 
        freqArray[colBS,rowBS]=freqArray[colBS,rowBS]+1l 

        ;; locate indices (x,y,z location of individual pixels within the FULL storm)
        pila=reform(grid_storm_FULL[col,row,*])
        w_CV=where(pila ne 0,ctaHgt)
                          
        if ctaHgt ge 1 then begin
                             
           ;; distance between lowest pixel and ground
           id_top1=(where(topo_lon ge lonsFull_sub[col]))[0]
           id_top2=(where(topo_lat ge latsFull_sub[row]))[0]

           ;; locate the pixel in the nearest fine grid cell
           tmp_col=(where(float(lonsF) eq lonsFull_sub[col],ctaC))[0]
           tmp_row=(where(float(latsF) eq latsFull_sub[row],ctaR))[0]

           ;; if pixel located within boundaries
           if ctaC ne 0 and ctaR ne 0 then begin

              ;; if there is rain at pixel
              if nearSrfR_Org ne SrfRain_fillValue then begin

                 rainArray[tmp_col,tmp_row]=rainArray[tmp_col,tmp_row]+nearSrfR_Org
                 nRaiArray[tmp_col,tmp_row]=nRaiArray[tmp_col,tmp_row]+1l

                 ;; create accumulated rain rate vectors
                 if raintypeFULL[col,row] eq CONV then begin
                    RTo_conv=RTo_conv+nearSrfR_Org
                    ctaConv=ctaConv+1l
                 endif else begin
                    if raintypeFULL[col,row] eq STRA then begin
                       RTo_stra=RTo_stra+nearSrfR_Org
                       ctaStra=ctaStra+1l
                    endif else begin
                       if raintypeFULL[col,row] ge OTHER then begin
                          RTo_othe=RTo_othe+nearSrfR_Org
                          ctaOthe=ctaOthe+1l
                       endif else begin
                          ;;if raintypeFULL[col,row] eq raintype_noRainValue then begin
                          if raintype[col,row]   eq raintype_noRainValue then begin
                             RTo_noRa=RTo_noRa+0.
                             ctaNoRa=ctaNoRa+1l
                          endif
                       endelse
                    endelse
                 endelse
                 
              endif                ;; if nearSrfR_Org ne SrfRain_fillValue (rain)
           endif                   ;; if ctaC ne 0 and ctaR ne 0 (in boundaries)
        endif                      ;; if ctaHgt ge 1
     endif                         ;; if ctaC ne 0 and ctaR ne 0 (in boundaries)
  endfor                           ;; for i=0l,pixsum-1l

  ;; clean up
  ;;undefine,pila
  ;;undefine,colBS
  ;;undefine,rowBS
  ;;undefine,tmp_col
  ;;undefine,tmp_row
  ;;undefine,t_col
  ;;undefine,t_row
  
 end
