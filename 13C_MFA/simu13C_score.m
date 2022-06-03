function [score,mij,mij_SS]=simu13C_score(varpar,mij_exp,manip_opti)
% Score from param vec (varpar) of the fit mij_exp on mij_theo
% Thommen et al
%,react_ivec

% tic

%% Flow
Fglu=1;
gpip=varpar(1);
pfkp=varpar(2);
aldp=varpar(3);
tpip=varpar(4);
g6pd=varpar(5);
rpep=varpar(6);
rpip=varpar(7);
tkt1p=varpar(8);
talp=varpar(9);
tkt2p=varpar(10);

tkt1m=varpar(11);

pgd=g6pd;
gpim=-((Fglu-g6pd)-gpip);
tkt2m=-((tkt1p-tkt1m)-tkt2p);
talm=-((tkt1p-tkt1m)-talp);
rpem=-((tkt1p-tkt1m)+(tkt2p-tkt2m)-rpep);
rpim=-(g6pd-2*(tkt1p-tkt1m)-rpip);
prpps=(g6pd-3*(tkt1p-tkt1m));
pfkm=-((gpip-gpim)+(talp-talm)+(tkt2p-tkt2m)-pfkp);%-(((gpip-gpim)+2*gapd)/5-pfkp);
aldm=-((gpip-gpim)+(talp-talm)+(tkt2p-tkt2m)-aldp);%-(((gpip-gpim)+2*gapd)/5-aldp);
tpim=-((gpip-gpim)+(talp-talm)+(tkt2p-tkt2m)-tpip);%-(((gpip-gpim)+2*gapd)/5-tpip);
gapd=(aldp-aldm)+(tkt1p-tkt1m)+(tpip-tpim);
% gapd=5*(tkt1p-tkt2m)+2*gly;


%       1     2    3   4    5    6     7    8    9   10   11   12   13  14    15   16   17    18   19    20   21    22     23   
flows=[Fglu gpip gpim pfkp pfkm aldp aldm tpip tpim g6pd pgd rpep rpem rpip rpim tkt1p tkt1m talp talm tkt2p tkt2m prpps gapd];    
% flows_dege=[gpip-gpim,pfkp-pfkm,aldp-aldm,tpip-tpim,rpep-rpem,rpip-rpim,tkt1p-tkt1m,talp-talm,tkt2p-tkt2m];   

if any(flows<=-2e-4)==1 % exit if wrong flow
    score=1e5;
    mij=0;mij_SS=0;
    return
end
%     score=1e5;
%     mij=0;mij_SS=0;

%% Initialisation fonction score

nflow=1000; % size of pop
Tref=nflow/Fglu;
tlimit=25*Tref;%limit time %25*Tref
iter_ratio=70; %ratio iteration / limit time ( for 10 and 25 Tref -> 60.15)


save_mij_vec= 1/tlimit/iter_ratio:1000/tlimit/iter_ratio:1;%[0,0.5,1];
save_mij=floor(tlimit*iter_ratio*save_mij_vec);%numero fixe d'iter pour save mij


mij_vec_save=[1 9 11 8 6 5 2];%position des meta dans format mij_exp
mij=zeros(size(mij_exp,1),11*3,length(save_mij));
iter_vec=zeros(size(mij_exp,1),length(save_mij));%vecteur des iterations quand save mij

for i=manip_opti%size(mij_exp,1)
    [meta_pop,meta_nb]=simu13C_meta();%ini meta
    
    next_time=-log(rand(1,size(flows,2)))./max(flows,1e-32);
    time=0;
    iter=0; % nb iterations 
    nb_mij=0;% i when save mij
    nb_react1=0;% nb of reaction 1
    while time<=tlimit %1.5sec/manip
        iter=iter+1;
        [~,react_i]=min(next_time); % tire la position du flux
        nb_react1=nb_react1+(react_i==1);
%         vect(iter)=react_i;
        [meta_pop,meta_nb]=simu13C_react(meta_pop,meta_nb,react_i,i,mod(nb_react1,2)); % fait la reaction 
        time=next_time(react_i);
        next_time(react_i)=time-log(0.5)/max(flows(react_i),1e-32); % decide qui sera le prochain flux
        
        %% mij calcul 0.05sec/manip
        if any((iter==save_mij)==1)
            nb_mij=nb_mij+1;iter_vec(i,nb_mij)=iter;
            mij(i,:,nb_mij)=simu13C_mijcalc(meta_pop,meta_nb); % calcul les ratio mij pour chaque metabo
        end
    end
end


%% score 0.0015sec
[zerosx,~]=find(~squeeze(sum(mij(1,:,:))));
if isempty(zerosx)==0
    mij=mij(:,:,1:(zerosx(1)-1));
else
    warning('iter>=max_iter')
end

mij_pre_SS(:,:,1)=mij(:,:,1);
mij_pre_SS(:,:,2)=mean(mij(:,:,floor(end/2*0.9):floor(end/2*1.1)),3);
mij_pre_SS(:,:,3)=mean(mij(:,:,floor(end/2):end),3);

mij_theo=mij_pre_SS(:,(mij_vec_save-1)*3+(1:3)',end);

mij_SS=(mij_pre_SS(:,:,2)-mij_pre_SS(:,:,3))./(mij_pre_SS(:,:,1)-mij_pre_SS(:,:,3));
mij_SS(isnan(mij_SS))=1;
mij_SS((mij_SS>1))=1;


score_vec=(mij_exp(manip_opti,:)-mij_theo(manip_opti,:)).^2/numel(mij_exp(manip_opti,:));
score_poids=100;
score=score_poids*sqrt(sum(sum(score_vec)));

%toc
end
