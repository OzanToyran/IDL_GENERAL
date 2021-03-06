
PRO read_line_ids, fname, wvl, outstr, range=range, shift=shift, count=count

;+
; NAME
;
;    READ_LINE_IDS
;
; EXPLANATION
;
;    Reads the file specified by FNAME
;    and outputs a structure containing all transitions close to the input 
;    wavelength WVL. The file contains for each transition an approximate 
;    wavelength (to 0.1 angstrom), an ion identifier of the form, e.g., 
;    ca_10, and the CHIANTI level indices of the transition. READ_LINE_IDS 
;    then reads data from the user's version of CHIANTI to determine the 
;    current CHIANTI wavelength of the transition.
;
;    Lines observed in 2nd order are treated as follows. Consider the
;    case of He II 303.79 observed in 2nd order. The line appears in
;    the measured spectrum at 607.58 A, and so the input WVL will be
;    close to this value. In the file FNAME, the wavelength should be
;    given as 607.58 (not 303.79). This then allows the 2nd order line
;    to be correctly matched. Second order lines are flagged by adding
;    "x2" to OUTSTR.STR.
;
;    Third or higher order lines are currently not flagged by this
;    routine. 
;
; INPUTS
;
;    FNAME  The name of the file containing the wavelengths and level 
;           identifiers. The format of the file should be of the form:
;
;           557.8  ca_10    1   3
;           574.0  ca_10    1   2
;
;           i.e., '(f7.0,a6,2i4)'. Wavelengths are given in angstroms,
;           and the third and fourth columns give the CHIANTI indices
;           for the lower and upper levels of the transition (the
;           CHIANTI .wgfa file contains these indices).
;
;    WVL    A wavelength in angstroms. READ_LINE_IDS will search for 
;           transitions in FNAME that lie within in +/- 1 
;           angstrom of this wavelength. This limit can be varied with the 
;           optional input RANGE.
;
; OUTPUTS
;
;    OUTSTR A structure containing information about the transitions lying 
;           close to WVL. The tags are:
;            .name  Name of the ion, e.g., 'Ca X'
;            .wvl   The wavelength of the transition (float).
;            .str   String containing ion and wavelength, e.g., 
;                   'Fe XVI 360.76'.
;            .gf    gf-value for transition
;            .aval  A-value for transition
;            .trans String containing transition information
;            .trans_latex  Transition information in latex format.
;            .lvl1  Lower level of transition
;            .lvl2  Upper level of transition
;
; OPTIONAL INPUTS
;
;    RANGE  By default the routine searches for lines within +/- 1 angstrom 
;           of WVL. RANGE allows this to be varied, e.g., RANGE=0.5.
;
;    SHIFT  When checking to see which lines satisfy RANGE, a velocity SHIFT
;           is included. The units are km/s, and +ve corresponds to a redshift
;           and -ve corresponds to blueshift.
;
; OPTIONAL OUTPUTS
;
;    COUNT  The number of matching lines.
;
; CALLS
;
;    V2LAMB, ION2SPECTROSCOPIC, ION2FILENAME, READ_WGFA2, LEVEL_STRING
;
; RESTRICTIONS
;
;    The line IDs file must have the particular format '(f7.0,a6,2i4)'.
;
; HISTORY
;
;    Ver.1, 6-Nov-2002, Peter Young
;    Ver.2, 17-Jul-2003, Peter Young
;         added FNAME input and removed reference to $CDS_LINE_IDS
;    Ver.3, 11-Dec-2003, Peter Young
;         changed findfile() call to file_search() as findfile was failing
;         to find a file on unix machine.
;    Ver.4, 12-Oct-2004, Peter Young
;         added extra tags to output structure
;    Ver.5, 8-Dec-2006, Peter Young
;         changed maximum size of OUTSTR to 500 (from 20)
;    Ver.6, 27-Oct-2008, Peter Young
;         added lvl1 and lvl2 tags to structure.
;    Ver.7, 7-Apr-2009, Peter Young
;         removed restriction on size of output structure
;    Ver.8, 10-Feb-2012, Peter Young
;         now uses read_wgfa2 instead of read_wgfa; also checks to
;         make sure the CHIANTI wavelength matches the wavelength in
;         FNAME; added COUNT= optional output.
;    Ver.9, 6-Apr-2012, Peter Young
;         fixed bug whereby for loop could leave an empty structure,
;         causing a crash.
;-

COMMON elvlc,l1a,term,conf,ss,ll,jj,ecm,eryd,ecmth,erydth,eref

IF n_params() LT 3 THEN BEGIN
  print,'Use: IDL> read_line_ids, fname, wvl, outstr, range=, shift='
  return
ENDIF


IF n_elements(range) EQ 0 THEN range=1.
IF n_elements(shift) EQ 0 THEN shift=0.

result=file_search(fname)
IF result[0] EQ '' THEN BEGIN
  print,'%READ_LINE_IDS: the specified file does not exist. Returning...'
  return
ENDIF

openr,lun,fname,/get_lun

str={wvl: 0., ion: '', l1: 0, l2: 0}
data=0

i=0
w=0.
ion=''
l1=0
l2=0
WHILE eof(lun) NE 1 DO BEGIN
  readf,lun,format='(f7.0,a6,2i4)',str
 ;
  IF n_tags(data) EQ 0 THEN data=str ELSE data=[data,str]
ENDWHILE
free_lun,lun


;data=data[0:i-1]

str={name: '', wvl: 0., str: '', gf: 0., aval: 0., trans: '', $
    trans_latex: '', lvl1: 0, lvl2: 0}
outstr=0

wvlshift=v2lamb(shift,wvl)

ind=where(abs(wvl-data.wvl-wvlshift) LT range)

count=0

IF ind[0] NE -1 THEN BEGIN
  n=n_elements(ind)
  FOR i=0,n-1 DO BEGIN
    l1=data[ind[i]].l1
    l2=data[ind[i]].l2
    ion=trim(data[ind[i]].ion)
    ion2filename,data[ind[i]].ion,rootname
    ion2spectroscopic,data[ind[i]].ion,iname
    file=strtrim(rootname,2)+'.wgfa'
    read_wgfa2,file,lvl1,lvl2,ww,gf,a_value,ref
   ;
    k=where(lvl1 EQ l1 AND lvl2 EQ l2,nk)
    IF nk NE 0 THEN BEGIN
      IF nk GT 1 THEN BEGIN
        chckwvl=ww[k]
        ichck=where(chckwvl NE 0.,nchck)
        IF nchck EQ 0 THEN GOTO,lbl1
        k=k[ichck[0]]
      ENDIF 
     ;
      str.wvl=abs(ww[k])  ; this allows negative wavelengths to match
      IF abs(wvl-wvlshift-str.wvl) LT range OR abs((wvl-wvlshift)-str.wvl*2) LT range*2. THEN BEGIN
        str.name=strtrim(iname,2)
        str.gf=gf[k]
        str.aval=a_value[k]
        str.trans=level_string(ion,l1)+' - '+ $
                    level_string(ion,l2)
        read_elvlc,trim(rootname)+'.elvlc',l1a,term,conf,ss,ll,jj,ecm,eryd,ecmth,erydth,eref
        result=convert_terms(l1,l2,result_latex=result_latex)
        str.trans_latex=result_latex
        str.lvl1=l1
        str.lvl2=l2
       ;
        IF abs((wvl-wvlshift)-str.wvl*2) LT range*2. THEN addstr='x2' ELSE addstr=''
        str.str=strtrim(iname,2)+' '+ $
                strtrim(string(format='(f12.2)',str.wvl),2)+addstr
       ;       
        IF n_tags(outstr) EQ 0 THEN outstr=str ELSE outstr=[outstr,str]
  
      ENDIF 
    ENDIF 
    lbl1: 
  ENDFOR
 ;
  IF n_tags(outstr) NE 0 THEN BEGIN 
    chck=abs(outstr.wvl-wvl)
    ii=sort(chck)
    outstr=outstr[ii]
    count=n_elements(outstr)
  ENDIF ELSE BEGIN
    outstr=-1
  ENDELSE 
ENDIF ELSE outstr=-1


END
  
