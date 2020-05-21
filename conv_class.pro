pro conv_class,id_storm,npix_str,grid_storm,num_storm

  ;; TODO - In get_storm_info
  ;; 1. area, hgt, top, bot should end in something diff than CV
  ;;       since this is name output from get_core_dims

  COMMON topoBlock,topo_lat,topo_lon,DEM
  COMMON infoBlock,orbit,datetime,info_DC,info_WC,info_DW,info_BS,info_SH
  COMMON convCoreBlock,shape_Core_DC,shape_Core_WC,shape_Core_DW, $
     rain_Core_DC,rain_Core_WC,rain_Core_DW, $
     rainTypeCore_DC,rainTypeCore_WC,rainTypeCore_DW, $
     rainCore_DC_NSR,rainCore_WC_NSR,rainCore_DW_NSR
  COMMON convStormBlock,shape_Full_DC,shape_Full_WC,shape_Full_DW, $
     rain_Full_DC,rain_Full_WC,rain_Full_DW, $
     rainTypeFull_DC,rainTypeFull_WC,rainTypeFull_DW, $
     rainFull_DC_NSR,rainFull_WC_NSR,rainFull_DW_NSR
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D
  COMMON maskBlock,bsr_mask,dcc_mask,dwc_mask,wcc_mask,shi_mask,storm_mask

  ;; include constants
  @constants.pro

  ;;resolve_routine,'get_subgrid_storm'   ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_subgrid_storm
  ;;resolve_routine,'get_storm_info'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_storm_info
  ;;resolve_routine,'get_core_dims'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_core_dims
  ;;resolve_routine,'inc_echo_count'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/inc_echo_count
  ;;resolve_routine,'get_str_shape'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_str_shape
  ;;resolve_routine,'get_class_stats'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_class_stats
  ;;;;resolve_routine,'get_rain_accum'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_rain_accum
  ;;resolve_routine,'get_raccum'          ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_raccum
  ;;resolve_routine,'get_rain_statistics' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_rain_statistics
  ;;resolve_routine,'get_cfad'            ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/get_cfad

  ;; initialize counts
  num_dcc = 0
  num_dwc = 0
  num_wcc = 0

  ;; identify Convective subset
  where_convective=where(refl_3D ge thr_dbZ,cta_thr_dbZ) ;;check for all pixels with >=thr_dbZ convective
  delvar,where_convective

  ;;here I only choose convective pixels and from those only >=2 pixels with refl>=thr_dbZ 
  donde_Convec=where(npix_str ge 2l,ctaConvective) 

  ;;*********************************************************************************************
  ;;Identify Convective cores (DCC-WCC-DWC)
  ;; if cta_conv (num conv pixels in raintype) ne 0 and
  ;;    id_storm from first find_storm call not empty and
  ;;       number entries in refl_3D > thr_dbZ, >= 2
  if cta_conv ne 0 and id_storm[0] ne -999l and cta_thr_dbZ ge 2 and ctaConvective gt 0 then begin
     
     for ss=0l,ctaConvective-1 do begin ;;only goes thru the volumes having more than 25 pixels

        ;; identify subgrid containing storm
        ;; singlestormgridConvective contains stormIds at pixels that are
        ;;    CONV and have refl > thr_dbZ; grid is size of storm grid
        refl_thres = thr_dbZ
        rtype = CONV
        get_subgrid_storm,id_storm,npix_str,grid_storm,donde_Convec,ss,$
                          refl_thres,rtype,w_idF,d_lonsFull,nlonsFull,$
                          d_latsFull,nlatsFull,singlestormgrid_Full,$
                          cta_Full,lonsFull_sub,latsFull_sub,$
                          singlestormgridConvective,pixelsumCV        

        ;; get storm area and max and min heights
        get_storm_info,pixelsumCV,singlestormgridConvective,lonsFull_sub,$
                       latsFull_sub,area_CV,dim_hgtCV,dim_topCV,dim_botCV
        if pixelsumCV ge 2 and DEBUG then begin
           print,'In conv_class: ss = ',ss
           print,'Back from get_storm_info:'
           help,area_CV,dim_hgtCV,dim_topCV,dim_botCV
        endif 

        ;; if storm meets one or both of extreme conv echo criteria
        if area_CV ge thr_aCV or dim_topCV ge thr_hCV then begin

           ;; find regions of adjacent conv pixels within storm
           findStormNew,refl_3D=singlestormgridConvective,$
                        ;;refl_3D_fillValue=refl_3D_fillValue,$
                        id_storm=id_CV,$
                        npix_str=npix_CV,$
                        grid_storm=grid_CV
           searchNaN_CV=where(grid_CV lt 0, nanCnt)
           if nanCnt gt 0 then grid_CV[searchNaN_CV]=0l
                 
           ;; identify only regions with 2 or more pixels
           donde_Convec2=where(npix_CV ge 2l,ctaConvective2) 
           if DEBUG then print,'In conv_class: ctaConvective2 = ',ctaConvective2

           ;; flag used to calc FULL storm stats only once
           firstTimeThru = 1

           for ssCV=0l,ctaConvective2-1 do begin

              ;; get numpixels, area and max and min heights of potential core area
              get_core_dims,id_CV,npix_CV,grid_CV,donde_Convec2,ssCV,$
                            nlonsFull,nlatsFull,lonsFull_sub,latsFull_sub,$
                            w_idCV,cta_CV,dondeCV_CV,pixelsumCV_CV,$
                            lonCV,lonC_CV,latCV,latC_CV,area_CV,dim_hgtCV,$
                            dim_topCV,dim_botCV

              ;; identify the contiguous areas belonging to a Deep or Wide convective event
              if pixelsumCV_CV ge 2 and (area_CV ge thr_aCV or (dim_topCV ge thr_hCV and dim_hgtCV ge thr_dCV) ) then begin
                 if DEBUG then print,'In conv_class: ssCV = ',ssCV

                 ;;------------------------------------------------------
                 ;; Increment core counts and update DWC,WCC & DCC  masks
                 ;;------------------------------------------------------               
                 if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin
                    inc_echo_count,num_dwc,d_lonsFull,d_latsFull,dondeCV_CV,dwc_mask
                 endif else begin
                    if area_CV ge thr_aCV then begin
                       inc_echo_count,num_wcc,d_lonsFull,d_latsFull,dondeCV_CV,wcc_mask                       
                    endif else begin
                       if dim_topCV ge thr_hCV then begin
                          inc_echo_count,num_dcc,d_lonsFull,d_latsFull,dondeCV_CV,dcc_mask
                       endif 
                    endelse
                 endelse

                 ;;-----------------------------------------------------
                 ;; Compute the Shape parameters and info of Conv region
                 ;;-----------------------------------------------------
                 ;;calculate dimensions for Convective pixels in the cluster
                 dim_lonCV=(max(lonsFull_sub[where(lonCV gt 0l)])-min(lonsFull_sub[where(lonCV gt 0l)]))+pixDeg
                 dim_latCV=(max(latsFull_sub[where(latCV gt 0l)])-min(latsFull_sub[where(latCV gt 0l)]))+pixDeg
                 
                 ;;calculates elevation (meters) of terrain for center of storm
                 id_top1=(where(topo_lon ge lonC_CV))[0] & id_top2=(where(topo_lat ge latC_CV))[0]
                 terr_hgtCV=DEM[id_top1,id_top2]
                 ;; set ocean/land mask (ocean=0 or land=1)
                 if terr_hgtCV eq 0 then land_oceanCV=0 else land_oceanCV=1

                 tmp_shapeCV=[lonC_CV,latC_CV,area_CV,dim_topCV,dim_botCV,dim_lonCV,dim_latCV,terr_hgtCV,land_oceanCV]
                       
                 ;;----------------------------------------------------
                 ;; Compute the Shape parameters and info of FULL storm
                 ;;----------------------------------------------------
                 ;; count number of pixels within each column of storm
                 grid_sum=total(singlestormgrid_Full,3)
                 ;; pixelsum is number of pixels in a 2D proj
                 donde=where(grid_sum gt 0,pixelsum)

                 get_str_shape,singlestormgrid_Full,lonsFull_sub,latsFull_sub,$
                               pixelsum,cen_lon,cen_lat,area,dim_lon,dim_lat,$
                               dim_top,dim_bot,terr_hgt,land_ocean
                 if DEBUG then begin
                    print,'Back from get_str_shape:'
                    help,cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean
                 endif
                 tmp_shape=[cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean]

                 ;;--------------------------------------------
                 ;; Increment storm count and update storm mask
                 ;;--------------------------------------------
                 inc_echo_count,num_storm,d_lonsFull,d_latsFull,donde,storm_mask

                 ;;----------------------------------------
                 ;; Statistics for NSR rain types and rates
                 ;;----------------------------------------
                 SrfRain_FULL=SrfRain[d_lonsFull,d_latsFull,*]
                 raintypeFULL=raintype[d_lonsFull,d_latsFull,*]
                 refl_3D_FULL=refl_3D[d_lonsFull,d_latsFull,*]
                 hgts_3D_FULL=hgts_3D[d_lonsFull,d_latsFull,*]

                 ;; stats for BSR area
                 get_class_stats,raintypeFULL,SrfRain_FULL,dondeCV_CV,lonC_CV,latC_CV,rain_momentCV,statsRain_CV                 
                 ;; stats for FULL area
                 get_class_stats,raintypeFULL,SrfRain_FULL,donde,cen_lon,cen_lat,rain_moment,statsRain
                 
                 ;;---------------------------------------------------------
                 ;; Calculate rainfall accumulation for Full and Core storms
                 ;;---------------------------------------------------------
                 grid_storm_FULL=lonarr(nlonsFull,nlatsFull,nlevels)
                 grid_storm_FULL=grid_storm[d_lonsFull,d_latsFull,*]

                 ;;------------------------------------------------------
                 ;; Rainfall accumulation for FULL STORM - only done once
                 ;;------------------------------------------------------
                 if firstTimeThru eq 1 then begin
                    freqArray=lonarr(nlonsC,nlatsC)
                    rainArray=fltarr(nlonsF,nlatsF)
                    nRaiArray=intarr(nlonsF,nlatsF)
                    get_rain_accum,pixelsum,donde,nlonsFull,SrfRain_FULL,raintypeFULL,$
                                   grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                                   RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                                   ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                                   freqArray,rainArray,nRaiArray                                        
                    if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin ;;deep and wide convective
                       freq_Full[*,*,2] = freq_Full[*,*,2] + freqArray
                       rain_NSRFull[*,*,2] = rain_NSRFull[*,*,2] + rainArray
                       nRai_NSRFull[*,*,2] = nRai_NSRFull[*,*,2] + nRaiArray
                    endif else begin
                       if area_CV ge thr_aCV then begin ;;wide convective
                          freq_Full[*,*,1] = freq_Full[*,*,1] + freqArray
                          rain_NSRFull[*,*,1] = rain_NSRFull[*,*,1] + rainArray
                          nRai_NSRFull[*,*,1] = nRai_NSRFull[*,*,1] + nRaiArray
                       endif else begin
                          if dim_topCV ge thr_hCV then begin ;;deep convective
                             freq_Full[*,*,0] = freq_Full[*,*,0] + freqArray
                             rain_NSRFull[*,*,0] = rain_NSRFull[*,*,0] + rainArray
                             nRai_NSRFull[*,*,0] = nRai_NSRFull[*,*,0] + nRaiArray
                          endif 
                       endelse
                    endelse                             
                    undefine,freqArray
                    undefine,rainArray
                    undefine,nRaiArray
                 endif

                 ;; Rain statistics for FULL Storm
                 get_rain_statistics,RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                                     ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                                     m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,$
                                     vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR,$
                                     cen_lon,cen_lat
                 tmp_statsRain_NSR=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,$
                                    vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]

                 ;;------------------------------------------
                 ;; Rainfall accumulation for Convective part
                 ;;------------------------------------------
                 freqArray=lonarr(nlonsC,nlatsC)
                 rainArray=fltarr(nlonsF,nlatsF)
                 nRaiArray=intarr(nlonsF,nlatsF)
                 get_rain_accum,pixelsumCV_CV,dondeCV_CV,nlonsFull,SrfRain_FULL,raintypeFULL,$
                                grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                                RTo_stra_NSR_CV,RTo_conv_NSR_CV,RTo_othe_NSR_CV,RTo_noRa_NSR_CV,$
                                ctaStra_NSR_CV,ctaConv_NSR_CV,ctaOthe_NSR_CV,ctaNoRa_NSR_CV,$
                                freqArray,rainArray,nRaiArray
                 if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin ;;deep and wide convective
                    freq_Core[*,*,2] = freq_Core[*,*,2] + freqArray
                    rain_NSRCore[*,*,2] = rain_NSRCore[*,*,2] + rainArray
                    nRai_NSRCore[*,*,2] = nRai_NSRCore[*,*,2] + nRaiArray
                 endif else begin
                    if area_CV ge thr_aCV then begin ;;wide convective
                       freq_Core[*,*,1] = freq_Core[*,*,1] + freqArray
                       rain_NSRCore[*,*,1] = rain_NSRCore[*,*,1] + rainArray
                       nRai_NSRCore[*,*,1] = nRai_NSRCore[*,*,1] + nRaiArray
                    endif else begin
                       if dim_topCV ge thr_hCV then begin ;;deep convective
                          freq_Core[*,*,0] = freq_Core[*,*,0] + freqArray
                          rain_NSRCore[*,*,0] = rain_NSRCore[*,*,0] + rainArray
                          nRai_NSRCore[*,*,0] = nRai_NSRCore[*,*,0] + nRaiArray
                       endif
                    endelse
                 endelse
                 undefine,freqArray
                 undefine,rainArray
                 undefine,nRaiArray

                 ;; Rain statistics for Convective part
                 get_rain_statistics,RTo_stra_NSR_CV,RTo_conv_NSR_CV,RTo_othe_NSR_CV,RTo_noRa_NSR_CV,$
                                     ctaStra_NSR_CV,ctaConv_NSR_CV,ctaOthe_NSR_CV,ctaNoRa_NSR_CV,$
                                     m_RainAll_NSR_CV,m_RainStrt_NSR_CV,m_RainConv_NSR_CV,$
                                     vol_Rain_All_NSR_CV,vol_Rain_Str_NSR_CV,vol_Rain_Con_NSR_CV,$
                                     cen_lon,cen_lat
                 tmp_statsRain_NSR_CV=[m_RainAll_NSR_CV,m_RainStrt_NSR_CV,m_RainConv_NSR_CV,$
                                       vol_Rain_All_NSR_CV,vol_Rain_Str_NSR_CV,vol_Rain_Con_NSR_CV]

                 ;;-------------------------------------------
                 ;; CFAD count for FULL Storm - done only once
                 ;;-------------------------------------------
                 if firstTimeThru eq 1 then begin
                    cfad=lonarr(n_refls,nlevels)
                    get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idF,cta_Full,npix_str,$
                             donde_Convec,ss,cfad              
                    if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                       CFAD_Full[*,*,2] = CFAD_Full[*,*,2] + cfad else $
                          if area_CV ge thr_aCV then CFAD_Full[*,*,1] = CFAD_Full[*,*,1] + cfad else $
                             if dim_topCV ge thr_hCV then CFAD_Full[*,*,0] = CFAD_Full[*,*,0] + cfad
                    undefine,cfad
                 endif
                 ;; set this after first time through so FULL storm data not computed again
                 firstTimeThru = 0

                 ;;-------------------------------
                 ;; CFAD count for Convective part
                 ;;-------------------------------
                 cfad=lonarr(n_refls,nlevels)
                 get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idCV,cta_CV,npix_CV,$
                          donde_Convec2,ssCV,cfad
                 if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                    CFAD_Core[*,*,2] = CFAD_Core[*,*,2] + cfad else $
                       if area_CV ge thr_aCV then CFAD_Core[*,*,1] = CFAD_Core[*,*,1] + cfad else $
                          if dim_topCV ge thr_hCV then CFAD_Core[*,*,0] = CFAD_Core[*,*,0] + cfad
                 undefine,cfad

                 ;;----------------------------------------------------------
                 ;;store the info for monthly_class & stats_class directories
                 ;;----------------------------------------------------------
                 if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin
                    info_DW=[info_DW,orbit+'.'+datetime+'.'+strtrim(string(num_dwc),2)]
                    shape_Core_DW=[[shape_Core_DW],[tmp_shapeCV]]
                    shape_Full_DW=[[shape_Full_DW],[tmp_shape]]
                    rain_Core_DW=[[rain_Core_DW],[rain_momentCV]]
                    rain_Full_DW=[[rain_Full_DW],[rain_moment]]
                    rainTypeCore_DW=[[rainTypeCore_DW],[statsRain_CV]]
                    rainTypeFull_DW=[[rainTypeFull_DW],[statsRain]]
                    rainCore_DW_NSR=[[rainCore_DW_NSR],[tmp_statsRain_NSR_CV]]
                    rainFull_DW_NSR=[[rainFull_DW_NSR],[tmp_statsRain_NSR]]

                 endif else begin
                    if area_CV ge thr_aCV then begin
                       info_WC=[info_WC,orbit+'.'+datetime+'.'+strtrim(string(num_wcc),2)]
                       shape_Core_WC=[[shape_Core_WC],[tmp_shapeCV]]
                       shape_Full_WC=[[shape_Full_WC],[tmp_shape]]
                       rain_Core_WC=[[rain_Core_WC],[rain_momentCV]]
                       rain_Full_WC=[[rain_Full_WC],[rain_moment]]
                       rainTypeCore_WC=[[rainTypeCore_WC],[statsRain_CV]]
                       rainTypeFull_WC=[[rainTypeFull_WC],[statsRain]]
                       rainCore_WC_NSR=[[rainCore_WC_NSR],[tmp_statsRain_NSR_CV]]
                       rainFull_WC_NSR=[[rainFull_WC_NSR],[tmp_statsRain_NSR]]

                    endif else begin
                       if dim_topCV ge thr_hCV then begin
                          info_DC=[info_DC,orbit+'.'+datetime+'.'+strtrim(string(num_dcc),2)]
                          shape_Core_DC=[[shape_Core_DC],[tmp_shapeCV]]
                          shape_Full_DC=[[shape_Full_DC],[tmp_shape]]
                          rain_Core_DC=[[rain_Core_DC],[rain_momentCV]]
                          rain_Full_DC=[[rain_Full_DC],[rain_moment]]
                          rainTypeCore_DC=[[rainTypeCore_DC],[statsRain_CV]]
                          rainTypeFull_DC=[[rainTypeFull_DC],[statsRain]]
                          rainCore_DC_NSR=[[rainCore_DC_NSR],[tmp_statsRain_NSR_CV]]
                          rainFull_DC_NSR=[[rainFull_DC_NSR],[tmp_statsRain_NSR]]

                       endif
                    endelse
                 endelse
                 
                 undefine,dim_lonCV
                 undefine,dim_latCV
                 undefine,hgt_sumCV
                 undefine,grid_sum
                 undefine,donde
                 undefine,pixelsum
                 undefine,hgt_sum
                 undefine,tmp_shapeCV
                 undefine,tmp_shape
                 ;;not undefined in v1
                 ;;undefine,rain_momentCV
                 ;;undefine,rain_moment
                 ;;undefine,statsRain_CV
                 ;;undefine,statsRain
                 ;;undefine,tmp_statsRain_NSR_CV
                 ;;undefine,tmp_statsRain_NSR
                 undefine,SrfRain_FULL
                 undefine,raintypeFULL
                 undefine,refl_3D_FULL
                 undefine,hgts_3D_FULL
                 undefine,grid_storm_FULL

              endif      ;;endif found a storm cluster with contiguous convective pixels within theresholds
              
              undefine,lonCV
              undefine,latCV
              undefine,singlestormgrid_CV
              undefine,grid_sum_CV_CV
              undefine,hgt_sumCV
              undefine,dondeCV_CV
              undefine,s_idCV
              undefine,w_idCV
              
           endfor        ;;endfor loop through analyzed storms clusters that maybe are deep-wide convective
           
           undefine,grid_CV
           undefine,npix_CV
           undefine,id_CV
           undefine,searchNaN_CV
           undefine,donde_Convec2
           
        endif            ;;endif for convective areas that could be matching the theresholds
        
        undefine,d_lonsFull
        undefine,d_latsFull
        undefine,singlestormgrid_Full
        undefine,lonsFull_sub
        undefine,latsFull_sub
        undefine,singlestormgridConvective
        undefine,w_idF
        
     endfor              ;;endfor loop thru convective volumes greater than 2 pixels
     
  endif                  ;;end if the orbit does have convective and reflec > 0 ==>raining

end
