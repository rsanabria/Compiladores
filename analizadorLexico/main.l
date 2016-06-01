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
void parser();
void imprimirIdentificadores();
void strreplace(char *src, char *str, char *rep) ;
void S();
void P();
void D();
void B();
void A();
void I();
void C();
void R();
void O();
void T(int a);
void K();
void F();
void N();
void U();
void L();
void E(int a);
FILE *tokens;
FILE *identificadores_f;
FILE *constantes_f;
FILE *constantesnum_f;
FILE *codigo_f;
FILE *argumentos_f;
FILE *codigo_traducido_f;
int palres = 0, ident = 0, rel = 0,esp = 0,cod = 0,cont_codigo = 0,contador = 0,contadorId = 0,contadorConst = 0,contadorNum=0,contadorCod=0,contadorEspeciales=0,contadorArgumento;
char codigo[500];
char *reservadas[] = {"#define","#elif","#else","#endif","#if" ,"#ifdef","#ifndef","#undef"};
char *relacionales[] = {"> ",">= ","< ","<= ","== ","!= "};
char identificadores_a[25][100];
char identificadores_a_valor_activos[25][100];
char constantes_a[25][100];
char constantesnum_a[25][100];
char codigo_a[25][300];
char argumentos_a[25][15];

/*Variables para el Analizador Sintáctic*/
char cadenaAtomos[600];
int  idx_atomos = 0;
char *atomosReservadas[] = {"d","l","e","n","i","f","g","u"};
char *atomosRelacionales[] = {">","y","<","m","s","t"};
/*Variables para el Traductor*/
int getPosTokens();
char getPosValor();
void indicarValor(int p,int v);
void activaConstante(int p);
void desactivarConstante(int p);
void codigoSustitucion (int q) ;
int d_activarCodigo_porId(int p, int q, int act);
void d_activarCodigo(int a,int q);
    
char *constantesnumericas[50][100];
char *valores_identificadores[25][25];
int identificadores_activos[25];
int codigos_activos[25];
%}

reservadas #(define|elif|else|endif|if|ifdef|ifndef|undef)(" ")?
identificadores [A-Z]+(" ")?
constantes \$.+$
constantesnum [0-9]+(.?[0-9]*)
relacionales (>|>=|<|<=|==|!=)" "
especiales \(|\)|,
%%
{reservadas} {

    if ( cod == 1) {
            cod = 0;
            cont_codigo = 0;
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
            
            /*Sitactico*/
            if (strcmp(yytext,"(") == 0) 
                cadenaAtomos[idx_atomos] = '(';
            else if (strcmp(yytext,")") == 0)
                cadenaAtomos[idx_atomos] = ')';
            else 
                cadenaAtomos[idx_atomos] = ',';
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
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
    }
    else if (cod=1) {
        codigo[cont_codigo] = '@';
        cont_codigo += 1;
        /*cod=0;*/
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
            switch(i) {
                case 0: cadenaAtomos[idx_atomos] = 'd';
                        break;
                case 1: cadenaAtomos[idx_atomos] = 'l';
                        break;
                case 2: cadenaAtomos[idx_atomos] = 'e';
                        break;
                case 3: cadenaAtomos[idx_atomos] = 'n';
                        break;
                case 4: cadenaAtomos[idx_atomos] = 'i';
                        break;
                case 5: cadenaAtomos[idx_atomos] = 'l';
                        break;
                case 6: cadenaAtomos[idx_atomos] = 'g';
                        break;
                case 7: cadenaAtomos[idx_atomos] = 'u';
                        break;
            }
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
            return;
        }
        
    }
}

void buscarRelacional(char cadena[]) {
    int i;
    for (i=0;i <6;i++) {
        if (strcmp(cadena,relacionales[i]) == 0) {
            fprintf(tokens,"4,%d\n",i);
        /*Sintáctico*/
            switch(i) {
                case 0: cadenaAtomos[idx_atomos] = '>';
                        break;
                case 1: cadenaAtomos[idx_atomos] = 'y';
                        break;
                case 2: cadenaAtomos[idx_atomos] = '<';
                        break;
                case 3: cadenaAtomos[idx_atomos] = 'm';
                        break;
                case 4: cadenaAtomos[idx_atomos] = 's';
                        break;
                case 5: cadenaAtomos[idx_atomos] = 't';
                        break;
            }
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
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
        strcpy(identificadores_a_valor_activos[contadorId],cadena_se);
        //fprintf(identificadores_f,"%s\n",cadena_se);
        fprintf(tokens,"1,%d\n",contadorId);
        contadorId += 1; 
        /*Sintáctico*/
        cadenaAtomos[idx_atomos] = 'a';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
    } else {
    for(i=0; i < contadorId;i++) {
        if(strcmp(identificadores_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"1,%d\n",i);
        /*Sintáctico*/
            cadenaAtomos[idx_atomos] = 'a';
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
        }
    }
    if(existe == 0 ) {
    strcpy(identificadores_a[contadorId],cadena_se);
    strcpy(identificadores_a_valor_activos[contadorId],cadena_se);
        //fprintf(identificadores_f,"%s\n",cadena_se);
        fprintf(tokens,"1,%d\n",contadorId);
        contadorId += 1; 
    /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'a';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
    }
    }
    
}
void pushConstantes(char cadena[]) {
    int i,cont=0;
    char cadena_se[20];
    memset(&cadena_se[0],0,20);
    
    for(i=1;i <strlen(cadena);i++) {
        if(cadena[i] != ' ' || cadena[i] != '$') {
            cadena_se[cont] = cadena[i];
            cont += 1;
        }
    }
    int existe = 0;
    if (contadorConst == 0) {
        strcpy(constantes_a[contadorConst],cadena_se);
        fprintf(constantes_f,"%s\n",cadena_se);
        fprintf(tokens,"2,%d\n",contadorConst);
        //strcpy(constantesnumericas[contadorConst],cadena_se);
        contadorConst += 1; 
            /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'v';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
    } else {
    for(i=0; i < contadorConst;i++) {
        if(strcmp(constantes_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"2,%d\n",i);
            /*Sitactico*/
            cadenaAtomos[idx_atomos] = 'v';
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
        }
    }
    if(existe == 0 ) {
    strcpy(constantes_a[contadorConst],cadena_se);
        fprintf(constantes_f,"%s\n",cadena_se);
        fprintf(tokens,"2,%d\n",contadorConst);
        //strcpy(constantesnumericas[contadorConst],cadena_se);
        contadorConst += 1;
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'v';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
        
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
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'c';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
    } else {
    for(i=0; i < contadorNum;i++) {
        if(strcmp(constantesnum_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"3,%d\n",i);
            /*Sitactico*/
            cadenaAtomos[idx_atomos] = 'c';
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
        }
    }
    if(existe == 0 ) {
    strcpy(constantesnum_a[contadorNum],cadena_se);
        fprintf(constantesnum_f,"%s\n",cadena_se);
        fprintf(tokens,"3,%d\n",contadorNum);
        contadorNum += 1;  
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'c';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
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
        }else {
            cadena_se[cont] = '@';
        }
        cont += 1;
    }
    strcpy(codigo_a[contadorCod],cadena_se);
        fprintf(tokens,"5,%d\n",contadorCod);
        fprintf(codigo_f,"%s\n",cadena_se);
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'q';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
        codigos_activos[contadorCod] = 1;
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
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'a';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
        
    } else {
    for(i=0; i < contadorArgumento;i++) {
        if(strcmp(argumentos_a[i],cadena_se) == 0) {
            existe = 1;
            fprintf(tokens,"7,%d\n",i);
            /*Sitactico*/
            cadenaAtomos[idx_atomos] = 'a';
            ++idx_atomos;
            printf("%s\n",cadenaAtomos);
            }
    }
    if(existe == 0 ) {
    strcpy(argumentos_a[contadorArgumento],cadena_se);
        fprintf(argumentos_f,"%s\n",cadena_se);
        fprintf(tokens,"7,%d\n",contadorArgumento);
        contadorArgumento += 1;   
        /*Sitactico*/
        cadenaAtomos[idx_atomos] = 'a';
        ++idx_atomos;
        printf("%s\n",cadenaAtomos);
    }
    }
    
}
/*Análisis Sintáctico*/
/*Inicio del Parser aquí se llamara al simbolo inicial de la gramatica y se analizara la cadena de atomos en un automata push down o tabla de parser*/
void parser() {
    idx_atomos = 0;
    printf("Inicio del PArser, cadena a analizar: %s\n",cadenaAtomos);
    
    S();
    if (cadenaAtomos[idx_atomos] == '&') {
        printf("No se encontraron errores léxicos\n");
    }
    
}

void S() {
    printf("Estado S, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
 if (cadenaAtomos[idx_atomos] == 'q' || cadenaAtomos[idx_atomos] == 'd' || cadenaAtomos[idx_atomos] == 'i' || cadenaAtomos[idx_atomos] == 'l' || cadenaAtomos[idx_atomos] == 'g' || cadenaAtomos[idx_atomos] == 'u') {
     T(-1);
 } else {
     printf("Error en S, al procesar: %c\n",cadenaAtomos[idx_atomos]);
 }
}

void P() {
    printf("Estado P, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    switch (cadenaAtomos[idx_atomos]) {
        case 'd':
            D();
            break;
        case 'i' :
            I();
            break;
        case 'l' :
            F();
            break;
        case 'g':
            N();
            break;
        case 'u':
            U();
            break;
        default: 
            printf("Error en P, al procesar: %c\n",cadenaAtomos[idx_atomos]);
            
    }
}

void D() {
    int p,v;
    printf("Estado D, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'd') {
        ++idx_atomos;
        if (cadenaAtomos[idx_atomos] == 'a') {
            p = getPosTokens();
            ++idx_atomos;
            B();
            if (cadenaAtomos[idx_atomos] == 'v') {
                v = getPosTokens(); //posicion del valor de la constante
            ++idx_atomos;
                indicarValor(p,v);
                activaConstante(p);
                return;
            } else {
                printf("Error en D,se esperaba v, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
            }
        } else {
           printf("Error en D,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
        }
        
    } else {
        printf("Error en D,se esperaba d, se procesó: %c\n",cadenaAtomos[idx_atomos]);
    }
    
    
}
void B() {
    printf("Estado B, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'v' /*|| cadenaAtomos[idx_atomos] == '&'*/) {
        return;
    }
    else if (cadenaAtomos[idx_atomos] == '(') {
        ++idx_atomos;
        if (cadenaAtomos[idx_atomos] == 'a') {
            ++idx_atomos;
            A();
            if (cadenaAtomos[idx_atomos] == ')') {
                 ++idx_atomos;
                return;
            } else {
               printf("Error en B,se esperaba ), se procesó: %c\n",cadenaAtomos[idx_atomos]);  
            }
        }else {
           printf("Error en B,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
        }
     
 } else {
    printf("Error en B, al procesar: %c\n",cadenaAtomos[idx_atomos]);
    } 
 
}
void A() {
    printf("Estado A, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]);
  if (cadenaAtomos[idx_atomos] == ',') {
      ++idx_atomos;
      if (cadenaAtomos[idx_atomos] == 'a') {
          ++idx_atomos;
          A();
      } else {
          printf("Error en A,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
      }
  } else if(cadenaAtomos[idx_atomos] == ')' ||cadenaAtomos[idx_atomos] == '&') {
      return;
  } else {
       printf("Error en A, al procesar: %c\n",cadenaAtomos[idx_atomos]);
  } 
}
void I(){
  printf("Estado I, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'i') {
        ++idx_atomos;
        C();
        O();
        if (cadenaAtomos[idx_atomos] == 'n') {
            ++idx_atomos;
            return;
        } else {
            printf("Error en I,se esperaba n, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
        }
    } else {
        printf("Error en I,se esperaba i, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
    }
    
}
void C(){
    printf("Estado C, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'a') {
        ++idx_atomos;
        R();
        if (cadenaAtomos[idx_atomos] == 'c') {
            ++idx_atomos;
            return;
        } else {
            printf("Error en C,se esperaba c, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
        }
    } else {
        printf("Error en C,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
    }
}
void R(){
    printf("Estado R, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == '>' || cadenaAtomos[idx_atomos] == 'y' || cadenaAtomos[idx_atomos] == '<' || cadenaAtomos[idx_atomos] == 'm' || cadenaAtomos[idx_atomos] == 's' || cadenaAtomos[idx_atomos] == 't') {
        ++idx_atomos;
        return;
    } else {
        printf("Error en A, al procesar: %c\n",cadenaAtomos[idx_atomos]);
    }
}
void O(){
    printf("Estado O, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
     if (cadenaAtomos[idx_atomos] == 'q' || cadenaAtomos[idx_atomos] == 'd' || cadenaAtomos[idx_atomos] == 'i' || cadenaAtomos[idx_atomos] == 'l' || cadenaAtomos[idx_atomos] == 'g' || cadenaAtomos[idx_atomos] == 'u') {
         T(-1);
         L();
         E(-1);
     }
}
void T(int a){
    int q;
    printf("Estado T, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'q') {
        q = getPosTokens();
        codigoSustitucion(q);
        if (a > 0)
            d_activarCodigo(a,q);
        ++idx_atomos;
        K();
        return;
    } else if (cadenaAtomos[idx_atomos] == 'd' || cadenaAtomos[idx_atomos] == 'i' || cadenaAtomos[idx_atomos] == 'l' || cadenaAtomos[idx_atomos] == 'g' || cadenaAtomos[idx_atomos] == 'u') {
        P();
        K();
        return;
    } else {
       printf("Error en T, al procesar: %c\n",cadenaAtomos[idx_atomos]); 
    }
}
void K(){
    int q;
    printf("Estado K, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'q') {
        q = getPosTokens();
        codigoSustitucion(q);
        ++idx_atomos;
        K();
        return;
    } else if (cadenaAtomos[idx_atomos] == 'd' || cadenaAtomos[idx_atomos] == 'i' || cadenaAtomos[idx_atomos] == 'l' || cadenaAtomos[idx_atomos] == 'g' || cadenaAtomos[idx_atomos] == 'u') {
        P();
        K();
        return;
    } else if (cadenaAtomos[idx_atomos] == '&') {
       return;
    }    
    
}
void F(){
    int p,q,a;
 printf("Estado F, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'l') {
        ++idx_atomos;
        if (cadenaAtomos[idx_atomos] == 'a') {
            p = getPosTokens();
            ++idx_atomos;
            if (cadenaAtomos[idx_atomos] == 'q') {
                q = getPosTokens();
                codigoSustitucion(q);
                a = d_activarCodigo_porId(p,q,1);
                ++idx_atomos;
                E(a);
                if (cadenaAtomos[idx_atomos] == 'n') { 
                    ++idx_atomos;
                    return;
                } else {
                printf("Error en F,se esperaba n, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
                }
            } else {
               printf("Error en F,se esperaba q, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
            }
        } else {
            printf("Error en F,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]);   
        }
    } else {
        printf("Error en F,se esperaba l, se procesó: %c\n",cadenaAtomos[idx_atomos]);
    }
}
void N(){
    int p,q,a;
 printf("Estado N, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'g') {
        ++idx_atomos;
        if (cadenaAtomos[idx_atomos] == 'a') {
            p = getPosTokens();
            ++idx_atomos;
            if (cadenaAtomos[idx_atomos] == 'q') {
                q = getPosTokens();
                codigoSustitucion(q);
                a = d_activarCodigo_porId(p,q,0);
                ++idx_atomos;
                E(a);
                if (cadenaAtomos[idx_atomos] == 'n') { 
                    ++idx_atomos;
                    return;
                } else {
                printf("Error en N,se esperaba n, se procesó: %c\n",cadenaAtomos[idx_atomos]);     
                }
            } else {
               printf("Error en N,se esperaba q, se procesó: %c\n",cadenaAtomos[idx_atomos]); 
            }
        } else {
            printf("Error en F,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]);   
        }
    } else {
        printf("Error en F,se esperaba g, se procesó: %c\n",cadenaAtomos[idx_atomos]);
    }
}
void U(){
 printf("Estado F, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'u') {
        int p;
        ++idx_atomos;
        if (cadenaAtomos[idx_atomos] == 'a') {
            p = getPosTokens();
            ++idx_atomos;
            desactivarConstante(p);
            return;
        } else {
            printf("Error en F,se esperaba a, se procesó: %c\n",cadenaAtomos[idx_atomos]);   
        }
    } else {
        printf("Error en F,se esperaba u, se procesó: %c\n",cadenaAtomos[idx_atomos]);
    }
}
void L(){
    printf("Estado L, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]);
    if (cadenaAtomos[idx_atomos] == 'l') {
        ++idx_atomos;
        C();
        T(-1);
        L();
        return;
    } else if (cadenaAtomos[idx_atomos] == 'e' || cadenaAtomos[idx_atomos] == '&') {
        return;
    } else {
        printf("Error en T, al procesar: %c\n",cadenaAtomos[idx_atomos]); 
    }
}
void E(int a){
   printf("Estado E, Valor a analizar: %c\n",cadenaAtomos[idx_atomos]); 
    if (cadenaAtomos[idx_atomos] == 'e') {
        ++idx_atomos;
        T(a);
        return;
    } else if (cadenaAtomos[idx_atomos] == 'n' || cadenaAtomos[idx_atomos] == '&') {
        return;
    } else {
       printf("Error en E, al procesar: %c\n",cadenaAtomos[idx_atomos]);  
    }
}


/*FUNCIONES AUXILIARES DEL TRADUCTOR*/
int getPosTokens() {
    int cont_token = 0;
    int a;
    char b;
    rewind(tokens);
    while (cont_token <= idx_atomos) {
        fscanf(tokens,"%d,%c",&a,&b);
        ++cont_token;
    }
    return atoi(&b);
}
void indicarValor(int p,int v) {
    int i,j;
    char valor[5];
    sprintf(valor," %d",v);
             strcat(identificadores_a_valor_activos[p],valor);
             //strcpy(valores_identificadores[p],valor);
}
void activaConstante(int p) {
             strcat(identificadores_a_valor_activos[p], " 1");
            identificadores_activos[p] = 1;

}
void desactivarConstante(int p) {
    strreplace(identificadores_a_valor_activos[p],"1","0");
    identificadores_activos[p] = 0;
}

void codigoSustitucion (int q) {
        int i;
        for (i=0;i < contadorId; i++) {
            if (identificadores_activos[i] == 1) {
                strreplace(codigo_a[q],identificadores_a[i],constantes_a[i]);
            }
        }
        //printf("%s\n",codigo_a[q]);
    
}
int d_activarCodigo_porId(int p, int q, int act) {
   if (act == 1){
       
       if (identificadores_activos[p] == 1) {
           codigos_activos[q] = 1;
           return 1;
       } else {
           codigos_activos[q] == 0;
           return 0;
       } 
   } else {
       if (identificadores_activos[p] == 0) {
           codigos_activos[q] = 1;
           return 1;
       } else {
           codigos_activos[q] = 0;
           return 0;
       }
   }
}
void d_activarCodigo(int a,int q) {
    if (a == 1) {
         /*entro al ifdef o ifndef*/
        codigos_activos[q] = 0;
    } else { 
        /*entro al #else*/
        codigos_activos[q] = 0;
    }
}


/*FUNCIONES AUXILIARES*/
void strreplace(char *src, char *str, char *rep) {
          
      char buffer[1024];
      char * ch;
 

      if(!(ch = strstr(src, str)))
              return;
 
      //copy todo el contenido del buffer antes de la primer ocurrencia de la busqueda
        strncpy(buffer, src, ch-src);
 
      //prepara el buffer para agregar, sumando un null al final
      buffer[ch-src] = 0;
 
      
      sprintf(buffer+(ch - src), "%s%s", rep, ch + strlen(str));
      src[0] = 0;
      strcpy(src, buffer);
      strreplace(src, str, rep);
    
}
void codigoTraducido() {
    int i;
    
    for(i=0; i < contadorCod;i++) {
        if (codigos_activos[i] == 1) {
        strreplace(codigo_a[i],"@","\n");
        fprintf(codigo_traducido_f,"%s",codigo_a[i]);
        }
    }
}
void imprimirIdentificadores(){
    for( int i= 0; i < contadorId;i++) {
        fprintf(identificadores_f,"%s\n",identificadores_a_valor_activos[i]);
    }
}
main (int argc,char *argv[]) {
    yyin = fopen(argv[1],"r");
    tokens = fopen("tokens.txt","w+");
    identificadores_f = fopen("identificadores.txt","w+");
    constantes_f = fopen("constantes.txt","w+");
    constantesnum_f = fopen("constantesnumericas.txt","w+");
    codigo_f = fopen("codigos.txt","w+");
    argumentos_f = fopen("argumentos.txt","w+");
    codigo_traducido_f = fopen("codigo.c","w+");
    yylex();
    pushCodigo(codigo);
    cadenaAtomos[idx_atomos] = '&'; /*fin de Cadena*/
    parser();
    imprimirIdentificadores();
    codigoTraducido();
    fclose(tokens);
    fclose(identificadores_f);
    fclose(constantes_f);
    fclose(codigo_f);
    fclose(argumentos_f);
    

    
}
