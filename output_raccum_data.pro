pro output_raccum_data,path_out,year,month,region,SH_CALCS

  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore

  ;; Check for output directories
  if file_test(path_out+'/stats_class_v11m',/directory) eq 0 then file_mkdir,path_out+'/stats_class_v11m'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain',/directory) eq 0 then file_mkdir,path_out+'/stats_class_v11m/NearSurfRain'
  if file_test(path_out+'/stats_class_v11m/NearSurfRain/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/stats_class_v11m/NearSurfRain/'+month

  ;;save the Rain accumulation Matrices for Near Surface Rain
  name=path_out+'/stats_class_v11m/NearSurfRain/'+month+'/infoRainNSR_Stra_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)                  ;;Create NetCDF file
  ncdf_control,id,/fill                                  ;; Fill the file with default values
  lnC_id = ncdf_dimdef(id,'lons_c',nlonsC)
  ltC_id = ncdf_dimdef(id,'lats_c',nlatsC)
  lnF_id = ncdf_dimdef(id,'lons_f',nlonsF)
  ltF_id = ncdf_dimdef(id,'lats_f',nlatsF)

  freqF_id=ncdf_vardef(id,'freq_Full',[lnC_id,ltC_id],/long) ;; Define variables:
  ncdf_attput,id,freqF_id,'long_name','pixel count for full storm',/char
  ncdf_attput,id,freqF_id,'missing_value','-9999.',/char

  freqC_id=ncdf_vardef(id,'freq_core',[lnC_id,ltC_id],/long) ;; Define variables:
  ncdf_attput,id,freqC_id,'long_name','pixel count for core storm',/char
  ncdf_attput,id,freqC_id,'missing_value','-9999.',/char
  ;;**    
  rainF_id_BS=ncdf_vardef(id,'rain_Full_BS',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rainF_id_BS,'long_name','Accumulated rain for full storm in BS',/char
  ncdf_attput,id,rainF_id_BS,'missing_value','-9999.',/char

  nR_F_id_BS=ncdf_vardef(id,'nRain_Full_BS',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_F_id_BS,'long_name','number of elements of rain for full storm in BS',/char
  ncdf_attput,id,nR_F_id_BS,'missing_value','-9999.',/char

  rain_id_BS=ncdf_vardef(id,'rain_Core_BS',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rain_id_BS,'long_name','Accumulated rain for BS cores',/char
  ncdf_attput,id,rain_id_BS,'missing_value','-9999.',/char

  nR_id_BS=ncdf_vardef(id,'nRain_Core_BS',[lnF_id,ltF_id],/long) ;; Define variables:
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

  ncdf_attput,id,/global,'Title','Information of Broad Stratiform classified storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
  ncdf_attput,id,/global,'rain_text1','rain calculated using Near Surface Rain'
  ncdf_control,id,/endef                    ;; Put file in data mode:

  ncdf_varput,id,freqF_id,freq_Full[*,*,3]                         ;;Write the data into file
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

  ;;save the accumulated rain matrices in Convective Cores computed using NEar surface rain
  name=path_out+'/stats_class_v11m/NearSurfRain/'+month+'/infoRainNSR_Conv_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)                  ;;Create NetCDF file
  ncdf_control,id,/fill                                  ;; Fill the file with default values
  lnC_id = ncdf_dimdef(id,'lons_c',nlonsC)
  ltC_id = ncdf_dimdef(id,'lats_c',nlatsC)
  lnF_id = ncdf_dimdef(id,'lons_f',nlonsF)
  ltF_id = ncdf_dimdef(id,'lats_f',nlatsF)
  var_id = ncdf_dimdef(id,'echo_type',3)

  freqF_id=ncdf_vardef(id,'freq_Full',[lnC_id,ltC_id,var_id],/long) ;; Define variables:
  ncdf_attput,id,freqF_id,'long_name','Event pixel count for Entire storm',/char
  ncdf_attput,id,freqF_id,'missing_value','-9999.',/char

  freqC_id=ncdf_vardef(id,'freq_core',[lnC_id,ltC_id,var_id],/long) ;; Define variables:
  ncdf_attput,id,freqC_id,'long_name','Event pixel count for cores',/char
  ncdf_attput,id,freqC_id,'missing_value','-9999.',/char
  ;;** 
  rainF_id_DC=ncdf_vardef(id,'rain_Full_DC',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rainF_id_DC,'long_name','Accumulated rain for Entire storm in DC',/char
  ncdf_attput,id,rainF_id_DC,'missing_value','-9999.',/char

  nR_F_id_DC=ncdf_vardef(id,'nRain_Full_DC',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_F_id_DC,'long_name','number of elements of rain for Entire storm in DC',/char
  ncdf_attput,id,nR_F_id_DC,'missing_value','-9999.',/char

  rain_id_DC=ncdf_vardef(id,'rain_Core_DC',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rain_id_DC,'long_name','Accumulated rain for DC cores',/char
  ncdf_attput,id,rain_id_DC,'missing_value','-9999.',/char

  nR_id_DC=ncdf_vardef(id,'nRain_Core_DC',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_id_DC,'long_name','number of elements of rain for DC cores',/char
  ncdf_attput,id,nR_id_DC,'missing_value','-9999.',/char
  ;;** 
  rainF_id_WC=ncdf_vardef(id,'rain_Full_WC',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rainF_id_WC,'long_name','Accumulated rain for Entire storm in WC',/char
  ncdf_attput,id,rainF_id_WC,'missing_value','-9999.',/char

  nR_F_id_WC=ncdf_vardef(id,'nRain_Full_WC',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_F_id_WC,'long_name','number of elements of rain for Entire storm in WC',/char
  ncdf_attput,id,nR_F_id_WC,'missing_value','-9999.',/char

  rain_id_WC=ncdf_vardef(id,'rain_Core_WC',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rain_id_WC,'long_name','Accumulated rain for WC cores',/char
  ncdf_attput,id,rain_id_WC,'missing_value','-9999.',/char

  nR_id_WC=ncdf_vardef(id,'nRain_Core_WC',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_id_WC,'long_name','number of elements of rain for WC cores',/char
  ncdf_attput,id,nR_id_WC,'missing_value','-9999.',/char
  ;;** 
  rainF_id_DW=ncdf_vardef(id,'rain_Full_DW',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rainF_id_DW,'long_name','Accumulated rain for Entire storm in DW',/char
  ncdf_attput,id,rainF_id_DW,'missing_value','-9999.',/char

  nR_F_id_DW=ncdf_vardef(id,'nRain_Full_DW',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_F_id_DW,'long_name','number of elements of rain for Entire storm in DW',/char
  ncdf_attput,id,nR_F_id_DW,'missing_value','-9999.',/char

  rain_id_DW=ncdf_vardef(id,'rain_Core_DW',[lnF_id,ltF_id],/float) ;; Define variables:
  ncdf_attput,id,rain_id_DW,'long_name','Accumulated rain for DW cores',/char
  ncdf_attput,id,rain_id_DW,'missing_value','-9999.',/char

  nR_id_DW=ncdf_vardef(id,'nRain_Core_DW',[lnF_id,ltF_id],/long) ;; Define variables:
  ncdf_attput,id,nR_id_DW,'long_name','number of elements of rain for DW cores',/char
  ncdf_attput,id,nR_id_DW,'missing_value','-9999.',/char
  ;;**
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

  ncdf_attput,id,/global,'Title','Information of Convective (DCC-WCC-DWCC) classified storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
  ncdf_attput,id,/global,'rain_text1','rain calculated using Near Surface Rain'
  ncdf_control,id,/endef                    ;; Put file in data mode:

  ncdf_varput,id,freqF_id,freq_Full[*,*,[0,1,2]]                         ;;Write the data into file
  ncdf_varput,id,freqC_id,freq_Core[*,*,[0,1,2]]

  ncdf_varput,id,rainF_id_DC,rain_NSRFull[*,*,0]
  ncdf_varput,id,nR_F_id_DC,nRai_NSRFull[*,*,0]
  ncdf_varput,id,rain_id_DC,rain_NSRCore[*,*,0]
  ncdf_varput,id,nR_id_DC,nRai_NSRCore[*,*,0]

  ncdf_varput,id,rainF_id_WC,rain_NSRFull[*,*,1]
  ncdf_varput,id,nR_F_id_WC,nRai_NSRFull[*,*,1]
  ncdf_varput,id,rain_id_WC,rain_NSRCore[*,*,1]
  ncdf_varput,id,nR_id_WC,nRai_NSRCore[*,*,1]
  
  ncdf_varput,id,rainF_id_DW,rain_NSRFull[*,*,2]
  ncdf_varput,id,nR_F_id_DW,nRai_NSRFull[*,*,2]
  ncdf_varput,id,rain_id_DW,rain_NSRCore[*,*,2]
  ncdf_varput,id,nR_id_DW,nRai_NSRCore[*,*,2]

  ncdf_varput,id,lonID_C,lonsC
  ncdf_varput,id,latID_C,latsC
  ncdf_varput,id,lonID_F,lonsF
  ncdf_varput,id,latID_F,latsF
  
  ncdf_close,id
  spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  ;;*********************************************************************************************************************

  if SH_CALCS then begin
     ;;save the Rain accumulation Matrices for Shallow Isolated with Near Surface Rain!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     name=path_out+'/stats_class_v11m/NearSurfRain/'+month+'/infoRainNSR_ShallowIsol_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
     id = ncdf_create(name+'.nc',/clobber)                  ;; Create NetCDF file
     ncdf_control,id,/fill                                  ;; Fill the file with default values
     lnC_id = ncdf_dimdef(id,'lons_c',nlonsC)
     ltC_id = ncdf_dimdef(id,'lats_c',nlatsC)
     lnF_id = ncdf_dimdef(id,'lons_f',nlonsF)
     ltF_id = ncdf_dimdef(id,'lats_f',nlatsF)

     freqF_id=ncdf_vardef(id,'freq_Full',[lnC_id,ltC_id],/long) ;; Define variables:
     ncdf_attput,id,freqF_id,'long_name','pixel count for full storm',/char
     ncdf_attput,id,freqF_id,'missing_value','-9999.',/char

     freqC_id=ncdf_vardef(id,'freq_core',[lnC_id,ltC_id],/long) ;; Define variables:
     ncdf_attput,id,freqC_id,'long_name','pixel count for core storm',/char
     ncdf_attput,id,freqC_id,'missing_value','-9999.',/char
     ;;**    
     rainF_id_SH=ncdf_vardef(id,'rain_Full_SH',[lnF_id,ltF_id],/float) ;; Define variables:
     ncdf_attput,id,rainF_id_SH,'long_name','Accumulated rain for full storm in SH',/char
     ncdf_attput,id,rainF_id_SH,'missing_value','-9999.',/char

     nR_F_id_SH=ncdf_vardef(id,'nRain_Full_SH',[lnF_id,ltF_id],/long) ;; Define variables:
     ncdf_attput,id,nR_F_id_SH,'long_name','number of elements of rain for full storm in SH',/char
     ncdf_attput,id,nR_F_id_SH,'missing_value','-9999.',/char

     rain_id_SH=ncdf_vardef(id,'rain_Core_SH',[lnF_id,ltF_id],/float) ;; Define variables:
     ncdf_attput,id,rain_id_SH,'long_name','Accumulated rain for SH cores',/char
     ncdf_attput,id,rain_id_SH,'missing_value','-9999.',/char

     nR_id_SH=ncdf_vardef(id,'nRain_Core_SH',[lnF_id,ltF_id],/long) ;; Define variables:
     ncdf_attput,id,nR_id_SH,'long_name','number of elements of rain for SH cores',/char
     ncdf_attput,id,nR_id_SH,'missing_value','-9999.',/char

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

     ncdf_attput,id,/global,'Title','Information of Shallow Isolated cores'
     ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
     ncdf_attput,id,/global,'rain_text1','rain calculated using Near Surface Rain'
     ncdf_control,id,/endef                    ;; Put file in data mode:

     ncdf_varput,id,freqF_id,freq_Full[*,*,4]                         ;;Write the data into file
     ncdf_varput,id,freqC_id,freq_Core[*,*,4]

     ncdf_varput,id,rainF_id_SH,rain_NSRFull[*,*,4]
     ncdf_varput,id,nR_F_id_SH,nRai_NSRFull[*,*,4]
     ncdf_varput,id,rain_id_SH,rain_NSRCore[*,*,4]
     ncdf_varput,id,nR_id_SH,nRai_NSRCore[*,*,4]

     ncdf_varput,id,lonID_C,lonsC
     ncdf_varput,id,latID_C,latsC
     ncdf_varput,id,lonID_F,lonsF
     ncdf_varput,id,latID_F,latsF

     ncdf_close,id
     spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  endif 

end
