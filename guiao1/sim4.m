%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fun��o para c�lculo da m�dia e do intervalo de confian�a   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediapiorbloqueio, iconfpiorbloq, mediaocupacao, iconfocup] = sim4(l, dm, c, n, p, ncorrida)

sbloqueio = [];
socupacao = [];
spiorbloqueio = [];
i = 0;

while i < ncorrida
    [bloqueio bloqueiopior mediaOcupacao] = simulador4(l, dm, c, n, p);
    sbloqueio = [sbloqueio bloqueio];
    socupacao = [socupacao mediaOcupacao];
    spiorbloqueio = [spiorbloqueio bloqueiopior];
    i = i +1;
end

mediabloqueio = mean(sbloqueio);
mediaocupacao = mean(socupacao);
mediapiorbloqueio = mean(spiorbloqueio);

variancebloqueio = var(sbloqueio);
varianceocupacao = var(socupacao);
variancepiorbloqueio = var(spiorbloqueio);

iconfbloq = norminv(0.95) * sqrt(variancebloqueio/ncorrida);
iconfocup = norminv(0.95) * sqrt(varianceocupacao/ncorrida);
iconfpiorbloq = norminv(0.95) * sqrt(variancepiorbloqueio/ncorrida);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[bloqueio, bloqueiopior, mediaOcupacao] = simulador4(l, dm, c, n, p)
bloqueadas = 0;
eventos = [];
chamadasporcanal = zeros(n);
estados = zeros(n);
ocupacao = 0;
nchamadas = 0;

for i = 1:n-1
    for j = i+1:n
        eventos = [eventos; exprnd(l(i,j)) 0 i j]; %% evento de chegada
    end
end

tempoUltevento = 0;

while nchamadas < p,
    eventos = sortrows(eventos);
    pnos = eventos(1,3:4); % par dos n�s em que o eventos vai ser processado
    tempochamadaproc = eventos(1,1);
    
    if eventos(1,2) == 1 % � uma partida
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sum(sum(triu(estados)));
        estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) - 1;
    else
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sum(sum(triu(estados)));
        nchamadas = nchamadas + 1;
        chamadasporcanal(pnos(1),pnos(2)) = chamadasporcanal(pnos(1), pnos(2)) + 1;
        
        if estados(pnos(1), pnos(2)) < c %% acesso directo
            estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) + 1;
            eventos = [eventos; (tempochamadaproc + exprnd(dm)) 1 pnos]; %%agendar partida
            
        else
            caminho = melhorcaminho(estados,c,pnos, 1:n); % calcular o melhor caminho poss�vel
            
            if caminho ==  -1
                estados(pnos(2), pnos(1)) = estados(pnos(2), pnos(1)) + 1;
            else
                orint = sort([pnos(1), caminho]); % canal origem -> intermedio
                intdest = sort([pnos(2), caminho]); % canal intermedio -> destino
                estados(orint(1), orint(2)) = estados(orint(1), orint(2)) + 1;
                estados(intdest(1), intdest(2)) = estados(intdest(1), intdest(2)) + 1;
                tempo = (tempochamadaproc + exprnd(dm)); %% tempo de agendamento das partidas
                eventos = [eventos; tempo 1 orint; tempo 1 intdest]; %%agendar partida
            end
        end
        eventos = [eventos; (tempochamadaproc + exprnd(l(pnos(1),pnos(2)))) 0 pnos]; % agendar chegada para o par de n�s processado
        tempoUltevento = tempochamadaproc;
    end
    
end
    bloqueio = sum(sum(tril(estados)))/p;
    bloqueadasporcanal = triu(estados);
    [i,j] = find(bloqueadasporcanal==max(bloqueadasporcanal(:)));
    bloqueiopior = max(bloqueadasporcanal(:))/chamadasporcanal(i,j);  
    mediaOcupacao = (ocupacao/tempochamadaproc)/(n*(n-1)/2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caminho  = melhorcaminho(estado, c, pnos, totalnos)
caminho = -1;
intermedios = setdiff(totalnos, pnos); % retirar par origem e destino da lista de nos
cargas = [];


if size(intermedios) > 0
    for i = 1:size(intermedios)
        orint = sort([pnos(1), intermedios(i)]);
        intdest = sort([pnos(2), intermedios(i)]);
        e1 = classificarLigacao(c, estado(orint(1), orint(2)));
        e2 = classificarLigacao(c, estado(intdest(1), intdest(2)));
        cargas = [cargas; intermedios(i) max(e1,e2)];
    end
    
    if size(cargas)> 0
        cargas = sortrows(cargas, 2);
        if cargas(1) < c
            caminho = cargas(1);
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classificacao = classificarLigacao(c, ncircuitos)

if ncircuitos <= c/2
    classificacao = 0; % CR
elseif ncircuitos > c/2 && ncircuitos < c
    classificacao = 1; % CE
else
    classificacao = 2; % OC
end
end