
function[bloqueio, iconfbloq, mediaOcupacao, iconfocup] = simulador1(l, dm, c, p)

chamadas = [];
sbloqueio = [];
socupacao = [];
nchamadas = 0;
l = l/60;

while nchamadas < p,
    [chamadas, bloqueadas, ocupacao] = simular(l, dm, c, chamadas);
    sbloqueio = [sbloqueio bloqueadas];
    socupacao = [socupacao ocupacao];
    nchamadas = nchamadas + 1;
end

[bloqueio, iconfbloq, mediaOcupacao, iconfocup] = intervalo(sbloqueio, socupacao,p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediaocupacao, iconfocup] = intervalo(sbloqueio, socupacao, p)

mediabloqueio = mean(sbloqueio);
mediaocupacao = mean(socupacao);

variancebloqueio = var(sbloqueio);
varianceocupacao = var(socupacao);

iconfbloq = norminv(0.95) * sqrt(variancebloqueio/p);
iconfocup = norminv(0.95) * sqrt(varianceocupacao/p);


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
