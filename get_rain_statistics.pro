pro get_rain_statistics,RTo_stra,RTo_conv,RTo_othe,RTo_noRa,$
                        ctaStra,ctaConv,ctaOthe,ctaNoRa,$
                        m_RainAll,m_RainStrt,m_RainConv,$
                        vol_Rain_All,vol_Rain_Str,vol_Rain_Con,$
                        lon,lat

  ;; NOTE: couldn't name this 'get_rain_stats' because got erro
  ;; saying 'Incorrect number of arguments'
  ;; Is there a system routine called 'get_rain_stats'?
  
  ;; include constants
  @constants.pro

  total_RainAll = RTo_stra + RTo_conv + RTo_othe + RTo_noRa
  total_RainCSs = RTo_stra + RTo_conv
  ;; calculate mean rainfall for all/stra/conv pixels
  m_RainAll = total_RainAll/float(ctaStra + ctaConv + ctaOthe + ctaNoRa)
  if ctaStra ne 0 then m_RainStrt = RTo_stra/ctaStra else m_RainStrt = 0.
  if ctaConv ne 0 then m_RainConv = RTo_conv/ctaConv else m_RainConv = 0.
  if ctaStra ne 0 or ctaConv ne 0 then $
     m_RainCSs = total_RainCSs/float(ctaStra + ctaConv) else m_RainCSs = -999.
  ;; calculate volumetric values of all/stra/conv rain [1e6*kg/s]
  size_pixels = deg2km(pixDeg,lon,lat)
  vol_Rain_All = total_RainAll*(size_pixels[0]*size_pixels[1])/secsPerHr
  vol_Rain_Str = RTo_stra*(size_pixels[0]*size_pixels[1])/secsPerHr
  vol_Rain_Con = RTo_conv*(size_pixels[0]*size_pixels[1])/secsPerHr
  
end
