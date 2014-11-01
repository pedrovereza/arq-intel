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
short rendimentoEngenheiro(int engenheiro);
short rendimentoEngenheiroWithOutput(int engenheiro);
void encerramento();
void parseFile();

void readFile();
short readNumber();

int main() {
    
    printf("Pedro Vereza - Cartao 242250\n");
    getchar();
    
    readFile();
    
    resumo();
    getchar();
    
    do {
        menu();
        scanf("%s", &opcao);
        
        switch (opcao) {
            case 'a':
                readFile();
                break;
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

void readFile() {
    printf(">>Forneca o nome do arquivo de dados:\n");
    
    scanf("%s", file_name);
    
    fp = fopen(file_name, "r");
    
    parseFile();
    
    fclose(fp);
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

short readNumber() {
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

void encerramento() {
    printf(" ¯\\_(ツ)_/¯");
}

void relatorioEngenheiro() {
    int engenheiro = 0;
    
    printf("Forneca o numero do engenheiro:");
    scanf("%d", &engenheiro);
    
    if (engenheiro < 0 || engenheiro >= numero_engenheiros) {
        mensagemErro();
        getchar();
        relatorioEngenheiro();
        return;
    }
    
    rendimentoEngenheiroWithOutput(engenheiro);
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

short rendimentoEngenheiroWithOutput(int engenheiro) {
    printf("\tRelatorio do engenheiro %d\n", engenheiro);
    
    short rendimento = 0;
    
    unsigned short eng = (memory[endEngenheiros + engenheiro]);
    
    unsigned short visitas = memory[eng];
    
    printf("\tNumero de visitas: %d\n", visitas);
    
    printf("\tCidade\tLucro\tPrejuizo\n");
    
    for (short i = 1; i <= visitas; ++i) {
        
        short cidade = memory[eng + i];
        
        short rendimentoCidade = memory[endCidades + cidade];
        
        if (rendimentoCidade < 0) {
            printf("\t\t%d\t\t\t\t%d\n", cidade, rendimentoCidade);
        }
        else {
            printf("\t\t%d\t\t%d\n", cidade, rendimentoCidade);
        }
        
        rendimento +=  rendimentoCidade;
        
    }
    
    if (rendimento < 0) {
        printf("\t\tTOTAL\t\t\t%d\n", rendimento);
    }
    else {
        printf("\t\tTOTAL\t%d\n", rendimento);
    }
    
    return rendimento;
}


void resumo() {
    printf("Arquivo de dados:\n\tNumero de cidades...... %d\n\tNumero de engenheiros.. %d", numero_engenheiros, numero_cidades);
}

void menu() {
    printf(">> Caracteres de comandos:\n\t[a] solicita novo arquivo de dados\n\t[g] apresenta o relatorio geral\n\t[e] apresenta relatorio de um engenheiro\n\t[f] encerra o programa\n\t[?] lista os comandos validos\nComando>");
}