DEBUG = 0           ;;0 (off) or 1 (on)

n_refls = 81        ;;number of refl bins in cfad arrays
nlevels = 176
delta_z = 0.125     ;;in km

res = 0.5           ;;coarse grid resolution
res_f = 0.05d       ;;fine grid resolution

makeCoreMasks = 1   
mask_missing_value = -99.

CV_CALCS = 1        ;;convective calcs (0=do not include; 1=include)
SH_CALCS = 1        ;;shallow isolated calcs (0=do not include; 1=include)
ST_CALCS = 1        ;;stratiform calcs (0=do not include; 1=include)

thres_in_use = 'land'  ;;'land' or 'ocean'

if thres_in_use eq 'land' then begin
   thr_aST=50000.   ;;threshold area to define Broad Stratiform regions
   thr_dbZ=40.      ;;reflectivity threshold for id the convective subset
   thr_hCV=10.      ;;height of the echo top for id deep cores
   thr_aCV=1000.    ;;area  of the echo core for id wide cores
   thr_dCV=5.       ;;min depth (maxHt-minHt) to be considered for DCC category
   output_version='v11s'
endif else begin
   if thres_in_use eq 'ocean' then begin
      thr_aST=40000.   ;;threshold area to define Broad Stratiform regions
      thr_dbZ=30.      ;;reflectivity threshold for id the convective subset
      thr_hCV=8.       ;;height of the echo top for id deep cores
      thr_aCV=800.     ;;area  of the echo core for id wide cores
      thr_dCV=4.       ;;min depth (maxHt-minHt) to be considered for DCC category
      output_version='v11m'
   endif else begin
      print,'Invalid threshold type -- must be land or ocean'
      stop
   endelse
endelse
   
STRA = 10
CONV = 20
OTHER = 30
SHIS = 40

pixKm = 5.5         ;;km
pixArea = pixKm*pixKm
npix_aST = fix(thr_aST/pixArea)
pixDeg = 0.05       ;; deg
secsPerHr = 3600.   ;; seconds

;;variable definition for computation of Rain rates using Z-R method.
;;Values from Romatscke and Houze 2010 
aRR=140     ;; %Z-R relation values for a and b (Z=a*R^b)  other
bRR=1.6     ;;
aRRc=100    ;; %Z-R relation values for a and b (Z=a*R^b) convective
bRRc=1.7    ;;
aRRs=200    ;; %Z-R relation values for a and b (Z=a*R^b) stratiform
bRRs=1.49   ;;

