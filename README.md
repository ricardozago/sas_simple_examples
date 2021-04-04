O SAS é uma importante ferramenta de análise de dados muito utilizada no mundo empresarial. Seu uso no ambiente doméstico não é tão trivial quanto o Python ou R, que além de gratuitos estão a um download de distância.

No caso do SAS é disponibilizado uma versão para uso acadêmico, chamada de [SAS University Edition](https://www.sas.com/pt_br/software/university-edition.html), essa versão brevemente será substituída pelo [SAS OnDemand for Academics](https://www.sas.com/pt_br/software/on-demand-for-academics/references/getting-started-with-sas-ondemand-for-academics-studio.html). Essas versões podem ser a porta de entrada se você quer aprender a linguagem.

Escrevi 5 códigos que fazem alguns tratamentos comuns de dados, utilizando os famosos datasets Airpassagers e Iris. A ideia não é dar um curso de SAS, mas sim servir como uma referência para quem já tem alguma noção da linguagem ou ao menos entende de SQL e precisa fazer alguma coisa básica em SAS (ou nem tão básica, já que entramos em Macros).

- [Exemplo 1: ARIMA](https://github.com/ricardozago/sas_simple_examples/blob/main/Exemplo_1_ARIMA.sas):
    - Renomeamos colunas em um dataset;
    - Ordenamos um dataset (PROC SORT);
    - Removemos linhas duplicadas (PROC SORT);
    - Comparamos dois datasets (PROC COMPARE);
    - Utilizamos um modelo ARIMA (PROC ARIMA);
    - Criamos média móveis e alisamento exponencial (PROC EXPAND);
    - Cruzamento de bases com DATA STEP (PROC MERGE);
- [Exemplo 2: IRIS](https://github.com/ricardozago/sas_simple_examples/blob/main/Exemplo_2_IRIS.sas):
    - Importamos um CSV (PROC IMPORT);
    - Verificamos as colunas e tipos da base (PROC CONTENTS);
    - Utilizamos comandos DATA STEP para tratar o dataset;
		- IF e ELSE IF (equivale ao case when no SQL);
    - Dividimos os dados em conjunto de treinamento e teste (PROC SURVEYSELECT);
    - Treinamos um modelo (PROC REG);
    - Escoramos o modelo (PROC SCORE);
    - Criação de queries em SQL (PROC SQL);
    - Modelo de árvore (PROC HPSPLIT);
- [Exemplo 3: Datas](https://github.com/ricardozago/sas_simple_examples/blob/main/Exemplo_3_DATAS.sas):
    - Criamos um dataset com dados escritos no próprio DATA utilizando o parâmetro "infile";
    - Mostramos como as datas são armazenadas no SAS;
    - Formatamos as datas;
    - Filtramos as datas;
    - Calculamos intervalos entre datas;
    - Convertemos texto para número;
    - Deixamos em maiúsculo ou minúsculo o texto;
- [Exemplo 4: Macros](https://github.com/ricardozago/sas_simple_examples/blob/main/Exemplo_4_MACROS.sas):
    - Definição de macro variáveis;
    - "Print" de texto no "console";
    - Criação de macro variáveis com PROC SQL;
    - Criação de macros;
    - Uso de controle de fluxo (if, else);
    - Uso de loop;
    - Uso de loop para escrita de SQL;
    - Truques para macros;
- [Exemplo 5: Gráficos](https://github.com/ricardozago/sas_simple_examples/blob/main/Exemplo_5_Plots.sas):
    - Plota gráfico de série temporal (PROC SGPLOT);
    - Esboça scatter plot com dataset Iris (PROC SGPLOT).

Sintam-se à vontade para abrir issues caso queiram algum conteúdo específico ou pull requests caso tenham alguma coisa a contribuir.
