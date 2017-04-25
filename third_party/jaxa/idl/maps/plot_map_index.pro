;+
; Project     : SOHO_CDS
;
; Name        : PLOT_MAP_INDEX
;
; Purpose     : Plot an image map
;
; Category    : imaging
;
; Syntax      : plot_map,map
;
; Inputs      : MAP = image structure map created by MAKE_MAP
;
; Keywords    :
;     /OVERLAY = overlay on previous image
;     /CONT = contour the image
;     SMOOTH_WIDTH = smoothing width (> 1)
;     FOV = [fx,fy] = field of view to be plotted
;     GRID_SPACING = grid spacing (deg) for latitude-longitude grid [def= 0, no grid]
;     GLABEL = label grid with coordinate values [def = 0, no labels]
;     GSTYLE = grid linestyle [def=0]
;     CENTER = [xc,yc] = center coordinates (arcsec) of FOV [def = center of image]
;            (if center is a valid map, then use its center)
;     DMIN,DMAX = min, max data for plot [def = data min,max]
;     BORDER = draw border around image [def = no]
;     /DEBUG = turn on extra debugging
;     /TAIL = allows user to tailor contours
;     /LOG_SCALE  = log_10 scale image
;     WINDOW = window index to send plot to
;     /NOAXES = inhibit plotting axes
;     /NODATA = inhibit plotting data (don't plot anything)
;     /NO_DATA = inhibit plotting data (but include axes, grid, etc) 
;     /NOTITLE = inhibit printing title
;     /NOLABELS = inhibit axis labels
;     /NOXTICKS = inhibit X-tick labels
;     /NOYTICKS = inhibit Y-tick labels
;     /DROTATE  = solar rotate image contour
;     LEVELS  = user specified contour levels
;     NLEVELS = # of default levels [def=10]
;     /PLUS_ONLY = plot positive data
;     /MINUS_ONLY = plot negative data
;     XRANGE,YRANGE = cartesian plot limits
;     /INTERLACE = interlace two images when overlaying
;     /COMPOSITE = simultaneously plot two images when overlaying
;                = type of compositing:
;                  1: original , 2: latest(new), 3: max(new/old) 4: min(new/old)
;     /AVERAGE   = average two images when using /COMPOSITE
;     BOTTOM = lowermost color index to use in color scaling [def=0]
;     LAST_SCALE = use MIN/MAX from previous plot
;     LIMB_PLOT = overplot solar limb
;     BTHICK = border thickness
;     BCOLOR = border line color (defaults to white)
;     LCOLOR = limb line color
;     LTHICK = limb line thickness
;     MULTI = set for multiple plots per page, e.g. mult=[2,2] (or 2) for 4
;             plots per page (!p.multi remains at this value until cleared)
;     NOERASE = don't erase previous plot
;     SQUARE_SCALE = force equal aspect ratio (def)
;     ERR_MSG = String error message if any
;     STATUS = 0/1 means failure/success
;     CBAR = 0/1 means draw colorbar on image plots (only works in > IDL 5.2)
;     PERCENT = if levels are entered, they are in % of data max
;     MARK_POINT = if set to a 2-element array, it is the x,y data coords of a point to be marked
;        If point is not within plot, and arrow off edge of plot shows direction to point.
;     DURTITLE = If set, plot title will include duration of image.  Title will be
;        map.id +  dd-mmm-yy hh:mm:ss-hh:mm:ss
;     NO_BYTE_SCALE = set to not byte scale images
;     ALPHA = transparency factor between 0 and 1 to blend to images.
;     XSHIFT, YSHIFT = translation shifts (arcecs) to input map (positive in
;     X and Y). 
;     ROLL_ANGLE = angle (degrees) to rotate input map (positive clockwise).
;     NO_FILL = don't fill area outside of plot box with background.
;     RED, GREEN, BLUE = (R,G,B) color arrays
;     TRUE_COLORS = display using true colors
;     BLEND = blend overlayed image with base image
;
; Restrictions:
;      - do not set /OVERLAY unless a plot exists on the current device
;
; History     : Written 22 December 1996, D. Zarro, SAC/GSFC
;             : S.L.Freeland - let COMPOSITE have different interpretations
;             : Major modifications 15 Feb 1999, Zarro (SM&A/GSFC)
;                -- reorganized
;                -- sped-up sub-field extraction
;                -- fixed potential bug in contour levels scaling
;                -- fixed potential bug in image color scaling
;                -- fixed roll correction
;             : Zarro (SM&A/GSFC) 28 April 1999
;                -- fixed roll_center interpretation
;                (heaven help me for onlining this during Gopal's CDAW)
;             : Zarro (SM&A/GSFC) 3 May 1999
;                -- allowed overlaying images with different roll centers.
;             : Zarro (SM&A/GSFC) 5 Aug 1999
;                -- Made VIEW_ADJUST=1 the default
;             : Zarro (SM&A/GSFC) 25 Sep 1999
;                -- Made VIEW_ADJUST=0 the default
;             : Zarro (SM&A/GSFC) 1 Nov 1999
;                -- Added GSTYLE grid style keyword
;             : Zarro (SM&A/GSFC) 30 Nov 1999
;                -- Added OVERLAY=2 hidden feature
;             : Zarro (SM&A/GSFC) 14 Feb 2000
;                -- changed CONT keyword to CONTOUR, and added /EXTEND
;             : Zarro (SM&A/GSFC) 27 Mar 2000
;                -- changed CLABEL, removed old keywords
;             : Zarro (SM&A/GSFC) 7 Apr 2000
;                -- fixed roundoff errors causing edge pixels
;                   to spill over during hardcopying. Also improved smoothing.
;             : Zarro (SM&A/GSFC) 25 Apr 2000
;                -- fixed problem with image viewport falling outside plot
;                   limits; removed EXTENDS, VIEW_ADJUST keywords
;             : Zarro (EIT/GSFC) 10 May 2000, added optional INDEX argument
;             : Zarro (EIT/GSFC) 28 June 2000, added MARGIN keyword and call
;                to GET_ASPECT
;             : Kim 27 Sep 2000 - added surface and shade_surface options
;             : Kim 29 Sep 2000 - removed some keywords to stay under 64
;                argument limit in versions < 5.3.  Handle new keywords in
;                _extra
;             : Kim 1 Oct 2000 - added show3 option
;             : Kim 4 Oct 2000 - added status keyword.  err keyword became
;                err_msg.
;             : Zarro (EIT/GSFC): 6 Oct 2000 -- restored capability to overlay
;                images without using contours.
;                                13 Oct 2000 -- added rescale zoom logic
;             : Kim 9 Jan 2001 - added colorbar option (for > IDL V 5.2)
;                and ccharsize keyword
;             : Khan (MSSL/ISAS): 2001 Mar 30 -- Changed Kim's colorbar to
;                cbar to avoid conflict with color keyword
;             : Zarro (EITI/GSFC): 2001 Jun 18 -- Fixed Z-buffer bug
;             : Zarro (EITI/GSFC): 2001 Sept 1 -- added /PERCENT
;             : Kim: 2001 Sep 6 - don't draw limb for surface, shade_surf,
;                or show3
;             : Zarro (EITI/GSFC): 1 Dec 2001 - made /SQUARE the default
;             : Kim Tolbert: 24-Jan-2002 -- Added mark_point keyword
;             : Zarro (EITI/GSFC): 16 Mar 2002 - check for unnecessary call
;                to PLOT_HELIO when GRID/LIMB=0
;             : Zarro (LAC/GSFC): 8 Oct 2002 - fixed roll bug + added check
;                for subfields outside fov + better handling of off-limb
;                pixels during solar rotation
;             : Zarro (EER/GSFC): 4 Nov 2002 - added GCOLOR and LMCOLOR for
;                grid and limb colors
;             : Henney (SOLIS/NSO): 15 Nov 2002 - replaced black background
;                with !p.background
;             : A. Caspi (SSL): 16 Dec 2002 - added BCOLOR for border color
;             : Zarro (EER/GSFC), 17 Dec 2002 - added /NODATA option
;             : Zarro (EER/GSFC), 22 Dec 2002 - fixed yet another ROLL bug and a problem
;               with ZOOM. It just never ends.
;             : Zarro (EER/GSFC), 20 Jan 2003 - fixed bug with DMIN/DMAX
;               keywords being ignored.
;             : Zarro (EER/GSFC), 24 Feb 2003 - added BORDER option for
;               contour overlays
;             : Kim, 23-Apr-2003. Removed /xstyle, /ystyle from call to show3
;             : Kim, 22-May-2003. Added log keyword to plot_map_colorbar
;             : Kim, 10-June-2003. Added NEAREST keyword
;             : Zarro (L-3/GSFC), 23 November 2003 - added check for roll values
;               less than 1 degree. Treat these as effectively 0 degree roll.
;             : Zarro (L-3Com/GSFC), 13 January 2004 - fixed FOV/CENTER
;               keyword inconsistency.
;             : Kim, 23-Feb-2004, added lmthick keyword for limb thickness
;             : Zarro (L-3Com/GSFC), 24 January 2004 - fixed minor roll bug
;               and moved PLOT_HELIO keywords to _EXTRA
;             : Zarro (L-3Com/GSFC), 27 February 2004 - added XSHIFT/YSHIFT
;             : Zarro (L-3Com/GSFC), 24 March 2004 - fixed problem with
;               masking out pixels that spill outside plot window in PS plots
;             : Zarro (L-3Com/GSFC), 27 April 2004 - preserved bytescale range
;               when compositing images.
;             : Zarro (L-3Com/GSFC), 11 Jan 2005 - added check for b0 in map
;             : Metcalf, 24 Jan 2005 - use square brackets on arange
;               to avoid confusion with the arange function
;             : Kim, 17 Feb 2005, added durtitle keyword to put duration in title
;             : Zarro (L-3Com/GSFC) 17 July 2005 - added 
;               c_thick, c_style, c_colors, c_label for compatibility
;               with RSI
;             : Zarro (ADNET) 2 April 2007 - 
;               added DIMENSIONS keyword and check for bytescale tags
;               in map 
;             : Zarro (ADNET) 7 May 2007 - added DATA=DATA to pass in
;               external data array
;             : Zarro (ADNET) 25 July 2007 
;                - added check for solar radius RSUN in map structure
;             : Zarro (ADNET) 6 October 2007
;                - added checks for L0, B0 angles in map to support
;                  STEREO views
;             : Zarro (ADNET) 11 November 2007
;                - moved roll checks to drot_map
;               Zarro (ADNET) 23 November 2007
;                - added check for 2-d smoothing width input
;               Zarro (ADNET) 25 February 2008
;                - passed L0 from PB0R
;               Zarro (ADNET) 21 April 2008
;                - restored SURFACE plotting
;               Zarro (ADNET) 27 June 2008
;                Extensive changes
;                - removed /SURFACE (use SURFACE_MAP)
;                - removed DIMENSION (use XSIZE, YSIZE)
;                - removed /TAIL (use _EXTRA)
;                - replaced /POSITIVE by /PLUS_ONLY
;                - replaced /NEGATIVE by /MINUS_ONLY
;                - removed TRANS (use SHIFT_MAP)
;                - passed all CONTOUR control keywords thru _EXTRA
;                - added /NO_BYTE_SCALE
;                - made RESCALE_ZOOM=0 the default
;                - added call to GET_MAP_ANGLES to support different
;                  spacecraft views
;                Zarro (ADNET) 10 October 2008
;                - fixed bug with RESCALE_ZOOM
;                Zarro (ADNET) 16 October 2008
;                - added alpha keyword to blend two images
;                Zarro (ADNET) 4 Dec 2008
;                - fixed edge effect with congrid not scaling edge
;                  pixels corrected.
;                Zarro (ADNET) 28 December 2008
;                - removed calls to nint which caused potential
;                  round-off issues when computing device coordinates.
;                Zarro (ADNET) 15 March 2009
;                - fixed issue with /last_scale not working with
;                  /log_scale
;                - reinforced NaN check
;		 Kucera (GSFC) 31 Aug 2010
;		 -added calls to setscale to allow
;		  square pixels when !p.multi ne 0
;                Zarro (ADNET) 21 November 2010
;                - added /center & /minus to congrid (per Fanning)
;                Zarro (ADNET) 23 December 2010
;                - added support for color maps
;                Zarro (ADNET) 22 January 2011
;                - removed /minus from CONGRID call
;                Kim, 7-May-2012.  When log of image is displayed,
;                pass 10.^prange to colorbar, not prange.
;                Zarro (ADNET) 29 May 2012
;                 - restored XSHIFT, YSHIFT keywords
;                 - moved INDEX and NEAREST to caller
;                 - renamed plot_map_index
;                Zarro (ADNET) 20 August 2013
;                 - fixed potential issue with 24 bit color plotting
;                 - added check for image already log scaled
;                Kim, 5-Dec-2013. Removed check for at least two
;                consecutive levels for contour.
;                Modified, 22 October 2014, Zarro (ADNET)
;                - converted to double-precision arithmetic
;                Zarro (ADNET), 5 December 2014
;                - Added /DEBUG
;                Zarro (ADNET), 22 December 2014
;                - added /NO_FILL
;                - computed device coordinates in double precision
;                Zarro (ADNET) 5 April 2015
;               - added check to not log scale input byte image
;                Zarro (ADNET) 8 August 2015
;               - added TRUE_COLORS keyword
;                Zarro (ADNET) 14 August 2015
;               - added RED, GREEN, BLUE color keywords
;                Zarro (ADNET) 31 August 2015
;               - added check for map colors
;               - added BLEND keyword
;                Zarro (ADNET) 24 November 2015
;               - added logic to not automatically roll overlaid
;                 image if user previously rolled base image
;                Zarro (ADNET) 7 February 2016
;               - removed /FULL_SIZE from ROT_MAP call 
;                 as it was adjusting pixel size
;                Zarro (ADNET) 9 February 2016
;               - added 2 to input NLEVELS to include data min/max
;               - allow byte scaling of byte map data
;                 
; Contact     : dzarro@solar.stanford.edu
;-

pro plot_map_index,map,contour=cont,overlay=overlay,smooth_width=smooth_width,border=border,$
 fov=fov,grid_spacing=grid_spacing,center=center,$
 log_scale=log_scale,notitle=notitle,title=title,$
 window=window,noaxes=noaxes,nolabels=nolabels,$
 new=new,$
 missing=missing,dmin=dmin,dmax=dmax,$
 top=top,quiet=quiet,square_scale=square_scale,$
 plus_only=plus_only,minus_only=minus_only,$
 time=time,bottom=bottom,nodata=nodata,no_data=no_data,$
 date_only=date_only,nodate=nodate,$
 last_scale=last_scale,composite=composite,$
 interlace=interlace,xrange=xrange,yrange=yrange,$
 average=average,ncolors=ncolors,drange=drange,$
 limb_plot=limb_plot,truncate=truncate,$
 duration=duration,bthick=bthick,bcolor=bcolor,drotate=drotate,$
 multi=multi,noerase=noerase,_extra=extra, $
 status=status, err_msg=err_msg,$
 rescale_zoom=rescale_zoom,cbar=cbar,$
 mark_point=mark_point,original_time=original_time,mask_value=mask_value,$
 no_mask=no_mask,background=background,durtitle=durtitle,percent=percent,$
 levels=levels,nlevels=nlevels,no_byte_scale=no_byte_scale,alpha=alpha,$
 roll_angle=roll_angle,xshift=xshift,yshift=yshift,debug=debug,$
 red=red,green=green,blue=blue,$
 true_colors=true_colors,use_colors=use_colors,blend=blend

;-- some variables saved in memory for overlay

common plot_map_index,last_window,last_time,last_drange,last_top,last_bottom,$
       last_xrange,last_yrange,last_multi,last_roll,last_rcenter,$
       last_b0,last_l0,last_rsun,saved_map,last_roll_correct

status = 1
err_msg =''
shifting=0b
rolling=0b
error=0

if ~keyword_set(debug) then begin
 catch,error
 if error ne 0 then begin
  err_msg=!err_string
  catch,/cancel
  goto,clean_up
 endif
endif

;-- overlay limb and/or grid on previous plot

if keyword_set(overlay) && (n_params() eq 0) then begin
 if ~exist(last_time) then begin
  err_msg='No previous image on which to overlay limb/grid'
  return
 endif
 plot_helio,last_time,roll=last_roll,grid_spacing=grid_spacing,$
  /over,rcenter=last_rcenter,$
  limb_plot=limb_plot,b0=last_b0,l0=last_l0,rsun=last_rsun,_extra=extra
 return
endif

;-- check input map

if ~exist(map) then begin
 err_msg = 'plot_map,map'
 pr_syntax,err_msg
 return
endif
if ~valid_map(map) then begin
 err_msg='Invalid input image map'
 return
endif
map_colors=color_map(map,true_index=true_index)
if true_index gt 0 then begin
 mprint,'TrueColor plotting not currently supported.'
 return
endif

;-- color controls

zbuff=!d.name eq 'Z'
wbuff=(!d.name eq 'X') || (!d.name eq 'WIN')
post=(!d.name eq 'PS')
n_colors=!d.table_size

input_colors=valid_colors(red,green,blue)
have_colors=(input_colors || map_colors)
true_colors=keyword_set(true_colors)
use_colors=keyword_set(use_colors)
load_colors=have_colors && (use_colors || true_colors || map_colors)
if true_colors && ~truecolor_device() then mprint,'TrueColor not supported on this device.'
true_colors= have_colors && true_colors && truecolor_device() 

if map_colors then begin
 ired=map.red & igreen=map.green & iblue=map.blue
endif

if input_colors then begin
 ired=red & igreen=green & iblue=blue
endif

if is_number(ncolors) then ncolors=(ncolors < n_colors) else ncolors=n_colors
add_cbar=keyword_set(cbar)
white=byte(n_colors-1) & black=0b
if is_number(bottom) then bottom= byte(float(bottom) > 0) else bottom=0b

if is_number(top) then top=byte(float(top) < (n_colors-1)) else $
 top=byte( (float(bottom)+ncolors-1) < (n_colors-1) ) 

temp=[top,bottom]
bottom = min(temp,max=top)

if ~is_number(bthick) then bthick=1
if ~is_number(bcolor) then bcolor=white

rescale_zoom=keyword_set(rescale_zoom)
if is_number(square_scale) then square_scale=(0b > square_scale < 1b) else $
 square_scale=1b
noaxes=keyword_set(noaxes)              ;-- no axes option
quiet=keyword_set(quiet)
loud=1-quiet
border=keyword_set(border)              ;-- plot image border

;-- check image scalings

dlog=keyword_set(log_scale)             ;-- log scale image
bscale=~keyword_set(no_byte_scale)      ;-- byte scale image

if dlog && have_tag(map,'log_scale') then begin
 if map.log_scale then begin
  mprint,'Input map already log-scaled.'
  dlog=0b
 endif
endif
if bscale && is_byte(map.data) then begin
; mprint,'Input map already byte-scaled.'
; bscale=0b
 dlog=0b
endif

if ~is_number(grid_spacing) then grid_spacing=0.  ;-- no grid
limb_plot = keyword_set(limb_plot)
grid_limb=(grid_spacing gt 0.) || limb_plot
last_scale=keyword_set(last_scale)

;-- always overlay as a contour unless /interlace, /composite, or cont=0, are set

if is_number(overlay) then over = (0b > overlay < 1b) else over=0b
if is_number(cont) then cont= (0b > cont < 1b) else cont=over
if is_number(noerase) then noerase= (0b > noerase < 1b) else noerase=over
comptype=0
if keyword_set(composite) then comptype=composite   ; intercept COMPTYPE
if over && ~cont then comptype=2
if keyword_set(interlace) then comptype=5
if keyword_set(average) then comptype=6
if (is_number(alpha) || keyword_set(blend)) && over then comptype=7
if comptype gt 0 then begin
 over=1b & cont=0b
endif
if over && true_colors then cont=0b

if ~is_number(xshift) then xshift=0.
if ~is_number(yshift) then yshift=0.
if ~is_number(roll_angle) then roll_angle=0.
rolling=((roll_angle mod 360.) ne 0.) 
shifting=(xshift ne 0.) || (yshift ne 0.)

;-- open a new window if one doesn't exist
;-- else get viewport from previous plot

if wbuff then begin
 if over then begin
  if is_wopen(last_window) then wset,last_window else begin
   err_msg='Overlay base window unavailable'
   goto,clean_up
  endelse
 endif else begin
  case 1 of 
   is_wopen(window): wset,window
   is_number(window): window,window,_extra=extra,retain=2,xsize=512,ysize=512
   keyword_set(new):window,_extra=extra,/free,retain=2,xsize=512,ysize=512
   is_wopen(!d.window): wset,!d.window
   else: window,_extra=extra,retain=2,xsize=512,ysize=512
  endcase
 endelse
 last_window=!d.window
endif

;-- check if alpha blending
;-- save current background image as 24-bit

if comptype eq 7 then begin
 if ~exist(alpha) then begin
  err_msg='Need transparency factor "alpha" between 0 and 1'
  goto,clean_up
 endif
 alpha= ( 0. > alpha < 1.)
 device2,get_decomposed=decomp
 device2,decomp=0
 back=tvrd(/true)
 device2,decomp=decomp
endif


;-- keep track of plot location for multi-page plots
;-- clear page if !p.multi changed

if exist(multi) then begin
 pmulti=[multi[0],multi[n_elements(multi)-1]]
 !p.multi[[1,2]]=pmulti
endif
pnx=!p.multi[1]
pny=!p.multi[2]
if n_elements(last_multi) lt 3 then last_multi=!p.multi
if (last_multi[1] ne pnx) || (last_multi[2] ne pny) then begin
 erase & !p.multi[0]=0
endif

;-- go to previous image if an overlay

sp=!p.multi[0]
if over then begin
 !p.multi[0]=(!p.multi[0]+1)
 if !p.multi[0] gt pnx*pny then !p.multi[0]=0
 sp=!p.multi[0]
endif

;-- translating or rolling map

saved_icenter=[map.xc,map.yc]
saved_rcenter=get_map_prop(map,/roll_center,def=saved_icenter)

if shifting || rolling then begin
 saved_map=map
 if rolling then map=rot_map(map,roll_angle,_extra=extra,/no_copy)
 if shifting then map=shift_map(map,xshift,yshift,/no_copy)
endif
if ~exist(last_roll_correct) || ~over then last_roll_correct=0b

odmin=min(map.data,max=odmax,/nan)
if (odmin eq 0) && (odmax eq 0) then begin
 err_msg='All data are zero'
 goto,clean_up
endif

;-- filter NaN's

off_scale=odmax*100.
mtype=size(map.data,/type)
if (mtype eq 2) then pic=float(map.data) else pic=map.data
nan=where(finite(pic,/nan),ncount)
if ncount gt 0 then begin
 if cont then pic[nan]=off_scale else pic[nan]=0.
endif

;-- smoothing?

if exist(smooth_width) then begin
 smo=smooth_width[0]
 if n_elements(smooth_width) eq 1 then smo=[smo,smo]
 if n_elements(smooth_width) gt 1 then smo=[smo,smooth_width[1]]
 if max(smo) gt 1 then pic=smooth(temporary(pic),smo,/edge_truncate,/nan)
 odmin=min(pic,max=odmax,/nan)
endif
odrange=float([odmin,odmax])

if dlog then begin
 ok=where(pic gt 0.,pcount)
 if pcount eq 0 then begin
  err_msg='All data are negative. Cannot plot on a log scale'
  goto,clean_up
 endif
 pmin=min(pic[ok],max=pmax,/nan)
 odrange=float([pmin,pmax])
endif

;-- establish plot labels

units=get_map_prop(map,/units,def='arcsecs')
if is_string(units) then units='('+units+')'
xunits=units & yunits=units
if tag_exist(map,'xunits') then xunits=map.xunits
if tag_exist(map,'yunits') then yunits=map.yunits
if is_string(xunits) then xtitle='X ('+xunits+')'
if is_string(yunits) then ytitle='Y ('+yunits+')'
if keyword_set(nolabels) then begin
 xtitle='' & ytitle=''
endif

;-- if solar rotating, check that we are rotating relative to last time image
;   rotated

atime=get_map_time(map,/tai)
rtime=atime
otime=get_map_time(map,/tai,/original)
mtitle=get_map_prop(map,/id,def='')
if ~over then begin
 err=''
 mtime=rtime
 if keyword_set(original_time) then mtime=otime
 if keyword_set(durtitle) then begin
  s_time = anytim (anytim2utc(mtime),/yohkoh,err=err,/truncate)
  if err eq '' then mtitle = mtitle+' '+s_time
  e_time = anytim (anytim2utc(mtime+get_map_prop(map,/dur)),/yohkoh,/time_only,/truncate,err=err)
  if err eq '' then mtitle=mtitle+'-'+e_time
 endif else begin
  date_obs=anytim2utc(mtime,/vms,err=err,time_only=keyword_set(nodate),$
   date_only=date_only,truncate=truncate)
  if ~keyword_set(date_only) then field=' UT' else field=''
  if err eq '' then mtitle=mtitle+' '+date_obs+field
 endelse
endif
mtitle=trim(mtitle)
if is_string(title,/blank) then mtitle=title
if keyword_set(notitle) then mtitle=''

;-- get some map properties

oxrange=get_map_xrange(map,/edge)
oyrange=get_map_yrange(map,/edge)
dx=map.dx & dy=map.dy
dx2=dx/2.d0 & dy2=dy/2.d0
icenter=[map.xc,map.yc]
curr_roll=get_map_prop(map,/roll_angle,def=0.)
curr_rcenter=get_map_prop(map,/roll_center,def=icenter)

;-- retrieve coordinate transformation angles for plotting limb and
;   overlaying

ang_error=''
angles=get_map_angles(map,err=ang_error,_extra=extra)
b0=angles.b0
l0=angles.l0
rsun=angles.rsun
dprint,'% b0,l0,rsun,roll_angle: ',b0,l0,rsun,curr_roll

;-- establish plot ranges
;   (start with image, then FOV, then XRANGE/YRANGE keywords)

dcenter=icenter
if valid_map(fov) then dcenter=get_map_center(fov)
if exist(center) then begin
 if valid_map(center) then dcenter=get_map_center(center) else begin
  if valid_range(center,/allow) then dcenter=double(center)
 endelse
endif

dxrange=oxrange
dyrange=oyrange
if exist(fov) then begin
 if valid_map(fov) then dfov=get_map_fov(fov,/edge) else begin
  nfov=n_elements(fov)
  dfov=60.d0*double([fov[0],fov[nfov-1]])
 endelse
 half_fov=dfov/2.
 dxrange=[dcenter[0]-half_fov[0],dcenter[0]+half_fov[0]]
 dyrange=[dcenter[1]-half_fov[1],dcenter[1]+half_fov[1]]
endif

if exist(center) && (~exist(fov)) then begin
 dxrange=dxrange+dcenter[0]-icenter[0]
 dyrange=dyrange+dcenter[1]-icenter[1]
endif

;-- if overlaying, match with previous viewport

if over then begin
 if valid_range(last_xrange) then begin
  dxrange[0]=last_xrange[0]   ; > dxrange[0]
  dxrange[1]=last_xrange[1]   ; < dxrange[1]
 endif
 if valid_range(last_yrange) then begin
  dyrange[0]=last_yrange[0]   ; > dyrange[0]
  dyrange[1]=last_yrange[1]   ; < dyrange[1]
 endif
endif

;-- overide with user input ranges

if valid_range(xrange) then dxrange=double(xrange)
if valid_range(yrange) then dyrange=double(yrange)
dxrange=[min(dxrange),max(dxrange)]
if min(dxrange) eq max(dxrange) then dxrange=oxrange
dyrange=[min(dyrange),max(dyrange)]
if min(dyrange) eq max(dyrange) then dyrange=oyrange

;-- bail out if trying to display at the sub-pixel level

diff_x=(max(dxrange)-min(dxrange))
diff_y=(max(dyrange)-min(dyrange))
if (diff_x lt dx2) || (diff_y lt dy2) then begin
 err_msg='Cannot display below half pixel resolution limit'
 goto,clean_up
endif

;-- define viewport

xmin=min(dxrange); -dx2 
xmax=max(dxrange); +dx2
ymin=min(dyrange); -dy2  
ymax=max(dyrange); +dy2

if (xmin eq xmax) || (ymin eq ymax) then begin
 err_msg='Plot scale MIN/MAX must differ'
 goto,clean_up
endif

;-- don't extract sub-region if contouring, since contour procedure
;   takes care of it via drange

if ~cont then begin
 spic=get_map_sub(map,xrange=dxrange,yrange=dyrange,arange=arange,$
                 count=zcount,err=err_msg,irange=irange,/no_data)
 if zcount eq 0 then goto,clean_up
 if zcount lt n_elements(map.data) then $
  pic=pic[irange[0]:irange[1],irange[2]:irange[3]]
endif

;-- plot axes & viewport
;-- try to preserve aspect ratio (won't work if multi is set)
;-- if contouring and not overlaying, then check for roll

no_drotate=~keyword_set(drotate)
no_project=no_drotate

ilimb=-1 & olimb=-1
no_roll_correct=rolling || last_roll_correct

if cont then begin
 if over then begin
  trans=[0,0]
  dum=drot_map(map,time=last_time,trans=trans,$
   b0=last_b0,l0=last_l0,rsun=last_rsun,roll=last_roll,olimb=olimb,$
   rcenter=last_rcenter,err=err_msg,xp=xp,yp=yp,/no_data,ilimb=ilimb,$
   no_drotate=no_drotate,no_project=no_project,$
   no_roll_correct=no_roll_correct,$
    _extra=extra)
  if is_string(err_msg) then goto,clean_up

;-- send off-limb points to outside fov

  if ilimb[0] ne -1 then pic[ilimb]=off_scale
  if olimb[0] ne -1 then pic[olimb]=off_scale
 endif else begin
  xp=get_map_xp(map)
  yp=get_map_yp(map)
 endelse
endif

;-- get data plot limits

if cont then begin
 inside=where( (xp le xmax) and (xp ge xmin) and $
               (yp le ymax) and (yp ge ymin) and $
               (pic ne off_scale), $
               in_count,complement=outside,ncomplement=out_count)
 if in_count eq 0 then begin
  err_msg='No data in contour field of view'
  goto,clean_up
 endif
 if in_count lt n_elements(pic) then begin
  min_x=min(xp[inside],max=max_x) 
  min_y=min(yp[inside],max=max_y)
 endif else begin
  min_x=min(xp,max=max_x) 
  min_y=min(yp,max=max_y)
 endelse
 if out_count gt 0 then pic[outside]=off_scale
endif else begin
 min_x=arange[0] & max_x=arange[1]
 min_y=arange[2] & max_y=arange[3]
endelse

;-- define outer edges of extracted data for border plot

emin_x=(min_x-dx2) ; > min(dxrange)
emax_x=(max_x+dx2) ; < max(dxrange)
emin_y=(min_y-dy2) ; > min(dyrange)
emax_y=(max_y+dy2) ; < max(dyrange)
xedge = [emin_x,emax_x,emax_x,emin_x,emin_x]
yedge = [emin_y,emin_y,emax_y,emax_y,emin_y]

;-- get data value limits
;-- start with actual data, then dmin/dmax keywords, then last scale, and
;   finally drange.

prange=odrange
if rescale_zoom then begin
 pmin=min(pic,max=pmax,/nan)
 if cont then begin
  if (in_count gt 0) && (in_count lt n_elements(pic)) then pmin=min(pic[inside],max=pmax,/nan)
 endif
 prange=float([pmin,pmax])
endif

;-- override with user keywords

if exist(dmin) then prange[0]=dmin
if exist(dmax) then prange[1]=dmax

if exist(drange) then begin
 if valid_map(drange) then prange=get_map_drange(drange) else $
  if valid_range(drange) then prange=float(drange)
endif

prange=[min(prange),max(prange)]
if (min(prange) eq max(prange)) then prange=odrange

plus=keyword_set(plus_only)
minus=keyword_set(minus_only)
if plus || minus then begin
 if plus then $
  ok=where( (pic ge 0.) and (pic ne off_scale),pcount,complement=nok,ncomplement=ncount) else $
   ok=where( (pic le 0.) and (pic ne off_scale),pcount,complement=nok,ncomplement=ncount)
 if pcount eq 0 then begin
  if plus then err_msg='All data are negative' else err_msg='All data are positive'
  goto,clean_up
 endif
 if ncount gt 0 then pic[nok]=off_scale
endif

;-- log scale?

if dlog then begin
 ok=where( (pic gt 0.) and (pic ne off_scale),pcount,complement=nok,ncomplement=ncount)
 if pcount eq 0 then begin
  err_msg='All data are negative. Cannot plot on a log scale'
  goto,clean_up
 endif
 pmin=min(pic[ok],max=pmax,/nan)
 if ncount gt 0 then begin
  if cont then pic[nok]=off_scale else pic[nok]=pmin
 endif
 pic=alog10(temporary(pic)) 
 if (prange[0] le 0) then $
  if rescale_zoom then prange[0]=pmin else prange[0]=odrange[0]
 if (prange[1] le 0) then $
  if rescale_zoom then prange[1]=pmax else prange[1]=odrange[1] 
 prange=alog10(prange)
endif

;-- override with last scaling

if last_scale then begin
 if valid_range(last_drange) then begin
  prange=last_drange
  if dlog then prange=alog10(last_drange)
 endif
endif

dprint,'%PRANGE',prange

;-- make an empty plot to establish scaling

if ~over then begin
 do_multi=pny*pnx gt 1
 if square_scale && ~do_multi && ~have_tag(extra,'position',/start) then begin
  dpos=get_aspect(xrange=dxrange,yrange=dyrange,_extra=extra)
  extra=rep_tag_value(extra,dpos,'position')
 endif
 if square_scale && do_multi && ~have_tag(extra,'position',/start) then begin  
;  if have_tag(extra,'charsize',tind,/start) then
;  charsize=extra.(tind)
;  xsave=!x & ysave=!y 
  setscale, xmin, xmax, ymin, ymax, /noborder,_extra=extra
 endif
 
 if have_tag(extra,'noxt') then begin
  xticks=replicate(' ',n_elements(!x.tickname)-1)
  extra=rep_tag_value(extra,xticks,'xtickname')
 endif
 if have_tag(extra,'noyt') then begin
  yticks=replicate(' ',n_elements(!y.tickname)-1)
  extra=rep_tag_value(extra,yticks,'ytickname')
 endif
 !p.multi[0]=sp
 plot,[xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],/data, $
  xstyle=5,ystyle=5,noerase=noerase,/nodata,xrange=dxrange,yrange=dyrange,$
  _extra=extra
endif

if keyword_set(no_data) then goto,done
if keyword_set(nodata) then goto,clean_up

;-- plot contours

!p.multi[0]=sp
if cont then begin
 if is_number(nlevels) then nlevs=(nlevels > 2)+2 else nlevs=10
 dlevels=(prange[1]-prange[0])/(nlevs-1.)
 def_levels=prange[0]+findgen(nlevs)*dlevels
 plevels=def_levels
 if n_elements(levels) gt 0 then begin
  plevels=get_uniq(float(levels))
  if keyword_set(percent) then plevels=levels*prange[1]/100. else begin
   if dlog then begin
    ok=where(plevels gt 0,pcount)
    if pcount eq 0 then begin
     mprint,'Contour levels must be greater than zero for log scale - using default set',/info
     plevels=def_levels
    endif else plevels=alog10(plevels[ok])
   endif
  endelse
 endif

  contour,pic,xp,yp,/data,xstyle=5,ystyle=5,$
  max_value=prange[1],min_value=prange[0],$
  over=(over gt 0),$
  noeras=(over eq 0),xrange=dxrange,yrange=dyrange,levels=plevels,$
  _extra=extra
  dprint,'%PLEVELS',plevels

endif else begin

;-- plot image

;-- outer device pixels of extracted data

 xb_dev=double(!d.x_size)*(double(!x.s[0])+double(!x.s[1])*xedge)
 yb_dev=double(!d.y_size)*(double(!y.s[0])+double(!y.s[1])*yedge)

;-- dimensions of scaled image

 sx=(abs(max(xb_dev)-min(xb_dev))+1.d0) > 1.d0
 sy=(abs(max(yb_dev)-min(yb_dev))+1.d0) > 1.d0

; sx=nint(sx)
; sy=nint(sy)

;-- device pixels of range window

 xr_dev=double(!d.x_size)*(double(!x.s[0])+double(!x.s[1])*dxrange)
 yr_dev=double(!d.y_size)*(double(!y.s[0])+double(!y.s[1])*dyrange)

 xscale=diff_x/(max(xr_dev)-min(xr_dev))
 yscale=diff_y/(max(yr_dev)-min(yr_dev))

;-- rebin image for X-windows or Z-buffer (!d.name = 'X' or 'Z')
;-- or plot in Postscript using scalable pixels (!d.name = 'PS')

 if bscale then begin
  pmin=prange[0] & pmax=prange[1]
  if is_byte(pic) then begin
   pmax = byte(float(pmax) < (n_colors-1)) 
   pmin = byte(float(pmin) > 0)
   do_scale=(pmax ne top) || (pmin ne bottom)
  endif else do_scale=1b
  dprint,'% do_scale, pmin, pmax, bottom, top: ',do_scale,pmin,pmax,bottom,top
  if do_scale then pic=bytscl(pic,max=pmax,min=pmin,top=top-bottom,/nan)+bottom
 endif else begin
  above=where(pic gt prange[1],p1)
  below=where(pic lt prange[0],p2)
  if p1 gt 0 then pic[above]=prange[1]
  if p2 gt 0 then pic[below]=prange[0]
 endelse
 brange=[bottom,top]

;-- check if composite/interlace is requested

 if zbuff || wbuff then begin
  words=data_chk(map.data,/type) ne 1         ; boolean for tv/tvrd
  true=!d.n_colors gt 256
  pic=congrid(temporary(pic),sx,sy,/center)

;-- set pixels outside plot window range to background
  
  xpic=xb_dev[0]+dindgen(sx)
  xleft=where(xpic lt xr_dev[0],lcount)
  xright=where(xpic gt xr_dev[1],rcount)

  ypic=yb_dev[0]+dindgen(sy)
  ybot=where(ypic lt yr_dev[0],bcount)
  ytop=where(ypic gt yr_dev[1],tcount)

  if ~keyword_set(no_fill) then begin
   if lcount gt 0 then pic[xleft[0]:xleft[lcount-1],*]= !p.background
   if rcount gt 0 then pic[xright[0]:xright[rcount-1],*]= !p.background
   if bcount gt 0 then pic[*,ybot[0]:ybot[bcount-1],*]= !p.background
   if tcount gt 0 then pic[*,ytop[0]:ytop[tcount-1],*]= !p.background
  endif
 
  if (comptype gt 0) && (comptype ne 7) then begin
   ok=(xb_dev[0] gt 0) && (xb_dev[0] lt !d.x_size) && $
      (yb_dev[0] gt 0) && (yb_dev[0] lt !d.y_size) && $
      (xb_dev[0]+sx lt !d.x_size) && $
      (yb_dev[0]+sy lt !d.y_size)

;-- just create a blank bytarr if underlying image cannot be read

   if ok then begin
    if zbuff then $
     base=tvrd(xb_dev[0],yb_dev[0],sx,sy,channel=words,words=words) else $
      base=tvrd(xb_dev[0],yb_dev[0],sx,sy)
   endif else base=bytarr(sx,sy)
   base=bytscl(base,top=last_top-last_bottom,max=brange[1],min=brange[0],/nan)+byte(last_bottom)

;-- combine underlying and overlaying images

   case comptype of 
    1: pic=temporary(base)+temporary(pic)
    3: pic=temporary(base) > temporary(pic)        ; 'largest'  pixel
    4: pic=temporary(base) < temporary(pic)        ; 'smallest' pixel
    5: begin
        base=swiss_cheese(base,last_bottom,/shift,/no_copy)
        pic=swiss_cheese(pic,bottom,/no_copy)
        pic=temporary(base)+temporary(pic)
       end
    6: pic=temporary(base)/2+temporary(pic)/2
    else: do_nothing=1
   endcase
  endif
 endif

;-- call TV
;-- SX and SY used only in postscript mode
;-- If blending, copy foreground image into pixmap and make composite with
;   background image

 device_colors,rold,gold,bold
 device2,get_decomp=decomp
 device2,decomp=0

 if load_colors && ~true_colors then tvlct,ired,igreen,iblue
 if wbuff then begin

;-- legacy block for image overlays

  if (comptype eq 7) && exist(back) then begin
   cur_win=!d.window
   window,/free,xsize=!d.x_size,ysize=!d.y_size,/pix
   pix_win=!d.window
   wset,pix_win
   device,copy=[0,0,!d.x_size,!d.y_size,0,0,cur_win]
   if have_colors then tvlct,ired,igreen,iblue
   tv,pic,xb_dev[0],yb_dev[0],/device
   fore=tvrd(/true)
   wdelete,pix_win
   wset,cur_win
   temp=(1.-alpha)*temporary(back)+alpha*temporary(fore)
   tvscl,temp,/true
   goto,clean_up
  endif 

;-- new block for truecolor support

  dprint,'% input_colors, map_colors, have_colors, use_colors, true_colors, load_colors'
  dprint,input_colors,map_colors,have_colors, use_colors, true_colors,load_colors

  if true_colors then begin
  dprint,'% bottom, top:',bottom,top
   tv,mk_24bit(pic,ired,igreen,iblue,top=top,bottom=botton,/no_copy),xb_dev[0],yb_dev[0],$
         /device,true=1 
  endif else begin
   tv,pic,xb_dev[0],yb_dev[0],/device
  endelse
 endif

;-- if Postscript, we literally "white-out" pixels outside viewport

 if post then begin
  tv,pic,xb_dev[0],yb_dev[0],xsize=sx,ysize=sy,/device
  if ~keyword_set(no_mask) then begin
   if is_number(mask_value) then background=mask_value
   plot_map_white,xb_dev,yb_dev,xr_dev,yr_dev,background=background
  endif
 endif

;-- if Z-buffer, we have to physically avoid pixels outside viewport

 if zbuff then begin
  inx=where( (xpic le !d.x_size) and (xpic ge 0) ,xcount)
  iny=where( (ypic le !d.y_size) and (ypic ge 0) ,ycount)
  if (xcount eq 0) || (ycount eq 0) then begin
   err_msg='Image overflows Z-buffer'
   goto,clean_up
  endif
  pic=temporary(pic[inx[0]:inx[xcount-1],iny[0]:iny[ycount-1]])
  ux=xpic[inx[0]]
  uy=ypic[iny[0]]
  dprint,'% ux, uy',ux,uy
  tv,pic,ux,uy,/device
 endif

 if add_cbar then begin
  cbar_range=dlog ? 10.^prange : prange
  if load_colors || true_colors then tvlct,ired,igreen,iblue
  ncolors=fix(top-bottom+1)
  plot_map_colorbar, cbar_range, bottom, ncolors, log=dlog, _extra=extra
 endif

endelse  ; end of 'plot image' instead of contours branch

done: 
if exist(rold) && exist(gold) && exist(bold) then tvlct,rold,gold,bold
 
;-- plot axes and labels

if ~over then begin
 !p.multi[0]=sp
 plot,[xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],/data, $
  xstyle=([1,5])[noaxes],ystyle=([1,5])[noaxes],/noeras,/nodata,xrange=dxrange,$
  yrange=dyrange,xtitle=xtitle,ytitle=ytitle,title=mtitle,$
  _extra=extra
endif

;-- overlay a solar latitude-longitude grid

if grid_limb && (~over || (comptype gt 0)) then begin
 !p.multi[0]=sp
 rcenter=shifting ? saved_rcenter : curr_rcenter
 plot_helio,atime,roll=curr_roll,grid_spacing=grid_spacing,$
  /over,rcenter=rcenter,no_roll_correct=no_roll_correct,$
  limb_plot=limb_plot,b0=b0,l0=l0,rsun=rsun,_extra=extra
endif

;-- mark point

mark_point,mark_point

;-- plot border edges

if border then begin
 !p.multi[0]=sp
 oplot,xedge,yedge,thick=bthick,color=bcolor
endif

;-- save last settings

if ~over then begin
 if exist(dxrange) then last_xrange=dxrange
 if exist(dyrange) then last_yrange=dyrange
 if exist(prange) && ~last_scale then begin
  if dlog then prange=10.^prange
  last_drange=prange
 endif
 if exist(rtime) then last_time=rtime else last_time=atime
 if exist(top) then last_top=top
 if exist(bottom) then last_bottom=bottom
 if exist(curr_roll) then last_roll=curr_roll
 if exist(curr_rcenter) then last_rcenter=curr_rcenter
 if exist(b0) then last_b0=b0
 if exist(l0) then last_l0=l0
 if exist(rsun) then last_rsun=rsun
 if rolling then last_roll_correct=1b
endif

!p.multi[0]=(!p.multi[0]-1)
if !p.multi[0] lt 0 then !p.multi[0]=(pnx*pny-1)
last_multi=!p.multi

if ~over then begin
 if square_scale && do_multi && ~have_tag(extra,'position',/start) then setscale
endif 

clean_up:
;if exist(xsave) then !x=xsave
;if exist(ysave) then !y=ysave

if shifting || rolling then begin
 if valid_map(saved_map) then map=temporary(saved_map)
endif 

if is_string(err_msg) then begin
 status=0
 mprint,err_msg,/info
endif else wshow2,last_window

if exist(rold) && exist(gold) && exist(bold) then tvlct,rold,gold,bold
if exist(decomp) then device2,decomp=decomp
delvarx,xp,yp,pic,xpic,ypic,spic,saved_map

return & end

