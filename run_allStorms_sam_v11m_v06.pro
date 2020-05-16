pro run_allStorms_sam_v11m_v06

  ;;-------------------------------------
  ;; BEFORE RUNNING:
  ;; 1. Check values in constants_xxx.pro
  ;; 2. Check paths in set_data_paths.pro
  ;;-------------------------------------
  
  ;;  .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/run_allStorms_sam_v11m_v06

  resolve_routine,'findStorm'          ;;  .r /home/disk/shear2/brodzik/IDL/gpm/findStorm
  resolve_routine,'findStormNew'       ;;  .r /home/disk/shear2/brodzik/IDL/gpm/findStormNew
  resolve_routine,'set_data_paths'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_data_paths
  resolve_routine,'set_topo_file'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_topo_file
  resolve_routine,'read_topo_file'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/read_topo_file
  resolve_routine,'initialize_matrices';; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/initialize_matrices
  resolve_routine,'define_grids'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/define_grids
  resolve_routine,'set_limits'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_limits
  resolve_routine,'read_nc_file'       ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/read_nc_file
  resolve_routine,'def_mask_vars'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/def_mask_vars
  resolve_routine,'stra_class'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/stra_class
  resolve_routine,'conv_class'         ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/conv_class
  resolve_routine,'shal_iso_class'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/shal_iso_class
  resolve_routine,'write_mask_vars'    ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/write_mask_vars
  resolve_routine,'output_monthly_class_data' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_monthly_class_data
  resolve_routine,'output_nsr_data'    ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_nsr_data
  resolve_routine,'output_raccum_data' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_raccum_data
  resolve_routine,'output_cfad_data'   ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_cfad_data
  resolve_routine,'get_subgrid_storm'  ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_subgrid_storm
  resolve_routine,'get_storm_info'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_storm_info
  resolve_routine,'get_core_dims'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_core_dims
  resolve_routine,'inc_echo_count'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/inc_echo_count
  resolve_routine,'get_str_shape'      ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_str_shape
  resolve_routine,'get_class_stats'    ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_class_stats
  resolve_routine,'get_rain_accum'     ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_accum
  resolve_routine,'get_rain_statistics';; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_statistics
  resolve_routine,'get_cfad'           ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_cfad
  resolve_routine,'allStorms_v11m_v06' ;; .r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/allStorms_v11m_v06

  ;; FOR TESTING ONLY
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/findStorm
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/findStormNew
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_data_paths
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_topo_file
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/read_topo_file
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/initialize_matrices
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/define_grids
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/set_limits
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/read_nc_file
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/def_mask_vars
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/stra_class
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/conv_class
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/shal_iso_class
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/write_mask_vars
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_monthly_class_data
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_nsr_data
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_raccum_data
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/output_cfad_data
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_subgrid_storm
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_storm_info
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_core_dims
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/inc_echo_count
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_str_shape
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_class_stats
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_accum
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_rain_statistics
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/get_cfad
  ;;.r /home/disk/shear2/brodzik/IDL/gpm/allStorms/OceanRunsTest/allStorms_v11m_v06

  ;;years=['2014','2015','2016','2017','2018']
  year=['2019']
  month=['12']
  region = 'SAM'
  
  for yy=0,n_elements(year)-1 do begin

     ;;if year[yy] eq '2019' then month = ['12'] else  $
        ;;if year[yy] eq '2020' then month = ['01'] else  $
           ;;month=['01','02','03','04','05','06','07','08','09','10','11','12']

     for mm=0,n_elements(month)-1 do begin
        allStorms_v11m_v06,year=year[yy],month=month[mm],region=region
     endfor

  endfor

end


;; directory
;path_in='/home/disk/bob/gpm/sam_ku/classify/ex_data_v06_test/'
;path_out='/home/disk/bob/gpm/sam_ku/classify/class_data_v06_test/'


