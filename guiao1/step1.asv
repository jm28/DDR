
function[bloqueio, mediaOcupacao] = simulador1(l, dm, c, p)

chamadas = [];
bloqueadas = 0;
ocupacao = 0;

while p > 0
    [chamadas, bloqueadas, ocupacao] = step1(l, dm, c, chamadas, bloqueadas, ocupacao);
    p = p-1;
end

bloqueio = bloqueadas/p;
mediaOcupacao = ocupacao/p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[chamadas, bloqueadas, ocupacao] = step1(l, dm, c, chamadas, bloqueadas, ocupacao)

tchamada = exprnd(1/l); %% evento de chegada

chamadas = chamadas - tchamada; %% retirar o tempo que passou
chamadas = chamadas(chamadas>0); %% retirar chamadas terminadas
ocupacao=ocupacao+size(chamadas, 2); %% actualizar ocupacao

if size(chamadas, 2)<c
    chamadas = [chamadas exprnd(dm)];
else
    bloqueadas = bloqueadas + 1;
end
