pro define_grids,limits

  COMMON coarseBlock,lonsC,latsC,nlonsC,nlatsC,freq_Full,freq_Core
  COMMON fineBlock,lonsF,latsF,nlonsF,nlatsF, $
     rain_NSRFull,nRai_NSRFull,rain_NSRCore,nRai_NSRCore

  ;; include constants
  @constants_ocean.pro
  
  lonsC=findgen(fix(1l+(limits[3]-limits[1])/res))*res+limits[1]
  latsC=findgen(fix(1l+(limits[2]-limits[0])/res))*res+limits[0]
  nlonsC=fix(1l+(limits[3]-limits[1])/res)
  nlatsC=fix(1l+(limits[2]-limits[0])/res)

  lonsF=findgen(fix(1l+(limits[3]-limits[1])/res_f))*res_f+limits[1]
  latsF=findgen(fix(1l+(limits[2]-limits[0])/res_f))*res_f+limits[0]
  nlonsF=fix(1l+(limits[3]-limits[1])/res_f)
  nlatsF=fix(1l+(limits[2]-limits[0])/res_f)

end

