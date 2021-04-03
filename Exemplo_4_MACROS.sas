/* Macro no SAS são funções, estas funções podem possuir variáveis que são conhecidas como macro variáveis */

/* Criamos um conjunto de dados para exemplo */
DATA dados;
   infile datalines delimiter=','; 
   input data $10. acessos local $20.;
   datalines;
1960-01-01,  -400, 99-Máquina do tempo
2020-01-01,  200,  01-Casa
2020-01-02,  400,  02-Apartamento
2020-02-01,  500,  02-Apartamento
;
RUN;

/* Uma macro variável pode ser declarada com: */
%LET var_num = 42;
%LET var_string = Um texto;

/* Para printar as macros variáveis */
/* O acesso as macro variáveis é feito com um & antes do nome e um "." no final. O "." na maioria das vezes pode ser omitido */
%put Var numérica: &var_num.;
%put Var texto: &var_string.;


/* Você pode criar uma macro variável utilizando into no PROC SQL */
PROC SQL;
select mean(acessos) into: macro_var_acessos
from dados
;
QUIT;

%put Var criada em PROC SQL: &macro_var_acessos.;




/* Agora vamos criar uma macro (função) com if e else */
%MACRO MACRO_EXEMPLO(qual_if);

	%IF &qual_if. = 1 %THEN 
		%DO;
			%PUT Entrou no if: 2;
		%END; 
	%ELSE %IF &qual_if. = 2 %THEN 
		%DO;
			%PUT Entrou no if: = 2;
		%END;
	%ELSE 
		%DO;
			%PUT Entrou no if: = ELSE;
		%END;
	
	%PUT A MACRO VAR qual_if = &qual_if.;
	%PUT O quadrado da MACRO VAR é: %eval(&qual_if. * 2);
	
	%do n=2 %to 20 %by 3;
		%PUT n no loop do = &n.;
	%end;

/* A macro termina com %MEND, você pode ou não colocar também o nome da macro para maior clareza */
%MEND MACRO_EXEMPLO;

%MACRO_EXEMPLO(2);


/* Agora vamos criar uma macro (função) com loops */
%MACRO MACRO_EXEMPLO_2();

/* Você pode utilizar if e do para escrever uma query, exemplo: */
	PROC SQL;
		select a.*
		/* Ele irá Rodar o Loop criando as linhas uma a uma (importante tomar cuidado com a sintaxe ",s") */
		%do n=2 %to 20 %by 3;
		, &n. as var_&n.
		%end;
		from dados as a
		;
	QUIT;

%MEND MACRO_EXEMPLO_2;

%MACRO_EXEMPLO_2();


/* Você tem uma série de elementos e gostaria de escolher qual utilizar */
/* A função scan pega o n-ésimo elemento consigerando um separado, que no nosso caso é um espaço */

%MACRO MACRO_EXEMPLO_3(elemento);

	%let texto = elemento_1 elemento_2 elemento_3;
	%PUT Printei o elemento: %scan(&texto., &elemento., " ");

%MEND MACRO_EXEMPLO_3;


%MACRO_EXEMPLO_3(2);




