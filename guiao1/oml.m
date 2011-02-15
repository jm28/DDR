function n = oml(l,nw,c)
p = (l/60)*nw;

cima = 0;
for i=1:c
    cima = cima + (p^i)/factorial(i-1);
end

baixo = 0;
for i=0:c
    baixo = baixo + (p^i)/factorial(i);
end

n = cima/baixo;