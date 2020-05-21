pro inc_echo_count,num,d_lonsFull,d_latsFull,dondeRT_RT,mask

  ;; INPUTS: num,d_lonsFull,d_latsFull,dondeRT_RT,mask
  ;; OUTPUTS: num,mask
  ;; INTERNAL: mask_sub
  
  ;; include constants
  @constants.pro

  num = num + 1
  if makeCoreMasks then begin
     mask_sub = mask[d_lonsFull,d_latsFull,0]
     mask_sub[dondeRT_RT]=num
     mask[d_lonsFull,d_latsFull,0] = mask_sub
     undefine,mask_sub
  endif 

end
