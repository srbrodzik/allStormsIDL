pro output_cfad_data,path_out,year,month,region

  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core

  ;; include constants
  @constants.pro
  
  ;; Check for output directories
  subDir = 'stats_class_'+output_version
  if file_test(path_out+'/'+subDir+'/Cfad',/directory) eq 0 then file_mkdir,path_out+'/'+subDir+'/Cfad'
  if file_test(path_out+'/'+subDir+'/Cfad/'+month,/directory) eq 0 then  $
     file_mkdir,path_out+'/'+subDir+'/Cfad/'+month

  if ST_CALCS then begin
     ;;Save the cfads for BSR storms
     name=path_out+'/'+subDir+'/Cfad/'+month+'/infoCfad_Stra_EchoCores_'+month+'_'+year+'_'+region+'_'+output_version
     id = ncdf_create(name+'.nc',/clobber)
     ncdf_control,id,/fill
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
     ncdf_control,id,/endef

     ncdf_varput,id,cfadF_id,CFAD_Full[*,*,3]
     ncdf_varput,id,cfadC_id,CFAD_Core[*,*,3]

     ncdf_close,id
     spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  endif 

  if CV_CALCS then begin
     ;;Save the cfads for Convective storms
     name=path_out+'/'+subDir+'/Cfad/'+month+'/infoCfad_Conv_EchoCores_'+month+'_'+year+'_'+region+'_'+output_version
     id = ncdf_create(name+'.nc',/clobber)
     ncdf_control,id,/fill
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
     ncdf_control,id,/endef

     ncdf_varput,id,cfadF_id,CFAD_Full[*,*,[0,1,2]]
     ncdf_varput,id,cfadC_id,CFAD_Core[*,*,[0,1,2]]

     ncdf_close,id
     spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  endif 
     
  if SH_CALCS then begin
     ;;Save the CFAD accumulation matrices for Shallow Isolated storms
     name=path_out+'/'+subDir+'/Cfad/'+month+'/infoCfad_ShallowIsol_EchoCores_'+month+'_'+year+'_'+region+'_'+output_version
     id = ncdf_create(name+'.nc',/clobber)
     ncdf_control,id,/fill
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
     ncdf_control,id,/endef
  
     ncdf_varput,id,cfadF_id,CFAD_Full[*,*,4]
     ncdf_varput,id,cfadC_id,CFAD_Core[*,*,4]

     ncdf_close,id
     spawn,'zip -mjq '+name+'.zip '+name+'.nc'
  endif 

end
