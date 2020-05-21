pro allStorms_v11_v06,year=year,month=month,region=region

  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRuns/allStorms_sam_v11_v06

  ;;allStorms_sam_v11_v06,type='03_2014_SAM'

  ;;NOTE from M Zuluaga about volume calculations (e.g. vol_Rain_All with units of 10^6 kg/s):
  ;;"That unit of rainfall is called Rainfall Productivity that is
  ;;[i.e., rain rate (kg m^-2 s^-1) x area (m2 )].
  ;;This is to follow Romatschke and Houze 2011. If you work out the units, you'll get that.
  ;;Multiply the rainfall rate (mm/hr) times the density of water (to get a volume)."
  
  if not keyword_set(year) or not keyword_set(month) or not keyword_set(region) then begin
     print,'keywords YEAR (yyyy), MONTH (mm) and REGION [AFC,AKA,CIO,EPO,EUR,H01,H02,H03,H04,H05,NAM,NAS,SAM,SAS,WMP] required'
     stop
  end

  ;;year='2019'
  ;;month='12'
  ;;region = 'SAM'

  ;; Define COMMON blocks
  COMMON topoBlock,topo_lat,topo_lon,DEM
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
  COMMON cfadBlock,alts_CFAD,refl_CFAD,CFAD_Full,CFAD_Core
  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF,rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D
  COMMON maskBlock,bsr_mask,dcc_mask,dwc_mask,wcc_mask,shi_mask,storm_mask

  resolve_routine,'findStorm'          ;; .r /home/disk/shear2/brodzik/IDL/gpm/findStorm
  resolve_routine,'findStormNew'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/findStormNew
  resolve_routine,'set_data_paths'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/set_data_paths
  resolve_routine,'set_topo_file'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/set_topo_file
  resolve_routine,'read_topo_file'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/read_topo_file
  resolve_routine,'initialize_matrices';; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/initialize_matrices
  resolve_routine,'define_grids'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/define_grids
  resolve_routine,'set_limits'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/set_limits
  resolve_routine,'read_nc_file'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/read_nc_file
  resolve_routine,'def_mask_vars'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/def_mask_vars
  resolve_routine,'stra_class'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/stra_class
  resolve_routine,'conv_class'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/conv_class
  resolve_routine,'shal_iso_class'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/shal_iso_class
  resolve_routine,'write_mask_vars'    ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/write_mask_vars
  resolve_routine,'output_monthly_class_data' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/output_monthly_class_data
  resolve_routine,'output_nsr_data'    ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/output_nsr_data
  resolve_routine,'output_raccum_data' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/output_raccum_data
  resolve_routine,'output_cfad_data'   ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/ModularCode/output_cfad_data

  close,/all
  startTime=systime(/utc)
  print,'start='+startTime

  ;;include constants
  @constants.pro
  
  ;;*************************NO NEED TO EDIT ANYTHING BELOW THIS LINE*************************

  ;;set data paths
  set_data_paths,region,path_in,path_out
  
  ;;read the topography data
  set_topo_file,region,topo_file
  read_topo_file,topo_file
  
  ;;get limits for region
  set_limits,region,limits
  
  ;;define coarse and fine matrices
  define_grids,limits

  ;;initialize output matrices
  initialize_matrices

  ;;get list of files for processing
  path=path_in+'/'+year+'/'+month
  cd,path
  files=findfile('*.nc',count=countNfiles)

  ;;process each file (file convention example: GPM2Ku6_uw3_20140330.072721_to_20140330.072843_000477_SAM.nc
  for ff=0l,countNfiles-1 do begin
     csa=str_sep(files[ff],'_')
     suffix = str_sep(csa[6],'.')
     ;; filen is filename without .nc suffix
     filen=csa[0]+'_'+csa[1]+'_'+csa[2]+'_'+csa[3]+'_'+csa[4]+'_'+csa[5]+'_'+suffix[0] 
     orbit=csa[5] & datetime=csa[2]
     print,'analyzing '+region+' region with allStorms_v11_v06 for orbit='+orbit+' datetime='+datetime+$
           ' for file='+strtrim(ff+1,2)+'/'+strtrim(countNfiles,2)

     ;; open netcdf file
     if makeCoreMasks then begin
        ncid = ncdf_open(path+'/'+filen+'.nc',/write)
     endif else begin
        ncid = ncdf_open(path+'/'+filen+'.nc',/nowrite)
     endelse

     ;; read netcdf file
     read_nc_file,ncid,lonDimID,latDimID,timDimID
     
     ;; define new variables for masks(if makeCoreMasks is set)
     if makeCoreMasks then begin     
        def_mask_vars,ncid,lonDimID,latDimID,timDimID
     
        ;; allocate space for mask arrays
        bsr_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
        dcc_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
        dwc_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
        wcc_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
        ;;shi_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
        storm_mask = make_array(nlons,nlats,ntimes,/float,value=mask_missing_value)
     endif 
        
     ;; initialize storm count
     num_storm = 0
     
     ;;********************
     ;;Start Classification 
     ;;********************
     refl_Rain=refl_3D
     ;; count pixels with refl ge 0
     ind_refl_ge_0 = where(refl_Rain ge 0.,cta_refl_ge_0)

     ;; proceed if at least 2 pixels with refl >= 0
     if cta_refl_ge_0 gt 2 then begin
        
        ;; set pixels where refl lt 0 to refl_3D_fillValue
        refl_Rain[where(refl_3D lt 0.)]=refl_3D_fillValue
        ;; find unique storms in the swath
        ;; SRB Check why including missing val causes errors
        findStormNew,refl_3D=refl_Rain,$
                     ;;refl_3D_fillValue=refl_3D_fillValue,$
                     id_storm=id_storm,$
                     npix_str=npix_str,$
                     grid_storm=grid_storm

        ;; set NaNs to zero in grid_storm matrix 
        searchNaN=where(grid_storm lt 0, nanCnt)
        if nanCnt gt 0 then grid_storm[searchNaN]=0l
        undefine,searchNaN

        ;;*******************
        print,'Id-Stratiform'
        ;;*******************
        if ST_CALCS then stra_class,id_storm,npix_str,grid_storm,num_storm
        
        ;;*******************
        print,'Id-Convective'
        ;;*******************
        if CV_CALCS then conv_class,id_storm,npix_str,grid_storm,num_storm
        
        ;;*********************
        print,'Id-Shallow Isol'
        ;;*********************
        if SH_CALCS then shal_iso_class,id_storm,npix_str,grid_storm,num_storm

        ;; clear findStorms vars
        undefine,grid_storm
        undefine,npix_str
        undefine,id_storm
        
     endif    ;;end if of pixels with reflectivity greater than 0 (its raining) ;;***********

     ;; clear netcdf data
     undefine,lons
     undefine,lats
     undefine,hgts
     undefine,raintype
     undefine,SrfRain
     undefine,refl_3D
     undefine,rain_type3D
     undefine,hgts_3D

     ;; Write mask info to input file and deallocate mask arrays
     if makeCoreMasks then begin
        write_mask_vars,ncid
     endif 

     ;; close input file
     ncdf_close,ncid
     
  endfor     ;;end for multiples file orbits within the directory (year-month)
  
  ;;*********************************************************************************************************************
  ;; Output results to files
  output_monthly_class_data,path_out,year,month,region
  output_nsr_data,path_out,year,month,region       ;; needs mods to 7th element of .rain output
  output_raccum_data,path_out,year,month,region    ;; needs mods to both core and full
  output_cfad_data,path_out,year,month,region      ;; needs mods to both core and full
  ;;*********************************************************************************************************************
     
  print,'start='+startTime
  print,'end  ='+systime(/utc)

end

function deg2km,deg,lon,lat
  ;;**Function to compute the distance in km from a distance in degrees for a region of
  ;;**the Earth centered at the lat-lon coordinates
  ;;kms[0] - Zonal distance (Equivalent of 1°) in kilometers at given Lon, Lat
  ;;kms[1] - meridional distance (Equivalent of 1° )in Kiometers at given Lon, Lat and
  ;;Re=6378.137   ;;this is the earth's radius at the equator   
  Re=6371.      ;;mean earth radius (this is equivalent to the matlab function)
  kms=fltarr(2)
  kms[0]=Re/(180.0/!pi)
  kms[1]=(Re/(180.0/!pi))*cos(lat*(!pi/180))
  kms=deg*kms
  return,kms
end

PRO undefine, varname  
  tempvar = SIZE(TEMPORARY(varname))
END


