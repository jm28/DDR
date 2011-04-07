%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para cálculo da média e do intervalo de confiança   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[mediabloqueio, iconfbloq, mediapiorbloqueio, iconfpiorbloq, piorfluxo, mediaocupacao, iconfocup] = sim4(l1, l2, dm, c, n, p, ncorrida)

sbloqueio = [];
socupacao = [];
l = [];
spiorbloqueio = [];
spiorfluxo = [];
i = 0;

for k = 1:n-1
    for z = k+1:n
        l(k,z) = 60/l1;
    end
end

l(1,2) = 60/l2;

while i < ncorrida
    [bloqueio bloqueiopior fluxo mediaOcupacao] = simulador4(l, dm, c, n, p);
    sbloqueio = [sbloqueio bloqueio];
    socupacao = [socupacao mediaOcupacao];
    spiorbloqueio = [spiorbloqueio bloqueiopior];
    spiorfluxo = [spiorfluxo; fluxo];
    i = i +1;
end

mediabloqueio = mean(sbloqueio);
mediaocupacao = mean(socupacao);
mediapiorbloqueio = mean(spiorbloqueio);
piorfluxo = mode(spiorfluxo);

variancebloqueio = var(sbloqueio);
varianceocupacao = var(socupacao);
variancepiorbloqueio = var(spiorbloqueio);

iconfbloq = norminv(0.95) * sqrt(variancebloqueio/ncorrida);
iconfocup = norminv(0.95) * sqrt(varianceocupacao/ncorrida);
iconfpiorbloq = norminv(0.95) * sqrt(variancepiorbloqueio/ncorrida);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[bloqueio, bloqueiopior, fluxo, mediaOcupacao] = simulador4(l, dm, c, n, p)
eventos = [];
bloqueadasporcanal = [];
chamadasporcanal = zeros(n); % criação de uma matriz nxn inicializada a zero
estados = zeros(n); %criação de uma matriz nxn inicializada a zero
ocupacao = 0;
nchamadas = 0;

for i = 1:n-1
    for j = i+1:n
        eventos = [eventos; exprnd(l(i,j)) 0 i j]; %gerar eventos de chegada
    end
end

tempoUltevento = 0;
sumestados = 0;

while nchamadas < p,
    eventos = sortrows(eventos);
    pnos = eventos(1,3:4); % par dos nós em que o eventos vai ser processado
    tempochamadaproc = eventos(1,1); %instante de tempo do evento a ser processado
    
    
    
    if eventos(1,2) == 1
        %% é uma partida
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sumestados; %actualizar ocupação
        estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) - 1; %decrementar n° de circuitos ocupados entre as duas centrais
        sumestados = sumestados - 1; %decrementar o n° de circuitos ocupados
    else
        %% é uma chegada
        eventos(1,:) = []; % retirar evento
        ocupacao = ocupacao + (tempochamadaproc-tempoUltevento)*sumestados; %actualizar ocupação
        nchamadas = nchamadas + 1; %incrementar o n° de chegadas
        
        if estados(pnos(1), pnos(2)) < c
            %% acesso directo
            estados(pnos(1), pnos(2)) = estados(pnos(1), pnos(2)) + 1; %incrementar circuitos ocupados entre as duas centrais
            eventos = [eventos; (tempochamadaproc + exprnd(dm)) 1 pnos]; %%agendar partida
            sumestados = sumestados + 1; %incrementar o n° de circuitos ocupados
            chamadasporcanal(pnos(1),pnos(2)) = chamadasporcanal(pnos(1), pnos(2)) + 1; %incrementar o n° de chamadas recebidas entre as duas estações
            
        else
            caminho = melhorcaminho(estados,c,pnos, 1:n); % calcular o melhor caminho possível
            
            
            
            if caminho ==  -1
                %não existe caminho livre
                estados(pnos(2), pnos(1)) = estados(pnos(2), pnos(1)) + 1; % incrementar as bloqueadas do canal
                
            else
                orint = sort([pnos(1), caminho]); % canal origem -> intermedio
                intdest = sort([pnos(2), caminho]); % canal intermedio -> destino
                estados(orint(1), orint(2)) = estados(orint(1), orint(2)) + 1; %incrementar circuitos ocupados entre as duas centrais
                estados(intdest(1), intdest(2)) = estados(intdest(1), intdest(2)) + 1;%incrementar circuitos ocupados entre as duas centrais
                tempo = (tempochamadaproc + exprnd(dm)); %% tempo de agendamento das partidas
                eventos = [eventos; tempo 1 orint; tempo 1 intdest]; %%agendar partida
                chamadasporcanal(orint(1),orint(2)) = chamadasporcanal(orint(1), orint(2)) + 1; %incrementar o n° de chamadas recebidas entre as duas estações
                chamadasporcanal(intdest(1),intdest(2)) = chamadasporcanal(intdest(1), intdest(2)) + 1; %incrementar o n° de chamadas recebidas entre as duas estações
                sumestados = sumestados + 2; %incrementar o n° de circuitos ocupados, é 2 porque vai da origem -> intermédio e intermédio -> destino
            end
        end
        eventos = [eventos; (tempochamadaproc + exprnd(l(pnos(1),pnos(2)))) 0 pnos]; % agendar chegada para o par de nós processado
    end
    tempoUltevento = tempochamadaproc; %actualizar o instante de tempo da última chamada processada
    
end

bloqueio = sum(sum(tril(estados)))/p; %Esta soma é efectuada somente uma vez, portanto não requer variável

for k = 1:n-1
    for z = k+1:n
        bloqueadasporcanal(k,z) = estados(z,k)/chamadasporcanal(k,z);
    end
end


[i,j] = find(bloqueadasporcanal == max(bloqueadasporcanal(:))); %encontra o circuito com mais chamadas bloqueadas

if i(1) == 1 && j(1) == 1
    fluxo = [0,0];
else
    fluxo = [i(1), j(1)];
end

bloqueiopior = bloqueadasporcanal(i(1),j(1));
mediaOcupacao = (ocupacao/tempoUltevento)/(n*(n-1)/2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caminho  = melhorcaminho(estado, c, pnos, totalnos)
caminho = -1;
intermedios = setdiff(totalnos, pnos); % retirar par origem e destino da lista de nos
cargas = [];
numNos = size(intermedios);


if numNos > 0
    for i = 1:numNos(2)
        orint = sort([pnos(1), intermedios(i)]);
        intdest = sort([pnos(2), intermedios(i)]);
        e1 = classificarLigacao(c, estado(orint(1), orint(2)));
        e2 = classificarLigacao(c, estado(intdest(1), intdest(2)));
        cargas = [cargas; intermedios(i) max(e1,e2)];
    end
    tamanhocargas = size(cargas);
    if tamanhocargas(2) > 0
        cargas = sortrows(cargas, 2);
        if cargas(1,2) < 2
            ncaminhos = 0;
            carga = cargas(1,2);
            for i = 2:tamanhocargas(2)
                if cargas(i,2) == carga
                    ncaminhos = ncaminhos + 1;
                end
            end
            caminho = cargas(floor((rand(1,1) * ncaminhos) + 1),1);
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