/* Apaga o dataset se ele já existir */
/* PROC SQL; */
/* drop table work.IRIS; */
/* QUIT; */

/* O SAS possui o dataset iris já implementado */
PROC PRINT
	data =  sashelp.iris;
RUN;

PROC UNIVARIATE data = sashelp.iris;
	var SepalLength SepalWidth;
	histogram;
RUN;

/* Importa o arquivo para mostrar como importar um arquivo .csv */
PROC IMPORT datafile = '/folders/myfolders/Iris.csv'
out = work.IRIS dbms = CSV;
RUN;

/* Troca a quantidade o tamanho da quantidade de observações utilizada */
/* Ou seja, as queries após essa instrução usarão apenas a quantidade de linhas indicada */
/* OPTIONS obs = 15; */
/* OPTIONS obs = MAX; */

/* Renomeia coluna */
DATA work.IRIS;
SET work.IRIS;
	rename species = VAR_RESP;
RUN;

PROC CONTENTS
	data =  work.IRIS;
RUN;


PROC FORMAT;
VALUE PLANTAS_NUM
	1 = "setosa"
	2 = "versic"
	3 = "virgin"
	OTHER = "";
RUN;

DATA work.IRIS_TRATADO(drop = VAR_RESP);
SET work.IRIS;
	/* 	Pre formata o campo VAR_RESP_NUM como número de 3 digitos */
	FORMAT VAR_RESP_NUM 3.;
	/* 	Pre formata o campo VAR_RESP_TEXT como string de 8 caracteres*/
	FORMAT VAR_RESP_TEXT $8.;
	
	/* 	"Case when" do DATASTEP do SAS */
	/* 	Similar a case when VAR_RESP = "Iris-setosa" THEN 1 ... end as VAR_RESP_NUM */
	IF VAR_RESP = "Iris-setosa" THEN VAR_RESP_NUM = 1;
	ELSE IF VAR_RESP = "Iris-versic" THEN VAR_RESP_NUM = 2;
	ELSE IF VAR_RESP = "Iris-virgin" THEN VAR_RESP_NUM = 3;
	
	/* 	Cria um campo formatado com o format criado acima */
	VAR_RESP_TEXT = put(VAR_RESP_NUM, PLANTAS_NUM.);
RUN;


/* Para fazer uma amostragem com seed */
PROC SURVEYSELECT data=IRIS_TRATADO out=IRIS_SAMPLE METHOD=SRS samprate=0.8 outall seed=42;
RUN;

/* Vamos verificar se a amostragem respeitou a quantidade pretendida */
PROC SQL;
CREATE TABLE TEMP_TESTE_AMOSTRA AS
select selected, count(*) as n,
(calculated n)/150 as PROPORCAO
from IRIS_SAMPLE
group by 1
;
QUIT;

/* Cria conjuntos de treinamento e teste */
/* ************************************************************************************************************************ */
/* Um detalhe é que existem dois métodos para se escorar um modelo: */
/* 1) Deixar como missing as observações que não devam entrar */
/* no conjunto de treinamento, mas que devem ser escoradas no conjunto de teste. Desta forma só o que não é missing é utilizado  */
/* para cálculo dos parametros do modelo e todas as observações são escoradas (mesmo as com missing na var resp). */
/* https://blogs.sas.com/content/iml/2014/02/17/the-missing-value-trick-for-scoring-a-regression-model.html */
/* 2)Também é possível o PROC SCORE. A seguir utilizaremos ambas as abordagens. */
/* https://blogs.sas.com/content/iml/2014/02/19/scoring-a-regression-model-in-sas.html */
/* ************************************************************************************************************************ */
DATA IRIS_DATA_TRAIN (KEEP = sepal_length sepal_width petal_length petal_width VAR_RESP_NUM);
SET IRIS_SAMPLE;
	if selected = 0 then VAR_RESP_NUM = .;
RUN;

DATA IRIS_DATA_TEST (KEEP = sepal_length sepal_width petal_length petal_width VAR_RESP_NUM);
SET IRIS_SAMPLE(where = (selected = 0));
RUN;

/* Vamos fazer uma regressão linear */
PROC REG data=IRIS_DATA_TRAIN OUTEST=PARAMETROS_REGRESSAO;
	/* noint remove o intercepto do modelo */
	YHat: model VAR_RESP_NUM = sepal_length sepal_width petal_length petal_width /noint;
	output out=MODELO_ESCORADO p=P; 
RUN;

/* Repare que mesmo as observações que possuem missing na VAR_RESP_NUM são escoradas */

/* Vamos escorar um modelo agora com o PROC SCORE*/
PROC SCORE data=IRIS_DATA_TEST score=PARAMETROS_REGRESSAO type=parms predict out=IRIS_DATA_PREDICAO_TEST;
   var sepal_length sepal_width petal_length petal_width;
RUN;

/* No SAS podemos utilizar tanto o data step quanto o PROC SQL, que roda comandos SQL, vamos escrever uma query para verificar */
/* a performance do nosso modelo em SQL. */
PROC SQL;
create table IRIS_DATA_PREDICAO_TEST as
select a.*, round(YHat) as YHat_ROUND
from IRIS_DATA_PREDICAO_TEST as A
;QUIT;

/* Agora vamos verificar a acurácia do nosso modelo de regressão linear */
PROC SQL;
create table dataset_acuracy as
select n/sum(n) as acuracy
from (
select case when var_resp_num = YHat_ROUND then 1 else 0 end as acertos,
count(*) as n
from IRIS_DATA_PREDICAO_TEST as A
group by 1)
having acertos = 1
;QUIT;
/* 97%, um bom número! */


/* Acaba aqui o código que roda no SAS University Edition */
/* O PROC HPSPLIT só roda no SAS OnDemand */
/* https://blogs.sas.com/content/sgf/2020/08/27/build-a-decision-tree-in-sas/ */

ODS GRAPHICS ON;

PROC HPSPLIT DATA=IRIS_DATA_TRAIN(where=(VAR_RESP_NUM ne .)) seed=42;
	class VAR_RESP_NUM _CHARACTER_ sepal_length sepal_width petal_length petal_width;
	model VAR_RESP_NUM = sepal_length sepal_width petal_length petal_width;
	grow ENTROPY;
	prune costcomplexity;
	CODE FILE='/folders/myfolders/tree_fit.sas';
    OUTPUT OUT = SCORED;
RUN;

DATA test_scored;
    SET IRIS_DATA_TEST;
    %INCLUDE '/folders/myfolders/tree_fit.sas';
    IF P_VAR_RESP_NUM1 = 1 THEN YHat = 1;
    ELSE IF P_VAR_RESP_NUM2 = 1 THEN YHat = 2;
    ELSE IF P_VAR_RESP_NUM3 = 1 THEN YHat = 3;
RUN;

/* Agora vamos verificar a acurácia do nosso modelo de árvore */
PROC SQL;
	create table dataset_acuracy as
	select n/sum(n) as acuracy
	from (select case when var_resp_num = YHat then 1 else 0 end as acertos,
	count(*) as n
	from test_scored as A
	group by 1)
	having acertos = 1
;QUIT;

/* 46%, para surpresa de ninguém o modelo de árvore overfitou */