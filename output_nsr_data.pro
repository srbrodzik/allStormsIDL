pro output_nsr_data,path_out,year,month,region

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

  ;;include constants
  @constants.pro
  
  ;;Near Surface Rain - here it saves: cen_lon,cen_lat,area_storm,max_height - check for directories
  subDir = 'stats_class_'+output_version
  if file_test(path_out+'/'+subDir,/directory) eq 0 then file_mkdir,path_out+'/'+subDir
  if file_test(path_out+'/'+subDir+'/NearSurfRain',/directory) eq 0 then file_mkdir,path_out+'/'+subDir+'/NearSurfRain'
  if file_test(path_out+'/'+subDir+'/NearSurfRain/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/'+subDir+'/NearSurfRain/'+month

  if CV_CALCS then begin
     ;;Save the Deep Convective core data  ;;***************************************************************************
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Deep_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.stats',/get_lun
     printf,lun,n_elements(info_DC)-1
     for i=1l,n_elements(info_DC)-1 do $
        printf,lun,format='(4f12.3,4f12.3,a27)',$
               shape_Core_DC[0:3,i],shape_Full_DC[0:3,i],info_DC[i]
     free_lun,lun

     ;;here it saves: mean_rain,mean_strat,mean_convec,vol_all,vol_strat,vol_conv  [1e6*kg/s] 
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Deep_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.rain',/get_lun
     printf,lun,n_elements(info_DC)-1
     for i=1,n_elements(info_DC)-1 do printf,lun,format='(24f12.2,a27)',$
                                             rainCore_DC_NSR[*,i],rainFull_DC_NSR[*,i],rainTypeCore_DC[*,i],rainTypeFull_DC[*,i],info_DC[i]
     free_lun,lun

     ;;Save the Wide Convective core data   ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Wide_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.stats',/get_lun
     printf,lun,n_elements(info_WC)-1
     for i=1l,n_elements(info_WC)-1 do $
        printf,lun,format='(4f12.3,4f12.3,a27)',$
               shape_Core_WC[0:3,i],shape_Full_WC[0:3,i],info_WC[i]
     free_lun,lun

     ;;here it saves: mean_rain,mean_strat,mean_convec,vol_all,vol_strat,vol_conv  [1e6*kg/s] 
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Wide_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.rain',/get_lun
     printf,lun,n_elements(info_WC)-1
     for i=1,n_elements(info_WC)-1 do printf,lun,format='(24f12.2,a27)',$
                                             rainCore_WC_NSR[*,i],rainFull_WC_NSR[*,i],rainTypeCore_WC[*,i],rainTypeFull_WC[*,i],info_WC[i]
     free_lun,lun

     ;;Save the Deep and Wide Convective core data  ;;***********************************************************************
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/DeepWide_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.stats',/get_lun
     printf,lun,n_elements(info_DW)-1
     for i=1l,n_elements(info_DW)-1 do $
        printf,lun,format='(4f12.3,4f12.3,a27)',$
               shape_Core_DW[0:3,i],shape_Full_DW[0:3,i],info_DW[i]
     free_lun,lun

     ;;here it saves: mean_rain,mean_strat,mean_convec,vol_all,vol_strat,vol_conv  [1e6*kg/s] 
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/DeepWide_Convec_'+month+'_'+year+'_'+region+'_'+output_version+'.rain',/get_lun
     printf,lun,n_elements(info_DW)-1
     for i=1,n_elements(info_DW)-1 do printf,lun,format='(24f12.2,a27)',$
                                             rainCore_DW_NSR[*,i],rainFull_DW_NSR[*,i],rainTypeCore_DW[*,i],rainTypeFull_DW[*,i],info_DW[i]
     free_lun,lun
  endif

  if ST_CALCS then begin
     ;;Save the Broad Stratiform Regions data  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Broad_Strat_'+month+'_'+year+'_'+region+'_'+output_version+'.stats',/get_lun
     printf,lun,n_elements(info_BS)-1
     for i=1l,n_elements(info_BS)-1 do $
        printf,lun,format='(4f12.3,4f12.3,a27)',$
               shape_Core_BS[0:3,i],shape_Full_BS[0:3,i],info_BS[i]
     free_lun,lun
     
     ;;here it saves: mean_rain,mean_strat,mean_convec,vol_all,vol_strat,vol_conv  [1e6*kg/s] 
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Broad_Strat_'+month+'_'+year+'_'+region+'_'+output_version+'.rain',/get_lun
     printf,lun,n_elements(info_BS)-1
     for i=1,n_elements(info_BS)-1 do printf,lun,format='(24f12.2,a27)',$
                                             rainCore_BS_NSR[*,i],rainFull_BS_NSR[*,i],rainTypeCore_BS[*,i],rainTypeFull_BS[*,i],info_BS[i]
     free_lun,lun
  endif

  if SH_CALCS then begin
     ;;Save the Shallow Isolated data  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Shallow_Isol_'+month+'_'+year+'_'+region+'_'+output_version+'.stats',/get_lun
     printf,lun,n_elements(info_SH)-1
     for i=1l,n_elements(info_SH)-1 do $
        printf,lun,format='(4f12.3,4f12.3,a27)',$
               shape_Core_SH[0:3,i],shape_Full_SH[0:3,i],info_SH[i]
     free_lun,lun

     ;;here it saves: mean_rain,mean_strat,mean_convec,vol_all,vol_strat,vol_conv  [1e6*kg/s] 
     openw,lun,path_out+'/'+subDir+'/NearSurfRain/'+month+'/Shallow_Isol_'+month+'_'+year+'_'+region+'_'+output_version+'.rain',/get_lun
     printf,lun,n_elements(info_SH)-1
     for i=1,n_elements(info_SH)-1 do printf,lun,format='(24f12.2,a27)',$
                                             rainCore_SH_NSR[*,i],rainFull_SH_NSR[*,i],rainTypeCore_SH[*,i],rainTypeFull_SH[*,i],info_SH[i]
     free_lun,lun
  endif 

end
