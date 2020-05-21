pro output_monthly_class_data,path_out,year,month,region

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
  
  ;; save the individual monthly files with detailed info of each core and full storm - check for directories
  subDir = 'monthly_class_'+output_version
  if file_test(path_out+'/'+subDir,/directory) eq 0 then file_mkdir,path_out+'/'+subDir
  if file_test(path_out+'/'+subDir+'/'+month,/directory) eq 0 then file_mkdir,path_out+'/'+subDir+'/'+month

  if CV_CALCS then begin
     ;;Save the Deep Convective core data  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/'+month+'/Deep_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.dat',/get_lun
     for i=1l,n_elements(info_DC)-1 do $
        printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_DC[*,i],rain_Core_DC[*,i],rainTypeCore_DC[*,i],shape_Full_DC[*,i],rain_Full_DC[*,i],rainTypeFull_DC[*,i]
     free_lun,lun
     openw,lun,path_out+'/'+subDir+'/'+month+'/Deep_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.info',/get_lun
     for i=1l,n_elements(info_DC)-1 do begin
        alen = '(a'+strtrim(string(strlen(info_DC[i])),2)+')'
        printf,lun,format=alen,info_DC[i]
     endfor 
     free_lun,lun

     ;;Save the Wide Convective core data  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/'+month+'/Wide_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.dat',/get_lun
     for i=1l,n_elements(info_WC)-1 do $
        printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_WC[*,i],rain_Core_WC[*,i],rainTypeCore_WC[*,i],shape_Full_WC[*,i],rain_Full_WC[*,i],rainTypeFull_WC[*,i]
     free_lun,lun
     openw,lun,path_out+'/'+subDir+'/'+month+'/Wide_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.info',/get_lun
     for i=1l,n_elements(info_WC)-1 do begin
        alen = '(a'+strtrim(string(strlen(info_WC[i])),2)+')'
        printf,lun,format=alen,info_WC[i]
     endfor 
     free_lun,lun

     ;;Save the Deep and Wide Convective core data  ;;************************************************************************
     openw,lun,path_out+'/'+subDir+'/'+month+'/DeepWide_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.dat',/get_lun
     for i=1l,n_elements(info_DW)-1 do $
        printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_DW[*,i],rain_Core_DW[*,i],rainTypeCore_DW[*,i],shape_Full_DW[*,i],rain_Full_DW[*,i],rainTypeFull_DW[*,i]
     free_lun,lun
     openw,lun,path_out+'/'+subDir+'/'+month+'/DeepWide_Convective_'+month+'_'+year+'_'+region+'_'+output_version+'.info',/get_lun
     for i=1l,n_elements(info_DW)-1 do begin
        alen = '(a'+strtrim(string(strlen(info_DW[i])),2)+')'
        printf,lun,format=alen,info_DW[i]
     endfor 
     free_lun,lun
  endif 

  if ST_CALCS then begin
     ;;Save the Broad Stratiform Regions data  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_'+output_version+'.dat',/get_lun
     for i=1l,n_elements(info_BS)-1 do $
        printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_BS[*,i],rain_Core_BS[*,i],rainTypeCore_BS[*,i],shape_Full_BS[*,i],rain_Full_BS[*,i],rainTypeFull_BS[*,i]
     free_lun,lun
     openw,lun,path_out+'/'+subDir+'/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_'+output_version+'.info',/get_lun
     for i=1l,n_elements(info_BS)-1 do begin
        alen = '(a'+strtrim(string(strlen(info_BS[i])),2)+')'
        printf,lun,format=alen,info_BS[i]
     endfor 
     free_lun,lun
  endif 

  if SH_CALCS then begin
     ;;Save the Shallow Isolated events  ;;****************************************************************************
     openw,lun,path_out+'/'+subDir+'/'+month+'/ShallowIsolated_'+month+'_'+year+'_'+region+'_'+output_version+'.dat',/get_lun
     for i=1l,n_elements(info_SH)-1 do $
        printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_SH[*,i],rain_Core_SH[*,i],rainTypeCore_SH[*,i],shape_Full_SH[*,i],rain_Full_SH[*,i],rainTypeFull_SH[*,i]
     free_lun,lun
     openw,lun,path_out+'/'+subDir+'/'+month+'/ShallowIsolated_'+month+'_'+year+'_'+region+'_'+output_version+'.info',/get_lun
     for i=1l,n_elements(info_SH)-1 do printf,lun,format='(a24)',info_SH[i]
     ;;for i=1l,n_elements(info_SH)-1 do begin
     ;;   alen = '(a'+strtrim(string(strlen(info_SH[i])),2)+')'
     ;;   printf,lun,format=alen,info_SH[i]
     ;;endfor 
     free_lun,lun
  endif 

end
