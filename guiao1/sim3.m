%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediaocupacao, iconfocup] = sim3(l, dm, c, n, p, ncorrida)

sbloqueio = [];
socupacao = [];
i = 0;

while i < ncorrida
    [bloqueio mediaOcupacao] = simulador1(l, dm, c, n, p);
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
function[bloqueio, mediaOcupacao] = simulador1(l, dm, c, n, p)
bloqueadas = 0;
estado = zeros(n);
ocupacao = 0;
nchamadas = 0;
l = l/60;
nos = randperm(n);

chamadas = [exprnd(1/l) 0 sort(nos(1:2))]; %% evento de chegada
ultimoevento = 0;

while nchamadas < p,
   chamadas = sortrows(chamadas);
   pnos = chamadas(1,3:4);
   chamadaproc = chamadas(1,1);
   
   if chamadas(1,2) == 1 % é uma partida 
       chamadas(1,:) = []; % retirar evento
       ocupacao = ocupacao + (chamadaproc-ultimoevento)*sum(sum(estado));
       estado(pnos(1), pnos(2)) = estado(pnos(1), pnos(2)) - 1;
   else
       chamadas(1,:) = []; % retirar evento
       ocupacao = ocupacao + (chamadaproc-ultimoevento)*sum(sum(estado));
       nchamadas = nchamadas + 1;
                                  
        if estado(pnos(1), pnos(2)) < c %% acesso directo
            estado(pnos(1), pnos(2)) = estado(pnos(1), pnos(2)) + 1;
            chamadas = [chamadas; (chamadaproc + exprnd(dm)) 1 pnos];
        else
            bloqueadas = bloqueadas + 1;
        end
        nos = randperm(n);
        chamadas = [chamadas; (chamadaproc + exprnd(1/l)) 0 sort(nos(1:2))];
   end
   ultimoevento = chamadaproc;
end

bloqueio = bloqueadas/p;
mediaOcupacao = ocupacao/chamadaproc;
