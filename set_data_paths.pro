pro set_data_paths,region,path_in,path_out

  base_dir = '/home/disk/bob/gpm'

  if region eq 'AFC' then begin
     path_in = base_dir+'/afc_ku/classify/ex_data_v06'
     path_out = base_dir+'/afc_ku/classify/class_data_v06'
  endif else if region eq 'AKA' then begin
     path_in = base_dir+'/aka_ku/classify/ex_data_v06'
     path_out = base_dir+'/aka_ku/classify/class_data_v06'
  endif else if region eq 'CIO' then begin
     path_in = base_dir+'/cio_ku/classify/ex_data_v06'
     path_out = base_dir+'/cio_ku/classify/class_data_v06'
  endif else if region eq 'EPO' then begin
     path_in = base_dir+'/epo_ku/classify/ex_data_v06'
     path_out = base_dir+'/epo_ku/classify/class_data_v06'
  endif else if region eq 'EUR' then begin
     path_in = base_dir+'/eur_ku/classify/ex_data_v06'
     path_out = base_dir+'/eur_ku/classify/class_data_v06'
  endif else if region eq 'H01' then begin
     path_in = base_dir+'/h01_ku/classify/ex_data_v06'
     path_out = base_dir+'/h01_ku/classify/class_data_v06'
  endif else if region eq 'H02' then begin
     path_in = base_dir+'/h02_ku/classify/ex_data_v06'
     path_out = base_dir+'/h02_ku/classify/class_data_v06'
  endif else if region eq 'H03' then begin
     path_in = base_dir+'/h03_ku/classify/ex_data_v06'
     path_out = base_dir+'/h03_ku/classify/class_data_v06'
  endif else if region eq 'H04' then begin
     path_in = base_dir+'/h04_ku/classify/ex_data_v06'
     path_out = base_dir+'/h04_ku/classify/class_data_v06'
  endif else if region eq 'H05' then begin
     path_in = base_dir+'/h05_ku/classify/ex_data_v06'
     path_out = base_dir+'/h05_ku/classify/class_data_v06'
  endif else if region eq 'NAM' then begin
     path_in = base_dir+'/nam_ku/classify/ex_data_v06'
     path_out = base_dir+'/nam_ku/classify/class_data_v06'
  endif else if region eq 'NAS' then begin
     path_in = base_dir+'/nas_ku/classify/ex_data_v06'
     path_out = base_dir+'/nas_ku/classify/class_data_v06'
  endif else if region eq 'SAM' then begin
     path_in = base_dir+'/sam_ku/classify/ex_data_v06_test'
     path_out = base_dir+'/sam_ku/classify/class_data_v06_test'
  endif else if region eq 'SAS' then begin
     path_in = base_dir+'/sas_ku/classify/ex_data_v06'
     path_out = base_dir+'/sas_ku/classify/class_data_v06'
  endif else if region eq 'WMP' then begin
     path_in = base_dir+'/wmp_ku/classify/ex_data_v06'
     path_out = base_dir+'/wmp_ku/classify/class_data_v06'
  endif else begin
     print,'Unknown region ',region,' - path_in and path_out not set . . . exiting'
     stop
  endelse

end
