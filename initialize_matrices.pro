pro initialize_matrices

  COMMON infoBlock,orbit,datetime,info_DC,info_WC,info_DW,info_BS,info_SH
  COMMON convCoreBlock,shape_Core_DC,shape_Core_WC,shape_Core_DW, $
         rain_Core_DC,rain_Core_WC,rain_Core_DW, $
         rainTypeCore_DC,rainTypeCore_WC,rainTypeCore_DW, $
         rainCore_DC_NSR,rainCore_WC_NSR,rainCore_DW_NSR
  COMMON convStormBlock,shape_Full_DC,shape_Full_WC,shape_Full_DW, $
         rain_Full_DC,rain_Full_WC,rain_Full_DW, $
         rainTypeFull_DC,rainTypeFull_WC,rainTypeFull_DW, $
         rainFull_DC_NSR,rainFull_WC_NSR,rainFull_DW_NSR
  COMMON straCoreBlock,shape_Core_BS,rain_Core_BS,rainTypeCore_BS, $
         rainCore_BS_NSR
  COMMON straStormBlock,shape_Full_BS,rain_Full_BS,rainTypeFull_BS, $
         rainFull_BS_NSR
  COMMON shIsoCoreBlock,shape_Core_SH,rain_Core_SH,rainTypeCore_SH, $
         rainCore_SH_NSR
  COMMON shIsoStormBlock,shape_Full_SH,rain_Full_SH,rainTypeFull_SH, $
         rainFull_SH_NSR
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore

  ;; include constants
  @constants_ocean.pro
  
  ;; initialize elements of infoBlock
  info_DC=strarr(1)
  info_WC=strarr(1)
  info_DW=strarr(1)
  info_BS=strarr(1)
  info_SH=strarr(1)

  ;; initialize 'shape' arrays
  shape_Core_DC=fltarr(9,1) & shape_Full_DC=fltarr(9,1)
  shape_Core_WC=fltarr(9,1) & shape_Full_WC=fltarr(9,1)
  shape_Core_DW=fltarr(9,1) & shape_Full_DW=fltarr(9,1)
  shape_Core_BS=fltarr(9,1) & shape_Full_BS=fltarr(9,1)
  shape_Core_SH=fltarr(9,1) & shape_Full_SH=fltarr(9,1)

  ;; initialize 'rain' arrays
  rain_Core_DC=fltarr(7,1)  & rain_Full_DC=fltarr(7,1)
  rain_Core_WC=fltarr(7,1)  & rain_Full_WC=fltarr(7,1)
  rain_Core_DW=fltarr(7,1)  & rain_Full_DW=fltarr(7,1)
  rain_Core_BS=fltarr(7,1)  & rain_Full_BS=fltarr(7,1)
  rain_Core_SH=fltarr(7,1)  & rain_Full_SH=fltarr(7,1)

  ;; initialize 'rainType' arrays
  rainTypeCore_DC=fltarr(6,1)  & rainTypeFull_DC=fltarr(6,1)
  rainTypeCore_WC=fltarr(6,1)  & rainTypeFull_WC=fltarr(6,1)
  rainTypeCore_DW=fltarr(6,1)  & rainTypeFull_DW=fltarr(6,1)
  rainTypeCore_BS=fltarr(6,1)  & rainTypeFull_BS=fltarr(6,1)
  rainTypeCore_SH=fltarr(6,1)  & rainTypeFull_SH=fltarr(6,1)

  ;; initialize 'rain' arrays
  rainCore_DC_NSR=fltarr(6,1)   &   rainFull_DC_NSR=fltarr(6,1)
  rainCore_WC_NSR=fltarr(6,1)   &   rainFull_WC_NSR=fltarr(6,1)
  rainCore_DW_NSR=fltarr(6,1)   &   rainFull_DW_NSR=fltarr(6,1)
  rainCore_BS_NSR=fltarr(6,1)   &   rainFull_BS_NSR=fltarr(6,1)
  rainCore_SH_NSR=fltarr(6,1)   &   rainFull_SH_NSR=fltarr(6,1)

  ;; initialize CFAD matrices
  alts_CFAD=findgen(nlevels)*delta_z  ;;altitudes in km
  refl_CFAD=findgen(n_refls)
  CFAD_Full=lonarr(n_refls,nlevels,5)    ;;5 type of systems (DC,WC,DW,BS,SH)
  CFAD_Core=lonarr(n_refls,nlevels,5)    ;;5 type of systems (DC,WC,DW,BS,SH)
  
  ;; initialize 'frequency' arrays for coarse grid
  freq_Full=lonarr(nlonsC,nlatsC,5)      ;;5 type of systems (DC,WC,DW,BS,SH)
  freq_Core=lonarr(nlonsC,nlatsC,5)      ;;5 type of systems (DC,WC,DW,BS,SH)

  ;; initialize 'cumulative rainfall rate' arrays for fine grid
  rain_NSRFull=fltarr(nlonsF,nlatsF,5)   ;;5 type of systems (DC,WC,DW,BS,SH)
  nRai_NSRFull=intarr(nlonsF,nlatsF,5)   ;;5 type of systems (DC,WC,DW,BS,SH)
  rain_NSRCore=fltarr(nlonsF,nlatsF,5)   ;;5 type of systems (DC,WC,DW,BS,SH)
  nRai_NSRCore=intarr(nlonsF,nlatsF,5)   ;;5 type of systems (DC,WC,DW,BS,SH)

end
