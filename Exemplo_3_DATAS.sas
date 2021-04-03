/* Neste arquivo iremos aprender os principais tratamentos de datas e alguns de conversões de tipos */
DATA tratamento;
   infile datalines delimiter=','; 
   input data $10. acessos local $20.;
   datalines;
1960-01-01,  -400, 99-Máquina do tempo
2020-01-01,  200,  01-Casa
2020-01-02,  400,  02-Apartamento
2020-02-01,  500,  02-Apartamento
;
RUN;

/* Transforma string em variável de data, além disso mostra como as datas são exibidas */
DATA tratamento_datas;
SET tratamento;

/* O SAS armazena datas como quantidade de anos a partir de 01/01/1960 */
DateSas_num = input(data,yymmdd10.);
DateSas_anos = DateSas_num /365; 

DateSas_date9 = input(data, yymmdd10.);
format DateSas_date9 date9.;

DateSas_DDMMYYD10 = input(data, yymmdd10.);
format DateSas_DDMMYYD10 DDMMYYD10.;

/* Calcula intervalo em meses ou anos entre duas datas */
anos = intck('YEAR', DateSas_num, mdy(12,30,2020), 'c');
meses = intck('MONTH', DateSas_num, mdy(12,30,2020), 'c');
RUN;

/* Filtra datas */
DATA tratamento_datas_filtrada;
set tratamento_datas (where=(DateSas_date9>"10sep2015"d));
RUN;


DATA tratamento_strings;
set tratamento; 
num_best = input(substr(local,1,2),best.);
num_3 = input(substr(local,1,2),3.);

LOCAL_MAIUSCULO = UPCASE(local);
LOCAL_MINUSCULO = LOWCASE (local);
RUN;
