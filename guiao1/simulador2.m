%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio1, iconfbloq1, mediaocupacao1, iconfocup1, mediabloqueio2, iconfbloq2, mediaocupacao2, iconfocup2] = simulador2(l, dm, c, p, ncorrida)

sbloqueio1 = [];
socupacao1 = [];
sbloqueio2 = [];
socupacao2 = [];
i = 0;

while i < ncorrida
    [bloqueio1 mediaOcupacao1 bloqueio2 mediaOcupacao2] = sim2(l, dm, c, p);
    sbloqueio1 = [sbloqueio1 bloqueio1];
    socupacao1 = [socupacao1 mediaOcupacao1];
    sbloqueio2 = [sbloqueio2 bloqueio2];
    socupacao2 = [socupacao2 mediaOcupacao2];
    i = i +1;
end

mediabloqueio1 = mean(sbloqueio1);
mediaocupacao1 = mean(socupacao1);

mediabloqueio2 = mean(sbloqueio2);
mediaocupacao2 = mean(socupacao2);

variancebloqueio1 = var(sbloqueio1);
varianceocupacao1 = var(socupacao1);

variancebloqueio2 = var(sbloqueio2);
varianceocupacao2 = var(socupacao2);

iconfbloq1 = norminv(0.95) * sqrt(variancebloqueio1/ncorrida);
iconfocup1 = norminv(0.95) * sqrt(varianceocupacao1/ncorrida);

iconfbloq2 = norminv(0.95) * sqrt(variancebloqueio2/ncorrida);
iconfocup2 = norminv(0.95) * sqrt(varianceocupacao2/ncorrida);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[bloqueio1, mediaOcupacao1, bloqueio2, mediaOcupacao2] = sim2(l, dm, c, p)
bloqueadas = 0;
estado = 0;
ocupacao = 0;
nchamadas = 0;
l = 60/l;

eventos = [exprnd(l) 0]; %% agendar evento de chegada
ultimoevento = 0;

while nchamadas < p,
           
        eventos = sortrows(eventos);
        eventoproc = eventos(1,1); % evento que vai ser processado
        
        if eventos(1,2) == 1 % é uma partida
            eventos(1,:) = []; % retirar evento
            ocupacao = ocupacao + (eventoproc-ultimoevento)*estado; %actualizar ocupação
            estado = estado - 1; %decrementar estado
        else
            eventos(1,:) = []; % retirar evento, neste caso uma chegada
            ocupacao = ocupacao + (eventoproc-ultimoevento)*estado; %actualizar ocupação
            nchamadas = nchamadas + 1; %incrementar número de chegadas
            
            if estado < c % Ainda existem circuitos livres ?
                estado = estado + 1; % incrementar o estado, pois vai ser ocupado um circuito
                eventos = [eventos; (eventoproc + exprnd(dm)) 1]; %agendar um evento de partida
            else
                bloqueadas = bloqueadas + 1; %Não há circuitos livres, logo a chegada é bloqueada
            end
            eventos = [eventos; (eventoproc + exprnd(l)) 0]; %agendar um evento de chegada
        end
        
        ultimoevento = eventoproc; %guardar o último evento processado
        
    if nchamadas == 20
        bloqueio1 = bloqueadas/nchamadas; %calcular probabilidade de bloqueio
        mediaOcupacao1 = ocupacao/ultimoevento; %calcular ocupação média
    elseif nchamadas == 200
        bloqueadas = 0;
        ocupacao = 0;
        ult200 = ultimoevento;
    elseif nchamadas == 220
        bloqueio2 = bloqueadas/20; %calcular probabilidade de bloqueio
        mediaOcupacao2 = ocupacao/(ultimoevento-ult200); %calcular ocupação média
    end
end

