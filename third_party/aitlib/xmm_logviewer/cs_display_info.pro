;+
; NAME:
;cs_display_info
;
;
; PURPOSE:
;displays manual information
;
;
; CATEGORY:
;xmm_logviewer subroutine
;widget
;
; CALLING SEQUENCE:
;cs_display_info, state
;
; INPUTS:
;state
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;includes: cs_display_info_event,
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_display_info_event, ev
WIDGET_CONTROL, ev.top, GET_UVALUE=text
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
CASE uval OF
  'DISPLAYDONE': WIDGET_CONTROL, ev.top, /DESTROY
ELSE:
ENDCASE
END


PRO cs_display_info, state
      IF XRegistered('cs_display_info') GT 0 THEN RETURN
           mainbase=WIDGET_BASE(GROUP_LEADER=state.mainbase, TITLE='INFO', ROW=3)
           displaybase = WIDGET_BASE(mainbase, SCROLL=1 , X_SCROLL_SIZE=700,Y_SCROLL_SIZE=400) 
        
          helptext = [ $
"                                                                                                                                 ", $
"  Beschreibung der Funktionen des Programmes:", $
" ", $
"  Anzeigen (plotten) eines Graphen:    ", $
"  	- Parameter der x- und der y- Achse w�hlen (TIME ist der Standard x-Parameter); s.u.   ", $
"  	- Anfangs- und Endumlauf w�hlen; s.u.", $
"  	- auf PLOT klicken; der Graph wird erstellt und unter den schon bestehenden Graphen angezeigt.", $
"           ", $
"  Auswahl des Umlaufes:                  ", $
"  	- geben Sie den ersten gew�nschten Umlauf in das Feld 'Revolution from:_____ ' ein    ", $
"  	- geben Sie den letzten gew�nschten Umlauf in das Feld 'to:_____ ' ein ", $
"  	Diese und die dazwischen liegenden Uml�ufe werden ausgelesen (nach klicken auf PLOT),", $
" 	wenn die auto-save Funktion (s. Preferences) nicht ausgeschaltet ist auch gespeichert und ", $
" 	in einem Graph unter den bereits erstellten Graphen angezeigt.", $
"                                                              ", $
"  Auswahl des Parameters:  ", $
" 	- geben Sie die vollst�ndige 'Kennziffer' Bsp. 'F 1375' ein, und dr�cken Sie auf ENTER; oder ", $
"	- geben Sie den vollst�ndigen Namen Bsp. 'A1 DSLINC' ein und dr�cken Sie auf ENTER; oder ", $
"  	- w�hlen Sie einen Eintrag in der PARAMETERLISTE aus, (s. unten)", $
"     ", $
"  Anzeigen einer Liste aller vom Programm unterst�tzten Parameter: (MAIN / Display parameterlist) ", $
" 	- klicken Sie im Men� auf MAIN und dann auf 'DISPLAY PARAMETERLIST...'    ", $
" 	- w�hlen Sie �ber den 'To x /To y' Knopf die Achse des anzuzeigenden Parameters aus ", $
" 	- w�hlen Sie aus der Liste der Parameter einen aus; der Parameter ist damit gew�hlt ", $
" 	zum Beenden klicken Sie auf DONE", $
"  ", $
"  Zoomen in X- bzw. Y- Richtung:  ", $
" 	- in X- Richtung: ", $
"		- klicken Sie mit der linken Maustaste auf den Anfang des zu zoomenden Bereiches, ", $
"  		- halten Sie die Maustaste gedr�ckt und ziehen Sie die Maus bis zum Ende des Zoombereiches ", $
"		- lassen Sie die Maustaste los; der Bereich wird gezoomt; oder", $
"		- geben Sie im OPTIONEN-Fenster (s.unten) zwei Werte in die daf�r vorgesehenen Fenster ein, ", $
"		- klicken Sie auf Zoom x", $ 
"	- in Y- Richtung:", $
" 		- geben Sie im OPTIONEN-Fenster (s.unten) zwei Werte in die daf�r vorgesehenen Fenster ein,", $
" 		- klicken Sie auf Zoom y", $
"  ", $
"  �ffnen des Fensters OPTIONEN: ", $
"  	- klicken Sie mit der rechten Maustaste auf den Graphen zu dem Sie das Optionen-Fenster �ffnen m�chten", $
"  	- dort sind die im Folgenden beschrieben Optionen auf diesem Graphen ausf�hrbar", $
"  ", $
"  Mathematische Operationen: (OPTIONEN / Calculate)", $
" 	- die Eingabe wird in eine EXECUTE Zeile umgewandelt: Bsp.: 'y+1000' wird zu EXECUTE('y=y+1000') ", $
"  	- y ist hierbei das Array aus den y-Werten des Graphen", $                
"  ", $
"  �ndern der Farbe des Graphen: (OPTIONEN /Set color)  ", $
"  	- die Farbwerte liegen zwischen 0-255; 0=Schwarz, 255=Wei�, ca.50=Rot", $
"  ", $
"  �ndern der Farbe des Hintergrundes und der Achsen: (OPTIONEN / Set bgcolor)", $
" 	- Hintergrundfarbe und Achsenfarbe sind zueinander komplement�r; sonst s.oben ", $
"  ", $
"  �ndern der Plotsymbole: (OPTIONEN / Set Symbol)", $
" 	- w�hlen Sie aus den Idl-Symbolen (0-7); Bsp.: 0=Linie, 3=Punkt", $
" ", $
"  Einstellen des PlotKeywords 'Y_STYLE': (OPTIONEN / Set y_style)",$
" 	-This keyword allows specification of axis options such as rounding of tick values and ", $
"	  selection of a box axis. Each option is described in the following table: ",$
"		  1	Force exact axis range.", $
"		  2	Extend axis range.", $
"		  4	Suppress entire axis", $
"		  8	Suppress box style axis (i.e., draw axis on only one side of plot)", $
"		 16	Inhibit setting the Y axis minimum value to 0", $
"	 Note that this keyword is set bitwise, so multiple effects can be set by adding values together. ", $
"	 For example, to make an Y axis that is both exact (value 1) and suppresses the box style (setting 8), ", $
"	 set the YAXIS keyword to 1+8, or 9", $
"  ", $
"  Bilden eines 'running -mean': (OPTIONEN / Smooth)", $  
"	-  der eingegebene Wert entspricht in Idl:", $
"		Width", $
"		The width of the smoothing window. Width should be an odd number, smaller than ", $
"		the smallest dimension of Array. If Width is an even number, one plus the given value of Width is used.", $
" ", $
"  Entfernen eines Graphen (OPTIONEN / delete)", $
"  	- zerst�rt den Graphen und das dazugeh�rige OPTIONEN-Fenster", $
"	- nicht r�ckg�ngig zu machen!", $
" ", $
"  Entfernen aller Graphen (MAIN / clear all)", $
"	- alle Graphen werden gel�scht; diese Operation ist nicht r�ckg�ngig zu machen!", $
" ", $
"  R�ckg�ngig machen aller Operationen: (OPTIONEN / reset)", $
" 	- setzt den Graph auf die urspr�nglichen Werte zur�ck und l�scht die Operationen-Liste", $
" 	- nicht r�ckg�ngig zu machen!", $
" ", $
"  R�ckg�ngig machen einer bestimmten Operation: (OPTIONEN / Undo)", $
" 	- w�hlen Sie einen Eintrag aus der Liste aus", $  
" 	- klicken Sie auf Undo", $
"	- nicht r�ckg�ngig zu machen!", $
" ", $
"  R�ckg�ngig machen eines Zooms, s. Undo", $
" ", $
"  R�ckg�ngig machen aller Zooms: (OPTIONEN / Unzoom)", $
" 	- macht alle zoom - Operationen r�ckg�ngig", $
" ", $
"  Gegeneinander Auftragen (Korrelieren) zweier bestehender Graphen: (OPTIONEN / Correlate)", $
" 	- w�hlen Sie die Nummer des Graphen, dessen y-Werte gegen die y-Werte des Graphen geplottet werden", $
"	   sollen, in dessen OPTIONEN Fenster diese Eingabe gemacht wird. ", $
"	- w�hlen Sie unter 'Time interval' ein Zeitintervall in ms aus, in dem Zeiten als zueinandergeh�rig", $
"	   betrachtet werden sollen.", $
"  ", $
"  Gegeneinander Auftragen (Korrelieren) zweier Parameter: ", $
" 	- w�hlen Sie vor dem Plotten als x-Parameter nicht TIME, sondern geben Sie einen zweiten Parameter ein", $
"	- 'Time interval' gibt das Zeitintervall an, in dem zwei Zeiten als zueinandergeh�rig angesehen werden.", $
" ", $
"  Vertauschen der Achsen: (OPTIONEN / Flip axes)", $
"  	- klicken Sie auf 'Flip axes' um die Orientierung der Daten zu vertauschen; das array, das bisher der ", $
"	  x-Achse zugeordnet wurde, wird jetzt der y-Achse zugeordnet und umgekehrt", $
" ", $
"  Drucken aller Graphen: (MAIN / print all...)", $
"	- alle bisher erstellten Graphen werden �ber den erscheinenden Dialog in ein ps-File geschrieben; ", $
"	  jeder Graph wird dabei auf eine eigene Seite geschrieben.", $
" 	- Aus uns nicht erkl�rlichen Gr�nden darf dabei kein OPTIONEN- Fenster ge�ffnet sein!!!", $   
" ", $
"  Festlegen der Starteinstellungen: (MAIN / Preferences)", $
" 	- in diesem Dialog kann man Einstellungen speichern", $
" 	- hier l��t sich auch das automatische Speichern der ausgelesenen Daten ausschalten", $
"  ", $
"  Beenden des Programms: (MAIN / exit)", $
" 	- schlie�t das Hauptfenster und alle aus dem Programm ge�ffneten Fenster", $
" ", $
"                          " ]
textsize = 120
textID = Widget_Text(displaybase, Value=helptext, YSize=textsize)    
donebutton = WIDGET_BUTTON(mainbase, VALUE='Done', UVALUE='DISPLAYDONE')
           text = { state:state, donebutton: donebutton}
           WIDGET_CONTROL, mainbase, SET_UVALUE=text
           WIDGET_CONTROL, mainbase, /REALIZE
           XMANAGER, 'cs_display_info', mainbase
END
