pro output_cfad_data,path_out,year,month,region,SH_CALCS

  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core

  ;; include constants
  @constants_ocean.pro
  
  ;; Check for output directories
  if file_test(path_out+'/stats_class_v11m/Cfad',/directory) eq 0 then file_mkdir,path_out+'/stats_class_v11m/Cfad'
  if file_test(path_out+'/stats_class_v11m/Cfad/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/stats_class_v11m/Cfad/'+month
  
  ;;Save the cfads for BSR storms
  name=path_out+'/stats_class_v11m/Cfad/'+month+'/infoCfad_Stra_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)                  ;; Create NetCDF file
  ncdf_control,id,/fill                                  ;; Fill the file with default values
  alt_id = ncdf_dimdef(id,'alts_CFAD',nlevels)
  ref_id = ncdf_dimdef(id,'refl_CFAD',n_refls)

  cfadF_id=ncdf_vardef(id,'CFAD_Full',[ref_id,alt_id],/long)
  ncdf_attput,id,cfadF_id,'long_name','CFAD count for Entire storm',/char
  ncdf_attput,id,cfadF_id,'missing_value','-9999.',/char

  cfadC_id=ncdf_vardef(id,'CFAD_Core',[ref_id,alt_id],/long)
  ncdf_attput,id,cfadC_id,'long_name','CFAD count for cores',/char
  ncdf_attput,id,cfadC_id,'missing_value','-9999.',/char

  ncdf_attput,id,/global,'Title','CFADs for BSR storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
  ncdf_control,id,/endef                    ;; Put file in data mode:

  ncdf_varput,id,cfadF_id,CFAD_Full[*,*,3]
  ncdf_varput,id,cfadC_id,CFAD_Core[*,*,3]

  ncdf_close,id
  spawn,'zip -mjq '+name+'.zip '+name+'.nc'

  ;;Save the cfads for Convective storms
  name=path_out+'/stats_class_v11m/Cfad/'+month+'/infoCfad_Conv_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
  id = ncdf_create(name+'.nc',/clobber)                  ;;Create NetCDF file
  ncdf_control,id,/fill                                  ;; Fill the file with default values
  alt_id = ncdf_dimdef(id,'alts_CFAD',nlevels)
  ref_id = ncdf_dimdef(id,'refl_CFAD',n_refls)
  var_id = ncdf_dimdef(id,'echo_type',3)
  
  cfadF_id=ncdf_vardef(id,'CFAD_Full',[ref_id,alt_id,var_id],/long)
  ncdf_attput,id,cfadF_id,'long_name','CFAD count for Entire storm',/char
  ncdf_attput,id,cfadF_id,'missing_value','-9999.',/char

  cfadC_id=ncdf_vardef(id,'CFAD_Core',[ref_id,alt_id,var_id],/long)
  ncdf_attput,id,cfadC_id,'long_name','CFAD count for cores',/char
  ncdf_attput,id,cfadC_id,'missing_value','-9999.',/char

  ncdf_attput,id,/global,'Title','CFADs for Convective storms'
  ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
  ncdf_control,id,/endef                    ;; Put file in data mode:

  ncdf_varput,id,cfadF_id,CFAD_Full[*,*,[0,1,2]]
  ncdf_varput,id,cfadC_id,CFAD_Core[*,*,[0,1,2]]

  ncdf_close,id
  spawn,'zip -mjq '+name+'.zip '+name+'.nc'

  if SH_CALCS then begin
     ;;Save the CFAD accumulation matrices for Shallow Isolated storms
     name=path_out+'/stats_class_v11m/Cfad/'+month+'/infoCfad_ShallowIsol_EchoCores_'+month+'_'+year+'_'+region+'_v11m'
     id = ncdf_create(name+'.nc',/clobber)                  ;;Create NetCDF file
     ncdf_control,id,/fill                                  ;; Fill the file with default values
     alt_id = ncdf_dimdef(id,'alts_CFAD',nlevels)
     ref_id = ncdf_dimdef(id,'refl_CFAD',n_refls)

     cfadF_id=ncdf_vardef(id,'CFAD_Full',[ref_id,alt_id],/long)
     ncdf_attput,id,cfadF_id,'long_name','CFAD count for Entire storm',/char
     ncdf_attput,id,cfadF_id,'missing_value','-9999.',/char

     cfadC_id=ncdf_vardef(id,'CFAD_Core',[ref_id,alt_id],/long)
     ncdf_attput,id,cfadC_id,'long_name','CFAD count for cores',/char
     ncdf_attput,id,cfadC_id,'missing_value','-9999.',/char

     ncdf_attput,id,/global,'Title','CFADs for Shallow Isolated storms'
     ncdf_attput,id,/global,'source','created using IDL by S.Brodzik UW, Seattle'
     ncdf_control,id,/endef                    ;; Put file in data mode:
  
     ncdf_varput,id,cfadF_id,CFAD_Full[*,*,4]
     ncdf_varput,id,cfadC_id,CFAD_Core[*,*,4]

     ncdf_close,id
     spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  endif 


end
