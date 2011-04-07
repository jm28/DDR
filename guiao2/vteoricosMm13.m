function[atrMed, ocupMedFE, taxaPerda] = vteoricosMm13(l, tamMax, tamMin, capL)
   
    medPacotes = ((tamMax+tamMin)/2)*8; %%esta bem
    mju = capL/medPacotes; %%esta bem
    
    atrMed = l/(2*mju*(mju-l));
    %%ocupMedFE = (l / (mju-l))*medPacotes;
    ocupMedFE = (l*atrMed)*medPacotes;
    %%pacotesF = (f*8)/medPacotes;
    %%taxaPerda = (l/mju)^pacotesF;
    taxaPerda = 0; %%M/G/1 considera uma fila de espera infinita
end