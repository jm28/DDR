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
function[bloqueio, mediaOcupacao] = simulador1(l, dm, c, p)
bloqueadas = 0;
estado = 0;
ocupacao = 0;
nchamadas = 0;
l = l/60;

chamadas = [exprnd(1/l) 0]; %% evento de chegada
ultimoevento = 0;

while nchamadas < p,
    
   chamadas = sortrows(chamadas);
   
   chamadaproc = chamadas(1,1);
   
   if chamadas(1,2) == 1 % é uma partida 
       chamadas(1,:) = []; % retirar evento
       ocupacao = ocupacao + (chamadaproc-ultimoevento)*estado;
       estado = estado - 1;
   else
       chamadas(1,:) = []; % retirar evento
       ocupacao = ocupacao + (chamadaproc-ultimoevento)*estado;
       nchamadas = nchamadas + 1;
                                  
        if estado < c
            estado = estado + 1;
            chamadas = [chamadas; (chamadaproc + exprnd(dm)) 1];
        else
            bloqueadas = bloqueadas + 1;
        end
        chamadas = [chamadas; (chamadaproc + exprnd(1/l)) 0];
   end
    
    ultimoevento = chamadaproc;
end

bloqueio = bloqueadas/p;
mediaOcupacao = ocupacao/chamadaproc;
