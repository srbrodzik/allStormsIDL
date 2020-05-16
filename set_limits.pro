pro set_limits,region,limits

  if region eq 'AFC' then limits = [-40.0, -30.0, 40.0,  60.0] else $
  if region eq 'AKA' then limits = [ 35.0,-178.0, 67.0,-115.0] else $
  if region eq 'CIO' then limits = [-40.0,  55.0, 10.0, 110.0] else $
  if region eq 'EPO' then limits = [-67.0,-178.0, 45.0,-130.0] else $
  if region eq 'EUR' then limits = [ 35.0, -20.0, 67.0,  45.0] else $
  if region eq 'H01' then limits = [-67.0,-140.0, 25.0, -85.0] else $
  if region eq 'H02' then limits = [ 15.0, -65.0, 67.0, -10.0] else $
  if region eq 'H03' then limits = [-67.0, -30.0,-35.0,  75.0] else $
  if region eq 'H04' then limits = [-67.0,  70.0,-35.0, 178.0] else $
  if region eq 'H05' then limits = [  5.0, 125.0, 40.0, 178.0] else $
  if region eq 'NAM' then limits = [ 15.0,-140.0, 67.0, -55.0] else $
  if region eq 'NAS' then limits = [ 35.0,  40.0, 67.0, 178.0] else $
  if region eq 'SAM' then limits = [-67.0, -95.0, 20.0, -25.0] else $
  if region eq 'SAS' then limits = [  5.0,  55.0, 40.0, 130.0] else $
  if region eq 'WMP' then limits = [-40.0, 105.0, 10.0, 178.0] else begin $
     print,'Unknown region ',region,' - limits not set . . . exiting'
     stop
  endelse
  
end
