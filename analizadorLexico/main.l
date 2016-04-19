/*Sanabria Del Campo Carlos Rodrigo
    Analizador Léxico para un preprocesador
    2016-2
    Compiladores
    pasar como argumento un archivo a leer

*/
%{    
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
void buscarReservadas( char cadena[]);
void buscarRelacional(char cadena[]);
void pushIdentificador(char cadena[]);
void pushConstantes(char cadena[]);
void pushConstantesNum(char cadena[]);
void pushCodigo(char cadena[]);
void pushArgumento(char cadena[]);
FILE *tokens;
FILE *identificadores_f;
FILE *constantes_f;
FILE *constantesnum_f;
FILE *codigo_f;
FILE *argumentos_f;
int palres = 0, ident = 0, rel = 0,esp = 0,cod = 0,cont_codigo = 0,contador = 0,contadorId = 0,contadorConst = 0,contadorNum=0,contadorCod=0,contadorEspeciales=0,contadorArgumento;
char codigo[500];
char *reservadas[] = {"#define","#elif","#else","#endif","#if" ,"#ifdef","#ifndef","#undef"};
char *relacionales[] = {"> ",">= ","< ","<= ","== ","!= "};
char identificadores_a[25][100];
char constantes_a[25][100];
char constantesnum_a[25][100];
char codigo_a[25][300];
char argumentos_a[25][15];
%}

reservadas #(define|elif|else|endif|if|ifdef|ifndef|undef)(" ")?
identificadores [A-Z]+(" ")?
constantes \$.+$
constantesnum [0-9]+(.?[0-9]*)
relacionales (>|>=|<|<=|==|!=)" "
especiales \(|\)|,
%%
{reservadas} {
    /*printf("Palabra Reservada detectada!: %s\n",yytext);*/

    if ( cod == 1) {
            cod = 0;
            cont_codigo = 0;
            /*printf("%s\n",codigo);*/
            pushCodigo(codigo);
            memset(&codigo[0], 0, sizeof(codigo));
        }
        if(palres == 0) {
        buscarReservadas(yytext);
        palres = 1;
    }
}
{identificadores} {
    if (palres==1) {
        if (esp == 1 && palres == 1) {
            pushArgumento(yytext);
            ident = 1;
        }
        else if (palres == 1 && esp==0) {
            int n= 0;
            while ( yytext[n] != '\0') {
                n+= 1;
            }
            if (n <=10) {
                pushIdentificador(yytext);
                ident = 1; 
            } else {
                printf("\033[31mIdentificador de longuitud mayor a la permitida: %s\033[0m\n",yytext);
            }
        }
    } else {
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        }
    }
    /*palres = 0;*/
      
}
{relacionales} {
    if (palres == 1) {
        if ( ident == 1) {
            rel = 1;
            buscarRelacional(yytext);
        }
    } else {
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        }
    }
    /*ident = 0;*/
    
}
{constantes} {
    if (palres == 1) {
        if (ident == 1) {
            int n = 0;
            pushConstantes(yytext);
        }
    } else {
        /*codigo*/
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        }
    }
    /*ident = 0;*/

}
{constantesnum} {
    if ( palres == 1) {
        if ( ident == 1) {
            /*printf("%s,Constante Numérica\n",yytext);*/
        }
    } else {
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        }
    }
    }
{especiales} {
    if (palres == 1) {
        if (ident == 1) {
           /* printf("%s, Símbolo Especial\n",yytext);*/
            fprintf(tokens,"6,%s\n",yytext);
            esp = 1;
        }
    } else {
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        } 
    }
}
\n {
    if (palres == 1) {
    ident = 0;
    palres = 0;
    rel = 0;
    esp = 0;
    } else {
        
    }
}
. {
    if (yytext != " ") {
        cod = 1;
        contador = 0;
        while (yytext[contador] != '\0') {
        codigo[cont_codigo] = yytext[contador];
            cont_codigo += 1;
            contador += 1;
        }
    } else {
    }
    } 
%%



void buscarReservadas( char cadena[]) {
    int i,cont=0;
    char nuevaCadena[20];
    memset(&nuevaCadena[0],0,20);
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != ' ') {
            nuevaCadena[cont] = cadena[i];
            cont += 1;
        }
    }
    for (i=0;i < 8 ;i++) {
        if (strcmp(nuevaCadena,reservadas[i]) == 0) {
            fprintf(tokens,"0,%d\n",i);
            return;
        }
        
    }
}

void buscarRelacional(char cadena[]) {
    int i;
    for (i=0;i <6;i++) {
        if (strcmp(cadena,relacionales[i]) == 0) {
            fprintf(tokens,"4,%d\n",i);
        }
    }
    
}
void pushIdentificador(char cadena[]) {
    int i,cont=0;
    char cadena_se[20];
    memset(&cadena_se[0],0,20);
    
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != ' ') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    int existe = 0;
    if (contadorId == 0) {
        strcpy(identificadores_a[contadorId],cadena_se);
        fprintf(identificadores_f,"%s\n",cadena_se);
        fprintf(tokens,"1,%d\n",contadorId);
        contadorId += 1; 
    } else {
    for(i=0; i < contadorId;i++) {
        if(strcmp(identificadores_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"1,%d\n",i);
        }
    }
    if(existe == 0 ) {
    strcpy(identificadores_a[contadorId],cadena_se);
        fprintf(identificadores_f,"%s\n",cadena_se);
        fprintf(tokens,"1,%d\n",contadorId);
        contadorId += 1;    
    }
    }
    
}
void pushConstantes(char cadena[]) {
    int i,cont=0;
    char cadena_se[20];
    memset(&cadena_se[0],0,20);
    
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != ' ' || cadena[i] == '$') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    int existe = 0;
    if (contadorConst == 0) {
        strcpy(constantes_a[contadorConst],cadena_se);
        fprintf(constantes_f,"%s\n",cadena_se);
        fprintf(tokens,"2,%d\n",contadorConst);
        contadorConst += 1; 
    } else {
    for(i=0; i < contadorConst;i++) {
        if(strcmp(constantes_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"2,%d\n",i);
        }
    }
    if(existe == 0 ) {
    strcpy(constantes_a[contadorConst],cadena_se);
        fprintf(constantes_f,"%s\n",cadena_se);
        fprintf(tokens,"2,%d\n",contadorConst);
        contadorConst += 1;    
    }
    }
    
}

void pushConstantesNum(char cadena[]) {
    int i,cont=0;
    char cadena_se[20];
    memset(&cadena_se[0],0,20);
    
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != ' ' || cadena[i] == '$') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    int existe = 0;
    if (contadorNum == 0) {
        strcpy(constantesnum_a[contadorNum],cadena_se);
        fprintf(constantesnum_f,"%s\n",cadena_se);
        fprintf(tokens,"3,%d\n",contadorNum);
        contadorNum += 1; 
    } else {
    for(i=0; i < contadorNum;i++) {
        if(strcmp(constantesnum_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"3,%d\n",i);
        }
    }
    if(existe == 0 ) {
    strcpy(constantesnum_a[contadorNum],cadena_se);
        fprintf(constantesnum_f,"%s\n",cadena_se);
        fprintf(tokens,"3,%d\n",contadorNum);
        contadorNum += 1;    
    }
    }
    
}
void pushCodigo(char cadena[]) {
    int i,cont=0;
    char cadena_se[300];
    memset(&cadena_se[0],0,300);
    
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != '\n') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    strcpy(codigo_a[contadorCod],cadena_se);
        fprintf(tokens,"5,%d\n",contadorCod);
        fprintf(codigo_f,"%s\n",cadena_se);
        
        contadorCod += 1;    
    
}
void pushArgumento(char cadena[]) {
    int i,cont=0;
    char cadena_se[20];
    memset(&cadena_se[0],0,20);
    
    for(i=0;i <strlen(cadena);i++) {
        if(cadena[i] != ' ') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    int existe = 0;
    if (contadorArgumento == 0) {
        strcpy(argumentos_a[contadorArgumento],cadena_se);
        fprintf(argumentos_f,"%s\n",cadena_se);
        fprintf(tokens,"7,%d\n",contadorArgumento);
        contadorArgumento += 1; 
    } else {
    for(i=0; i < contadorArgumento;i++) {
        if(strcmp(argumentos_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"7,%d\n",i);
        }
    }
    if(existe == 0 ) {
    strcpy(argumentos_a[contadorArgumento],cadena_se);
        fprintf(argumentos_f,"%s\n",cadena_se);
        fprintf(tokens,"7,%d\n",contadorArgumento);
        contadorArgumento += 1;    
    }
    }
    
}
main (int argc,char *argv[]) {
    yyin = fopen(argv[1],"r");
    tokens = fopen("tokens.txt","w+");
    identificadores_f = fopen("identificadores.txt","w+");
    constantes_f = fopen("constantes.txt","w+");
    constantesnum_f = fopen("constantesnumericas.txt","w+");
    codigo_f = fopen("codigo.txt","w+");
    argumentos_f = fopen("argumentos.txt","w+");
    yylex();
    pushCodigo(codigo);
    fclose(tokens);
    fclose(identificadores_f);
    fclose(constantes_f);
    fclose(codigo_f);
    fclose(argumentos_f);
}
