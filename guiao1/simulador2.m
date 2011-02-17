
function[bloqueio1, iconfbloq1, mediaOcupacao1, iconfocup1,bloqueio2, iconfbloq2,mediaOcupacao2, iconfocup2,bloqueio, iconfbloq, mediaOcupacao, iconfocup] = simulador2(l, dm, c, p)

chamadas = [];
sbloqueio = [];
socupacao = [];
nchamadas = 0;
l = l/60;

while nchamadas < p,
    [chamadas, bloqueadas, ocupacao] = simular(l, dm, c, chamadas);
    
    if nchamadas == 20
        [bloqueio1, iconfbloq1, mediaOcupacao1, iconfocup1] = intervalo(sbloqueio, socupacao, nchamadas);
    elseif (nchamadas == 201)
        while nchamadas < 220
            sbloqueio = [sbloqueio bloqueadas];
            socupacao = [socupacao ocupacao];
            nchamadas = nchamadas + 1;
        end
        [bloqueio2, iconfbloq2, mediaOcupacao2, iconfocup2] = intervalo(sbloqueio, socupacao, nchamadas);
    else
        sbloqueio = [sbloqueio bloqueadas];
        socupacao = [socupacao ocupacao];
    end
    nchamadas = nchamadas + 1;
end

[bloqueio, iconfbloq, mediaOcupacao, iconfocup] = intervalo(sbloqueio, socupacao,nchamadas);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediaocupacao, iconfocup] = intervalo(sbloqueio, socupacao, nchamadas)

mediabloqueio = mean(sbloqueio);
mediaocupacao = mean(socupacao);

variancebloqueio = var(sbloqueio);
varianceocupacao = var(socupacao);

iconfbloq = norminv(0.95) * sqrt(variancebloqueio/nchamadas);
iconfocup = norminv(0.95) * sqrt(varianceocupacao/nchamadas);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[chamadas, bloqueadas, ocupacao] = simular(l, dm, c, chamadas)

tchamada = exprnd(1/l); %% evento de chegada

chamadas = chamadas - tchamada; %% retirar o tempo que passou
chamadas = chamadas(chamadas>0); %% retirar chamadas terminadas
ocupacao = size(chamadas, 2); %% actualizar ocupacao

if size(chamadas, 2) < c
    chamadas = [chamadas exprnd(dm)];
    bloqueadas = 0;
else
    bloqueadas =  1;
end
