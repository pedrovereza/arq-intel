#include <stdio.h>
#include <stdlib.h>

unsigned short memory[5000];
unsigned short endCidades = 0;
unsigned short endEngenheiros = 0;
unsigned short memoryIndex = 0;

unsigned short numero_engenheiros = 3;
unsigned short numero_cidades = 0;

char file_name[100];
char ch;
FILE *fp;

char opcao;

void resumo();
void menu();
void relatorioEngenheiro();
void relatorioGeral();
void mensagemErro();
short rendimentoEngenheiro();
void encerramento();
void parseFile();

int main() {
    
    printf("Pedro Vereza");
    getchar();
    
    gets(file_name);
    
    fp = fopen(file_name, "r");
    
    parseFile();
    
    fclose(fp);
    
    resumo();
    getchar();
    
    do {
        menu();
        opcao = getchar();
        
        switch (opcao) {
            case 'r':
                resumo();
                break;
                
                case 'e':
                relatorioEngenheiro();
                break;
                
                case 'g':
                relatorioGeral();
                break;
                
            case 'f':
                encerramento();
            default:
                break;
        }
        
        
    } while (opcao != 'f');
    
    return 0;
}

int readNumber() {
    char numero[8];
    
    for (int i = 0; i < 7; ++i) {
        ch = fgetc(fp);
        
        if (ch == ',' || ch == '\n') {
            numero[i] = 0;
            break;
        }
        
        numero[i] = ch;
    }
    
    return atoi(numero);
}

void parseFile() {
    
    numero_engenheiros = readNumber();
    
    numero_cidades = readNumber();
    
    int i = 0;
    
    for (i = 0; i < numero_cidades; ++i) {
        memory[i] = readNumber();
    }
    
    memoryIndex += i;
    
    endEngenheiros = memoryIndex;
    
    memoryIndex += numero_engenheiros;
    
    for (int j = 0; j < numero_engenheiros; ++j) {
        memory[endEngenheiros+j] = memoryIndex;
        
        int visitas = readNumber();
        memory[memoryIndex] = visitas;
        
        for (i = 1; i <= visitas; ++i) {
            memory[memoryIndex+i] = readNumber();
        }
        
        memoryIndex += i;
    }
    
}

void encerramento() {
    printf(" ¯\\_(ツ)_/¯");
}

void relatorioEngenheiro(){
    int engenheiro = 0;
    
    printf("Engenheiro:");
    scanf("%d", &engenheiro);
    
    if (engenheiro < 0 || engenheiro >= numero_engenheiros) {
        mensagemErro();
        getchar();
        relatorioEngenheiro();
        return;
    }
    
    short rendimento = rendimentoEngenheiro(engenheiro);
    
    printf("Engenheiro: %d \t lucro: %d\n", engenheiro, rendimento);
        
}

void mensagemErro(){
    printf("Engenheiro não identificado\n");
}

void relatorioGeral() {
    short maior = 0;
    short engenheiro = 0;
    short rendimento = 0;
    
    for (short i = numero_engenheiros - 1; i >= 0; --i) {
        rendimento = rendimentoEngenheiro(i);
        
        if (rendimento >= maior) {
            maior = rendimento;
            engenheiro = i;
        }
    }
    
    printf("Maior lucro: %d do engenheiro: %d", maior, engenheiro);
}

short rendimentoEngenheiro(int engenheiro) {
    short rendimento = 0;
    
    unsigned short eng = (memory[endEngenheiros + engenheiro]);
    
    unsigned short visitas = memory[eng];
    
    for (short i = 1; i <= visitas; ++i) {
        rendimento +=  memory[endCidades + memory[eng + i]];
        
    }
    
    return rendimento;
}


void resumo() {
    printf("Engenheiros: %d \t Cidades: %d\n", numero_engenheiros, numero_cidades);
}

void menu() {
    printf("Selecione uma ação: [r] [e] [g] [f]");
}