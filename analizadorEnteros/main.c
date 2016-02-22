                                                                /*Analizador Léxico de Enteros*/
                                                              /*Sanabria del Campo Carlos Rodrigo*/
                                                                    /*Compiladores 2016-2*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*Estados del automáta, cada estado recibe un caracter y dependiendo lo que reciba llamará otro estado o terminara su ejecución*/
int a(char v);
int b(char v);
int c(char v);
int d(char v);
int e(char v);
int f(char v);
int g(char v);
int h(char v);
int i(char v);
int j(char v);
int k(char v);
int l(char v);
int m(char v);
int n(char v);
int o(char v);
int p(char v);

/*Atributos globales del Automata*/
int contador = 0; //Caracter Actual
char palabra[50]; //palabra a leer
/************************/

int main(int argc, char *argv[]) {
    FILE *fp;
    int f, nueva = 0, contador_palabra=0;
    fp = fopen(argv[1],"r");
    
    if (fp == NULL) {
        printf("Error ese archivo no existe\n");
        return -1;
    }
    
    while((f = getc(fp)) != EOF) {
        if  ( (int)f >= 48 && (int)f <122)  {
            /*Leemos un archivo y buscamos simbolos que sean aceptables desde el 0 a la z, lo demas se considerará una separador de palabra */
            if (!nueva) {
                /*Inicializamos una nueva palabra*/
                nueva = 1;
            }
                /*Se guardara en un arreglo de caracteres cada palabra que identifique*/
                palabra[contador_palabra] = f;
                contador_palabra += 1;
        } else  {
            if (nueva) {
                /*Si identifica un separador Empieza la rutina del Automata*/
                printf("-------------------------\n");
                printf("\033[36mPalabra: %s \033[0m\n",palabra);
                if (a(palabra[0]) <0 ) {
                    printf("\033[31mPalabra erronea : %s\033[0m\n",palabra);
                } else {
                    printf("\033[32mPalabra Aceptada!\n\033[0m");
                }
            }
            /*Reiniciamos Valores*/
            nueva = 0;
            contador_palabra = 0;
            memset(&palabra[0], 0, sizeof(palabra)); //limpiamos palabra
            contador = 0;
            //printf("e");
        }
    }
    fclose(fp);
    
    
}

int a(char v) 
{
  if(v == '0') {
      contador += 1;
      c(palabra[contador]);
      
  } else if (v >='1' && v <='9') {
      contador += 1;
      b(palabra[contador]);
  }
    else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int b(char v) {
    if (v >= '0' && v <= '9') {
        contador += 1;
        b(palabra[contador]);
    } else if (v == 'l' || v == 'L') {
        contador += 1;
        e(palabra[contador]);
    } else if(v == 'u' || v == 'U') {
        contador +=1;
        d(palabra[contador]);
    
    } else if ( v == '\0') {
        printf("Es un entero!\n");       
    }
    else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}

int c(char v) 
{
    if ( v >= '0' && v <= '7') {
        contador += 1;
        g(palabra[contador]);
    } else if (v == 'l' || v == 'L') {
        contador += 1;
        e(palabra[contador]);
    } else if (v == 'u' || v == 'U') {
        contador += 1;
        d(palabra[contador]);
    } else if (v == 'x' || v == 'X') {
        contador +=1;
        k(palabra[contador]);
    } else if ( v == '\0') {
        printf("Es un entero!\n");
        
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int d (char v) {
    if (v == '\0') {
        printf("es un entero sin signo!\n");
    } else if (v == 'l' || v == 'L') {
        contador += 1;
        f(palabra[contador]);
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}

int e (char v) {
    if (v == '\0') {
        printf("Es un entero largo!\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;        
    }
    return 0;
    
}
int f (char v) {
    if (v == '\0') {
        printf("Es un entero largo sin signo!\n");
        return 0;
    } else {
        printf("ERROR! No es un entero\n");
        return -1;        
    }    
}
int g (char v) {
    if (v >= '0' && v <= '7') {
        contador += 1;
        g(palabra[contador]);
    } else if (v == 'l' || v == 'L') {
        contador += 1;
        i(palabra[contador]);
    } else if ( v == 'u' || v == 'U') {
        contador += 1;
        h(palabra[contador]);
    } else if (v == '\0') {
        printf("Es un entero octal\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int h (char v) {
    if (v == 'l' || v == 'L' ) {
        contador +=1;
        j(palabra[contador]);
    } else if ( v == '\0') {
        printf("Es un entero octal sin signo\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int i (char v) {
    if (v == '\0') {
        printf("Es un entero octal largo\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int j (char v) {
    if (v == '\0') {
        printf("Es un entero octal largo sin signo\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}
int k (char v) {
    if (v >= '0' && v <= '9') {
        contador += 1;
        l(palabra[contador]);
    } else if ( atoi(&v) >= 65 && atoi(&v) <=70) {
        contador += 1;
        m(palabra[contador]);
    } else if ( atoi(&v) >= 97 && atoi(&v) <= 102) {
        contador += 1;
        m(palabra[contador]);
    } else {
       printf("ERROR! No es un entero\n");
        return -1; 
    }
    return 0;
}
int l (char v) {
    if (v >= '0' && v <= '9') {
        contador += 1;
        l(palabra[contador]);
    } else if ( atoi(&v) >= 65 && atoi(&v) <=70) {
        contador += 1;
        m(palabra[contador]);
    } else if ( atoi(&v) >= 97 && atoi(&v) <= 102) {
        contador += 1;
        m(palabra[contador]);
    } else if (v == 'l' || v == 'L') {
        contador +=1;
        o(palabra[contador]);
    } else if (v == 'u' || v == 'U') {
        contador +=1;
        n(palabra[contador]);
    } else if (v == '\0') {
        printf("Es un entero en hexadecimal\n");
    } else {
       printf("ERROR! No es un entero\n");
        return -1; 
    }
    return 0;
}
int m (char v) {
    if (v >= '0' && v <= '9') {
        contador += 1;
        l(palabra[contador]);
    } else if ( atoi(&v) >= 65 && atoi(&v) <=70) {
        contador += 1;
        m(palabra[contador]);
    } else if ( atoi(&v) >= 97 && atoi(&v) <= 102) {
        contador += 1;
        m(palabra[contador]);
    } else if (v == 'l' || v == 'L') {
        contador +=1;
        o(palabra[contador]);
    } else if (v == 'u' || v == 'U') {
        contador +=1;
        n(palabra[contador]);
    } else if (v == '\0') {
        printf("Es un entero en hexadecimal\n");
    } else {
       printf("ERROR! No es un entero\n");
        return -1; 
    }
    return 0;
}
int n (char v) {
    if (v == 'l' || v == 'L') {
        contador += 1;
        p(palabra[contador]);
    } else if (v == '\0') {
        printf("Es un entero sin signo en hexadecimal\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
} 
int o (char v) {
   if (v == '\0') {
        printf("Es un entero largo  en hexadecimal\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0; 
}
int p (char v) {
    if (v == '\0') {
        printf("Es un entero largo sin signo en hexadecimal\n");
    } else {
        printf("ERROR! No es un entero\n");
        return -1;
    }
    return 0;
}