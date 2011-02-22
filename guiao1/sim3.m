%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediaocupacao, iconfocup] = sim3(l, dm, c, n, p, ncorrida)

sbloqueio = [];
socupacao = [];
i = 0;

while i < ncorrida
    [bloqueio mediaOcupacao] = simulador3(l, dm, c, n, p);
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[bloqueio, mediaOcupacao] = simulador3(l, dm, c, n, p)
bloqueadas = 0;
estado = zeros(n);
ocupacao = 0;
lnos = 1:n;
nchamadas = 0;
l = l/60;
nos = randperm(n);

chamadas = [exprnd(1/l) 0 sort(nos(1:2))]; %% evento de chegada
ultimoevento = 0;

while nchamadas < p,
    chamadas = sortrows(chamadas)
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
            chamadas = [chamadas; (chamadaproc + exprnd(dm)) 1 pnos]; %%agendar partida
        else
            caminhos = setdiff(lnos, pnos); % retirar par origem e destino da lista de nos
            caminho = melhorcaminho(estado,c,pnos,caminhos);
            
            if caminho ==  -1
                bloqueadas = bloqueadas + 1
            else
                orint = sort([pnos(1), caminho]);
                intdest = sort([pnos(2), caminho]);
                estado(orint(1), orint(2)) = estado(orint(1), orint(2)) + 1;
                estado(intdest(1), intdest(2)) = estado(intdest(1), intdest(2)) + 1;
                tempo = (chamadaproc + exprnd(dm));
                chamadas = [chamadas; tempo 1 orint; tempo 1 intdest]; %%agendar partida
            end    
        end
        nos = randperm(n);
        chamadas = [chamadas; (chamadaproc + exprnd(1/l)) 0 sort(nos(1:2))];
        ultimoevento = chamadaproc;
    end
    
    bloqueio = bloqueadas/p;
    mediaOcupacao = ocupacao/chamadaproc;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caminho  = melhorcaminho(estado, c, pnos, nos) %no1 tem de ser menor que no2
caminhos=[];

for i = 1:size(nos)
    orint = sort([pnos(1), nos(i)]);
    intdest = sort([pnos(2), nos(i)]);
    e1 =estado(orint(1), orint(2));
    e2 = estado(intdest(1), intdest(2));
    
    if e1 < c && e2 < c
        caminhos = [caminhos; nos(i) e1+e2];
    end
end

if size(caminhos)> 0
    caminhos = sortrows(caminhos, 2);
    caminho = caminhos(1);
else
    caminho = -1;
end
end