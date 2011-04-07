%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Função inicial do simulador                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tperdidos,tperdidosconf,atrmed,atrmedconf,atrmax,atrmaxconf,ocupmed,ocupmedconf] = sim1(l,f,p,niter)
    
sperdidos = [];
satrmed = [];
satrmax = [];
socupmed = [];
l = 1/l;
i = 0;
    while i < niter
        [tperdidos, atrmed, atrmax, ocupmed] = simulador1(l,f,p);
        sperdidos = [sperdidos tperdidos];
        satrmed   = [satrmed atrmed];
        satrmax   = [satrmax atrmax];
        socupmed  = [socupmed ocupmed];
        i = i+1;
    end
      
    [tperdidos, tperdidosconf] = calciconf(sperdidos, niter);
    [atrmed, atrmedconf] = calciconf(satrmed, niter);
    [atrmax, atrmaxconf] = calciconf(satrmax, niter);
    [ocupmed, ocupmedconf] = calciconf(socupmed, niter);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Função para cálculo do intervalo de confiança    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[med, iconf] = calciconf(s, niter)
    med = mean(s);
    variance = var(s);
    iconf =  norminv(0.95) * sqrt(variance/niter);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Função que executa o simulador                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tperdidos, atrmed, atrmax, ocupmed] = simulador1(l,f,p)

IOcupacao = 0; % inicialização da variável de cálculo da ocupação
PacotesTotal = 0; % inicialização da variável que contabiliza o n° de pacotes
OcupacaoFila = 0; % inicialização da variável que contabiliza a ocupação da fila de espera num determinado instante
Instante = 0; % inicialização da variável que determina o instante de tempo do último pacote processado
Estado = 0; %inicialização da variável que determina o estado do simulador, 0 para livre e 1 para ocupado
PacotesPerdidos = 0; %inicialização da variável que contabiliza o n° de pacotes perdidos.
FilaEspera = []; %inicialização  da fila de espera
Atraso = 0; %Atraso dos pacotes
atrmax = 0;
Npartidas = 0; %inicialização da variável que contabiliza o número de partidas
UltimoEvento = 0;

ListaEventos = [exprnd(l) 0]; %inicializar ListaEventos com uma chegada

while Npartidas < p
    ListaEventos = sortrows(ListaEventos); %Determinar qual o primeiro evento da lista
    TempoEventoProcessado = ListaEventos(1,1); %Instante de tempo do evento a ser processado
        
    if ListaEventos(1,2) == 0 
        %Primeiro evento é uma chegada
        ListaEventos(1,:) = []; %Retirar Chegada da ListaEventos
        IOcupacao = IOcupacao + OcupacaoFila * (TempoEventoProcessado-UltimoEvento);%Actualizar 
        pacote = round((rand()*1452) + 48); %gerar tamanho do pacote
        PacotesTotal = PacotesTotal + 1; %Incrementar o número de pacotes recebidos
        ListaEventos = [ListaEventos; TempoEventoProcessado + exprnd(l) 0]; % Agendar nova chegada
        
        if Estado == 1
            %Simulador está ocupado
            if (OcupacaoFila + pacote) <= f
                %Pacote cabe na fila de espera
                FilaEspera = [FilaEspera; TempoEventoProcessado pacote]; %%actualizar instante actual
                OcupacaoFila = OcupacaoFila + pacote;
            else
                %Pacote não cabe na fila de espera
                PacotesPerdidos = PacotesPerdidos + 1;
            end
        else
            %Simulador está livre
            Estado = 1; %Colocar o estado como ocupado
            Instante = TempoEventoProcessado; %Actualizar instante
            ListaEventos = [ListaEventos; TempoEventoProcessado+(8*pacote/2000000) 1]; %Agendar partida
        end
    else
        %Primeiro evento é uma partida
        IOcupacao = IOcupacao + OcupacaoFila * (TempoEventoProcessado-UltimoEvento);%Actualizar 
        
        Atraso = Atraso + (TempoEventoProcessado - Instante);
        if (TempoEventoProcessado - Instante) > atrmax
            atrmax = TempoEventoProcessado - Instante;
        end
        
        Npartidas = Npartidas + 1; % Incrementar número de partidas
        if Npartidas < p
            %Ainda não foi atingido o critério de paragem
            ListaEventos(1,:) = []; %Retirar Partida da ListaEventos
            if OcupacaoFila > 0
                %Existem elementos na fila de espera
                Instante = FilaEspera(1,1);
                ListaEventos = [ListaEventos; TempoEventoProcessado+(FilaEspera(1,2)*8/2000000) 1]; %Agendar partida
                OcupacaoFila = OcupacaoFila - FilaEspera(1,2);
                FilaEspera(1,:) = []; % Retirar pacote da fila de espera
            else
                Estado = 0; %Estado passa a estar livre
            end
        end
    end
    UltimoEvento = TempoEventoProcessado;
end

tperdidos = PacotesPerdidos/PacotesTotal; %calcular taxa de perda de pacotes
atrmed = Atraso/p; %calcular atraso médio dos pacotes
ocupmed = IOcupacao/TempoEventoProcessado; %calcular ocupação média da fila de espera
end
