pro read_nc_file,ncid,lonDimID,latDimID,timDimID

  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants.pro

  ;; get file dimensions
  lonDimID = ncdf_dimid(ncid,'lon')
  ncdf_diminq,ncid,lonDimID,name,nlons  ;; nlon is old n_col
  latDimID = ncdf_dimid(ncid,'lat')
  ncdf_diminq,ncid,latDimID,name,nlats  ;; nlat is old n_row
  altDimID = ncdf_dimid(ncid,'alt')
  ncdf_diminq,ncid,altDimID,name,nalts
  timDimID = ncdf_dimid(ncid,'time')
  ncdf_diminq,ncid,timDimID,name,ntimes

  ;; get vars
  latID = ncdf_varid(ncid,'lat')
  ncdf_varget,ncid,latID,lats
  lonID = ncdf_varid(ncid,'lon')
  ncdf_varget,ncid,lonID,lons
  hgts=findgen(nlevels)*delta_z                 ;; this is kilometers CHANGE hgts to alts

  raintypeID = ncdf_varid(ncid,'rain_type_raw') ;; CHANGE var name used to be rain_type_orig
  ncdf_varget,ncid,raintypeID,raintype
  ncdf_attget,ncid,raintypeID,'_FillValue',raintype_fillValue
  ncdf_attget,ncid,raintypeID,'no_rain_value',raintype_noRainValue
  shallow_rtypeID = ncdf_varid(ncid,'shallow_rain_type')
  ncdf_varget,ncid,shallow_rtypeID,shallow_raintype
  
  surf_rainID = ncdf_varid(ncid,'near_surf_rain')
  ncdf_varget,ncid,surf_rainID,SrfRain    ;; CHANGE var name to near_surf_rain
  ncdf_attget,ncid,surf_rainID,'_FillValue',SrfRain_fillValue
  
  reflID = ncdf_varid(ncid,'refl')        ;; CHANGE var name used to be maxdz
  ncdf_varget,ncid,reflID,refl_3D
  ncdf_attget,ncid,reflID,'_FillValue',refl_3D_fillValue

  ;;this uses the native raintype data to select more categories..
  d_strt=where(raintype ge 10000000 and raintype lt 20000000,cta_strt)
  d_conv=where(raintype ge 20000000 and raintype lt 30000000,cta_conv)
  ;;d_NoShal=where(shallow_raintype eq 0,cta_NoShal)                       ;;no shallow rain (0)
  ;;d_Shal=where(shallow_raintype eq 10 or shallow_raintype eq 11 or $
  ;;             shallow_raintype eq 20 or shallow_raintype eq 21,cta_Shal)  ;;shallow rain (10,11,20,21)
  d_ShIs=where(shallow_raintype eq 10 or shallow_raintype eq 11,cta_ShIs)  ;;shallow Isolated rain (10,11)
  ;;d_ShNi=where(shallow_raintype eq 20 or shallow_raintype eq 21,cta_ShNi);;shallow Non-Iso rain (20,21)
  d_othe=where(raintype ge 30000000,cta_othe)
  
  if cta_strt ne 0 then raintype[d_strt]=STRA     ;;stratiform
  if cta_conv ne 0 then raintype[d_conv]=CONV     ;;convective
  if cta_othe ne 0 then raintype[d_othe]=OTHER    ;;Others

  ;;this are the definitions for shallow rain
  ;;if cta_Shal ne 0 then raintype[d_Shal]=SHIS   ;;Shallow
  if cta_ShIs ne 0 then raintype[d_ShIs]=SHIS     ;;Shallow Isolated
  ;;if cta_ShNi ne 0 then raintype[d_ShNi]=SHIS   ;;Shallow Non-Isolated
  
  rain_type3D=lonarr(nlons,nlats,nlevels)
  for i=0,nlevels-1 do rain_type3D[*,*,i]=raintype

  hgts_3D=fltarr(nlons,nlats,nlevels)
  for i=0l,nlevels-1l do hgts_3D[*,*,i]=hgts[i]

  undefine,d_strt
  undefine,d_conv
  ;;undefine,d_NoShal
  ;;undefine,d_Shal
  undefine,d_ShIs
  ;;undefine,d_ShNi
  undefine,d_othe
  ;;undefine,d_noRa
  
end
