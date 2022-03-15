function [Result,score_vec,score_std] = simuDetox_AlgoGene()
%Param optimisation
% Opti_genet

tic

rngval=1;
rng(rngval);


reverseStr='';

plot_meanstd=0;
savefile=1;


%% Parameter solver

% If start from a previous vector
% dataname='0.612_1000000_Result_2021-02-08_15h11';
% data=dlmread(strcat(dataname,'.dat'),' ',1,0);
% 
% 
% [~,sortidx]=sort(data(:,size(data(1,:),2)));
% data_sorted=data(sortidx,:);
% % selection du jeu
% param0=data_sorted(1,1:48);

%% Param param0
% kgpx kshgpx ksggpx kgrx ksngrx ksggrx knad knadph Kinnh kg6pd
%   1      2      3    4      5      6    7      8     9    10
% Kig6pd kglase k6pgd Ki6pgd Ks6pgd krpe1 krpe2 krpi1 krpi2 ktkt11
%    11     12    13     14     15    16    17    18    19     20
% ktkt12 kstkt1 ktal1 ktal2 kstal ktkt21 ktkt22 kstkt2 khk Kihk
%    21     22    23    24    25     26     27     28  29   30
% kgpi1 kgpi2 Kigpi kpfk1 kfbp kald1 kald2 ktpi1 ktpi2 kox
%   31    32    33    34   35    36    37    38    39  40
% kcat kdiff kprpps Ksprpps kgapd Kigapd NADtot Gluttot
%  41    42     43      44    45     46     47      48

% If start from a given param vector
kgpx=2.412;kshgpx=0.04;ksggpx=9.72;kgrx=163.96;ksngrx=8.5;ksggrx=65;knad=1.4;knadph=0.2;Kinnh=100;kg6pd=0.024;
Kig6pd=10.66;kglase=+0.1;k6pgd=3.73e-3;Ki6pgd=200;Ks6pgd=500;krpe1=0.098;krpe2=5.4;krpi1=0.121;krpi2=1.9815;ktkt11=4.73e-2;
ktkt12=1.432;kstkt1=200;ktal1=4.81e-2;ktal2=1.132;kstal=200;ktkt21=4.53e-2;ktkt22=1.8;kstkt2=200;khk=0.1;Kihk=300;
kgpi1=0.62;kgpi2=6.1376;Kigpi=500;kpfk1=3.48;kfbp=1.93;kald1=1.614;kald2=1309.18;ktpi1=8.87;ktpi2=0.548;kox=7;
kdiff=0.2;kcat=10;kprpps=0.02;Ksprpps=4477;kgapd=5.52;Kigapd=50;Ntot=30;Gltot=3000;

param0=log10([kgpx,kshgpx,ksggpx,kgrx,ksngrx,ksggrx,knad,knadph,Kinnh,kg6pd,Kig6pd,kglase,...
    k6pgd,Ki6pgd,Ks6pgd,krpe1,krpe2,krpi1,krpi2,ktkt11,ktkt12,kstkt1,ktal1,ktal2,kstal,...
    ktkt21,ktkt22,kstkt2,khk,Kihk,kgpi1,kgpi2,Kigpi,kpfk1,kfbp,kald1,kald2,ktpi1,ktpi2,kox...
    kdiff,kcat,kprpps,Ksprpps,kgapd,Kigapd,Ntot,Gltot]);


% savefile init
[h,m]=hms(datetime);
if length(num2str(h))==1
    h=['0',num2str(h)];
else
    h=num2str(h);
end
if length(num2str(m))==1
    m=['0',num2str(m)];
else
    m=num2str(m);
end
tim=datestr(datetime,29);

%% Opti_complet


nfam=40;%family size
ntest=1e6; %nb of test run
ngen=ntest;% nb of generation
rmut=log10(2);%modification value
tmut=0.1; %nb of modify param

score_vec=zeros(1,ngen);
score_std=zeros(1,ngen);

Result=[param0 0].*ones(nfam,1)+(rand(nfam,length(param0)+1)*2-1)*rmut;
Result(1,:)=[param0 0];
for i =1: nfam
    Result(i,end)=simuDetox_score(Result(i,1:length(param0))); % attribue le score des parents
end

%Test run
for i = 1:ngen
    % New family
    randparent=floor(nfam*rand()+1);%select parent
    randj=floor((length(param0)-2)*rand(1,floor(tmut*length(param0))+1)+1); % param vector to change
    randinterv=(rand(1,floor(tmut*length(param0))+1)*2-1)*rmut; % param shift 
    newgen=Result(randparent,:);%child generation
    newgen(randj)=newgen(randj)+randinterv;
    
    % Control / fixed parameters
    param_borne_interval=log10([1e-3 1e6]);
    parout_x=(newgen<param_borne_interval(1));newgen=newgen.*(parout_x==0)+parout_x*(param_borne_interval(1));
    parout_x=(newgen>param_borne_interval(2));newgen=newgen.*(parout_x==0)+parout_x*param_borne_interval(2);
    
    paramkxi_vect=[7 8 10 12 16 18 29 31 34 35 36 38 41 42 43 45];
    newgen(nonzeros(((newgen(paramkxi_vect)>log10(1e2)).*paramkxi_vect))')=log10(1e2);% force kxi<10
   
    param_benfkue_vect=[1:6 33];param_benfkue_val=log10([1 4e-2 9.72 49 8.5 65 200]);
    param_benfkue_index=param_benfkue_vect(newgen(param_benfkue_vect)>(log10(1e1)+param_benfkue_val));% borne supp Benfeitas + kuehne
    newgen(param_benfkue_index)=log10(1e1)+param_benfkue_val(ismember(param_benfkue_vect,param_benfkue_index));
    param_benfkue_index=param_benfkue_vect(newgen(param_benfkue_vect)<(log10(1e-1)+param_benfkue_val));% borne inf Benfeitas + kuehne
    newgen(param_benfkue_index)=log10(1e-1)+param_benfkue_val(ismember(param_benfkue_vect,param_benfkue_index));
    
    param_inib_vect=[11 14];%kig6pd ki6gpd
    newgen(nonzeros((newgen(param_inib_vect)>log10(1e2)).*param_inib_vect)')=log10(1e2);
    newgen(nonzeros((newgen(param_inib_vect)<log10(10^0.5)).*param_inib_vect)')=log10(10^0.5);
%     
    param_inib_vect=46; %kigapd
    newgen(nonzeros(((newgen(param_inib_vect)>log10(10^2.5)).*param_inib_vect))')=log10(10^2.5);
    newgen(nonzeros(((newgen(param_inib_vect)<log10(10^0.5)).*param_inib_vect))')=log10(10^0.5);
    
    newgen([47 48])=log10([30 3000]);% fixed parameters
    
    
    %Score calculation
    newgen(end)=simuDetox_score(newgen(1:48));

    
    % Sort & select family
    [~,indexminsc] = max(Result(:,end));%find le max score
    Result(indexminsc,:)=newgen; % remplace le moins bon jeu de param (max score) par enfant.
    

    score_vec(i)=min(Result(:,49));
    score_std(i)=std(Result(:,49));

    %         tolpercent=0.5;
    %         if i>floor(tolpercent*ngen) && abs(score_vec(i)-score_vec(i-floor(tolpercent*ngen)))<1e-4
    %             break;
    %         end
    
    % Advancement
    if mod(i,100)==0
        msg=sprintf('%d / %d ',i,ngen);
        fprintf([reverseStr,msg]);
        reverseStr=repmat(sprintf('\b'),1, length(msg));
    end
end

% to plot score variation
if plot_meanstd==1
    clf(figure(1))
    figure(1)
    %         set(figure(1),'Visible','off')
    plot(1:ngen,score_vec,'LineWidth',2)
    set(gca,'FontSize',18);
    grid on
    
    clf(figure(2))
    figure(2)
    %         set(figure(2),'Visible','off')
    plot(1:ngen,score_std,'LineWidth',2)
    set(gca,'FontSize',18);
    set(gca, 'YScale', 'log')
    grid on
end



[~,sortidx]=sort(Result(:,size(Result(1,:),2)));
Result=Result(sortidx,:);% trie les enfants + parents


% save to file
if savefile==1
    score_min=min(Result(:,size(Result,2)));
    dataname0=strcat(num2str(score_min,'%.3f'),'_',num2str(ngen),'_Result_',tim,'_',h,'h',m);
    dataname=[dataname0 '.dat'];
    fileID = fopen(dataname,'w');
    fprintf(fileID, '%s\n','Result');
    formatSpec = [repmat('%f ',1,length(param0)),'%f\n'];
    for i=1:size(Result,1)
        fprintf(fileID, formatSpec, Result(i,:));
    end
    fclose(fileID);
    
    if plot_meanstd==1
        saveas(figure(1),[dataname0 '_scorevec.fig']);
        saveas(figure(2),[dataname0 '_scorestd.fig']);
    end
end



toc
end

