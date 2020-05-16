pro output_monthly_class_data,path_out,year,month,region,SH_CALCS

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
  
  ;; save the individual monthly files with detailed info of each core and full storm - check for directories
  if file_test(path_out+'/monthly_class_v11m',/directory) eq 0 then file_mkdir,path_out+'/monthly_class_v11m'
  if file_test(path_out+'/monthly_class_v11m/'+month,/directory) eq 0 then file_mkdir,path_out+'/monthly_class_v11m/'+month

  ;;Save the Deep Convective core data  ;;****************************************************************************
  openw,1,path_out+'/monthly_class_v11m/'+month+'/Deep_Convective_'+month+'_'+year+'_'+region+'_v11m.dat'
  for i=1l,n_elements(info_DC)-1 do $
     printf,1,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
            shape_Core_DC[*,i],rain_Core_DC[*,i],rainTypeCore_DC[*,i],shape_Full_DC[*,i],rain_Full_DC[*,i],rainTypeFull_DC[*,i]
  close,1
  openw,1,path_out+'/monthly_class_v11m/'+month+'/Deep_Convective_'+month+'_'+year+'_'+region+'_v11m.info'
  ;; MASK MOD - change format statment to max len of a record in info_DC
  ;;for i=1l,n_elements(info_DC)-1 do printf,1,format='(a25)',info_DC[i]
  for i=1l,n_elements(info_DC)-1 do begin
     alen = '(a'+strtrim(string(strlen(info_DC[i])),2)+')'
     printf,1,format=alen,info_DC[i]
  endfor 
  close,1

  ;;Save the Wide Convective core data  ;;****************************************************************************
  openw,1,path_out+'/monthly_class_v11m/'+month+'/Wide_Convective_'+month+'_'+year+'_'+region+'_v11m.dat'
  for i=1l,n_elements(info_WC)-1 do $
     printf,1,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
            shape_Core_WC[*,i],rain_Core_WC[*,i],rainTypeCore_WC[*,i],shape_Full_WC[*,i],rain_Full_WC[*,i],rainTypeFull_WC[*,i]
  close,1
  openw,1,path_out+'/monthly_class_v11m/'+month+'/Wide_Convective_'+month+'_'+year+'_'+region+'_v11m.info'
  ;; MASK MOD - change format statment to max len of a record in info_WC
  ;;for i=1l,n_elements(info_WC)-1 do printf,1,format='(a25)',info_WC[i]
  for i=1l,n_elements(info_WC)-1 do begin
     alen = '(a'+strtrim(string(strlen(info_WC[i])),2)+')'
     printf,1,format=alen,info_WC[i]
  endfor 
  close,1

  ;;Save the Deep and Wide Convective core data  ;;************************************************************************
  openw,1,path_out+'/monthly_class_v11m/'+month+'/DeepWide_Convective_'+month+'_'+year+'_'+region+'_v11m.dat'
  for i=1l,n_elements(info_DW)-1 do $
     printf,1,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
            shape_Core_DW[*,i],rain_Core_DW[*,i],rainTypeCore_DW[*,i],shape_Full_DW[*,i],rain_Full_DW[*,i],rainTypeFull_DW[*,i]
  close,1
  openw,1,path_out+'/monthly_class_v11m/'+month+'/DeepWide_Convective_'+month+'_'+year+'_'+region+'_v11m.info'
  ;; MASK MOD - change format statment to max len of a record in info_DW
  ;;for i=1l,n_elements(info_DW)-1 do printf,1,format='(a25)',info_DW[i]
  for i=1l,n_elements(info_DW)-1 do begin
     alen = '(a'+strtrim(string(strlen(info_DW[i])),2)+')'
     printf,1,format=alen,info_DW[i]
  endfor 
  close,1

  ;;Save the Broad Stratiform Regions data  ;;****************************************************************************
  openw,1,path_out+'/monthly_class_v11m/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_v11m.dat'
  for i=1l,n_elements(info_BS)-1 do $
     printf,1,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
            shape_Core_BS[*,i],rain_Core_BS[*,i],rainTypeCore_BS[*,i],shape_Full_BS[*,i],rain_Full_BS[*,i],rainTypeFull_BS[*,i]
  close,1
  openw,1,path_out+'/monthly_class_v11m/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_v11m.info'
  ;; MASK MOD - change format statment to max len of a record in info_BS
  ;;for i=1l,n_elements(info_BS)-1 do printf,1,format='(a25)',info_BS[i]
  for i=1l,n_elements(info_BS)-1 do begin
     alen = '(a'+strtrim(string(strlen(info_BS[i])),2)+')'
     printf,1,format=alen,info_BS[i]
  endfor 
  close,1

  if SH_CALCS then begin
     ;;Save the Shallow Isolated events  ;;****************************************************************************
     openw,1,path_out+'/monthly_class_v11m/'+month+'/ShallowIsolated_'+month+'_'+year+'_'+region+'_v11m.dat'
     for i=1l,n_elements(info_SH)-1 do $
        printf,1,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
               shape_Core_SH[*,i],rain_Core_SH[*,i],rainTypeCore_SH[*,i],shape_Full_SH[*,i],rain_Full_SH[*,i],rainTypeFull_SH[*,i]
     close,1
     openw,1,path_out+'/monthly_class_v11m/'+month+'/ShallowIsolated_'+month+'_'+year+'_'+region+'_v11m.info'
     ;; MASK MOD - change format statment to max len of a record in info_SH
     for i=1l,n_elements(info_SH)-1 do printf,1,format='(a24)',info_SH[i]
     ;;for i=1l,n_elements(info_SH)-1 do begin
     ;;alen = '(a'+strtrim(string(strlen(info_SH[i])),2)+')'
     ;;printf,1,format=alen,info_SH[i]
     ;;endfor 
     close,1
  endif 

end
