function [pop,nb]=simu13C_react(pop,nb,reaction,expe,rand_glu)
% Apply Reactions

%               1       2      3      4      5      6      7      8      9     10      11
% meta_names=[' G6P';'  PG';'Ru5P';' X5P';' R5P';' S7P';' E4P';' F6P';' FBP';'DHAP';' GAP'];
nbC=[6, 6, 5, 5, 5, 7, 4, 6, 6, 3, 3];
G6P=1;PG=2;Ru5P=3;X5P=4;R5P=5;S7P=6;E4P=7;F6P=8;FBP=9;DHAP=10;GAP=11;

if reaction==1 %GLU -> G6P  %Fglu
    n3=nb(G6P)+1;
    nb(G6P)=nb(G6P)+1;
    
    if expe==1 % 50% 1-13C
        pop(n3,1:nbC(G6P),G6P)=rand_glu*[1,0,0,0,0,0];
    elseif expe==2 % 50% 2-13C
        pop(n3,1:nbC(G6P),G6P)=rand_glu*[0,1,0,0,0,0];
    elseif expe==3 % 100% 1,2-13C
        pop(n3,1:nbC(G6P),G6P)=[1,1,0,0,0,0];
    elseif expe==4 % 50% 1,2-13C
        pop(n3,1:nbC(G6P),G6P)=rand_glu*[1,1,0,0,0,0];
    end
    
elseif reaction==2 %G6P -> F6P  %GPIp
    n1=floor((nb(G6P))*rand()+1);
    n3=nb(F6P)+1;
    nb(F6P)=nb(F6P)+1;
    
    pop(n3,1:nbC(F6P),F6P)=pop(n1,1:nbC(G6P),G6P);
    
    pop(n1,1:nbC(G6P),G6P)=pop(nb(G6P),1:nbC(G6P),G6P);
    nb(G6P)=nb(G6P)-1;
    
elseif reaction==3 %F6P -> G6P  %GPIm
    n1=floor((nb(F6P))*rand()+1);
    n3=nb(G6P)+1;
    nb(G6P)=nb(G6P)+1;
     
    pop(n3,1:nbC(G6P),G6P)=pop(n1,1:nbC(F6P),F6P);
    
    pop(n1,1:nbC(F6P),F6P)=pop(nb(F6P),1:nbC(F6P),F6P);
    nb(F6P)=nb(F6P)-1;
    
elseif reaction==4 %F6P -> FBP  %PFKp
    n1=floor((nb(F6P))*rand()+1);
    n3=nb(FBP)+1;
    nb(FBP)=nb(FBP)+1;
     
    pop(n3,1:nbC(FBP),FBP)=pop(n1,1:nbC(F6P),F6P);
    
    pop(n1,1:nbC(F6P),F6P)=pop(nb(F6P),1:nbC(F6P),F6P);
    nb(F6P)=nb(F6P)-1;
    
elseif reaction==5 %FBP -> F6P  %PFKm
    n1=floor((nb(FBP))*rand()+1);
    n3=nb(F6P)+1;
    nb(F6P)=nb(F6P)+1;
     
    pop(n3,1:nbC(F6P),F6P)=pop(n1,1:nbC(FBP),FBP);
    
    pop(n1,1:nbC(FBP),FBP)=pop(nb(FBP),1:nbC(FBP),FBP);
    nb(FBP)=nb(FBP)-1;
    
elseif reaction==6 %FBP -> DHAP + GAP  %ALDp
    n1=floor((nb(FBP))*rand()+1);
    n3=nb(DHAP)+1;
    n4=nb(GAP)+1;
    nb(DHAP)=nb(DHAP)+1;
    nb(GAP)=nb(GAP)+1;
    
    pop(n3,1:nbC(DHAP),DHAP)=pop(n1,1:nbC(DHAP),FBP);
    pop(n4,1:nbC(GAP),GAP)=pop(n1,nbC(GAP)+1:nbC(GAP)+3,FBP);
    
    pop(n1,1:nbC(FBP),FBP)=pop(nb(FBP),1:nbC(FBP),FBP);
    nb(FBP)=nb(FBP)-1;
    
elseif reaction==7 %DHAP + GAP -> FBP  %ALDm
    n1=floor((nb(DHAP))*rand()+1);
    n2=floor((nb(GAP))*rand()+1);
    n3=nb(FBP)+1;
    nb(FBP)=nb(FBP)+1;
    
    pop(n3,1:nbC(DHAP),FBP)=pop(n1,1:nbC(DHAP),DHAP);
    pop(n3,nbC(GAP)+1:nbC(GAP)+3,FBP)=pop(n2,1:nbC(GAP),GAP);
    
    pop(n1,1:nbC(DHAP),DHAP)=pop(nb(DHAP),1:nbC(DHAP),DHAP);
    nb(DHAP)=nb(DHAP)-1;
    pop(n2,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;
    
elseif reaction==8 %DHAP -> GAP  %TPIp
    n1=floor((nb(DHAP))*rand()+1);
    n3=nb(GAP)+1;
    nb(GAP)=nb(GAP)+1;
    
    pop(n3,1:nbC(GAP),GAP)=pop(n1,nbC(DHAP):-1:1,DHAP);
    
    pop(n1,1:nbC(DHAP),DHAP)=pop(nb(DHAP),1:nbC(DHAP),DHAP);
    nb(DHAP)=nb(DHAP)-1;
    
elseif reaction==9 %GAP -> DHAP  %TPIm
    n1=floor((nb(GAP))*rand()+1);
    n3=nb(DHAP)+1;
    nb(DHAP)=nb(DHAP)+1;
    
    pop(n3,1:nbC(DHAP),DHAP)=pop(n1,nbC(GAP):-1:1,GAP);
    
    pop(n1,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;

elseif reaction==23 %GAP -> 0  %GAPD
    n1=floor((nb(GAP))*rand()+1);
    
    pop(n1,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;
    
%%%%%%%% PPP %%%%%%%%  
elseif reaction==10 %G6P -> 6PG  %G6PD
    n1=floor((nb(G6P))*rand()+1);
    n3=nb(PG)+1;
    nb(PG)=nb(PG)+1;
    
    pop(n3,1:nbC(PG),PG)=pop(n1,1:nbC(G6P),G6P);
    
    pop(n1,1:nbC(G6P),G6P)=pop(nb(G6P),1:nbC(G6P),G6P);
    nb(G6P)=nb(G6P)-1;
    
elseif reaction==11 %6PG -> Ru5P  %PGD
    n1=floor((nb(PG))*rand()+1);
    n3=nb(Ru5P)+1;
    nb(Ru5P)=nb(Ru5P)+1;
    
    pop(n3,1:nbC(Ru5P),Ru5P)=pop(n1,2:nbC(PG),PG);
    
    pop(n1,1:nbC(PG),PG)=pop(nb(PG),1:nbC(PG),PG);
    nb(PG)=nb(PG)-1;
    
elseif reaction==12 %Ru5P -> X5P  %RPEp
    n1=floor((nb(Ru5P))*rand()+1);
    n3=nb(X5P)+1;
    nb(X5P)=nb(X5P)+1;
    
    pop(n3,1:nbC(X5P),X5P)=pop(n1,1:nbC(Ru5P),Ru5P);
    
    pop(n1,1:nbC(Ru5P),Ru5P)=pop(nb(Ru5P),1:nbC(Ru5P),Ru5P);
    nb(Ru5P)=nb(Ru5P)-1;
    
elseif reaction==13 %X5P -> Ru5P  %RPEm
    n1=floor((nb(X5P))*rand()+1);
    n3=nb(Ru5P)+1;
    nb(Ru5P)=nb(Ru5P)+1;
    
    pop(n3,1:nbC(Ru5P),Ru5P)=pop(n1,1:nbC(X5P),X5P);
    
    pop(n1,1:nbC(X5P),X5P)=pop(nb(X5P),1:nbC(X5P),X5P);
    nb(X5P)=nb(X5P)-1;
    
elseif reaction==14 %Ru5P -> R5P  %RPIp
    n1=floor((nb(Ru5P))*rand()+1);
    n3=nb(R5P)+1;
    nb(R5P)=nb(R5P)+1;
    
    pop(n3,1:nbC(R5P),R5P)=pop(n1,1:nbC(Ru5P),Ru5P);
    
    pop(n1,1:nbC(Ru5P),Ru5P)=pop(nb(Ru5P),1:nbC(Ru5P),Ru5P);
    nb(Ru5P)=nb(Ru5P)-1;
    
elseif reaction==15 %R5P -> Ru5P  %RPIm
    n1=floor((nb(R5P))*rand()+1);
    n3=nb(Ru5P)+1;
    nb(Ru5P)=nb(Ru5P)+1;
    
    pop(n3,1:nbC(Ru5P),Ru5P)=pop(n1,1:nbC(R5P),R5P);
    
    pop(n1,1:nbC(R5P),R5P)=pop(nb(R5P),1:nbC(R5P),R5P);
    nb(R5P)=nb(R5P)-1;
    
elseif reaction==22 %R5P -> 0  %PRPPs
    n1=floor((nb(R5P))*rand()+1);
    
    pop(n1,1:nbC(R5P),R5P)=pop(nb(R5P),1:nbC(R5P),R5P);
    nb(R5P)=nb(R5P)-1;
   
%%%%%%%% non-oxPPP %%%%%%%%     
    
elseif reaction==16 %X5P + R5P -> GAP + S7P  %TKT1p
    n1=floor((nb(X5P))*rand()+1);
    n2=floor((nb(R5P))*rand()+1);
    n3=nb(GAP)+1;
    n4=nb(S7P)+1;
    nb(GAP)=nb(GAP)+1;
    nb(S7P)=nb(S7P)+1;
    
    pop(n3,1:nbC(GAP),GAP)=pop(n1,3:5,X5P);
    pop(n4,1:2,S7P)=pop(n1,1:2,X5P);
    pop(n4,3:7,S7P)=pop(n2,1:nbC(R5P),R5P);
    
    pop(n1,1:nbC(X5P),X5P)=pop(nb(X5P),1:nbC(X5P),X5P);
    nb(X5P)=nb(X5P)-1;
    pop(n2,1:nbC(R5P),R5P)=pop(nb(R5P),1:nbC(R5P),R5P);
    nb(R5P)=nb(R5P)-1;
    
elseif reaction==17 %GAP + S7P -> X5P + R5P  %TKT1m
    n1=floor((nb(GAP))*rand()+1);
    n2=floor((nb(S7P))*rand()+1);
    n3=nb(X5P)+1;
    n4=nb(R5P)+1;
    nb(X5P)=nb(X5P)+1;
    nb(R5P)=nb(R5P)+1;
    
    pop(n3,1:2,X5P)=pop(n2,1:2,S7P);
    pop(n3,3:5,X5P)=pop(n1,1:nbC(GAP),GAP);
    pop(n4,1:nbC(R5P),R5P)=pop(n2,3:7,S7P);
    
    pop(n1,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;
    pop(n2,1:nbC(S7P),S7P)=pop(nb(S7P),1:nbC(S7P),S7P);
    nb(S7P)=nb(S7P)-1;
    
elseif reaction==18 %GAP + S7P -> F6P + E4P  %TALp
    n1=floor((nb(GAP))*rand()+1);
    n2=floor((nb(S7P))*rand()+1);
    n3=nb(F6P)+1;
    n4=nb(E4P)+1;
    nb(F6P)=nb(F6P)+1;
    nb(E4P)=nb(E4P)+1;
    
    pop(n3,1:3,F6P)=pop(n2,1:3,S7P);
    pop(n3,4:6,F6P)=pop(n1,1:nbC(GAP),GAP);
    pop(n4,1:nbC(E4P),E4P)=pop(n2,4:7,S7P);
    
    pop(n1,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;
    pop(n2,1:nbC(S7P),S7P)=pop(nb(S7P),1:nbC(S7P),S7P);
    nb(S7P)=nb(S7P)-1;
    
elseif reaction==19 %F6P + E4P -> GAP + S7P  %TALm
    n1=floor((nb(F6P))*rand()+1);
    n2=floor((nb(E4P))*rand()+1);
    n3=nb(GAP)+1;
    n4=nb(S7P)+1;
    nb(GAP)=nb(GAP)+1;
    nb(S7P)=nb(S7P)+1;
    
    pop(n3,1:nbC(GAP),GAP)=pop(n1,4:6,F6P);
    pop(n4,1:3,S7P)=pop(n1,1:3,F6P);
    pop(n4,4:7,S7P)=pop(n2,1:nbC(E4P),E4P);
    
    pop(n1,1:nbC(F6P),F6P)=pop(nb(F6P),1:nbC(F6P),F6P);
    nb(F6P)=nb(F6P)-1;
    pop(n2,1:nbC(E4P),E4P)=pop(nb(E4P),1:nbC(E4P),E4P);
    nb(E4P)=nb(E4P)-1;
    
elseif reaction==20 %X5P + E4P -> F6P + GAP  %TKT2p
    n1=floor((nb(X5P))*rand()+1);
    n2=floor((nb(E4P))*rand()+1);
    n3=nb(F6P)+1;
    n4=nb(GAP)+1;
    nb(F6P)=nb(F6P)+1;
    nb(GAP)=nb(GAP)+1;
    
    pop(n3,1:2,F6P)=pop(n1,1:2,X5P);
    pop(n3,3:6,F6P)=pop(n2,1:nbC(E4P),E4P);
    pop(n4,1:nbC(GAP),GAP)=pop(n1,3:5,X5P);
    
    pop(n1,1:nbC(X5P),X5P)=pop(nb(X5P),1:nbC(X5P),X5P);
    nb(X5P)=nb(X5P)-1;
    pop(n2,1:nbC(E4P),E4P)=pop(nb(E4P),1:nbC(E4P),E4P);
    nb(E4P)=nb(E4P)-1;

elseif reaction==21 %F6P + GAP -> X5P + E4P  %TKT2m
    n1=floor((nb(F6P))*rand()+1);
    n2=floor((nb(GAP))*rand()+1);
    n3=nb(X5P)+1;
    n4=nb(E4P)+1;
    nb(X5P)=nb(X5P)+1;
    nb(E4P)=nb(E4P)+1;
    
    pop(n3,1:2,X5P)=pop(n1,1:2,F6P);
    pop(n3,3:5,X5P)=pop(n2,1:nbC(GAP),GAP);
    pop(n4,1:nbC(E4P),E4P)=pop(n1,3:6,F6P);
    
    pop(n1,1:nbC(F6P),F6P)=pop(nb(F6P),1:nbC(F6P),F6P);
    nb(F6P)=nb(F6P)-1;
    pop(n2,1:nbC(GAP),GAP)=pop(nb(GAP),1:nbC(GAP),GAP);
    nb(GAP)=nb(GAP)-1;
        
end   
end
