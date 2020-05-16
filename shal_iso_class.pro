pro shal_iso_class,id_storm,npix_str,grid_storm,num_storm

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

  ;;include constants
  @constants_ocean.pro

  ;; initialize num_shi
  ;;num_shi = 0

  ;;here it is going to identify shallow convective part
  if cta_ShIs ne 0 then begin ;;here analyze only when shallow pixels exist
     ;;here I only choose shallow convective volumes with more than 2 pixels (same as for DCC-WCC)
     donde_shallow=where(npix_str ge 2l,ctaShallow)
           
     for ss=0l,ctaShallow-1 do begin 
        s_idF=id_storm[donde_shallow[ss]]
        w_idF=where(grid_storm eq s_idF,cta1)
        if cta1 ne npix_str[donde_shallow[ss]] then stop  ;; just to check!
        singlestormgrid=lonarr(nlons,nlats,nlevels)
        singlestormgrid[w_idF]=s_idF

        ;;Here I will subset the singleFULL storm found to reduce the size of the matrix
        total_lonFull=total(total(singlestormgrid,2),2) 
        d_lonsFull=where(total_lonFull gt 0l,nlonsFull) ;;this are the horizontal positions within a selcted contiguous area
        total_latFull=total(total(singlestormgrid,1),2) 
        d_latsFull=where(total_latFull gt 0l,nlatsFull)
         
        singlestormgrid_Full=lonarr(nlonsFull,nlatsFull,nlevels)
        singlestormgrid_Full=singlestormgrid[d_lonsFull,d_latsFull,*]
        w_idF=where(singlestormgrid_Full eq s_idF,cta_Full)
        lonsFull_sub=lons[d_lonsFull]
        latsFull_sub=lats[d_latsFull]
         
        undefine,singlestormgrid
         
        ;;Identify the Shallow pixels in storm (refl >= 0 and All shallow convectve pixels)
        singlestormgridShallow=singlestormgrid_Full
        singlestormgridShallow[where(refl_3D[d_lonsFull,d_latsFull,*]  lt 0.)]=0l
        singlestormgridShallow[where(rain_type3D[d_lonsFull,d_latsFull,*] ne SHIS)]=0l   ;;everything but shallow ==0l
               
        ;;2D horizontal array of number of Shallow pixels within storm
        grid_sumSH=total(singlestormgridShallow,3) 
        dondeSH=where(grid_sumSH gt 0,pixelsumSH) ;;pixelsum=number of pixels in a 2D proj
        
        if pixelsumSH ge 2 then begin  ;;shallow conv volumes with more than 2 pixels (to avoid smaller areas)
           lonSH=total(total(singlestormgridShallow,2),2) 
           lon_SH=(max(lonsFull_sub[where(lonSH gt 0l)])+min(lonsFull_sub[where(lonSH gt 0l)]))/2. ;;center of Shallow

           latSH=total(total(singlestormgridShallow,1),2) 
           lat_SH=(max(latsFull_sub[where(latSH gt 0l)])+min(latsFull_sub[where(latSH gt 0l)]))/2. ;;center of Shallow

           size_pixels=deg2km(pixDeg,lon_SH,lat_SH)
           area_SH=pixelsumSH*(size_pixels[0]*size_pixels[1]) ;;stratiform area in km  
        endif else begin
           area_SH=0.                                 ;;to avoid regions with two few pixels togheter
           size_pixels=[pixKm,pixKm]                  ;; this is set so next if loop not entered when area=0
        endelse

        ;;This is original way; new way more restrictive (pixArea*2 =60.5)        ;; SRB
        ;;if area_Sh gt 40. then begin ;;  ~30km2 is the size of a single pixel (Avoid single pixels!)
        if area_Sh ge (2*(size_pixels[0]*size_pixels[1])) then begin ;;  Avoid single pixels
           ;;if area_Sh ge (pixArea*2) then begin ;;  pixArea (~30km2) is the size of a single pixel (Avoid single pixels!)
           ;;Does the shallow isolated area belongs to a single storm? (acomplish contiguous pixel condition)
           ;;Again, uses the shallow pixels to identify contiguous pixels
           findStormNew,refl_3D=singlestormgridShallow,$
                        ;;refl_3D_fillValue=refl_3D_fillValue,$
                        id_storm=id_SH,$
                        npix_str=npix_SH,$
                        grid_storm=grid_SH
           searchNaN_SH=where(grid_SH lt 0, nanCnt)
           if nanCnt gt 0 then grid_SH[searchNaN_SH]=0l ;;%set NaNs to zero in the  grid matrix 
        
           ;;identify only volumes with more than 4 pixels - THIS DOESN'T MAKE SENSE  ;;SRB
           donde_Shallow2=where(npix_SH ge 2l,ctaShallow2) ;;permiting to have 2 contiguous pixels of greater
                    
           areaIsFULL=0. & lonCIsFULL=0. & latCIsFull=0. ;;this is to locate only ONE full storm
                    
           for ssSH=0,ctaShallow2-1 do begin ;;only goes thru volumes greater than 2 pixels (speed the process)
              s_id_SH=id_SH[donde_Shallow2[ssSH]]
              w_id_SH=where(grid_SH eq s_id_SH,cta1_SH)
              if cta1_SH ne npix_SH[donde_Shallow2[ssSH]] then stop  ;; just to check!

              singlestormgrid_SH=lonarr(nlonsFull,nlatsFull,nlevels)
              singlestormgrid_SH[w_id_SH]=s_id_SH
              
              ;;2D horizontal array of number of Shallow pixels within storm
              grid_sum_SH_SH=total(singlestormgrid_SH,3) 
              dondeSH_SH=where(grid_sum_SH_SH gt 0,pixelsumSH_SH) ;;pixelsum=number of pixels in a 2D proj
               
              ;; this is going to be done because the calculation of rain and LH for ALL-Events is done considering
              ;; 2 horizontal pixels or more!!
              if pixelsumSH_SH ge 2 then begin
                 lonSH=total(total(singlestormgrid_SH,2),2) 
                 lonC_SH=(max(lonsFull_sub[where(lonSH gt 0l)])+min(lonsFull_sub[where(lonSH gt 0l)]))/2. ;;center of Shallow
                 
                 latSH=total(total(singlestormgrid_SH,1),2) 
                 latC_SH=(max(latsFull_sub[where(latSH gt 0l)])+min(latsFull_sub[where(latSH gt 0l)]))/2. ;;center of Shallow
                 
                 size_pixels=deg2km(pixDeg,lonC_SH,latC_SH)
                 area_SH=pixelsumSH_SH*(size_pixels[0]*size_pixels[1]) ;;Broad Shallow area in km  
              endif else begin
                 area_SH=0.
                 size_pixels=[pixKm,pixKm]  ;; this is set so next if loop not entered when area=0
              endelse 
                       
              ;;now it tries to identify the real Shallow contiguous area
              ;;if area_SH ge 30. then begin ;; This is original way        ;; SRB
              ;; ----------------- SRB Why does this test use 30 & above uses 40 --------------------------
              if area_SH ge (2*(size_pixels[0]*size_pixels[1])) then begin ;; area of one pixel is pixArea (~30km^2)
                 ;;if area_SH ge (pixArea*2) then begin ;; area of one pixel is pixArea (~30km^2)                          
                 ;;calculate the dimensions for Shallow pixels in the cluster
                 ;;******************************************************************************************
                 dim_lonSH=(max(lonsFull_sub[where(lonSH gt 0l)])-min(lonsFull_sub[where(lonSH gt 0l)]))+pixDeg
                 dim_latSH=(max(latsFull_sub[where(latSH gt 0l)])-min(latsFull_sub[where(latSH gt 0l)]))+pixDeg

                 hgt_sumSH=total(total(singlestormgrid_SH,2),1)
                 dim_hgtSH=max(hgts[where(hgt_sumSH gt 0l)])-min(hgts[where(hgt_sumSH gt 0l)])
                 dim_topSH=max(hgts[where(hgt_sumSH gt 0l)])                                   ;;###############
                 dim_botSH=min(hgts[where(hgt_sumSH gt 0l)])                                   ;;###############
                
                 ;;calculates the elevation of the terrain for the center of the storm  !21
                 id_top1=(where(topo_lon ge lonC_SH))[0] & id_top2=(where(topo_lat ge latC_SH))[0]
                 terr_hgtSH=DEM[id_top1,id_top2]                                     ;;elevation in meters
                 if terr_hgtSH eq 0 then land_oceanSH=0 else land_oceanSH=1          ;;ocean=0 or land=1!

                 tmp_shapeSH=[lonC_SH,latC_SH,area_SH,dim_topSH,dim_botSH,dim_lonSH,dim_latSH,terr_hgtSH,land_oceanSH]
                 
                 ;;num_shi = num_shi++
                 ;;;; add storm id to shi_mask if makeCoreMasks is set         
                 ;;if makeCoreMasks then begin
                 ;;   shi_mask_sub = shi_mask[d_lonsFull,d_latsFull,0]
                 ;;   shi_mask_sub[dondeSH_SH]=num_shi
                 ;;   shi_mask[d_lonsFull,d_latsFull,0] = shi_mask_sub
                 ;;   undefine,shi_mask_sub
                 ;;endif
                          
                 ;;now it calculate the dimensions for full storm (all pixels in the cluster)
                 ;;******************************************************************************************
                 grid_sum=total(singlestormgrid_Full,3)       ;;2D horiz array of number of all pixels within storm
                 donde=where(grid_sum gt 0,pixelsum)          ;;pixelsum=number of pixels in a 2D proj
                
                 lon_sum=total(total(singlestormgrid_Full,2),2)   
                 cen_lon=(max(lonsFull_sub[where(lon_sum gt 0l)])+min(lonsFull_sub[where(lon_sum gt 0l)]))/2.              ;;longitude coordinate
                 dim_lon=(max(lonsFull_sub[where(lon_sum gt 0l)])-min(lonsFull_sub[where(lon_sum gt 0l)]))+pixDeg          ;;longitudinal extents
                
                 lat_sum=total(total(singlestormgrid_Full,1),2)   
                 cen_lat=(max(latsFull_sub[where(lat_sum gt 0l)])+min(latsFull_sub[where(lat_sum gt 0l)]))/2.              ;;latitude coordinate
                 dim_lat=(max(latsFull_sub[where(lat_sum gt 0l)])-min(latsFull_sub[where(lat_sum gt 0l)]))+pixDeg          ;;latitudinal extents
                
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 area=pixelsum*size_pixels[0]*size_pixels[1] ;;in km horizontal area of selected storm
                
                 hgt_sum=total(total(singlestormgrid_Full,2),1)
                 dim_hgt=(max(hgts[where(hgt_sum gt 0l)])-min(hgts[where(hgt_sum gt 0l)])) ;;%vertical extent in km
                 dim_top=max(hgts[where(hgt_sum gt 0l)])                                   ;;###############          
                 dim_bot=min(hgts[where(hgt_sum gt 0l)])                                   ;;###############
                
                 ;;%calculates the elevation of the terrain for the center of the storm  !21
                 id_top1=(where(topo_lon ge cen_lon))[0] & id_top2=(where(topo_lat ge cen_lat))[0]
                 terr_hgt=DEM[id_top1,id_top2]                                 ;;elevation in meters
                 if terr_hgt eq 0 then land_ocean=0 else land_ocean=1          ;;mask  ocean=0 or land=1!

                 tmp_shape=[cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean]

                 ;;******************************************************************************************
                 ;;Statistics for rain types and rain rates *************************************************
                 ;;Statistics over Convective subset!
                 SrfRain_FULL=SrfRain[d_lonsFull,d_latsFull,*]
                 raintypeFULL=raintype[d_lonsFull,d_latsFull,*]
                 refl_3D_FULL=refl_3D[d_lonsFull,d_latsFull,*]
                 hgts_3D_FULL=hgts_3D[d_lonsFull,d_latsFull,*]

                 stratconv=raintypeFULL[dondeSH_SH]                              ;;type of rain in each 2D pixel that compose the storm
                 strats=where(stratconv eq STRA,ctaStr)                          ;;stratiform
                 convec=where(stratconv eq CONV,ctaCon)                          ;;convective
                 others=where(stratconv ge OTHER,ctaOth)                         ;;other type
                 noRain=where(stratconv eq raintype_noRainValue,ctaNoR)          ;;no rain
                 missin=where(stratconv eq raintype_fillValue,ctaMis)            ;;missing value

                 rainSH=SrfRain_FULL[dondeSH_SH] ;;this is based on Near Surface Rain
                 rain_nomiss=where(rainSH ne -9999.,Rmiss)
                          
                 ;;here I calculate moments of simple rain within storm
                 if Rmiss ge 2 then rain_momentSH=[mean(rainSH[rain_nomiss]),stdev(rainSH[rain_nomiss]),$
                                                   max(rainSH[rain_nomiss]),min(rainSH[rain_nomiss]),float(Rmiss), $
                                                   float(ctaStr),float(ctaCon)] $
                 else rain_momentSH=[-9999.,-9999.,-9999.,-9999.,-9999.,-9999.,-9999.]
                 
                 ;;here I calculate rainrate sums in [mm/hr]
                 if ctaStr ne 0 then RTo_stra=total(rainSH[strats]) else RTo_stra=0.          ;;total stratiform rain
                 if ctaCon ne 0 then RTo_conv=total(rainSH[convec]) else RTo_conv=0.          ;;total convective rain
                 if ctaOth ne 0 then RTo_othe=total(rainSH[others]) else RTo_othe=0.          ;;total other rain
                 if ctaNoR ne 0 then RTo_noRa=total(rainSH[noRain]) else RTo_noRa=0.          ;;total no_rain rain
                 total_RainAll=RTo_stra+RTo_conv+RTo_othe+RTo_noRa
                 total_RainCSs=RTo_stra+RTo_conv

                 m_RainAll=total_RainAll/(ctaStr+ctaCon+ctaOth+ctaNoR+ctaMis)               ;;mean rainfall all pixels
                 if ctaStr ne 0 then m_RainStrt=RTo_stra/ctaStr else m_RainStrt=0.          ;;mean stratiform rain
                 if ctaCon ne 0 then m_RainConv=RTo_conv/ctaCon else m_RainConv=0.          ;;mean convective rain
                 if ctaStr ne 0 or ctaCon ne 0 then m_RainCSs=total_RainCSs/(ctaStr+ctaCon) $
                 else m_RainCSs=-999.
                
                 ;;here calculate volumetric values of rain  ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,lonC_SH,latC_SH)
                 vol_Rain_All=total_RainAll*(size_pixels[0]*size_pixels[1])/secsPerHr  
                 vol_Rain_Str=RTo_stra*(size_pixels[0]*size_pixels[1])/secsPerHr 
                 vol_Rain_Con=RTo_conv*(size_pixels[0]*size_pixels[1])/secsPerHr
   
                 ;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 statsRain_SH=[m_RainAll,m_RainStrt,m_RainConv,vol_Rain_All,vol_Rain_Str,vol_Rain_Con]

                 ;;Satisitics for rain types and rain rates **********************************************
                 ;;***************************************************************************************
                 stratconv=raintypeFULL[donde]                                   ;;type of rain in each 2D pixel that compose the storm
                 strats=where(stratconv eq STRA,ctaStr)                          ;;stratiform
                 convec=where(stratconv eq CONV,ctaCon)                          ;;convective
                 others=where(stratconv ge OTHER,ctaOth)                         ;;other type  Including shallow rain!
                 noRain=where(stratconv eq raintype_noRainValue,ctaNoR)          ;;no rain
                 missin=where(stratconv eq raintype_fillValue,ctaMis)            ;;missing value
                          
                 rain=SrfRain_FULL[donde] ;;this is based on Near Surface Rain
                 rain_nomiss=where(rain ne SrfRain_fillValue,Rmiss)

                 ;;here I calculate moments of simple rain within storm
                 if Rmiss ge 2 then rain_moment=[mean(rain[rain_nomiss]),stdev(rain[rain_nomiss]),$
                                                 max(rain[rain_nomiss]),min(rain[rain_nomiss]),float(Rmiss), $
                                                 float(ctaStr),float(ctaCon)] $
                 else rain_moment=[-9999.,-9999.,-9999.,-9999.,-9999.,-9999.,-9999.]
                 
                 ;;here I calculate rainrate sums in [mm/hr]
                 if ctaStr ne 0 then RTo_stra=total(rain[strats]) else RTo_stra=0.          ;;total stratiform rain
                 if ctaCon ne 0 then RTo_conv=total(rain[convec]) else RTo_conv=0.          ;;total convective rain
                 if ctaOth ne 0 then RTo_othe=total(rain[others]) else RTo_othe=0.          ;;total other rain
                 if ctaNoR ne 0 then RTo_noRa=total(rain[noRain]) else RTo_noRa=0.          ;;total no_rain rain
                 total_RainAll=RTo_stra+RTo_conv+RTo_othe+RTo_noRa
                 total_RainCSs=RTo_stra+RTo_conv
                  
                 m_RainAll=total_RainAll/(ctaStr+ctaCon+ctaOth+ctaNoR+ctaMis)               ;;mean rainfall all pixels
                 if ctaStr ne 0 then m_RainStrt=RTo_stra/ctaStr else m_RainStrt=0.          ;;mean stratiform rain
                 if ctaCon ne 0 then m_RainConv=RTo_conv/ctaCon else m_RainConv=0.          ;;mean convective rain
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

                 ;;**********************************************************************************************
                 grid_storm_FULL=lonarr(nlonsFull,nlatsFull,nlevels)
                 grid_storm_FULL=grid_storm[d_lonsFull,d_latsFull,*]
                 
                 ;;----------------------------------------------------------------------------------------------
                 ;;MOVED THIS CODE INTO IF LOOP WHERE IT NEEDS TO BE TO GET RID OF NaN OUTPUTS
                 ;;Statistics for rain rates Calculated using Z-R method 
                 ;;we need to get all the needed information for the lowest pixels in each storm
                 ;;locate the indices of the lowest pixels with data   (Full Storm) (Romatschke and Houze 2011
                 ;;;;RTo_conv_R11=0. & ctaConv_R11=0l   ;;total convective rain              ;; SRB
                 ;;;;RTo_stra_R11=0. & ctaStra_R11=0l   ;;total stratiform rain              ;; SRB
                 ;;;;RTo_othe_R11=0. & ctaOthe_R11=0l   ;;total other rain                   ;; SRB
                 ;;;;RTo_noRa_R11=0. & ctaNoRa_R11=0l   ;;total no_rain rain                 ;; SRB
                  
                 ;;Near Surface Rain
                 RTo_conv_NSR=0. & ctaConv_NSR=0l          ;;total convective rain
                 RTo_stra_NSR=0. & ctaStra_NSR=0l          ;;total stratiform rain
                 RTo_othe_NSR=0. & ctaOthe_NSR=0l          ;;total other rain
                 RTo_noRa_NSR=0. & ctaNoRa_NSR=0l          ;;total no_rain rain
                 ;;----------------------------------------------------------------------------------------------

                 ;;print,'BEFORE STORM CALCS: ss=',string(strtrim(ss,2)),' and ssSH=',string(strtrim(ssSH,2)), $
                 ;;      ' and area=',string(strtrim(area,2)),' and areaIsFULL=',string(strtrim(areaIsFULL,2))

                 ;;here also is accounted n_pixels in matrix matching with storm location and locate indices (lowest pixels           
                 ;;this is only evaluated ONCE! (accouting for a single FULL storm)
                 if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFull then begin
                             
                    ;;print,'     RUNNING THROUGH CALCS FOR STORM - SHOULD BE ONLY ONCE'
                    
                    ;;Statistics for rain rates Calculated using Z-R method 
                    ;;we need to get all the needed information for the lowest pixels in each storm
                    ;;locate the indices of the lowest pixels with data   (Full Storm) (Romatschke and Houze 2011
                    ;;RTo_conv_R11=0. & ctaConv_R11=0l   ;;total convective rain              ;; SRB
                    ;;RTo_stra_R11=0. & ctaStra_R11=0l   ;;total stratiform rain              ;; SRB
                    ;;RTo_othe_R11=0. & ctaOthe_R11=0l   ;;total other rain                   ;; SRB
                    ;;RTo_noRa_R11=0. & ctaNoRa_R11=0l   ;;total no_rain rain                 ;; SRB
                    
                    ;;Near Surface Rain
                    RTo_conv_NSR=0. & ctaConv_NSR=0l          ;;total convective rain
                    RTo_stra_NSR=0. & ctaStra_NSR=0l          ;;total stratiform rain
                    RTo_othe_NSR=0. & ctaOthe_NSR=0l          ;;total other rain
                    RTo_noRa_NSR=0. & ctaNoRa_NSR=0l          ;;total no_rain rain

                    for i=0l,pixelsum-1l do begin
                       col=donde[i] mod nlonsFull                        ;;column ID of the pixel
                       fil=long(fix(donde[i]/float(nlonsFull)))          ;;row    ID of the pixel
                                
                       nearSrfR_Org=SrfRain_FULL[col,fil]
                                
                       t_col=where(lonsC le lonsFull_sub[col],ctaC) ;;count the pixels
                       t_row=where(latsC le latsFull_sub[fil],ctaR) 
                       if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                          colCV=(reverse(t_col))[0] 
                          rowCV=(reverse(t_row))[0] 
                          freq_Full[colCV,rowCV,4]=freq_Full[colCV,rowCV,4]+1l 
                                   
                          ;;locate indices (x,y,z location of individual pixels within the FULL storm)
                          pila=reform(grid_storm_FULL[col,fil,*])
                          w_CV=where(pila ne 0,ctaHgt)
                          if ctaHgt ge 1 then begin 
                             ;;distance between lowest pixel and ground
                             id_top1=(where(topo_lon ge lonsFull_sub[col]))[0]
                             id_top2=(where(topo_lat ge latsFull_sub[fil]))[0]
                                      
                             ;;%we sort out all the pixels that are higher than 2.5km above the ground
                             ;;if (hgts[w_CV[0]]-float(DEM[id_top1,id_top2])/1000.) le 2.5 then begin                   ;; SRB
                             ;;locate the pixel in the nearest fine grid cell
                             tmp_col=(where(float(lonsF) eq lonsFull_sub[col],ctaC))[0]
                             tmp_row=(where(float(latsF) eq latsFull_sub[fil],ctaR))[0]
                               
                             if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                                ;;if ctaC eq 0 or ctaR eq 0 then stop
                                
                                ;;if nearSrfR_Org ne -9999.00 and refl_3D_FULL[col,fil,w_CV[0]] ne -999.0 then begin   ;; SRB
                                if nearSrfR_Org ne SrfRain_fillValue then begin
                                   ;;reflectivZ=10^(refl_3D_FULL[col,fil,w_CV[0]]*0.1)  ;;%convert from dBZ to Z
                                  
                                   ;;here I create accumulated matrices with rain rate Near Surf Rain
                                   rain_NSRFull[tmp_col,tmp_row,4]=rain_NSRFull[tmp_col,tmp_row,4]+nearSrfR_Org
                                   nRai_NSRFull[tmp_col,tmp_row,4]=nRai_NSRFull[tmp_col,tmp_row,4]+1l
                                  
                                   ;;here I create accumulated rain rate vectors with R11 method
                                   if raintypeFULL[col,fil] eq CONV then begin ;;convective rain
                                      RTo_conv_NSR=RTo_conv_NSR+nearSrfR_Org                     &  ctaConv_NSR=ctaConv_NSR+1l
                                      ;;RTo_conv_R11=RTo_conv_R11+(reflectivZ/aRRc)^(1/bRRc)       &  ctaConv_R11=ctaConv_R11+1l ;; SRB

                                      ;;tmp_rain=(reflectivZ/aRRc)^(1/bRRc)                                                      ;; SRB
                                      ;;rain_R11Full[tmp_col,tmp_row,4]=rain_R11Full[tmp_col,tmp_row,4]+tmp_rain                 ;; SRB
                                      ;;nRai_R11Full[tmp_col,tmp_row,4]=nRai_R11Full[tmp_col,tmp_row,4]+1l                       ;; SRB
                                   endif else begin
                                      if raintypeFULL[col,fil] eq STRA then begin ;;stratiform rain
                                         RTo_stra_NSR=RTo_stra_NSR+nearSrfR_Org                  &  ctaStra_NSR=ctaStra_NSR+1l
                                         ;;RTo_stra_R11=RTo_stra_R11+(reflectivZ/aRRs)^(1/bRRs)    &  ctaStra_R11=ctaStra_R11+1l ;; SRB

                                         ;;tmp_rain=(reflectivZ/aRRs)^(1/bRRs)                                                   ;; SRB
                                         ;;rain_R11Full[tmp_col,tmp_row,4]=rain_R11Full[tmp_col,tmp_row,4]+tmp_rain              ;; SRB
                                         ;;nRai_R11Full[tmp_col,tmp_row,4]=nRai_R11Full[tmp_col,tmp_row,4]+1l                    ;; SRB
                                      endif else begin
                                         if raintypeFULL[col,fil] ge OTHER then begin ;;other rain
                                            RTo_othe_NSR=RTo_othe_NSR+nearSrfR_Org               &  ctaOthe_NSR=ctaOthe_NSR+1l
                                            ;;RTo_othe_R11=RTo_othe_R11+(reflectivZ/aRR)^(1/bRR)   &  ctaOthe_R11=ctaOthe_R11+1l ;; SRB

                                            ;;tmp_rain=(reflectivZ/aRR)^(1/bRR)                                                  ;; SRB
                                            ;;rain_R11Full[tmp_col,tmp_row,4]=rain_R11Full[tmp_col,tmp_row,4]+tmp_rain           ;; SRB
                                            ;;nRai_R11Full[tmp_col,tmp_row,4]=nRai_R11Full[tmp_col,tmp_row,4]+1l                 ;; SRB
                                         endif else begin
                                            if raintype[col,fil] eq raintype_noRainValue then begin ;;No rain
                                               RTo_noRa_NSR=RTo_noRa_NSR+0.   &   ctaNoRa_NSR=ctaNoRa_NSR+1l
                                               ;;RTo_noRa_R11=RTo_noRa_R11+0.   &   ctaNoRa_R11=ctaNoRa_R11+1l                   ;; SRB

                                               ;;rain_R11Full[tmp_col,tmp_row,4]=rain_R11Full[tmp_col,tmp_row,4]+0               ;; SRB
                                               ;;nRai_R11Full[tmp_col,tmp_row,4]=nRai_R11Full[tmp_col,tmp_row,4]+1l              ;; SRB
                                            endif
                                         endelse
                                      endelse
                                   endelse
                                endif          ;; end for missing values....
                             endif             ;; if ctaC ne 0 and ctaR ne 0
                             ;;endif       ;; end for pixels with height > 2.5km
                          endif
                       endif
                    endfor
                 endif  ;;end for flag of accounting for a single FULL storm...
                       
                 ;;print,'AT BOTTOM OF STORM CALCS: ss=',string(strtrim(ss,2)),' and ssSH=',string(strtrim(ssSH,2)), $
                 ;;      ' and area=',string(strtrim(area,2)),' and areaIsFull=',string(strtrim(areaIsFull,2))
                 ;;;;print,'     ctaStra_R11=',string(strtrim(ctaStra_R11,2)),' and ctaConv_R11=',string(strtrim(ctaConv_R11,2)), $
                 ;;;;     ' ctaOthe_R11=',string(strtrim(ctaOthe_R11,2)),' ctaNoRa_R11=',string(strtrim(ctaNoRa_R11,2))
                 ;;print,'     ctaStra_NSR=',string(strtrim(ctaStra_NSR,2)),' and ctaConv_NSR=',string(strtrim(ctaConv_NSR,2)), $
                 ;;      ' ctaOthe_NSR=',string(strtrim(ctaOthe_NSR,2)),' ctaNoRa_NSR=',string(strtrim(ctaNoRa_NSR,2))
                       
                 ;;************************************************************************************************************
                 ;;;;Romatschke and Houze 2011
                 ;;total_RainAll_R11=RTo_stra_R11+RTo_conv_R11+RTo_othe_R11+RTo_noRa_R11
                 ;;total_RainCSs_R11=RTo_stra_R11+RTo_conv_R11
                 ;;m_RainAll_R11=total_RainAll_R11/float(ctaStra_R11+ctaConv_R11+ctaOthe_R11+ctaNoRa_R11) ;;mean rainfall for all pixels
                 ;;if ctaStra_R11 ne 0 then m_RainStrt_R11=RTo_stra_R11/ctaStra_R11 else m_RainStrt_R11=0. ;;mean stratiform rain
                 ;;if ctaConv_R11 ne 0 then m_RainConv_R11=RTo_conv_R11/ctaConv_R11 else m_RainConv_R11=0. ;;mean convective rain
                 ;;if ctaStra_R11 ne 0 or ctaConv_R11 ne 0 then $
                 ;;   m_RainCSs_R11=total_RainCSs_R11/float(ctaStra_R11+ctaConv_R11) else m_RainCSs_R11=-999.
                 ;;;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 ;;size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 ;;vol_Rain_All_R11=total_RainAll_R11*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;vol_Rain_Str_R11=RTo_stra_R11*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;vol_Rain_Con_R11=RTo_conv_R11*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 ;;tmp_statsRain_R11=[m_RainAll_R11,m_RainStrt_R11,m_RainConv_R11,vol_Rain_All_R11,vol_Rain_Str_R11,vol_Rain_Con_R11]
                       
                 ;;************************************************************************************************************
                 ;;Near Surface Rain
                 total_RainAll_NSR=RTo_stra_NSR+RTo_conv_NSR+RTo_othe_NSR+RTo_noRa_NSR
                 total_RainCSs_NSR=RTo_stra_NSR+RTo_conv_NSR
                 m_RainAll_NSR=total_RainAll_NSR/float(ctaStra_NSR+ctaConv_NSR+ctaOthe_NSR+ctaNoRa_NSR)           ;;mean rainfall for all pixels
                 if ctaStra_NSR ne 0 then m_RainStrt_NSR=RTo_stra_NSR/ctaStra_NSR else m_RainStrt_NSR=0.          ;;mean stratiform rain
                 if ctaConv_NSR ne 0 then m_RainConv_NSR=RTo_conv_NSR/ctaConv_NSR else m_RainConv_NSR=0.          ;;mean convective rain
                 if ctaStra_NSR ne 0 or ctaConv_NSR ne 0 then $
                    m_RainCSs_NSR=total_RainCSs_NSR/float(ctaStra_NSR+ctaConv_NSR) else m_RainCSs_NSR=-999.
                 ;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 vol_Rain_All_NSR=total_RainAll_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Str_NSR=RTo_stra_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Con_NSR=RTo_conv_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 tmp_statsRain_NSR=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]

                 ;;*********************************************************************************************
                 ;;Now only for the Convective Core
                 ;;*******************************************************************************************
                 ;; ADDED _SH TO THESE VAR NAMES FOR CLARITY  ;; SRB 8/3/2018
                 ;; Z-R Method
                 ;;RTo_conv_R11_SH=0. & ctaConv_R11_SH=0l ;;total convective rain
                 ;;RTo_stra_R11_SH=0. & ctaStra_R11_SH=0l ;;total stratiform rain
                 ;;RTo_othe_R11_SH=0. & ctaOthe_R11_SH=0l ;;total other rain
                 ;;RTo_noRa_R11_SH=0. & ctaNoRa_R11_SH=0l ;;total no_rain rain

                 ;; ADDED _SH TO THESE VAR NAMES FOR CLARITY  ;; SRB 8/3/2018
                 ;; Near Surface Rain
                 RTo_conv_NSR_SH=0. & ctaConv_NSR_SH=0l          ;;total convective rain
                 RTo_stra_NSR_SH=0. & ctaStra_NSR_SH=0l          ;;total stratiform rain
                 RTo_othe_NSR_SH=0. & ctaOthe_NSR_SH=0l          ;;total other rain
                 RTo_noRa_NSR_SH=0. & ctaNoRa_NSR_SH=0l          ;;total no_rain rain

                 ;;Count pixels in matrix matching with storm location and locate indices (CORE STORM)
                 for i=0l,pixelsumSH_SH-1l do begin   
                    col=dondeSH_SH[i] mod nlonsFull                        ;;column ID of the pixel
                    fil=long(fix(dondeSH_SH[i]/float(nlonsFull)))          ;;row    ID of the pixel
                   
                    nearSrfR_Org=SrfRain_FULL[col,fil]
 
                    t_col=where(lonsC le lonsFull_sub[col],ctaC) ;;count the pixels
                    t_row=where(latsC le latsFull_sub[fil],ctaR) 
                    if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                       colCV=(reverse(t_col))[0] 
                       rowCV=(reverse(t_row))[0]  

                       freq_Core[colCV,rowCV,4]=freq_Core[colCV,rowCV,4]+1l
                       
                       ;;locate indices (x,y,z location of individual pixels within the Convective storm)
                       pila=reform(grid_storm_FULL[col,fil,*]) ;;Matching the location within the full storm containing the core
                       w_CV=where(pila ne 0,ctaHgt)
                       if ctaHgt ge 1 then begin 
                          ;;distance between lowest pixel and ground
                          id_top1=(where(topo_lon ge lonsFull_sub[col]))[0]
                          id_top2=(where(topo_lat ge latsFull_sub[fil]))[0]
 
                          ;;%we sort out all the pixels that are higher than 2.5km above the ground
                          ;;if (hgts[w_CV[0]]-float(DEM[id_top1,id_top2])/1000.) le 2.5 then begin                                 ;; SRB 

                          ;;locate the pixel in the nearest fine grid cell
                          tmp_col=(where(float(lonsF) eq lonsFull_sub[col],ctaC))[0]
                          tmp_row=(where(float(latsF) eq latsFull_sub[fil],ctaR))[0]
                            
                          if ctaC ne 0 and ctaR ne 0 then begin ;;just to make sure pixel located within boundaries
                             ;;if ctaC eq 0 or ctaR eq 0 then stop
                            
                             ;;if nearSrfR_Org ne -9999.00 and refl_3D_FULL[col,fil,w_CV[0]] ne -999.0 then begin                  ;; SRB
                             if nearSrfR_Org ne SrfRain_fillValue then begin
                                ;;reflectivZ=10^(refl_3D_FULL[col,fil,w_CV[0]]*0.1)  ;;%convert from dBZ to Z                      ;; SRB
                               
                                ;;here I create accumulated matrices with rain rate for shallow Near Surf Rain
                                rain_NSRCore[tmp_col,tmp_row,4]=rain_NSRCore[tmp_col,tmp_row,4]+nearSrfR_Org
                                nRai_NSRCore[tmp_col,tmp_row,4]=nRai_NSRCore[tmp_col,tmp_row,4]+1l

                                ;;here I create accumulated rain rate vectors
                                if raintypeFULL[col,fil] eq CONV then begin ;;convective rain
                                   RTo_conv_NSR_SH=RTo_conv_NSR_SH+nearSrfR_Org                     &  ctaConv_NSR_SH=ctaConv_NSR_SH+1l
                                   ;;RTo_conv_R11_SH=RTo_conv_R11_SH+(reflectivZ/aRRc)^(1/bRRc)       &  ctaConv_R11_SH=ctaConv_R11_SH+1l      ;; SRB

                                   ;;tmp_rain=(reflectivZ/aRRc)^(1/bRRc)                                                           ;; SRB
                                   ;;rain_R11Core[tmp_col,tmp_row,4]=rain_R11Core[tmp_col,tmp_row,4]+tmp_rain                      ;; SRB
                                   ;;nRai_R11Core[tmp_col,tmp_row,4]=nRai_R11Core[tmp_col,tmp_row,4]+1l                            ;; SRB
                                endif else begin
                                   if raintypeFULL[col,fil] eq STRA then begin ;;stratiform rain
                                      RTo_stra_NSR_SH=RTo_stra_NSR_SH+nearSrfR_Org                  &  ctaStra_NSR_SH=ctaStra_NSR_SH+1l
                                      ;;RTo_stra_R11_SH=RTo_stra_R11_SH+(reflectivZ/aRRs)^(1/bRRs)    &  ctaStra_R11_SH=ctaStra_R11_SH+1l      ;; SRB
                                     
                                      ;;tmp_rain=(reflectivZ/aRRs)^(1/bRRs)                                                        ;; SRB
                                      ;;rain_R11Core[tmp_col,tmp_row,4]=rain_R11Core[tmp_col,tmp_row,4]+tmp_rain                   ;; SRB
                                      ;;nRai_R11Core[tmp_col,tmp_row,4]=nRai_R11Core[tmp_col,tmp_row,4]+1l                         ;; SRB
                                   endif else begin
                                      if raintypeFULL[col,fil] ge OTHER then begin ;;other rain
                                         RTo_othe_NSR_SH=RTo_othe_NSR_SH+nearSrfR_Org               &  ctaOthe_NSR_SH=ctaOthe_NSR_SH+1l
                                         ;;RTo_othe_R11_SH=RTo_othe_R11_SH+(reflectivZ/aRR)^(1/bRR)   &  ctaOthe_R11_SH=ctaOthe_R11_SH+1l      ;; SRB
                                        
                                         ;;tmp_rain=(reflectivZ/aRR)^(1/bRR)                                                       ;; SRB
                                         ;;rain_R11Core[tmp_col,tmp_row,4]=rain_R11Core[tmp_col,tmp_row,4]+tmp_rain                ;; SRB
                                         ;;nRai_R11Core[tmp_col,tmp_row,4]=nRai_R11Core[tmp_col,tmp_row,4]+1l                      ;; SRB
                                      endif else begin
                                         if raintype[col,fil] eq raintype_noRainValue then begin ;;No rain
                                            RTo_noRa_NSR_SH=RTo_noRa_NSR_SH+0.   &   ctaNoRa_NSR_SH=ctaNoRa_NSR_SH+1l
                                            ;;RTo_noRa_R11_SH=RTo_noRa_R11_SH+0.   &   ctaNoRa_R11_SH=ctaNoRa_R11_SH+1l                        ;; SRB

                                            ;;rain_R11Core[tmp_col,tmp_row,4]=rain_R11Core[tmp_col,tmp_row,4]+0                    ;; SRB
                                            ;;nRai_R11Core[tmp_col,tmp_row,4]=nRai_R11Core[tmp_col,tmp_row,4]+1l                   ;; SRB
                                         endif
                                      endelse
                                   endelse
                                endelse
                             endif          ;; end for missing values....
                          endif             ;; if ctaC ne 0 and ctaR ne 0
                          ;;endif       ;; end for pixels with height > 2.5km
                       endif          ;;checking if there is data in the vertical
                    endif             ;;checking if there is data inside the boundaries of full storm  
                 endfor               ;;for going thry different pixelsum (indivdual pixels within storm)
                          
                 ;;;;************************************************************************************************************
                 ;;;;Romatschke and Houze 2011
                 ;;total_RainAll_R11=RTo_stra_R11_SH+RTo_conv_R11_SH+RTo_othe_R11_SH+RTo_noRa_R11_SH
                 ;;total_RainCSs_R11=RTo_stra_R11_SH+RTo_conv_R11_SH
                 ;;m_RainAll_R11=total_RainAll_R11/float(ctaStra_R11_SH+ctaConv_R11_SH+ctaOthe_R11_SH+ctaNoRa_R11_SH) ;;mean rainfall for all pixels
                 ;;if ctaStra_R11_SH ne 0 then m_RainStrt_R11=RTo_stra_R11_SH/ctaStra_R11_SH else m_RainStrt_R11=0. ;;mean stratiform rain
                 ;;if ctaConv_R11_SH ne 0 then m_RainConv_R11=RTo_conv_R11_SH/ctaConv_R11_SH else m_RainConv_R11=0. ;;mean convective rain
                 ;;if ctaStra_R11_SH ne 0 or ctaConv_R11_SH ne 0 then $
                 ;;   m_RainCSs_R11=total_RainCSs_R11/float(ctaStra_R11_SH+ctaConv_R11_SH) else m_RainCSs_R11=-999.
                 ;;;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 ;;size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 ;;vol_Rain_All_R11=total_RainAll_R11*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;vol_Rain_Str_R11=RTo_stra_R11_SH*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;vol_Rain_Con_R11=RTo_conv_R11_SH*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 ;;tmp_statsRain_R11_SH=[m_RainAll_R11,m_RainStrt_R11,m_RainConv_R11,vol_Rain_All_R11,vol_Rain_Str_R11,vol_Rain_Con_R11]
                       
                 ;;************************************************************************************************************
                 ;;Near Surface Rain
                 total_RainAll_NSR=RTo_stra_NSR_SH+RTo_conv_NSR_SH+RTo_othe_NSR_SH+RTo_noRa_NSR_SH
                 total_RainCSs_NSR=RTo_stra_NSR_SH+RTo_conv_NSR_SH
                 m_RainAll_NSR=total_RainAll_NSR/float(ctaStra_NSR_SH+ctaConv_NSR_SH+ctaOthe_NSR_SH+ctaNoRa_NSR_SH) ;;mean rainfall for all pixels
                 if ctaStra_NSR_SH ne 0 then m_RainStrt_NSR=RTo_stra_NSR_SH/ctaStra_NSR_SH else m_RainStrt_NSR=0.   ;;mean stratiform rain
                 if ctaConv_NSR_SH ne 0 then m_RainConv_NSR=RTo_conv_NSR_SH/ctaConv_NSR_SH else m_RainConv_NSR=0.   ;;mean convective rain
                 if ctaStra_NSR_SH ne 0 or ctaConv_NSR_SH ne 0 then $
                    m_RainCSs_NSR=total_RainCSs_NSR/float(ctaStra_NSR_SH+ctaConv_NSR_SH) else m_RainCSs_NSR=-999.
                 ;;here calculate volumetric values of rain ;;volume in [1e6*kg/s]
                 size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
                 vol_Rain_All_NSR=total_RainAll_NSR*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Str_NSR=RTo_stra_NSR_SH*(size_pixels[0]*size_pixels[1])/secsPerHr
                 vol_Rain_Con_NSR=RTo_conv_NSR_SH*(size_pixels[0]*size_pixels[1])/secsPerHr
                 ;;mean rain, mean strat, mean convec, vol all, vol strat, vol conv [1e6*kg/s]
                 tmp_statsRain_NSR_SH=[m_RainAll_NSR,m_RainStrt_NSR,m_RainConv_NSR,vol_Rain_All_NSR,vol_Rain_Str_NSR,vol_Rain_Con_NSR]
                 
                 ;;*********************************************************************************************
                 ;;Here I calculate the CFAD count !!! for Full Storm!!! (only for one single Full storm)
                 if area ne areaIsFULL and cen_lon ne lonCIsFULL and cen_lat ne latCIsFull then begin
                    refl_SingleStorm=fltarr(nlonsFull,nlatsFull,nlevels)
                    refl_SingleStorm[*,*,*]=refl_3D_fillValue
                    refl_SingleStorm[w_idF]=refl_3D_FULL[w_idF]
                    if cta_Full ne npix_str[donde_shallow[ss]] then stop  ;; just to check! because this is in 3D!
                    
                    ;;here count reflectivity for each pixel that compose the storm into a matrix of CFAD
                    for i=0l,cta_Full-1l do begin  
                       col_R=where(refl_CFAD eq round(refl_3D_FULL[w_idF[i]]),ctaZ)   
                       row_H=where(alts_CFAD eq hgts_3D_FULL[w_idF[i]],ctaH)   ;;here locate the height of the pixel
                       if ctaH ne 0 and ctaZ ne 0 then CFAD_Full[col_R,row_H,4]=CFAD_Full[col_R,row_H,4]+1l   
                    endfor
                 endif

                 ;;*********************************************************************************************
                 ;;Here I calculate the CFAD count !!! for Convective component!!!
                 refl_SingleStorm=fltarr(nlonsFull,nlatsFull,nlevels)
                 refl_SingleStorm[*,*,*]=refl_3D_fillValue
                 refl_SingleStorm[w_id_SH]=refl_3D_FULL[w_id_SH]
                 if cta1_SH ne npix_SH[donde_Shallow2[ssSH]] then stop  ;; just to check! because this is in 3D!
                
                 ;;here count reflectivity for each pixel that compose the storm into a matrix of CFAD
                 for i=0l,cta1_SH-1 do begin  
                    col_R=where(refl_CFAD eq round(refl_3D_FULL[w_id_SH[i]]),ctaZ)   
                    row_H=where(alts_CFAD eq hgts_3D_FULL[w_id_SH[i]],ctaH)   ;;here locate the height of the pixel
                    if ctaH ne 0 and ctaZ ne 0 then CFAD_Core[col_R,row_H,4]=CFAD_Core[col_R,row_H,4]+1l   
                 endfor

                 areaIsFULL=area & lonCIsFULL=cen_lon & latCIsFull=cen_lat   ;;return area counter to avoid double count of fullStorm
                 
                 ;;info_SH=[info_SH,orbit+'.'+datetime+'.'+strtrim(string(s_id_SH),2)]  ;;MASK MOD
                 ;;info_SH=[info_SH,orbit+'.'+datetime+'.'+strtrim(string(num_shi),2)]  ;;MASK MOD
                 info_SH=[info_SH,orbit+'.'+datetime+'.0']  ;;MASK MOD
                 shape_Core_SH=[[shape_Core_SH],[tmp_shapeSH]]
                 shape_Full_SH=[[shape_Full_SH],[tmp_shape]]
                 rain_Core_SH=[[rain_Core_SH],[rain_momentSH]]
                 rain_Full_SH=[[rain_Full_SH],[rain_moment]]
                 rainTypeCore_SH=[[rainTypeCore_SH],[statsRain_SH]]
                 rainTypeFull_SH=[[rainTypeFull_SH],[statsRain]]
                
                 rainCore_SH_NSR=[[rainCore_SH_NSR],[tmp_statsRain_NSR_SH]]
                 rainFull_SH_NSR=[[rainFull_SH_NSR],[tmp_statsRain_NSR]]
                 ;;rainCore_SH_R11=[[rainCore_SH_R11],[tmp_statsRain_R11_SH]]
                 ;;rainFull_SH_R11=[[rainFull_SH_R11],[tmp_statsRain_R11]]
                
                 undefine,dim_lonSH
                 undefine,dim_latSH
                 undefine,hgt_sumSH
                 undefine,grid_sum
                 undefine,donde
                 undefine,pixelsum
                 undefine,lon_sum
                 undefine,lat_sum
                 undefine,hgt_sum
                 undefine,tmp_shapeSH
                 undefine,tmp_shape
                 undefine,SrfRain_FULL
                 undefine,raintypeFULL
                 undefine,refl_3D_FULL
                 undefine,hgts_3D_FULL
                 undefine,grid_storm_FULL
                 undefine,rainSH
                 undefine,rain
                 undefine,rain_nomiss
                 undefine,stratconv
                 undefine,strats
                 undefine,convec
                 undefine,others
                 undefine,noRain
                 undefine,missin
                 undefine,refl_SingleStorm
                 undefine,col_R
                 undefine,row_H
              endif              ;;endif found a storm cluster with contiguous convective pixels within theresholds 
              undefine,s_id_SH
              undefine,w_id_SH
              undefine,singlestormgrid_SH
              undefine,grid_sum_SH_SH
              undefine,dondeSH_SH
              undefine,lonSH
              undefine,latSH
           endfor         ;;endfor loop through analyzed storms clusters that maybe are deep-wide convective
           undefine,id_SH
           undefine,npix_SH
           undefine,grid_SH
           undefine,searchNaN_SH
           undefine,donde_Shallow2
        endif                   ;;endif for convective areas that could be matching the theresholds
        undefine,lonSH
        undefine,latSH
        undefine,dondeSH
        undefine,grid_sumSH
        undefine,singlestormgridShallow
        undefine,lonsFull_sub
        undefine,latsFull_sub
        undefine,singlestormgrid_Full
        undefine,d_latsFull
        undefine,d_lonsFull
        undefine,total_latFull
        undefine,total_lonFull
        undefine,s_idF
        undefine,w_idF
     endfor         ;;endfor loop thru full storm volumens greater than 2l
  endif             ;;end if the orbit does have shallow isolated pixels
           
end
