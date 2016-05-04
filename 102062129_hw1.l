%option noyywrap
%{
	/*	1.Variable declaration/initialization
		2.Int, double, char
		3.Simple statement (number,character,string)
		4.Branch (if,else if,else,for,while)
		5.Function
		6.Comment 
		7.Switch (switch,case,default)
		8.Variable scope
		9.Array
		10.Pointer
		11.Include/define
		12.Struct
	*/

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define  name_length 256
	#define  variables_num 100
	#define  functions_num 100
	int count=1;
	int vnum=0;			//variable numbers
	int fnum=0;			//function numbers
	struct variable {
		char name[name_length];
		char scope[name_length];
	};
	
	struct function {
		char name[name_length];
	};
	struct variable variables[variables_num];
	struct function functions[functions_num];
	
	char nowscope[name_length]="global";
	int array_flag=0;
	int global_flag=0;
	int flag=0;
%}
%x COMMENT1
%x COMMENT2
%x DEFINE
sp [ \f\n\r\t\v]
branch (if|while|for|else|else{sp}if)
operator ("++"|"--"|"=="|"!="|"<="|">="|"<<"|">>"|"&&"|"||"|"+"|"-"|"*"|"/"|"="|"<"|">"|"&"|"|"|"!"|"%")
data (int{sp}*\**|double{sp}*\**|char{sp}*\**|void|struct)
punctuation (","|":")
name [[:alpha:]_][[:alnum:]_\-\>\.]*
active (#include|return|continue|break|typedef)
switch (switch|case|default)
define #(define|ifdef|ifndef)
%%
\n					{count++;} 	//Record lines here
"//" 				{printf("#%d comment\n",count);BEGIN COMMENT1;}
"/*" 				{printf("#%d comment\n",count);BEGIN COMMENT2;}
{define}			{printf("#%d %s ",count,yytext);BEGIN DEFINE;}
\<{name}\.h\>		{printf("#%d headerfile : %s\n",count,yytext);}
{data}				{printf("#%d data type  : %s\n",count,yytext);flag=1;}
{operator}			{printf("#%d operator   : %s\n",count,yytext);}
{branch}/{sp}*\(*	{printf("#%d %s\n",count,yytext);}
{punctuation}		{printf("#%d %s\n",count,yytext);}
[\(\{]				{printf("#%d %s\n",count,yytext);global_flag++;}
[\)\}]				{printf("#%d %s\n",count,yytext);global_flag--;}
";"					{printf("#%d %s\n",count,yytext);flag=0;if(global_flag==0){strcpy(nowscope,"global");}}
{active}			{printf("#%d %s\n",count,yytext);}
{switch}/{sp}*\(*	{printf("#%d %s\n",count,yytext);}
(\[[[:digit:]]*\])*	{printf("#%d array      : %s\n",count,yytext);}
\'.\'				{printf("#%d character  : %s\n",count,yytext);}
\".+\"				{printf("#%d string     : %s\n",count,yytext);}
[[:digit:]]+"."?[[:digit:]]*	{printf("#%d number     : %s\n",count,yytext);}
{name}/{sp}*\(	{	int i=0;
					while(i<fnum){
						if(strcmp(yytext,functions[i].name)==0){
							printf("#%d function ID: %s\n",count,yytext);
							break;
						}
						i++;
					}
					if(i==fnum){
						printf("#%d function declaration ID: %s\n",count,yytext);
						strcpy(functions[fnum].name,yytext);
						fnum++;
					}
					if(global_flag==0)
						strcpy(nowscope,functions[i].name);
				}
{name}			{	int i=0;
					int j=0;
					int k;

					while(i<vnum){
						if(strcmp(yytext,variables[i].name)==0&&strcmp(nowscope,variables[i].scope)==0){
							printf("#%d variable ID: %s\n",count,yytext);
							k=i;
							break;
						}
						i++;
					}
					while(j<vnum&&i==vnum){
						if(strcmp(yytext,variables[j].name)==0&&strcmp("global",variables[j].scope)==0&&flag==0){
							printf("#%d variable ID: %s\n",count,yytext);
							k=j;
							break;
						}
						j++;
					}
					if(i==vnum&&j==vnum){
						printf("#%d variable declaration ID: %s\n",count,yytext);
						strcpy(variables[vnum].name,yytext);
						strcpy(variables[vnum].scope,nowscope);
						k=vnum;
						vnum++;
					}
					printf("#%d scope      : %s\n",count,variables[k].scope);
					if(array_flag==1){
						yymore();
						array_flag=0;
					}
				}
{name}/{sp}*=				{if(flag==1){printf("#%d variable initialization\n",count);}REJECT;}
{name}/(\[[[:digit:]]*\])*	{array_flag=1;REJECT;}
<COMMENT1>\n	{count++;BEGIN 0;}
<COMMENT2>\n	{count++;printf("#%d comment\n",count);}
<COMMENT2>"*/"	{BEGIN 0;}
<COMMENT1,COMMENT2>.
<DEFINE>\n		{printf("%s",yytext);BEGIN 0;}
.				
%%
int main(){
	yylex();
	return 0;
}
