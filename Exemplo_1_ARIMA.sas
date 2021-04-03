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
	forecast id=Passengers out=forecast LEAD=60;
QUIT;
