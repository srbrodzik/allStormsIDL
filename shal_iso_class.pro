pro shal_iso_class,id_storm,npix_str,grid_storm,num_storm

  ;; TODO - In get_core_dims function:
  ;; 1. rename *SH to show diff between storm and core stats
  ;; 2. var w_id_SH doesn't match stra & conv routines
  ;;    should be w_idSH
  
  COMMON topoBlock,topo_lat,topo_lon,DEM
  COMMON infoBlock,orbit,datetime,info_DC,info_WC,info_DW,info_BS,info_SH
  COMMON shIsoCoreBlock,shape_Core_SH,rain_Core_SH,rainTypeCore_SH, $
     rainCore_SH_NSR
  COMMON shIsoStormBlock,shape_Full_SH,rain_Full_SH,rainTypeFull_SH, $
     rainFull_SH_NSR
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D
  COMMON maskBlock,bsr_mask,dcc_mask,dwc_mask,wcc_mask,shi_mask,storm_mask

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

  ;;include constants
  @constants.pro

  ;; initialize num_shi
  ;;num_shi = 0

  ;; identify shallow conv volumes more than 2 pixels
  donde_shallow=where(npix_str ge 2l,ctaShallow)
           
  ;; identify shallow convective subset
  if ctaShallow ne 0 then begin
     
     for ss=0l,ctaShallow-1 do begin
        
        ;; identify subgrid containing storm
        refl_thres = 0.
        rtype = SHIS
        get_subgrid_storm,id_storm,npix_str,grid_storm,donde_shallow,ss,$
                          refl_thres,rtype,w_idF,d_lonsFull,nlonsFull,$
                          d_latsFull,nlatsFull,singlestormgrid_Full,$
                          cta_Full,lonsFull_sub,latsFull_sub,$
                          singlestormgridShallow,pixelsumSH        

        ;; get storm area
        get_storm_info,pixelsumSH,singlestormgridShallow,lonsFull_sub,$
                       latsFull_sub,area_SH,dim_hgtSH,dim_topSH,dim_botSH
        if pixelsumSH ge 2 and DEBUG then begin
           print,'In shal_iso_class: ss = ',ss
           print,'Back from get_storm_info:'
           help,area_SH,dim_hgtSH,dim_topSH,dim_botSH
        endif 

        ;; if storm meets Shallow Isolated criteria
        if pixelsumSH ge 2 then begin

           findStormNew,refl_3D=singlestormgridShallow,$
                        ;;refl_3D_fillValue=refl_3D_fillValue,$
                        id_storm=id_SH,$
                        npix_str=npix_SH,$
                        grid_storm=grid_SH
           searchNaN_SH=where(grid_SH lt 0, nanCnt)
           if nanCnt gt 0 then grid_SH[searchNaN_SH]=0l
     
           ;;identify only volumes with 2 or more pixels
           donde_Shallow2=where(npix_SH ge 2l,ctaShallow2)
           if DEBUG then print,'In shal_iso_class: ctaShallow2 = ',ctaShallow2
                    
           ;; flag used to calc FULL storm stats only once
           firstTimeThru = 1
                      
           for ssSH=0,ctaShallow2-1 do begin
              
              get_core_dims,id_SH,npix_SH,grid_SH,donde_Shallow2,ssSH,$
                            nlonsFull,nlatsFull,lonsFull_sub,latsFull_sub,$
                            w_id_SH,cta_SH,dondeSH_SH,pixelsumSH_SH,$
                            lonSH,lonC_SH,latSH,latC_SH,area_SH,dim_hgtSH,$
                            dim_topSH,dim_botSH

              ;; identify the real Shallow contiguous area
              if pixelsumSH_SH ge 2 then begin
                 if DEBUG then print,'In shal_iso_class: ssSH = ',ssSH
                 
                 ;;-----------------------------------------
                 ;; Increment core count and update SHI mask
                 ;;-----------------------------------------                  
                 ;;inc_echo_count,num_shi,d_lonsFull,d_latsFull,dondeSH_SH,shi_mask

                 ;;----------------------------------------------------
                 ;; Compute the Shape parameters and info of SHI region
                 ;;----------------------------------------------------
                 ;;calculate the dimensions for Shallow pixels in the cluster
                 dim_lonSH=(max(lonsFull_sub[where(lonSH gt 0l)])-min(lonsFull_sub[where(lonSH gt 0l)]))+pixDeg
                 dim_latSH=(max(latsFull_sub[where(latSH gt 0l)])-min(latsFull_sub[where(latSH gt 0l)]))+pixDeg

                 ;; calculate elevation (meters) of terrain for the center of the core
                 id_top1=(where(topo_lon ge lonC_SH))[0] & id_top2=(where(topo_lat ge latC_SH))[0]
                 terr_hgtSH=DEM[id_top1,id_top2]
                 ;; set ocean/land mask (ocean=0 or land=1)
                 if terr_hgtSH eq 0 then land_oceanSH=0 else land_oceanSH=1

                 tmp_shapeSH=[lonC_SH,latC_SH,area_SH,dim_topSH,dim_botSH,dim_lonSH,dim_latSH,terr_hgtSH,land_oceanSH]
                 
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
                 ;;inc_echo_count,num_storm,d_lonsFull,d_latsFull,donde,storm_mask
                 
                 ;;----------------------------------------
                 ;; Statistics for NSR rain types and rates
                 ;;----------------------------------------
                 SrfRain_FULL=SrfRain[d_lonsFull,d_latsFull,*]
                 raintypeFULL=raintype[d_lonsFull,d_latsFull,*]
                 refl_3D_FULL=refl_3D[d_lonsFull,d_latsFull,*]
                 hgts_3D_FULL=hgts_3D[d_lonsFull,d_latsFull,*]

                 ;; stats for BSR area
                 get_class_stats,raintypeFULL,SrfRain_FULL,dondeSH_SH,lonC_SH,latC_SH,rain_momentSH,statsRain_SH
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
                    get_raccum,pixelsum,donde,nlonsFull,SrfRain_FULL,raintypeFULL,$
                               grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                               RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                               ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                               freqArray,rainArray,nRaiArray
                    freq_Full[*,*,4] = freq_Full[*,*,4] + freqArray
                    rain_NSRFull[*,*,4] = rain_NSRFull[*,*,4] + rainArray
                    nRai_NSRFull[*,*,4] = nRai_NSRFull[*,*,4] + nRaiArray
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
                 tmp_statsRain_NSR=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]

                 ;;------------------------------------------------
                 ;; Rainfall accumulation for Shallow Isolated part
                 ;;------------------------------------------------
                 freqArray=lonarr(nlonsC,nlatsC)
                 rainArray=fltarr(nlonsF,nlatsF)
                 nRaiArray=intarr(nlonsF,nlatsF)
                 get_raccum,pixelsumSH_SH,dondeSH_SH,nlonsFull,SrfRain_FULL,raintypeFULL,$
                            grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                            RTo_stra_NSR_SH,RTo_conv_NSR_SH,RTo_othe_NSR_SH,RTo_noRa_NSR_SH,$
                            ctaStra_NSR_SH,ctaConv_NSR_SH,ctaOthe_NSR_SH,ctaNoRa_NSR_SH,$
                            freqArray,rainArray,nRaiArray
                 freq_Core[*,*,4] = freq_Core[*,*,4] + freqArray
                 rain_NSRCore[*,*,4] = rain_NSRCore[*,*,4] + rainArray
                 nRai_NSRCore[*,*,4] = nRai_NSRCore[*,*,4] + nRaiArray
                 undefine,freqArray
                 undefine,rainArray
                 undefine,nRaiArray

                 ;; Rain statistics for SHI part
                 get_rain_statistics,RTo_stra_NSR_SH,RTo_conv_NSR_SH,RTo_othe_NSR_SH,RTo_noRa_NSR_SH,$
                                     ctaStra_NSR_SH,ctaConv_NSR_SH,ctaOthe_NSR_SH,ctaNoRa_NSR_SH,$
                                     m_RainAll_NSR_SH,m_RainStrt_NSR_SH,m_RainConv_NSR_SH,$
                                     vol_Rain_All_NSR_SH,vol_Rain_Str_NSR_SH,vol_Rain_Con_NSR_SH,$
                                     cen_lon,cen_lat
                 tmp_statsRain_NSR_SH=[m_RainAll_NSR_SH,m_RainStrt_NSR_SH,m_RainConv_NSR_SH,$
                                       vol_Rain_All_NSR_SH,vol_Rain_Str_NSR_SH,vol_Rain_Con_NSR_SH]

                 ;;-------------------------------------------
                 ;; CFAD count for FULL Storm - done only once
                 ;;-------------------------------------------
                 if firstTimeThru eq 1 then begin
                    cfad=lonarr(n_refls,nlevels)
                    get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idF,cta_Full,npix_str,$
                             donde_shallow,ss,cfad
                    CFAD_Full[*,*,4] = CFAD_Full[*,*,4] + cfad
                    undefine,cfad
                 endif
                 ;; set this after first time through so FULL storm data not computed again
                 firstTimeThru = 0

                 ;;-------------------------------------
                 ;; CFAD count for Shallow Isolated part
                 ;;-------------------------------------
                 cfad=lonarr(n_refls,nlevels)
                 get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_id_SH,cta_SH,npix_SH,$
                          donde_Shallow2,ssSH,cfad
                 CFAD_Core[*,*,4] = CFAD_Core[*,*,4] + cfad
                 undefine,cfad

                 ;;----------------------------------------------------------
                 ;;store the info for monthly_class & stats_class directories
                 ;;----------------------------------------------------------
                 info_SH=[info_SH,orbit+'.'+datetime+'.0']
                 
                 shape_Core_SH=[[shape_Core_SH],[tmp_shapeSH]]
                 shape_Full_SH=[[shape_Full_SH],[tmp_shape]]
                 
                 rain_Core_SH=[[rain_Core_SH],[rain_momentSH]]
                 rain_Full_SH=[[rain_Full_SH],[rain_moment]]
                 
                 rainTypeCore_SH=[[rainTypeCore_SH],[statsRain_SH]]
                 rainTypeFull_SH=[[rainTypeFull_SH],[statsRain]]
                
                 rainCore_SH_NSR=[[rainCore_SH_NSR],[tmp_statsRain_NSR_SH]]
                 rainFull_SH_NSR=[[rainFull_SH_NSR],[tmp_statsRain_NSR]]
                
                 undefine,dim_lonSH
                 undefine,dim_latSH
                 undefine,hgt_sumSH
                 undefine,grid_sum
                 undefine,donde
                 undefine,pixelsum
                 undefine,hgt_sum
                 undefine,tmp_shapeSH
                 undefine,tmp_shape
                 ;;not undefined in v1
                 ;;undefine,rain_momentSH
                 ;;undefine,rain_moment
                 ;;undefine,statsRain_SH
                 ;;undefine,statsRain
                 ;;undefine,tmp_statsRain_NSR_SH
                 ;;undefine,tmp_statsRain_NSR                 
                 undefine,SrfRain_FULL
                 undefine,raintypeFULL
                 undefine,refl_3D_FULL
                 undefine,hgts_3D_FULL
                 undefine,grid_storm_FULL
                 
              endif         ;;endif found a storm cluster with contiguous convective pixels within theresholds
              
              undefine,lonSH
              undefine,latSH
              undefine,singlestormgrid_SH
              undefine,grid_sum_SH_SH
              undefine,dondeSH_SH
              undefine,pixelsumSH_SH
              undefine,s_id_SH
              undefine,w_id_SH
              
           endfor           ;;endfor loop through analyzed storms clusters that maybe are deep-wide convective
           
           undefine,grid_SH
           undefine,npix_SH
           undefine,id_SH
           undefine,searchNaN_SH
           undefine,donde_Shallow2
           
        endif               ;;endif for convective areas that could be matching the theresholds
        
        undefine,d_lonsFull
        undefine,d_latsFull
        undefine,singlestormgrid_Full
        undefine,lonsFull_sub
        undefine,latsFull_sub
        undefine,singlestormgridShallow
        undefine,w_idF

     endfor                 ;;endfor loop thru full storm volumens greater than 2l
     
  endif                     ;;end if the orbit does have shallow isolated pixels
           
end
