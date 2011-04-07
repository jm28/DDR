%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediaocupacao, iconfocup] = simulador1_ver2(l, dm, c, p, ncorrida)

sbloqueio = [];
socupacao = [];
i = 0;

while i < ncorrida
    [bloqueio mediaOcupacao] = simulador1(l, dm, c, p);
    sbloqueio = [sbloqueio bloqueio];
    socupacao = [socupacao mediaOcupacao];
    i = i +1;
end

mediabloqueio = mean(sbloqueio);
mediaocupacao = mean(socupacao);

variancebloqueio = var(sbloqueio);
varianceocupacao = var(socupacao);

iconfbloq = norminv(0.95) * sqrt(variancebloqueio/ncorrida);
iconfocup = norminv(0.95) * sqrt(varianceocupacao/ncorrida);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Simulação com os parâmetros obtidos                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[bloqueio, mediaOcupacao] = simulador1(l, dm, c, p)
bloqueadas = 0;
estadoLigacoes = 0;
ocupacao = 0;
nchamadas = 0;
l = 60/l;

eventos = [exprnd(l) 0]; %% evento de chegada
tempoultimoevento = 0;

while nchamadas < p,
    
   eventos = sortrows(eventos);  
   tempoEventoproc = eventos(1,1); %tempo do evento que vai ser processado
   
   if eventos(1,2) == 1 % é uma partida 
       eventos(1,:) = []; % retirar evento
       ocupacao = ocupacao + (tempoEventoproc-tempoultimoevento)*estadoLigacoes; %actualiza o tempo das ocupacoes
       estadoLigacoes = estadoLigacoes - 1; %liberta um canal
   else
       eventos(1,:) = []; % retirar evento
       ocupacao = ocupacao + (tempoEventoproc-tempoultimoevento)*estadoLigacoes; %actualizar o tempo da ocupação
       nchamadas = nchamadas + 1; % incrementa o número de chamadas recebidas
                                  
        if estadoLigacoes < c %ainda existem canais livres ?
            estadoLigacoes = estadoLigacoes + 1; % ocupa um canal
            eventos = [eventos; (tempoEventoproc + exprnd(dm)) 1]; %agenda um evento de partida
        else
            bloqueadas = bloqueadas + 1; %incrementa o número de chamadas bloqueadas
        end
        eventos = [eventos; (tempoEventoproc + exprnd(l)) 0]; %agenda um evento de chegada
   end
    
    tempoultimoevento = tempoEventoproc;
end

bloqueio = bloqueadas/p;
mediaOcupacao = ocupacao/tempoEventoproc;
