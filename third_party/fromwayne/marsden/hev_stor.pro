pro hev_stor,dc_,opt_,int_,counts_,lvtme_,idfs_,idfe_,disp_,$
                a_counts_,a_lvtme_,det_,rt_,ltime_,cp_,dt_,num_dets_,$
                rates0_,rates1_,num_chns_,num_spec_,det_str_,fnme_
;***************************************************************************
; Program loads the Histogram data variables into the 
; common block necessary for program execution. 
; 6/10/94 Current version
;First the common block:
;***************************************************************************
common hev_block,dc,opt,int,counts,lvtme,idfs,idfe,disp,a_counts,$
                    a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,$
                    num_chns,num_spec,det_str,fnme
;***************************************************************************
; Now assign the variables
;***************************************************************************
dc = dc_
opt = opt_
int = int_
counts = counts_
lvtme = lvtme_
idfs = idfs_
idfe = idfe_
disp = disp_
a_counts = a_counts_
a_lvtme = a_lvtme_
det = det_
rt = rt_
ltime = ltime_
cp = cp_
dt = dt_
num_dets = num_dets_
rates0 = rates0_
rates1 = rates1_
num_chns = num_chns_
num_spec = num_spec_
det_str = det_str_
fnme = fnme_
;***************************************************************************
; Thats all ffolks
;***************************************************************************
return
end