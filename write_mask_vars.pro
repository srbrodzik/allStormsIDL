pro write_mask_vars,ncid

  COMMON maskBlock,bsr_mask,dcc_mask,dwc_mask,wcc_mask,shi_mask,storm_mask

  bsr_id = ncdf_varid(ncid,'bsr_mask_mod')
  if bsr_id ne -1 then ncdf_varput,ncid,bsr_id,bsr_mask
  dcc_id = ncdf_varid(ncid,'dcc_mask_mod')
  if dcc_id ne -1 then ncdf_varput,ncid,dcc_id,dcc_mask
  dwc_id = ncdf_varid(ncid,'dwc_mask_mod')
  if dwc_id ne -1 then ncdf_varput,ncid,dwc_id,dwc_mask
  wcc_id = ncdf_varid(ncid,'wcc_mask_mod')
  if wcc_id ne -1 then ncdf_varput,ncid,wcc_id,wcc_mask
  ;;shi_id = ncdf_varid(ncid,'shi_mask_mod')
  ;;if shi_id ne -1 then ncdf_varput,ncid,shi_id,shi_mask
  storm_id = ncdf_varid(ncid,'storm_mask_mod')
  if storm_id ne -1 then ncdf_varput,ncid,storm_id,storm_mask

  undefine,bsr_mask
  undefine,dcc_mask
  undefine,dwc_mask
  undefine,wcc_mask
  ;;undefine,shi_mask
  undefine,storm_mask

end

