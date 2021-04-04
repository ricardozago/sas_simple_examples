/* Verifica quais licenças estão disponíveis */
PROC SETINIT;
RUN;

/* O SAS já possui o dataset AirPassengers implementado */
PROC PRINT
	data =  sashelp.air;
RUN;

/* Renomeia colunas */
DATA work.AirPassengers;
SET sashelp.air;
	rename AIR = Passengers;
	rename DATE = Month;
RUN;

/* Mostra as colunas e os tipos dos dados */
PROC CONTENTS
	data = work.AirPassengers;
RUN;

/* Mostra estatísticas do dataset, não útil aqui */
PROC FREQ data = work.AirPassengers;
RUN;

/* Desordenada os dados para ordenamos novamente */
/* https://sasnrd.com/sas-randomize-data-set/ */
PROC SURVEYSELECT data=work.AirPassengers out=work.AirPassengers
	outrandom
	method=srs 
	samprate=1
	seed=42;
RUN;

/* Ordena o dataset por mês */
PROC SORT IN = work.AirPassengers;
 	BY /* descending */ Month; 
RUN;

/* Vamos adicionar alguma 10 linha duplicada, para depois remover */
DATA TEMP;
SET work.AirPassengers (obs = 10);
RUN;

/* Unimos a dataset original e a de linhas duplicadas */
PROC SQL;
create table work.AirPassengers_DUP as
select * from work.AirPassengers
union all
select * from TEMP
;QUIT;

/* O PROC SQL acima é equivalente a: */
DATA work.AirPassengers_DUP;
SET
	work.AirPassengers
	TEMP;
RUN;

/* Vamos remover as linhas duplicadas */
PROC SORT data = work.AirPassengers_DUP
	nodupkey dupout = work.duplicadas
	out = work.AirPassengers_DEDUP;
	by Month;
RUN;

/* Vamos verificar se o dataset deduplicado é igual ao dataset original: */
PROC COMPARE BASE=AirPassengers 
	COMPARE=AirPassengers_DEDUP;
RUN;

/* Utilizamos um modelo do tipo ARIMA para realizar a projeção dos dados */
PROC ARIMA data=work.AirPassengers;
	identify var=Passengers(1);
	estimate p=(1)(12);
	forecast id=Month interval=month LEAD=60 out=forecast;
QUIT;


PROC SGPLOT data=forecast cycleattrs;
   series x=Month y=Passengers / name='MA'   legendlabel="Série observada";
   series x=Month y=Forecast  / name='WMA'  legendlabel="Projeção";
   xaxis label="Data" grid;
   yaxis label="Quantidade de passageiros" grid;
   title Resultado do modelo ARIMA com AR 1 e 12;
RUN;

/* Acaba aqui o código que roda no SAS University Edition */
/* O PROC EXPAND só roda no SAS OnDemand */

/* Vamos calcular a média móvel dos dados */
/* Os códigos foram adaptados da documentação do SAS para o exemplo */
/* https://blogs.sas.com/content/iml/2016/01/27/moving-average-in-sas.html */
/* Calcula uma média móvel 5 */
/* Calcula um alisamento exponencial igual a WMA(t) = (5yt + 4yt-1 + 3yt-2 + 2yt-3 + 1yt-4) / 15 */
/* Calcula um alisamento exponencial com fator de 0.3 */
PROC EXPAND data=AirPassengers out=AirPassengers_MA method=none;
   id Month;
   convert Passengers = MA   / transout=(movave 5);
   convert Passengers = WMA  / transout=(movave(1 2 3 4 5)); 
   convert Passengers = EWMA / transout=(ewma 0.3);
RUN;

PROC SGPLOT data=AirPassengers_MA cycleattrs;
   series x=Month y=MA   / name='MA'   legendlabel="MA(5)";
   series x=Month y=WMA  / name='WMA'  legendlabel="WMA(1,2,3,4,5)";
   series x=Month y=EWMA / name='EWMA' legendlabel="EWMA(0.3)";
   scatter x=Month y=Passengers;
   keylegend 'MA' 'WMA' 'EWMA';
   xaxis label="Data" grid;
   yaxis label="Quantidade de passageiros" grid;
RUN;

/* Exemplo de uso do MERGE, equivale a join no SQL */
DATA AirPassengers_MERGE;
MERGE
	AirPassengers
	AirPassengers_MA (KEEP = Month MA);
by Month;
RUN;