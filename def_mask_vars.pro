pro def_mask_vars,ncid,lonDimID,latDimID,timDimID

  ;; include constants
  @constants_ocean.pro
  
  ;; put input file in define mode
  ncdf_control,ncid,/redef
        
  result = ncdf_varid(ncid,'bsr_mask_mod')
  if result eq -1 then begin
     bsr_id = ncdf_vardef(ncid,'bsr_mask_mod',[lonDimID,latDimID,timDimID],/float,gzip=5)
     ncdf_attput,ncid,bsr_id,'_FillValue',mask_missing_value,/float
     ncdf_attput,ncid,bsr_id,'units','none',/char
     ncdf_attput,ncid,bsr_id,'long_name','BroadStratiform Core mask for moderate thresholds',/char
  endif 
  result = ncdf_varid(ncid,'dcc_mask_mod')
  if result eq -1 then begin
     dcc_id = ncdf_vardef(ncid,'dcc_mask_mod',[lonDimID,latDimID,timDimID],/float,gzip=5)
     ncdf_attput,ncid,dcc_id,'_FillValue',mask_missing_value,/float
     ncdf_attput,ncid,dcc_id,'units','none',/char
     ncdf_attput,ncid,dcc_id,'long_name','DeepConvective Core mask for moderate thresholds',/char
  endif 
  result = ncdf_varid(ncid,'dwc_mask_mod')
  if result eq -1 then begin
     dwc_id = ncdf_vardef(ncid,'dwc_mask_mod',[lonDimID,latDimID,timDimID],/float,gzip=5)
     ncdf_attput,ncid,dwc_id,'_FillValue',mask_missing_value,/float
     ncdf_attput,ncid,dwc_id,'units','none',/char
     ncdf_attput,ncid,dwc_id,'long_name','DeepWideConvective Core mask for moderate thresholds',/char
  endif 
  result = ncdf_varid(ncid,'wcc_mask_mod')
  if result eq -1 then begin
     wcc_id = ncdf_vardef(ncid,'wcc_mask_mod',[lonDimID,latDimID,timDimID],/float,gzip=5)
     ncdf_attput,ncid,wcc_id,'_FillValue',mask_missing_value,/float
     ncdf_attput,ncid,wcc_id,'units','none',/char
     ncdf_attput,ncid,wcc_id,'long_name','WideConvective Core mask for moderate thresholds',/char
  endif
  ;;result = ncdf_varid(ncid,'shi_mask_mod')
  ;;if result eq -1 then begin
  ;;   shi_id = ncdf_vardef(ncid,'shi_mask',[lonDimID,latDimID,timDimID],/float,gzip=5)
  ;;   ncdf_attput,ncid,shi_id,'_FillValue',mask_missing_value,/float
  ;;   ncdf_attput,ncid,shi_id,'units','none',/char
  ;;   ncdf_attput,ncid,shi_id,'long_name','ShallowIsolated Core mask',/char
  ;;endif
  result = ncdf_varid(ncid,'storm_mask_mod')
  if result eq -1 then begin
     storm_id = ncdf_vardef(ncid,'storm_mask_mod',[lonDimID,latDimID,timDimID],/float,gzip=5)
     ncdf_attput,ncid,storm_id,'_FillValue',mask_missing_value,/float
     ncdf_attput,ncid,storm_id,'units','none',/char
     ncdf_attput,ncid,storm_id,'long_name','Storm mask for moderate thresholds',/char
  endif 
           
  ;; add global attribute descriptors for masks
  ncdf_attput,ncid,/global,'BroadStratiform_Criteria_Moderate', $
              'contiguous stratiform echo >= 40,000km^2',/char
  ncdf_attput,ncid,/global,'DeepConvective_Criteria_Moderate', $
              'contiguous, convective, 40dBZ echos with max height >= 8km',/char
  ncdf_attput,ncid,/global,'WideConvective_Criteria_Moderate', $
              'contiguous, convective, 40dBZ echos with max horizontal dim >= 800km^2',/char
  ncdf_attput,ncid,/global,'DeepWideConvective_Criteria_Moderate', $
              'meets both DeepConvective_Criteria_Moderate and WideConvective_Criteria_Moderate',/char
        
  ;; put input file in data mode
  ncdf_control,ncid,/endef

end
