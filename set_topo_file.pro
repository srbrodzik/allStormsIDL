pro set_topo_file,region,topo_file

  ;;topo_base_dir = '/home/disk/radar/data/GTOPO30'
  topo_base_dir = '/home/disk/shear2/brodzik/GTOPO30'

  if region eq 'AFC' then topo_base_file = 'gtopo5km_AFC_gpm.hdf' else $
  if region eq 'AKA' then topo_base_file = 'gtopo5km_AKA_gpm.hdf' else $
  if region eq 'CIO' then topo_base_file = 'gtopo5km_CIO_gpm.hdf' else $
  if region eq 'EPO' then topo_base_file = 'gtopo5km_EPO_gpm.hdf' else $
  if region eq 'EUR' then topo_base_file = 'gtopo5km_EUR_gpm.hdf' else $
  if region eq 'H01' then topo_base_file = 'gtopo5km_H01_gpm.hdf' else $
  if region eq 'H02' then topo_base_file = 'gtopo5km_H02_gpm.hdf' else $
  if region eq 'H03' then topo_base_file = 'gtopo5km_H03_gpm.hdf' else $
  if region eq 'H04' then topo_base_file = 'gtopo5km_H04_gpm.hdf' else $
  if region eq 'H05' then topo_base_file = 'gtopo5km_H05_gpm_v06.hdf' else $   ;; NEW
  if region eq 'NAM' then topo_base_file = 'gtopo5km_NAM_gpm.hdf' else $
  if region eq 'NAS' then topo_base_file = 'gtopo5km_NAS_gpm.hdf' else $
  if region eq 'SAM' then topo_base_file = 'gtopo5km_SAM_gpm.hdf' else $
  if region eq 'SAS' then topo_base_file = 'gtopo5km_SAS_gpm.hdf' else $
  if region eq 'WMP' then topo_base_file = 'gtopo5km_WMP_gpm_v06.hdf' else begin $
     print,'Unknown region ',region,' - topo_file not set . . . exiting'
     stop
  endelse

  topo_file = topo_base_dir+'/'+topo_base_file
  
end
