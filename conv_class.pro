pro conv_class,id_storm,npix_str,grid_storm,num_storm

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
  @constants_ocean.pro

  resolve_routine,'get_subgrid_storm'   ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_subgrid_storm
  resolve_routine,'get_storm_info'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_storm_info
  resolve_routine,'get_core_dims'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_core_dims
  resolve_routine,'inc_echo_count'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/inc_echo_count
  resolve_routine,'get_str_shape'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_str_shape

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
        print,'In conv_class: ss = ',ss

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
        ;; NOTE: area, hgt, top, bot should end in something diff than CV
        ;;       since this is name output from get_core_dims
        get_storm_info,pixelsumCV,singlestormgridConvective,lonsFull_sub,$
                       latsFull_sub,area_CV,dim_hgtCV,dim_topCV,dim_botCV

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
           print,'In conv_class: ctaConvective2 = ',ctaConvective2

           ;; flag used to calc FULL storm stats only once
           firstTimeThru = 1

           for ssCV=0l,ctaConvective2-1 do begin
              print,'In conv_class: ssCV = ',ssCV

              ;; get numpixels, area and max and min heights of potential core area
              get_core_dims,id_CV,npix_CV,grid_CV,donde_Convec2,ssCV,$
                            nlonsFull,nlatsFull,lonsFull_sub,latsFull_sub,$
                            w_idCV,cta_CV,dondeCV_CV,pixelsumCV_CV,$
                            lonCV,lonC_CV,latCV,latC_CV,area_CV,dim_hgtCV,$
                            dim_topCV,dim_botCV

              ;; identify the contiguous areas belonging to a Deep or Wide convective event
              if pixelsumCV_CV ge 2 and (area_CV ge thr_aCV or (dim_topCV ge thr_hCV and dim_hgtCV ge thr_dCV) ) then begin

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

                 ;; Increment storm count and update storm mask
                 inc_echo_count,num_storm,d_lonsFull,d_latsFull,donde,storm_mask

                 get_str_shape,singlestormgrid_Full,lonsFull_sub,latsFull_sub,$
                               pixelsum,cen_lon,cen_lat,area,dim_lon,dim_lat,$
                               dim_top,dim_bot,terr_hgt,land_ocean
                 tmp_shape=[cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean]

                 ;;----------------------------------------
                 ;; Statistics for NSR rain types and rates
                 ;;----------------------------------------
                 SrfRain_FULL=SrfRain[d_lonsFull,d_latsFull,*]
                 raintypeFULL=raintype[d_lonsFull,d_latsFull,*]
                 refl_3D_FULL=refl_3D[d_lonsFull,d_latsFull,*]
                 hgts_3D_FULL=hgts_3D[d_lonsFull,d_latsFull,*]

                 ;; stats for BSR area
                 ;;get_class_stats,raintypeFULL,SrfRain_FULL,dondeST_ST,lonC_ST,latC_ST,rain_momentBS,statsRain_BS
                 
                 stratconv=raintypeFULL[dondeCV_CV]                           ;;type of rain in each 2D pixel that compose the storm
                 strats=where(stratconv eq STRA,ctaStr)                       ;;stratiform
                 convec=where(stratconv eq CONV,ctaCon)                       ;;convective
                 others=where(stratconv ge OTHER,ctaOth)                      ;;other type
                 noRain=where(stratconv eq raintype_noRainValue,ctaNoR)       ;;no rain
                 missin=where(stratconv eq raintype_fillValue,ctaMis)         ;;missing value
                       
                 rainCV=SrfRain_FULL[dondeCV_CV] ;;this is based on Near Surface Rain
                 rain_nomiss=where(rainCV ne SrfRain_fillValue,Rmiss)

                 ;;here I calculate moments of simple rain within storm
                 if Rmiss ge 2 then rain_momentCV=[mean(rainCV[rain_nomiss]),stdev(rainCV[rain_nomiss]),$
                                                   max(rainCV[rain_nomiss]),min(rainCV[rain_nomiss]),float(Rmiss),$
                                                   float(ctaStr),float(ctaCon)] $
                 else rain_momentCV=[-9999.,-9999.,-9999.,-9999.,-9999.,-9999.,-9999.]

                 ;;here I calculate rainrate sums in [mm/hr]
                 if ctaStr ne 0 then RTo_stra=total(rainCV[strats]) else RTo_stra=0.       ;;total stratiform rain
                 if ctaCon ne 0 then RTo_conv=total(rainCV[convec]) else RTo_conv=0.       ;;total convective rain
                 if ctaOth ne 0 then RTo_othe=total(rainCV[others]) else RTo_othe=0.       ;;total other rain
                 if ctaNoR ne 0 then RTo_noRa=total(rainCV[noRain]) else RTo_noRa=0.       ;;total no_rain rain
                 total_RainAll=RTo_stra+RTo_conv+RTo_othe+RTo_noRa
                 total_RainCSs=RTo_stra+RTo_conv

                 m_RainAll=total_RainAll/(ctaStr+ctaCon+ctaOth+ctaNoR+ctaMis)            ;;mean rainfall all pixels
                 if ctaStr ne 0 then m_RainStrt=RTo_stra/ctaStr else m_RainStrt=0.       ;;mean stratiform rain
                 if ctaCon ne 0 then m_RainConv=RTo_conv/ctaCon else m_RainConv=0.       ;;mean convective rain
                 if ctaStr ne 0 or ctaCon ne 0 then m_RainCSs=total_RainCSs/(ctaStr+ctaCon) $
                 else m_RainCSs=-999.

                 ;;here calculate volumetric values of rain  ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,lonC_CV,latC_CV)
                 vol_Rain_All=total_RainAll*(size_pixels[0]*size_pixels[1])/secsPerHr  
                 vol_Rain_Str=RTo_stra*(size_pixels[0]*size_pixels[1])/secsPerHr 
                 vol_Rain_Con=RTo_conv*(size_pixels[0]*size_pixels[1])/secsPerHr
   
                 ;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 statsRain_CV=[m_RainAll,m_RainStrt,m_RainConv,vol_Rain_All,vol_Rain_Str,vol_Rain_Con]
 
                 ;; stats for FULL area
                 ;;get_class_stats,raintypeFULL,SrfRain_FULL,donde,cen_lon,cen_lat,rain_moment,statsRain
                 
                 stratconv=raintypeFULL[donde]                                ;;type of rain in each 2D pixel that compose the storm
                 strats=where(stratconv eq STRA,ctaStr)                       ;;stratiform
                 convec=where(stratconv eq CONV,ctaCon)                       ;;convective
                 others=where(stratconv ge OTHER,ctaOth)                      ;;other type
                 noRain=where(stratconv eq raintype_noRainValue,ctaNoR)       ;;no rain
                 missin=where(stratconv eq raintype_fillValue,ctaMis)         ;;missing value
                 
                 rain=SrfRain_FULL[donde] ;;this is based on Near Surface Rain
                 rain_nomiss=where(rain ne SrfRain_fillValue,Rmiss)
                       
                 ;;here I calculate moments of simple rain within storm
                 if Rmiss ge 2 then rain_moment=[mean(rain[rain_nomiss]),stdev(rain[rain_nomiss]),$
                                                 max(rain[rain_nomiss]),min(rain[rain_nomiss]),float(Rmiss),$
                                                 float(ctaStr),float(ctaCon)] $
                 else rain_moment=[-9999.,-9999.,-9999.,-9999.,-9999.,-9999.,-9999.]

                 ;;here I calculate rainrate sums in [mm/hr]
                 if ctaStr ne 0 then RTo_stra=total(rain[strats]) else RTo_stra=0.       ;;total stratiform rain
                 if ctaCon ne 0 then RTo_conv=total(rain[convec]) else RTo_conv=0.       ;;total convective rain
                 if ctaOth ne 0 then RTo_othe=total(rain[others]) else RTo_othe=0.       ;;total other rain
                 if ctaNoR ne 0 then RTo_noRa=total(rain[noRain]) else RTo_noRa=0.       ;;total no_rain rain
                 total_RainAll=RTo_stra+RTo_conv+RTo_othe+RTo_noRa
                 total_RainCSs=RTo_stra+RTo_conv

                 m_RainAll=total_RainAll/(ctaStr+ctaCon+ctaOth+ctaNoR+ctaMis)            ;;mean rainfall all pixels
                 if ctaStr ne 0 then m_RainStrt=RTo_stra/ctaStr else m_RainStrt=0.       ;;mean stratiform rain
                 if ctaCon ne 0 then m_RainConv=RTo_conv/ctaCon else m_RainConv=0.       ;;mean convective rain
                 if ctaStr ne 0 or ctaCon ne 0 then m_RainCSs=total_RainCSs/(ctaStr+ctaCon) $
                 else m_RainCSs=-999.

                 ;;here calculate volumetric values of rain  ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 ;;area=pixelsum*size_pixels[0]*size_pixels[1] ;;in km horizontal area of selected storm

                 vol_Rain_All=total_RainAll*(size_pixels[0]*size_pixels[1])/secsPerHr  
                 vol_Rain_Str=RTo_stra*(size_pixels[0]*size_pixels[1])/secsPerHr 
                 vol_Rain_Con=RTo_conv*(size_pixels[0]*size_pixels[1])/secsPerHr

                 ;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 statsRain=[m_RainAll,m_RainStrt,m_RainConv,vol_Rain_All,vol_Rain_Str,vol_Rain_Con]
                 
                 ;;---------------------------------------------------------
                 ;; Calculate rainfall accumulation for Full and Core storms
                 ;;---------------------------------------------------------
                 grid_storm_FULL=lonarr(nlonsFull,nlatsFull,nlevels)
                 grid_storm_FULL=grid_storm[d_lonsFull,d_latsFull,*]

                 ;;------------------------------------------------------
                 ;; Rainfall accumulation for FULL STORM - only done once
                 ;;------------------------------------------------------
                 
                 ;;if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFull then begin
                 if firstTimeThru eq 1 then begin

                    ;;freqArray=lonarr(nlonsC,nlatsC)
                    ;;rainArray=fltarr(nlonsF,nlatsF)
                    ;;nRaiArray=intarr(nlonsF,nlatsF)
                    ;;get_rain_accum,pixelsum,donde,nlonsFull,SrfRain_FULL,raintypeFULL,$
                    ;;               grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                    ;;               RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                    ;;               ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                    ;;               freqArray,rainArray,nRaiArray
                    ;;freq_Full[*,*,3] = freqArray
                    ;;rain_NSRFull[*,*,3] = rainArray
                    ;;nRai_NSRFull[*,*,3] = nRaiArray
                    ;;undefine,freqArray
                    ;;undefine,rainArray
                    ;;undefine,nRaiArray
                    
                    ;;Statistics for rain rates Calculated using Near Surface Rain
                    RTo_conv_NSR=0. & ctaConv_NSR=0l       ;;total convective rain
                    RTo_stra_NSR=0. & ctaStra_NSR=0l       ;;total stratiform rain
                    RTo_othe_NSR=0. & ctaOthe_NSR=0l       ;;total other rain
                    RTo_noRa_NSR=0. & ctaNoRa_NSR=0l       ;;total no_rain rain

                    for i=0l,pixelsum-1l do begin   
                       col=donde[i] mod nlonsFull                     ;;column ID of the pixel
                       fil=long(fix(donde[i]/float(nlonsFull)))       ;;row    ID of the pixel
                       
                       nearSrfR_Org=SrfRain_FULL[col,fil]
                             
                       t_col=where(lonsC le lonsFull_sub[col],ctaC) ;;count the pixels
                       t_row=where(latsC le latsFull_sub[fil],ctaR) 
                       if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                          colCV=(reverse(t_col))[0] 
                          rowCV=(reverse(t_row))[0] 
                          if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                             freq_Full[colCV,rowCV,2]=freq_Full[colCV,rowCV,2]+1l else $
                                if area_CV ge thr_aCV then freq_Full[colCV,rowCV,1]=freq_Full[colCV,rowCV,1]+1l $
                                else if dim_topCV ge thr_hCV then freq_Full[colCV,rowCV,0]=freq_Full[colCV,rowCV,0]+1l 

                          ;;locate indices (x,y,z location of individual pixels within the FULL storm)
                          pila=reform(grid_storm_FULL[col,fil,*])
                          w_CV=where(pila ne 0,ctaHgt)
                          if ctaHgt ge 1 then begin 
                             ;;distance between lowest pixel and ground
                             id_top1=(where(topo_lon ge lonsFull_sub[col]))[0]
                             id_top2=(where(topo_lat ge latsFull_sub[fil]))[0]

                             ;;%we sort out all the pixels that are higher than 2.5km above the ground
                             ;;if (hgts[w_CV[0]]-float(DEM[id_top1,id_top2])/1000.) le 2.5 then begin                     ;; SRB
                             ;;locate the pixel in the nearest fine grid cell
                             tmp_col=(where(float(lonsF) eq lonsFull_sub[col],ctaC))[0]
                             tmp_row=(where(float(latsF) eq latsFull_sub[fil],ctaR))[0]
                               
                             if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                                ;;if ctaC eq 0 or ctaR eq 0 then stop
                               
                                ;;if nearSrfR_Org ne -9999.00 and refl_3D_FULL[col,fil,w_CV[0]] ne -999.0 then begin      ;; SRB
                                if nearSrfR_Org ne SrfRain_fillValue then begin
                                   ;;reflectivZ=10^(refl_3D_FULL[col,fil,w_CV[0]]*0.1)  ;;%convert from dBZ to Z          ;; SRB
                                  
                                   ;;here I create accumulated matrices with rain rate for each type of convective system
                                   if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin ;;deep and wide convective
                                      rain_NSRFull[tmp_col,tmp_row,2]=rain_NSRFull[tmp_col,tmp_row,2]+nearSrfR_Org
                                      nRai_NSRFull[tmp_col,tmp_row,2]=nRai_NSRFull[tmp_col,tmp_row,2]+1l
                                   endif else begin
                                      if area_CV ge thr_aCV then begin
                                         rain_NSRFull[tmp_col,tmp_row,1]=rain_NSRFull[tmp_col,tmp_row,1]+nearSrfR_Org
                                         nRai_NSRFull[tmp_col,tmp_row,1]=nRai_NSRFull[tmp_col,tmp_row,1]+1l
                                      endif else begin
                                         if dim_topCV ge thr_hCV then begin
                                            rain_NSRFull[tmp_col,tmp_row,0]=rain_NSRFull[tmp_col,tmp_row,0]+nearSrfR_Org
                                            nRai_NSRFull[tmp_col,tmp_row,0]=nRai_NSRFull[tmp_col,tmp_row,0]+1l
                                         endif 
                                      endelse
                                   endelse
                                            
                                   ;;here I create accumulated rain rate vectors
                                   if raintypeFULL[col,fil] eq CONV then begin ;;convective rain
                                      RTo_conv_NSR=RTo_conv_NSR+nearSrfR_Org
                                      ctaConv_NSR=ctaConv_NSR+1l

                                   endif else begin
                                      if raintypeFULL[col,fil] eq STRA then begin ;;stratiform rain
                                         RTo_stra_NSR=RTo_stra_NSR+nearSrfR_Org
                                         ctaStra_NSR=ctaStra_NSR+1l

                                      endif else begin
                                         if raintypeFULL[col,fil] ge OTHER then begin ;;other rain
                                            RTo_othe_NSR=RTo_othe_NSR+nearSrfR_Org
                                            ctaOthe_NSR=ctaOthe_NSR+1l

                                         endif else begin
                                            if raintype[col,fil] eq raintype_noRainValue then begin ;;No rain
                                               RTo_noRa_NSR=RTo_noRa_NSR+0.
                                               ctaNoRa_NSR=ctaNoRa_NSR+1l
                                            endif
                                         endelse
                                      endelse
                                   endelse
                                endif       ;; end for missing values....
                             endif          ;; if ctaC ne 0 and ctaR ne 0
                             ;;endif       ;; end for pixels with height > 2.5km
                          endif
                       endif
                    endfor
                 endif  ;;end for flag of accounting for a single FULL storm...

                 ;; Rain statistics for FULL Storm
                 ;;get_rain_statistics,RTo_stra_NSR,RTo_conv_NSR,RTo_othe_NSR,RTo_noRa_NSR,$
                 ;;                    ctaStra_NSR,ctaConv_NSR,ctaOthe_NSR,ctaNoRa_NSR,$
                 ;;                    m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,$
                 ;;                    vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR,$
                 ;;                    cen_lon,cen_lat
                 
                 ;;Near Surface Rain
                 total_RainAll_NSR=RTo_stra_NSR+RTo_conv_NSR+RTo_othe_NSR+RTo_noRa_NSR
                 total_RainCSs_NSR=RTo_stra_NSR+RTo_conv_NSR
                 m_RainAll_NSR=total_RainAll_NSR/float(ctaStra_NSR+ctaConv_NSR+ctaOthe_NSR+ctaNoRa_NSR)        ;;mean rainfall for all pixels
                 if ctaStra_NSR ne 0 then m_RainStrt_NSR=RTo_stra_NSR/ctaStra_NSR else m_RainStrt_NSR=0.       ;;mean stratiform rain
                 if ctaConv_NSR ne 0 then m_RainConv_NSR=RTo_conv_NSR/ctaConv_NSR else m_RainConv_NSR=0.       ;;mean convective rain
                 if ctaStra_NSR ne 0 or ctaConv_NSR ne 0 then $
                    m_RainCSs_NSR=total_RainCSs_NSR/float(ctaStra_NSR+ctaConv_NSR) else m_RainCSs_NSR=-999.
                 ;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 vol_Rain_All_NSR=total_RainAll_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Str_NSR=RTo_stra_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Con_NSR=RTo_conv_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;mean rain, mean strat, mean convec, vol all, vol
                 ;;strat, vol conv [1e6*kg/s]
                 
                 tmp_statsRain_NSR=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]

                 ;;------------------------------------------
                 ;; Rainfall accumulation for Convective part
                 ;;------------------------------------------
                 ;;freqArray=lonarr(nlonsC,nlatsC)
                 ;;rainArray=fltarr(nlonsF,nlatsF)
                 ;;nRaiArray=intarr(nlonsF,nlatsF)
                 ;;get_rain_accum,pixelsumST_ST,dondeST_ST,nlonsFull,SrfRain_FULL,raintypeFULL,$
                 ;;               grid_storm_FULL,lonsFull_sub,latsFull_sub,$
                 ;;               RTo_stra_NSR_ST,RTo_conv_NSR_ST,RTo_othe_NSR_ST,RTo_noRa_NSR_ST,$
                 ;;               ctaStra_NSR_ST,ctaConv_NSR_ST,ctaOthe_NSR_ST,ctaNoRa_NSR_ST,$
                 ;;               freqArray,rainArray,nRaiArray
                 ;;freq_Core[*,*,3] = freqArray
                 ;;rain_NSRCore[*,*,3] = rainArray
                 ;;nRai_NSRCore[*,*,3] = nRaiArray
                 ;;undefine,freqArray
                 ;;undefine,rainArray
                 ;;undefine,nRaiArray
                 
                 RTo_conv_NSR_CV=0. & ctaConv_NSR_CV=0l       ;;total convective rain
                 RTo_stra_NSR_CV=0. & ctaStra_NSR_CV=0l       ;;total stratiform rain
                 RTo_othe_NSR_CV=0. & ctaOthe_NSR_CV=0l       ;;total other rain
                 RTo_noRa_NSR_CV=0. & ctaNoRa_NSR_CV=0l       ;;total no_rain rain

                 ;;Count pixels in matrix matching with storm location and locate indices (CORE STORM)
                 for i=0l,pixelsumCV_CV-1l do begin   
                    col=dondeCV_CV[i] mod nlonsFull                     ;;column ID of the pixel
                    fil=long(fix(dondeCV_CV[i]/float(nlonsFull)))       ;;row    ID of the pixel
                   
                    nearSrfR_Org=SrfRain_FULL[col,fil]
                          
                    t_col=where(lonsC le lonsFull_sub[col],ctaC) ;;count the pixels
                    t_row=where(latsC le latsFull_sub[fil],ctaR) 
                    if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                       colCV=(reverse(t_col))[0] 
                       rowCV=(reverse(t_row))[0]  
                       if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                          freq_Core[colCV,rowCV,2]=freq_Core[colCV,rowCV,2]+1l else $
                             if area_CV ge thr_aCV then freq_Core[colCV,rowCV,1]=freq_Core[colCV,rowCV,1]+1l $
                             else if dim_topCV ge thr_hCV then freq_Core[colCV,rowCV,0]=freq_Core[colCV,rowCV,0]+1l 
                             
                       ;;locate indices (x,y,z location of individual pixels within the Convective storm)
                       pila=reform(grid_storm_FULL[col,fil,*]) ;;Matching the location within the full storm containing the core
                       w_CV=where(pila ne 0,ctaHgt)
                       if ctaHgt ge 1 then begin 
                          ;;distance between lowest pixel and ground
                          id_top1=(where(topo_lon ge lonsFull_sub[col]))[0]
                          id_top2=(where(topo_lat ge latsFull_sub[fil]))[0]
 
                          ;;%we sort out all the pixels that are higher than 2.5km above the ground
                          ;;if (hgts[w_CV[0]]-float(DEM[id_top1,id_top2])/1000.) le 2.5 then begin                    ;; SRB

                          ;;locate the pixel in the nearest fine grid cell
                          tmp_col=(where(float(lonsF) eq lonsFull_sub[col],ctaC))[0]
                          tmp_row=(where(float(latsF) eq latsFull_sub[fil],ctaR))[0]
                            
                          if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                             ;;if ctaC eq 0 or ctaR eq 0 then stop
                            
                             ;;if nearSrfR_Org ne -9999.00 and refl_3D_FULL[col,fil,w_CV[0]] ne -999.0 then begin     ;; SRB
                             if nearSrfR_Org ne SrfRain_fillValue then begin
                                ;;reflectivZ=10^(refl_3D_FULL[col,fil,w_CV[0]]*0.1)  ;;%convert from dBZ to Z         ;; SRB
                               
                                ;;here I create accumulated matrices with rain rate for each type of convective system
                                if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin ;;deep and wide convective
                                   rain_NSRCore[tmp_col,tmp_row,2]=rain_NSRCore[tmp_col,tmp_row,2]+nearSrfR_Org
                                   nRai_NSRCore[tmp_col,tmp_row,2]=nRai_NSRCore[tmp_col,tmp_row,2]+1l
                                   
                                endif else begin
                                   if area_CV ge thr_aCV then begin
                                      rain_NSRCore[tmp_col,tmp_row,1]=rain_NSRCore[tmp_col,tmp_row,1]+nearSrfR_Org
                                      nRai_NSRCore[tmp_col,tmp_row,1]=nRai_NSRCore[tmp_col,tmp_row,1]+1l
                                               
                                   endif else begin
                                      if dim_topCV ge thr_hCV then begin
                                         rain_NSRCore[tmp_col,tmp_row,0]=rain_NSRCore[tmp_col,tmp_row,0]+nearSrfR_Org
                                         nRai_NSRCore[tmp_col,tmp_row,0]=nRai_NSRCore[tmp_col,tmp_row,0]+1l
                                                  
                                      endif 
                                   endelse
                                endelse
                               
                                ;;here I create accumulated rain rate vectors
                                if raintypeFULL[col,fil] eq CONV then begin ;;convective rain
                                   RTo_conv_NSR_CV=RTo_conv_NSR_CV+nearSrfR_Org
                                   ctaConv_NSR_CV=ctaConv_NSR_CV+1l

                                endif else begin
                                   if raintypeFULL[col,fil] eq STRA then begin ;;stratiform rain
                                      RTo_stra_NSR_CV=RTo_stra_NSR_CV+nearSrfR_Org
                                      ctaStra_NSR_CV=ctaStra_NSR_CV+1l
                                     
                                   endif else begin
                                      if raintypeFULL[col,fil] ge OTHER then begin ;;other rain
                                         RTo_othe_NSR_CV=RTo_othe_NSR_CV+nearSrfR_Org
                                         ctaOthe_NSR_CV=ctaOthe_NSR_CV+1l
                                        
                                      endif else begin
                                         ;;if raintypeFULL[col,fil] eq raintype_noRainValue then begin  ;;No rain
                                         if raintype[col,fil] eq raintype_noRainValue then begin ;;No rain
                                            RTo_noRa_NSR_CV=RTo_noRa_NSR_CV+0.
                                            ctaNoRa_NSR_CV=ctaNoRa_NSR_CV+1l
                                         endif
                                      endelse
                                   endelse
                                endelse
                             endif       ;; end for missing values....
                          endif          ;; if ctaC ne 0 and ctaR ne 0
                          ;;endif       ;; end for pixels with height > 2.5km                                                      ;; SRB
                       endif          ;;checking if there is data in the vertical
                    endif             ;;checking if there is data inside the boundaries of full storm  
                 endfor               ;;for going thry different pixelsum (indivdual pixels within storm)

                 ;; Rain statistics for Convective part
                 ;;get_rain_statistics,RTo_stra_NSR_ST,RTo_conv_NSR_ST,RTo_othe_NSR_ST,RTo_noRa_NSR_ST,$
                 ;;                    ctaStra_NSR_ST,ctaConv_NSR_ST,ctaOthe_NSR_ST,ctaNoRa_NSR_ST,$
                 ;;                    m_RainAll_NSR_ST,m_RainStrt_NSR_ST,m_RainConv_NSR_ST,$
                 ;;                    vol_Rain_All_NSR_ST,vol_Rain_Str_NSR_ST,vol_Rain_Con_NSR_ST,$
                 ;;                    cen_lon,cen_lat

                 total_RainAll_NSR=RTo_stra_NSR_CV+RTo_conv_NSR_CV+RTo_othe_NSR_CV+RTo_noRa_NSR_CV
                 total_RainCSs_NSR=RTo_stra_NSR_CV+RTo_conv_NSR_CV
                 m_RainAll_NSR=total_RainAll_NSR/float(ctaStra_NSR_CV+ctaConv_NSR_CV+ctaOthe_NSR_CV+ctaNoRa_NSR_CV)
                 if ctaStra_NSR_CV ne 0 then m_RainStrt_NSR=RTo_stra_NSR_CV/ctaStra_NSR_CV else m_RainStrt_NSR=0.
                 if ctaConv_NSR_CV ne 0 then m_RainConv_NSR=RTo_conv_NSR_CV/ctaConv_NSR_CV else m_RainConv_NSR=0.
                 if ctaStra_NSR_CV ne 0 or ctaConv_NSR_CV ne 0 then $
                    m_RainCSs_NSR=total_RainCSs_NSR/float(ctaStra_NSR_CV+ctaConv_NSR_CV) else m_RainCSs_NSR=-999.
                 ;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 vol_Rain_All_NSR=total_RainAll_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Str_NSR=RTo_stra_NSR_CV*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Con_NSR=RTo_conv_NSR_CV*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;mean rain, mean strat, mean convec, vol all, vol
                 ;;strat, vol conv [1e6*kg/s]
                 
                 tmp_statsRain_NSR_CV=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]

                 ;;-------------------------------------------
                 ;; CFAD count for FULL Storm - done only once
                 ;;-------------------------------------------
                 ;;if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFull then begin
                 if firstTimeThru eq 1 then begin

                    ;;cfad=lonarr(n_refls,nlevels)
                    ;;get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idF,cta_Full,npix_str,$
                    ;;         donde_BrdStr,ss,cfad
                    ;;CFAD_Full[*,*,3] = cfad
                    ;;undefine,cfad
                    
                    refl_SingleStorm=fltarr(nlonsFull,nlatsFull,nlevels)
                    refl_SingleStorm[*,*,*]=refl_3D_fillValue
                    refl_SingleStorm[w_idF]=refl_3D_FULL[w_idF]
                    if cta_Full ne npix_str[donde_Convec[ss]] then stop  ;; just to check! because this is in 3D!
                   
                    ;;here count reflectivity for each pixel that compose the storm into a matrix of CFAD
                    for i=0l,cta_Full-1l do begin  
                       col_R=where(refl_CFAD eq round(refl_3D_FULL[w_idF[i]]),ctaZ)   
                       row_H=where(alts_CFAD eq hgts_3D_FULL[w_idF[i]],ctaH)   ;;here locate the height of the pixel
                       if ctaH ne 0 and ctaZ ne 0 then $
                          if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                             CFAD_Full[col_R,row_H,2]=CFAD_Full[col_R,row_H,2]+1l else $
                                if area_CV ge thr_aCV then CFAD_Full[col_R,row_H,1]=CFAD_Full[col_R,row_H,1]+1l else $
                                   if dim_topCV ge thr_hCV then CFAD_Full[col_R,row_H,0]=CFAD_Full[col_R,row_H,0]+1l  
                    endfor
                 endif
                 ;; set these after first time through so FULL storm data not recomputed
                 ;;areaIsFULL=area & lonCIsFULL=cen_lon & latCIsFULL=cen_lat
                 firstTimeThru = 0

                 ;;-------------------------------
                 ;; CFAD count for Convective part
                 ;;-------------------------------
                 ;;cfad=lonarr(n_refls,nlevels)
                 ;;get_cfad,refl_3D_FULL,hgts_3D_FULL,nlonsFull,nlatsFull,w_idST,cta_ST,npix_ST,$
                 ;;         donde_BrdStr2,ssST,cfad
                 ;;CFAD_Core[*,*,3] = cfad
                 ;;undefine,cfad

                 refl_SingleStorm=fltarr(nlonsFull,nlatsFull,nlevels)
                 refl_SingleStorm[*,*,*]=refl_3D_fillValue
                 refl_SingleStorm[w_idCV]=refl_3D_FULL[w_idCV]
                 if cta_CV ne npix_CV[donde_Convec2[ssCV]] then stop  ;; just to check! because this is in 3D!
                
                 for i=0l,cta_CV-1 do begin  
                    col_R=where(refl_CFAD eq round(refl_3D_FULL[w_idCV[i]]),ctaZ)   
                    row_H=where(alts_CFAD eq hgts_3D_FULL[w_idCV[i]],ctaH)   ;;here locate the height of the pixel
                    if ctaH ne 0 and ctaZ ne 0 then $
                       if area_CV ge thr_aCV and dim_topCV ge thr_hCV then $
                          CFAD_Core[col_R,row_H,2]=CFAD_Core[col_R,row_H,2]+1l else $
                             if area_CV ge thr_aCV then CFAD_Core[col_R,row_H,1]=CFAD_Core[col_R,row_H,1]+1l else $
                                if dim_topCV ge thr_hCV then CFAD_Core[col_R,row_H,0]=CFAD_Core[col_R,row_H,0]+1l  
                 endfor

                 ;;----------------------------------------------------------
                 ;;store the info for monthly_class & stats_class directories
                 ;;----------------------------------------------------------
                 if area_CV ge thr_aCV and dim_topCV ge thr_hCV then begin ;;store info ;;both Convective categories
                    ;;info_DW=[info_DW,orbit+'.'+datetime+'.'+strtrim(string(s_idCV),2)]  ;;MASK MOD
                    info_DW=[info_DW,orbit+'.'+datetime+'.'+strtrim(string(num_dwc),2)]  ;;MASK MOD
                    shape_Core_DW=[[shape_Core_DW],[tmp_shapeCV]]
                    shape_Full_DW=[[shape_Full_DW],[tmp_shape]]
                    rain_Core_DW=[[rain_Core_DW],[rain_momentCV]]
                    rain_Full_DW=[[rain_Full_DW],[rain_moment]]
                    rainTypeCore_DW=[[rainTypeCore_DW],[statsRain_CV]]
                    rainTypeFull_DW=[[rainTypeFull_DW],[statsRain]]

                    rainCore_DW_NSR=[[rainCore_DW_NSR],[tmp_statsRain_NSR_CV]]
                    rainFull_DW_NSR=[[rainFull_DW_NSR],[tmp_statsRain_NSR]]
                    ;;rainCore_DW_R11=[[rainCore_DW_R11],[tmp_statsRain_R11_CV]]                                     ;; SRB
                    ;;rainFull_DW_R11=[[rainFull_DW_R11],[tmp_statsRain_R11]]                                        ;; SRB

                 endif else begin
                    if area_CV ge thr_aCV then begin   ;;store info Wide Convective Subset (Convective area2D >= thr_aCV)
                       ;;info_WC=[info_WC,orbit+'.'+datetime+'.'+strtrim(string(s_idCV),2)]  ;;MASK MOD
                       info_WC=[info_WC,orbit+'.'+datetime+'.'+strtrim(string(num_wcc),2)]  ;;MASK MOD
                       shape_Core_WC=[[shape_Core_WC],[tmp_shapeCV]]
                       shape_Full_WC=[[shape_Full_WC],[tmp_shape]]
                       rain_Core_WC=[[rain_Core_WC],[rain_momentCV]]
                       rain_Full_WC=[[rain_Full_WC],[rain_moment]]
                       rainTypeCore_WC=[[rainTypeCore_WC],[statsRain_CV]]
                       rainTypeFull_WC=[[rainTypeFull_WC],[statsRain]]
                             
                       rainCore_WC_NSR=[[rainCore_WC_NSR],[tmp_statsRain_NSR_CV]]
                       rainFull_WC_NSR=[[rainFull_WC_NSR],[tmp_statsRain_NSR]]
                       ;;rainCore_WC_R11=[[rainCore_WC_R11],[tmp_statsRain_R11_CV]]                                  ;; SRB
                       ;;rainFull_WC_R11=[[rainFull_WC_R11],[tmp_statsRain_R11]]                                     ;; SRB

                    endif else begin
                       if dim_topCV ge thr_hCV then begin ;;store info Deep Convective Subset (Convective hgt >= thr_hCV)
                          
                          ;;info_DC=[info_DC,orbit+'.'+datetime+'.'+strtrim(string(s_idCV),2)]  ;;MASK MOD
                          info_DC=[info_DC,orbit+'.'+datetime+'.'+strtrim(string(num_dcc),2)]  ;;MASK MOD
                          shape_Core_DC=[[shape_Core_DC],[tmp_shapeCV]]
                          shape_Full_DC=[[shape_Full_DC],[tmp_shape]]
                          rain_Core_DC=[[rain_Core_DC],[rain_momentCV]]
                          rain_Full_DC=[[rain_Full_DC],[rain_moment]]
                          rainTypeCore_DC=[[rainTypeCore_DC],[statsRain_CV]]
                          rainTypeFull_DC=[[rainTypeFull_DC],[statsRain]]
                          
                          rainCore_DC_NSR=[[rainCore_DC_NSR],[tmp_statsRain_NSR_CV]]
                          rainFull_DC_NSR=[[rainFull_DC_NSR],[tmp_statsRain_NSR]]
                          ;;rainCore_DC_R11=[[rainCore_DC_R11],[tmp_statsRain_R11_CV]]                               ;; SRB
                          ;;rainFull_DC_R11=[[rainFull_DC_R11],[tmp_statsRain_R11]]                                  ;; SRB

                       endif
                    endelse
                 endelse
                 undefine,dim_lonCV
                 undefine,dim_latCV
                 undefine,hgt_sumCV
                 undefine,grid_sum
                 ;;undefine,storm_mask_sub ;;new
                 undefine,donde
                 undefine,pixelsum
                 ;;undefine,lon_sum
                 ;;undefine,lat_sum
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
              
           endfor      ;;endfor loop through analyzed storms clusters that maybe are deep-wide convective
           
           undefine,grid_CV
           undefine,npix_CV
           undefine,id_CV
           undefine,searchNaN_CV
           undefine,donde_Convec2
           
        endif      ;;endif for convective areas that could be matching the theresholds
        
        ;;undefine,total_lonFull
        undefine,d_lonsFull
        ;;undefine,total_latFull
        undefine,d_latsFull
        ;;undefine,singlestormgrid ;;new
        undefine,singlestormgrid_Full
        undefine,lonsFull_sub
        undefine,latsFull_sub
        undefine,singlestormgridConvective
        ;;undefine,grid_sumCV
        ;;undefine,dondeCV
        ;;undefine,s_idF
        undefine,w_idF
        
     endfor            ;;endfor loop thru convective volumes greater than 25 pixels
     
  endif                ;;end if the orbit does have convective and reflec > 0 ==>raining
  
end
