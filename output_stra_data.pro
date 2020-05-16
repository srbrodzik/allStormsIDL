pro output_stra_data,path_out,year,month,region

  ;; INPUTS: path_out,year,month,region
  ;; OUTPUTS: output files in monthly_class & stats_class dirs

  COMMON infoBlock,orbit,datetime,info_DC,info_WC,info_DW,info_BS,info_SH
  COMMON straCoreBlock,shape_Core_BS,rain_Core_BS,rainTypeCore_BS, $
     rainCore_BS_NSR
  COMMON straStormBlock,shape_Full_BS,rain_Full_BS,rainTypeFull_BS, $
     rainFull_BS_NSR
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core

  ;; include constants
  @constants_ocean.pro
  
  ;; (1) save the shape data of each core & full storm
  ;;--------------------------------------------------
  ;; check for directories
  if file_test(path_out+'/monthly_class_v11m',/directory) eq 0 then $
     file_mkdir,path_out+'/monthly_class_v11m'
  if file_test(path_out+'/monthly_class_v11m/'+month,/directory) eq 0 then $
     file_mkdir,path_out+'/monthly_class_v11m/'+month

  ;; output data
  openw,lun,path_out+'/monthly_class_v11m/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_v11m.dat',/get_lun
  for i=1l,n_elements(info_BS)-1 do $
     printf,lun,format='(9f10.2,7f10.2,6f11.4,9f10.2,7f10.2,6f11.4)',$
            shape_Core_BS[*,i],rain_Core_BS[*,i],rainTypeCore_BS[*,i],$
            shape_Full_BS[*,i],rain_Full_BS[*,i],rainTypeFull_BS[*,i]
  free_lun,lun
  
  openw,lun,path_out+'/monthly_class_v11m/'+month+'/BroadStratiform_'+month+'_'+year+'_'+region+'_v11m.info',/get_lun
  for i=1l,n_elements(info_BS)-1 do begin
     alen = '(a'+strtrim(string(strlen(info_BS[i])),2)+')'
     printf,lun,format=alen,info_BS[i]
  endfor 
  free_lun,lun

  ;; (2) save mean rain, rain volume data of each core and storm
  ;;------------------------------------------------------------
  ;; check for directories
  if file_test(path_out+'/stats_class_v11m',/directory) eq 0 then $
     file_mkdir,path_out+'/stats_class_v11m'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain',/directory) eq 0 then $
     file_mkdir,path_out+'/stats_class_v11m/NearSurfRain'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/stats_class_v11m/NearSurfRain/'+month

  ;; output data
  openw,lun,path_out+'/stats_class_v11m/NearSurfRain/'+month+'/Broad_Strat_'+month+'_'+year+'_'+region+'_v11m.stats',/get_lun
  printf,lun,n_elements(info_BS)-1
  for i=1l,n_elements(info_BS)-1 do $
     printf,lun,format='(4f12.3,4f12.3,a27)',$
            shape_Core_BS[0:3,i],shape_Full_BS[0:3,i],info_BS[i]
  free_lun,lun

  openw,lun,path_out+'/stats_class_v11m/NearSurfRain/'+month+'/Broad_Strat_'+month+'_'+year+'_'+region+'_v11m.rain',/get_lun
  printf,lun,n_elements(info_BS)-1
  for i=1,n_elements(info_BS)-1 do $
     printf,lun,format='(24f12.2,a27)',$
            rainCore_BS_NSR[*,i],rainFull_BS_NSR[*,i],rainTypeCore_BS[*,i],rainTypeFull_BS[*,i],info_BS[i]
  free_lun,lun

  ;; (3) save rain accum data for each core and storm
  ;;-------------------------------------------------
  ;; check for directories
  if file_test(path_out+'/stats_class_v11m',/directory) eq 0 then $
     file_mkdir,path_out+'/stats_class_v11m'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain',/directory) eq 0 then $
     file_mkdir,path_out+'/stats_class_v11m/NearSurfRain'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/stats_class_v11m/NearSurfRain/'+month
  
  ;; create netcdf file
  name=path_out+'/stats_class_v11m/NearSurfRain/'+month+'/infoRainNSR_Stra_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)
  ncdf_control,id,/fill

  ;; define dims
  lnC_id = ncdf_dimdef(id,'lons_c',nlonsC)
  ltC_id = ncdf_dimdef(id,'lats_c',nlatsC)
  lnF_id = ncdf_dimdef(id,'lons_f',nlonsF)
  ltF_id = ncdf_dimdef(id,'lats_f',nlatsF)

  ;; define vars & attributes
  freqF_id=ncdf_vardef(id,'freq_Full',[lnC_id,ltC_id],/long)
  ncdf_attput,id,freqF_id,'long_name','pixel count for full storm',/char
  ncdf_attput,id,freqF_id,'missing_value','-9999.',/char

  freqC_id=ncdf_vardef(id,'freq_core',[lnC_id,ltC_id],/long)
  ncdf_attput,id,freqC_id,'long_name','pixel count for core storm',/char
  ncdf_attput,id,freqC_id,'missing_value','-9999.',/char

  rainF_id_BS=ncdf_vardef(id,'rain_Full_BS',[lnF_id,ltF_id],/float)
  ncdf_attput,id,rainF_id_BS,'long_name','Accumulated rain for full storm in BS',/char
  ncdf_attput,id,rainF_id_BS,'missing_value','-9999.',/char

  nR_F_id_BS=ncdf_vardef(id,'nRain_Full_BS',[lnF_id,ltF_id],/long)
  ncdf_attput,id,nR_F_id_BS,'long_name','number of elements of rain for full storm in BS',/char
  ncdf_attput,id,nR_F_id_BS,'missing_value','-9999.',/char

  rain_id_BS=ncdf_vardef(id,'rain_Core_BS',[lnF_id,ltF_id],/float)
  ncdf_attput,id,rain_id_BS,'long_name','Accumulated rain for BS cores',/char
  ncdf_attput,id,rain_id_BS,'missing_value','-9999.',/char

  nR_id_BS=ncdf_vardef(id,'nRain_Core_BS',[lnF_id,ltF_id],/long)
  ncdf_attput,id,nR_id_BS,'long_name','number of elements of rain for BS cores',/char
  ncdf_attput,id,nR_id_BS,'missing_value','-9999.',/char

  lonID_C = ncdf_vardef(id,'lonsC',[lnC_id],/float)
  ncdf_attput,id,lonID_C,'units','degrees',/char
  ncdf_attput,id,lonID_C,'long_name','longitudes in coarse grid',/char
  
  latID_C = ncdf_vardef(id,'latsC',[ltC_id],/float)
  ncdf_attput,id,latID_C,'units','degrees',/char
  ncdf_attput,id,latID_C,'long_name','latitudes in coarse grid',/char

  lonID_F = ncdf_vardef(id,'lonsF',[lnF_id],/double)
  ncdf_attput,id,lonID_F,'units','degrees',/char
  ncdf_attput,id,lonID_F,'long_name','longitudes in fine grid',/char
  
  latID_F = ncdf_vardef(id,'latsF',[ltF_id],/double)
  ncdf_attput,id,latID_F,'units','degrees',/char
  ncdf_attput,id,latID_F,'long_name','latitudes in fine grid',/char

  ;; define global attributes
  ncdf_attput,id,/global,'Title','Information of Broad Stratiform classified storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
  ncdf_attput,id,/global,'rain_text1','rain calculated using Near Surface Rain'

  ;; put file in data mode
  ncdf_control,id,/endef

  ;; write data to file
  ncdf_varput,id,freqF_id,freq_Full[*,*,3]
  ncdf_varput,id,freqC_id,freq_Core[*,*,3]

  ncdf_varput,id,rainF_id_BS,rain_NSRFull[*,*,3]
  ncdf_varput,id,nR_F_id_BS,nRai_NSRFull[*,*,3]
  ncdf_varput,id,rain_id_BS,rain_NSRCore[*,*,3]
  ncdf_varput,id,nR_id_BS,nRai_NSRCore[*,*,3]

  ncdf_varput,id,lonID_C,lonsC
  ncdf_varput,id,latID_C,latsC
  ncdf_varput,id,lonID_F,lonsF
  ncdf_varput,id,latID_F,latsF

  ncdf_close,id
  spawn,'zip -mjq '+name+'.zip '+name+'.nc'

  ;; (4) save cfad data for each core and storm
  ;; check for directories
  if file_test(path_out+'/stats_class_v11m/Cfad',/directory) eq 0 then $
     file_mkdir,path_out+'/stats_class_v11m/Cfad'
  if file_test(path_out+'/stats_class_v11m/Cfad/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/stats_class_v11m/Cfad/'+month

  ;; create netcdf file
  name=path_out+'/stats_class_v11m/Cfad/'+month+'/infoCfad_Stra_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)
  ncdf_control,id,/fill

  ;; define dims
  alt_id = ncdf_dimdef(id,'alts_CFAD',nlevels)
  ref_id = ncdf_dimdef(id,'refl_CFAD',n_refls)

  ;; define vars and attributes
  cfadF_id=ncdf_vardef(id,'CFAD_Full',[ref_id,alt_id],/long)
  ncdf_attput,id,cfadF_id,'long_name','CFAD count for Entire storm',/char
  ncdf_attput,id,cfadF_id,'missing_value','-9999.',/char

  cfadC_id=ncdf_vardef(id,'CFAD_Core',[ref_id,alt_id],/long)
  ncdf_attput,id,cfadC_id,'long_name','CFAD count for cores',/char
  ncdf_attput,id,cfadC_id,'missing_value','-9999.',/char

  ;; define global attributes
  ncdf_attput,id,/global,'Title','CFADs for BSR storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'

  ;; put file in data mode
  ncdf_control,id,/endef 

  ;; write data to file
  ncdf_varput,id,cfadF_id,CFAD_Full[*,*,3]
  ncdf_varput,id,cfadC_id,CFAD_Core[*,*,3]

  ncdf_close,id
  spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  
end
