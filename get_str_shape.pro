pro get_str_shape,singlestormgrid_Full,lonsFull_sub,latsFull_sub,$
                  pixelsum,cen_lon,cen_lat,area,dim_lon,dim_lat,$
                  dim_top,dim_bot,terr_hgt,land_ocean

  ;; INPUTS: singlestormgrid_Full,lonsFull_sub,latsFull_sub,pixelsum
  ;; OUTPUTS: cen_lon,cen_lat,pixelsum,area,dim_lon,dim_lat,
  ;;          dim_top,dim_bot,terr_hgt,land_ocean
  ;; INTERNAL: lon_sum,lat_sum,hgt_sum,id_top1,id_top2

  COMMON topoBlock,topo_lat,topo_lon,DEM
  COMMON ncInfoBlock,nlons,nlats,nalts,ntimes,lats,lons,hgts,raintype,raintype_fillValue, $
     raintype_noRainValue,SrfRain,SrfRain_fillValue,refl_3D,refl_3D_fillValue, $
     cta_strt,cta_conv,cta_ShIs,rain_type3D,hgts_3D

  ;; include constants
  @constants_ocean.pro

  print,'Top of get_str_shape'
  
  ;; find center of storm area
  lon_sum=total(total(singlestormgrid_Full,2),2)
  cen_lon=(max(lonsFull_sub[where(lon_sum gt 0l)])+min(lonsFull_sub[where(lon_sum gt 0l)]))/2.
  lat_sum=total(total(singlestormgrid_Full,1),2)  
  cen_lat=(max(latsFull_sub[where(lat_sum gt 0l)])+min(latsFull_sub[where(lat_sum gt 0l)]))/2.
                 
  ;; find horizontal area in km  
  size_pixels=deg2km(pixDeg,cen_lon,cen_lat)
  area=pixelsum*size_pixels[0]*size_pixels[1]
     
  ;; calculate dimensions for storm pixels in the cluster
  dim_lon=(max(lonsFull_sub[where(lon_sum gt 0l)])-min(lonsFull_sub[where(lon_sum gt 0l)]))+pixDeg
  dim_lat=(max(latsFull_sub[where(lat_sum gt 0l)])-min(latsFull_sub[where(lat_sum gt 0l)]))+pixDeg

  ;; find vertical extent in km
  hgt_sum=total(total(singlestormgrid_Full,2),1)
  dim_hgt=(max(hgts[where(hgt_sum gt 0l)])-min(hgts[where(hgt_sum gt 0l)]))
  dim_top=max(hgts[where(hgt_sum gt 0l)])
  dim_bot=min(hgts[where(hgt_sum gt 0l)])

  ;; calculate elevation (meters) of terrain for center of the storm
  id_top1=(where(topo_lon ge cen_lon))[0]
  id_top2=(where(topo_lat ge cen_lat))[0]
  terr_hgt=DEM[id_top1,id_top2]
  ;; set ocean/land mask (ocean=0 or land=1)
  if terr_hgt eq 0 then land_ocean=0 else land_ocean=1

  print,'Bottom of get_str_shape:'
  help,cen_lon,cen_lat,area,dim_top,dim_bot,dim_lon,dim_lat,terr_hgt,land_ocean

end
