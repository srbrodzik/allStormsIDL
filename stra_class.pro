pro stra_class,id_storm,npix_str,grid_storm,num_storm

  ;; TODO - rename vars to more readable names
  ;;   ss => istorm
  ;;   ssST => iCore or iBSR
  ;;   w_idF/s_idF
  ;;   w_idST/s_idST
  ;;   donde => ind or indices??
  ;;   cta => cnt or count
  
  COMMON topoBlock,topo_lat,topo_lon,DEM
  COMMON infoBlock,orbit,datetime,info_DC,info_WC,info_DW,info_BS,info_SH
  COMMON straCoreBlock,shape_Core_BS,rain_Core_BS,rainTypeCore_BS, $
     rainCore_BS_NSR
  COMMON straStormBlock,shape_Full_BS,rain_Full_BS,rainTypeFull_BS, $
     rainFull_BS_NSR
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D
  COMMON maskBlock,bsr_mask,dcc_mask,dwc_mask,wcc_mask,shi_mask,storm_mask

  resolve_routine,'get_subgrid_storm'   ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_subgrid_storm
  resolve_routine,'get_storm_info'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_storm_info
  resolve_routine,'get_core_dims'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_core_dims
  resolve_routine,'inc_echo_count'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/inc_echo_count
  resolve_routine,'get_str_shape'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_str_shape
  resolve_routine,'get_class_stats'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_class_stats
  resolve_routine,'get_rain_accum'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_accum
  resolve_routine,'get_rain_statistics' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_statistics
  resolve_routine,'get_cfad'            ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_cfad

  ;; include constants
  @constants_ocean.pro

  ;; initialize num_bsr
  num_bsr = 0
  
  ;; identify broad stra volumes with npix_str > npix_aST (in constants; ~npix for thr_aST)
  donde_BrdStr=where(npix_str gt 1000l,ctaBrdStr) ;;1000 pixels just to be conservative

  ;; identify Stratiform subset
  if cta_strt ne 0 and ctaBrdStr gt 0 then begin

     ;; go through each storm that meets the npix criteria for BSR
     for ss=0l,ctaBrdStr-1 do begin  ;; TESTING - use ss=9
        print,'In stra_class: ss = ',ss

        ;; identify subgrid containing storm
        refl_thres = 0.
        rtype = STRA
        get_subgrid_storm,id_storm,npix_str,grid_storm,donde_BrdStr,ss,$
                          refl_thres,rtype,w_idF,d_lonsFull,nlonsFull,$
                          d_latsFull,nlatsFull,singlestormgrid_Full,$
                          cta_Full,lonsFull_sub,latsFull_sub,$
                          singlestormgridStratiform,pixelsumST        

        ;; get storm area
        get_storm_info,pixelsumST,singlestormgridStratiform,lonsFull_sub,$
                       latsFull_sub,area_ST,dim_hgtST,dim_topST,dim_botST
        print,'Back from get_storm_info:'
        help,area_ST,dim_hgtST,dim_topST,dim_botST
       
        ;; if storm meets BSR criteria
        if area_ST ge thr_aST then begin ;; TESTING - true for ss=9

           ;; find regions of adjacent strat pixels within storm
           findStormNew,refl_3D=singlestormgridStratiform,$
                        ;;refl_3D_fillValue=refl_3D_fillValue,$
                        id_storm=id_ST,$
                        npix_str=npix_ST,$
                        grid_storm=grid_ST
           searchNaN_ST=where(grid_ST lt 0, nanCnt)
           if nanCnt gt 0 then grid_ST[searchNaN_ST]=0l
                 
           ;; identify only volumes with more than npix_aST (~1350 pixels)
           donde_BrdStr2=where(npix_ST gt 1000l,ctaBrdStr2) ;;1000 pixels just to be conservative
           print,'In stra_class: ctaBrdStr2 = ',ctaBrdStr2

           ;; flag used to calc FULL storm stats only once
           firstTimeThru = 1

           for ssST=0l,ctaBrdStr2-1 do begin   ;; TESTING - use ssST = 0
              print,'In stra_class: ssST = ',ssST

              get_core_dims,id_ST,npix_ST,grid_ST,donde_BrdStr2,ssST,$
                            nlonsFull,nlatsFull,lonsFull_sub,latsFull_sub,$
                            w_idST,cta_ST,dondeST_ST,pixelsumST_ST,$
                            lonST,lonC_ST,latST,latC_ST,area_BS,dim_hgtBS,$
                            dim_topBS,dim_botBS

              ;; identify the BSR contiguous area
              if area_BS ge thr_aST then begin 

                 ;;-----------------------------------------
                 ;; Increment core count and update BSR mask
                 ;;-----------------------------------------                  
                 inc_echo_count,num_bsr,d_lonsFull,d_latsFull,dondeST_ST,bsr_mask

                 ;;----------------------------------------------------
                 ;; Compute the Shape parameters and info of BSR region
                 ;;----------------------------------------------------
                 ;; calculate dimensions for BSR pixels in the cluster
                 dim_lonBS=(max(lonsFull_sub[where(lonST gt 0l)])-min(lonsFull_sub[where(lonST gt 0l)]))+pixDeg
                 dim_latBS=(max(latsFull_sub[where(latST gt 0l)])-min(latsFull_sub[where(latST gt 0l)]))+pixDeg

                 ;; calculate elevation (meters) of terrain for center of storm
                 id_top1=(where(topo_lon ge lonC_ST))[0] & id_top2=(where(topo_lat ge latC_ST))[0]
                 terr_hgtBS=DEM[id_top1,id_top2]
                 ;; set ocean/land mask (ocean=0 or land=1)
                 if terr_hgtBS eq 0 then land_oceanBS=0 else land_oceanBS=1

                 tmp_shapeBS=[lonC_ST,latC_ST,area_BS,dim_topBS,dim_botBS,dim_lonBS,dim_latBS,terr_hgtBS,land_oceanBS]

                 ;;----------------------------------------------------
                 ;; Compute the Shape parameters and info of FULL storm
                 ;;----------------------------------------------------
                 ;; count number of pixels within each column of storm
                 grid_sum=total(singlestormgrid_Full,3)
                 ;; pixelsum is number of pixels in a 2D proj
                 donde=where(grid_sum gt 0,pixelsum)
                 
                 ;; Increment storm count and update storm mask
                 inc_echo_count,num_storm,d_lonsFull,d_latsFull,donde,storm_mask

                 get_str_shape,singlestormgrid_Full,lonsFull_sub,latsFull_sub,$
                               pixelsum,cen_lon,cen_lat,area,dim_lon,dim_lat,$
                               dim_top,dim_bot,terr_hgt,land_ocean
                 print,'Back from get_str_shape:'
                 help,cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean
                 tmp_shape=[cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean]
                 help,tmp_shape
      
                 ;;----------------------------------------
                 ;; Statistics for NSR rain types and rates
                 ;;----------------------------------------
                 SrfRain_FULL=SrfRain[d_lonsFull,d_latsFull,*]
                 raintypeFULL=raintype[d_lonsFull,d_latsFull,*]
                 refl_3D_FULL=refl_3D[d_lonsFull,d_latsFull,*]
                 hgts_3D_FULL=hgts_3D[d_lonsFull,d_latsFull,*]

                 ;; stats for BSR area
                 get_class_stats,raintypeFULL,SrfRain_FULL,dondeST_ST,lonC_ST,latC_ST,rain_momentBS,statsRain_BS
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
                 
                 ;;if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFULL then begin
                 if firstTimeThru eq 1 then begin
                    freqArray=lonarr(nlonsC,nlatsC)
                    rainArray=fltarr(nlonsF,nlatsF)
                    nRaiArray=intarr(nlonsF,nlatsF)
                    get_rain_accum,pixelsum,donde,nlonsFull,SrfRain_FULL,raintypeFULL,$
                                   grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                                   RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                                   ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                                   freqArray,rainArray,nRaiArray
                    freq_Full[*,*,3] = freqArray
                    rain_NSRFull[*,*,3] = rainArray
                    nRai_NSRFull[*,*,3] = nRaiArray
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

                 ;;------------------------------------------------
                 ;; Rainfall accumulation for Broad Stratiform part
                 ;;------------------------------------------------                 
                 freqArray=lonarr(nlonsC,nlatsC)
                 rainArray=fltarr(nlonsF,nlatsF)
                 nRaiArray=intarr(nlonsF,nlatsF)
                 get_rain_accum,pixelsumST_ST,dondeST_ST,nlonsFull,SrfRain_FULL,raintypeFULL,$
                                grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                                RTo_stra_NSR_ST,RTo_conv_NSR_ST,RTo_othe_NSR_ST,RTo_noRa_NSR_ST,$
                                ctaStra_NSR_ST,ctaConv_NSR_ST,ctaOthe_NSR_ST,ctaNoRa_NSR_ST,$
                                freqArray,rainArray,nRaiArray
                 freq_Core[*,*,3] = freqArray
                 rain_NSRCore[*,*,3] = rainArray
                 nRai_NSRCore[*,*,3] = nRaiArray
                 undefine,freqArray
                 undefine,rainArray
                 undefine,nRaiArray
                 
                 ;; Rain statistics for Broad Stratiform part
                 get_rain_statistics,RTo_stra_NSR_ST,RTo_conv_NSR_ST,RTo_othe_NSR_ST,RTo_noRa_NSR_ST,$
                                     ctaStra_NSR_ST,ctaConv_NSR_ST,ctaOthe_NSR_ST,ctaNoRa_NSR_ST,$
                                     m_RainAll_NSR_ST,m_RainStrt_NSR_ST,m_RainConv_NSR_ST,$
                                     vol_Rain_All_NSR_ST,vol_Rain_Str_NSR_ST,vol_Rain_Con_NSR_ST,$
                                     cen_lon,cen_lat
                 tmp_statsRain_NSR_BS=[m_RainAll_NSR_ST,m_RainStrt_NSR_ST,m_RainConv_NSR_ST,$
                                       vol_Rain_All_NSR_ST,vol_Rain_Str_NSR_ST,vol_Rain_Con_NSR_ST]
                       
                 ;;-------------------------------------------
                 ;; CFAD count for FULL Storm - done only once
                 ;;-------------------------------------------
                 ;;if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFULL then begin
                 if firstTimeThru eq 1 then begin
                    cfad=lonarr(n_refls,nlevels)
                    get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idF,cta_Full,npix_str,$
                             donde_BrdStr,ss,cfad
                    CFAD_Full[*,*,3] = cfad
                    undefine,cfad
                 endif
                 ;; set these after first time through so FULL storm data not recomputed
                 ;;areaIsFULL=area & lonCIsFULL=cen_lon & latCIsFULL=cen_lat
                 firstTimeThru = 0
                       
                 ;;-------------------------------------
                 ;; CFAD count for Broad Stratiform part
                 ;;-------------------------------------
                 cfad=lonarr(n_refls,nlevels)
                 get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idST,cta_ST,npix_ST,$
                          donde_BrdStr2,ssST,cfad
                 CFAD_Core[*,*,3] = cfad
                 undefine,cfad
                 
                 ;;------------------------------------------
                 ;;store the info for monthly_class directory
                 ;;------------------------------------------
                 info_BS=[info_BS,orbit+'.'+datetime+'.'+strtrim(string(num_bsr),2)]

                 shape_Core_BS=[[shape_Core_BS],[tmp_shapeBS]]
                 shape_Full_BS=[[shape_Full_BS],[tmp_shape]]

                 rain_Core_BS=[[rain_Core_BS],[rain_momentBS]]
                 rain_Full_BS=[[rain_Full_BS],[rain_moment]]

                 rainTypeCore_BS=[[rainTypeCore_BS],[statsRain_BS]]
                 rainTypeFull_BS=[[rainTypeFull_BS],[statsRain]]

                 ;;----------------------------------------
                 ;;store the info for stats_class directory
                 ;;----------------------------------------
                 rainCore_BS_NSR=[[rainCore_BS_NSR],[tmp_statsRain_NSR_BS]]
                 rainFull_BS_NSR=[[rainFull_BS_NSR],[tmp_statsRain_NSR]]

                 undefine,dim_lonBS
                 undefine,dim_latBS
                 undefine,hgt_sumBS
                 undefine,grid_sum
                 ;;undefine,storm_mask_sub ;;new
                 undefine,donde
                 undefine,pixelsum
                 ;;undefine,lon_sum
                 ;;undefine,lat_sum                 
                 undefine,hgt_sum
                 undefine,tmp_shapeBS
                 undefine,tmp_shape
                 ;;not undefined in v1
                 ;;undefine,rain_momentBS
                 ;;undefine,rain_moment
                 ;;undefine,statsRain_BS
                 ;;undefine,statsRain
                 ;;undefine,tmp_statsRain_NSR_BS
                 ;;undefine,tmp_statsRain_NSR
                 undefine,SrfRain_FULL
                 undefine,raintypeFULL
                 undefine,refl_3D_FULL
                 undefine,hgts_3D_FULL
                 undefine,grid_storm_FULL

              endif      ;;endif area_BS gt thr_aST

              undefine,lonST
              undefine,latST
              undefine,singlestormgrid_ST
              undefine,grid_sum_ST_ST
              undefine,dondeST_ST              
              undefine,pixelsumST_ST
              undefine,s_idST
              undefine,w_idST
              
           endfor     ;;endfor loop through pixels that maybe are broad Stratiform
           
           undefine,grid_ST
           undefine,npix_ST
           undefine,id_ST
           undefine,searchNaN_ST
           undefine,donde_BrdStr2

        endif      ;;endif for stratiforms areas (area_ST) > thr_aST
        
        ;;undefine,total_lonFull
        undefine,d_lonsFull
        ;;undefine,total_latFull
        undefine,d_latsFull
        ;;undefine,singlestormgrid ;;new
        undefine,singlestormgrid_Full
        undefine,lonsFull_sub
        undefine,latsFull_sub
        undefine,singlestormgridStratiform
        ;;undefine,grid_sumST
        ;;undefine,dondeST
        ;;undefine,s_idF
        undefine,w_idF

     endfor        ;;endfor loop thru stratiform volumes greater than 1000 pixels
     
  endif            ;;end if cta_strt ne 0 and ctaBrdStr gt 0
        
end
