PRO mkplotgain,gain,ccd,minen,maxen,bg,ps=ps,ghost=ghost,comment=comment,$ 
               plotfile=plotfile,chatty=chatty
;+
; NAME:            mkspectrum
;
;
;
; PURPOSE:
;                  Plot the gain course derived by mkcalcgain from 
;                  xmm observation data
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  mkplotgain,gdat,0,100.,3000.,2.,/ps,/ghost
;
; 
; INPUTS:
;                  gain   : The gain vactor to be plotted
;                  ccd    : The number of the CCD
;                  minen  : Minimum energy used in mkfitgain to derive
;                           the gain (in ADU)
;                  maxen  : Maximum energy used in mkfitgain to derive 
;                           the gain (in ADU)
;
;
; OPTIONAL INPUTS:
;                 comment : Optional comment, printed in the header of
;                           the plot 
;                 plotfile: Name of the ps-file (default: 'gain.ps')
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on
;                  /ps     : Plot to ps-file 
;                  /ghost  : show ps-file with 'gv'
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;                  none
;
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  mkplotgain,dat,1,10.,3000.,2.,/ps,/ghost
;
;
; MODIFICATION HISTORY:
; V 1.0 14.12.99 M. Kuster first initial version
;-
   
   IF (keyword_set(ps)) THEN psplot=1 ELSE psplot=0
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   IF (NOT keyword_set(plotfile)) THEN plotfile='gain.ps'
   IF (NOT keyword_set(comment)) THEN comment='' 
   
   IF (psplot EQ 1) THEN BEGIN 
       set_plot, 'ps'
       loadct, 13
       plotfile=STRTRIM(plotfile,2)
       print,'% MKPLOTGAIN: Printing to file: ',plotfile
       spawn,"date '+%d %b %Y  %H:%M:%S'",date ; get system date
       user=getenv('USER')      ; get username
       host=getenv('HOST')      ; get hostname
       
       device, bits_per_pixel=8,/COLOR, XSIZE=20.0, YSIZE=29, /PORTRAIT, $
         FILE=plotfile,xoffset=0.5,yoffset=0
       !p.font=0                ; Use Helvetica
   ENDIF 
   pgain=1.d0/gain
   
   mingain=min(gain)
   maxgain=max(gain)
   mingain=mingain-mingain*0.02   
   maxgain=maxgain+maxgain*0.02
   
   plot,pgain, /YNOZERO, /XSTYLE, XRANGE = [0, 63], $
     yrange=[mingain,maxgain],$
     XTITLE = 'Column No.', PSYM = 10, YTITLE = 'Gain factor', $
     TITLE = 'Gain Course', POSITION=[.10, 0.40, .96, .80]
   
   ;; search for NaNs and mark them as not valid data
   indfail=where(finite(gain) EQ 0,numfail)
   center=(mingain+maxgain)/2.
   IF numfail GT 0 THEN BEGIN 
       XYOUTS,indfail+.5,center ,$
         'bad channel', ORIENTATION = 90, /DATA, COLOR =250, CHARTHICK=2, $
         ALIGNMENT = .5, CHARSIZE = 1.0
   ENDIF 
   
   xyouts,.10,.92, 'CCD No.: '+STRING(format='(I2)',ccd),charsize=0.9, $
     alignment=0.,/normal
   xyouts,.10,.90, 'Energy Range: '+string(format='(I4)', minen)+' - '+ $
     STRING(format='(I4)', maxen)+' ADC',charsize=0.9, $
     alignment=0.,/normal
   xyouts,.10,.88, 'Bin Size: '+string(format='(I2)', bg),charsize=0.9, $
     alignment=0.,/normal
   IF (psplot EQ 1) THEN BEGIN 
       xyouts,0.10,0.95,'Comment: '+comment,$
         alignment=0.,/normal
       xyouts,0.98,0.03,'IAAT by '+user+'@'+host+' '+date,charsize=0.9, $
         alignment=1.,/normal
       device,/close
       set_plot,'x'
   ENDIF 
   IF (keyword_set(ghost) AND (psplot EQ 1)) THEN BEGIN 
       spawn, 'gv '+plotfile,/sh
   ENDIF
END


