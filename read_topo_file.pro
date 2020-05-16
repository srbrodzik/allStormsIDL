pro read_topo_file,topo_file

  COMMON topoBlock,topo_lat,topo_lon,DEM

  sdsfileid = hdf_sd_start(topo_file,/read)
  hdf_sd_fileinfo,sdsfileid,numsds,ngatt
  sds_id= hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid,'Latitude'))
  hdf_sd_getdata,sds_id,topo_lat
  sds_id= hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid,'Longitude'))
  hdf_sd_getdata,sds_id,topo_lon
  sds_id= hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid,'elevation'))
  hdf_sd_getdata,sds_id,DEM
  hdf_sd_end, sdsfileid
  DEM[where(DEM le 0l)]=0l       ;;here I set all <0 as sea level!!

end
