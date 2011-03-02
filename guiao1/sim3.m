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
eventos = [];
estados = zeros(n);
ocupacao = 0;
nchamadas = 0;
l = 60/l;

for i = 1:n-1
    for j = i+1:n
        eventos = [eventos; exprnd(l) 0 i j]; %% evento de chegada
    end
end
sumestados= 0;
tempoUltevento = 0;

while nchamadas < p,
    eventos = sortrows(eventos)
    pnos = eventos(1,3:4); % par dos nós em que o eventos vai ser processado
    tempochamadaproc = eventos(1,1);
    
    if eventos(1,2) == 1 % é uma partida
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sumestados;
        estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) - 1;
        sumestados= sumestados-1;
    else
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sumestados;
        nchamadas = nchamadas + 1;
        
        if estados(pnos(1), pnos(2)) < c %% acesso directo
            estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) + 1;
            sumestados= sumestados+1;
            eventos = [eventos; (tempochamadaproc + exprnd(dm)) 1 pnos]; %%agendar partida
        else
            caminho = melhorcaminho(estados,c,pnos, 1:n) % calcular o melhor caminho possível
            
            if caminho ==  -1
                bloqueadas = bloqueadas + 1;
            else
                orint = sort([pnos(1), caminho]); % canal origem -> intermedio
                intdest = sort([pnos(2), caminho]); % canal intermedio -> destino
                estados(orint(1), orint(2)) = estados(orint(1), orint(2)) + 1;
                estados(intdest(1), intdest(2)) = estados(intdest(1), intdest(2)) + 1;
                sumestados= sumestados+2;
                tempo = (tempochamadaproc + exprnd(dm)); %% tempo de agendamento das partidas
                eventos = [eventos; tempo 1 orint; tempo 1 intdest]; %%agendar partida
            end
        end
        eventos = [eventos; (tempochamadaproc + exprnd(l)) 0 pnos]; % agendar chegada para o par de nós processado
    end
    tempoUltevento = tempochamadaproc;
    
end
    bloqueio = bloqueadas/p;
    mediaOcupacao = (ocupacao/tempochamadaproc)/(n*(n-1)/2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caminho  = melhorcaminho(estado, c, pnos, totalnos)
caminho = -1;
intermedios = setdiff(totalnos, pnos); % retirar par origem e destino da lista de nos
cargas = [];
numNos = size(intermedios);


if numNos > 0
    for i = 1:numNos
        orint = sort([pnos(1), intermedios(i)]);
        intdest = sort([pnos(2), intermedios(i)]);
        e1 = classificarLigacao(c, estado(orint(1), orint(2)));
        e2 = classificarLigacao(c, estado(intdest(1), intdest(2)));
        cargas = [cargas; intermedios(i) max(e1,e2)];
    end
    tamanhocargas = size(cargas);
    if tamanhocargas > 0
        cargas = sortrows(cargas, 2);
        if cargas(1) < c    
            ncaminhos = 0;
            carga = cargas(1);
            for i = 2:tamanhocargas
                if cargas(i) == carga
                	ncaminhos = ncaminhos + 1;
                end
            end
            caminho = cargas(floor((rand(1,1) * ncaminhos) + 1));
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