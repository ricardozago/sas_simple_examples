/* Vamos utilizar os datasets do SAS */

ods text= "Texto que deve ser escrito nos outputs, possivelmente explicando os resultados";
    
title 'Passageiros aéreos';

PROC SGPLOT data=sashelp.air;
   series x=date y=AIR / markers;
   format date yyqc.;
   yaxis label = "QTD Passageiros" 
   		values = (100 to 650 by 50) 
   		grid minor minorcount=2;
   xaxis label = "Datas" grid;
   refline '15jul51'd / axis=x;
   *title 'Passageiros aéreos';
RUN;

title;


/* https://blogs.sas.com/content/graphicallyspeaking/2016/10/04/getting-started-sgplot-part-1-scatter-plot/ */
PROC SGPLOT data=sashelp.iris;
	styleattrs datasymbols=(circlefilled trianglefilled)
                   datacontrastcolors=(olive maroon);
	scatter x=SepalLength y=SepalWidth / group=Species
		filledoutlinedmarkers markerattrs=(size=12) 
		markerfillattrs=(color=white) 
		markeroutlineattrs=(thickness=2);
	keylegend / location=inside position=bottomright;
	title 'Iris Dataset';
RUN;




