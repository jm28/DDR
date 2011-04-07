function n = pbl(l, nw, c)
p = (l/60)*nw;

cima = (p^c)/factorial(c);
baixo = 0;

for i=0:c
    baixo = baixo + ((p^i)/factorial(i)); 
end

n = cima/baixo;