function param_MCMC=simu13C_MCMC(manip,iniguess)
tic
rngval=1;
rng(rngval);
%Experimental manip to fit
manip_opti=1:4;

%% File
reverseStr='';
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

%% MIJ exp to fit
%%%%%%%%%%%%%%%%%%%%%%%%G6P%%%%%%%%%%%%%%FBP%%%%%%%%%%%%%%GAP%%%%%%%%%%%%%%F6P%%%%%%%%%%%%%%S7P%%%%%%%%%%%%%%R5P%%%%%%%%%%%%%%6PG%%%%%%%%
nbr_var=21;
mij_exp_ctrl=zeros(4,nbr_var);
mij_exp_ctrl(1,:)=[0.47,0.52,0.01,  0.48,0.49,0.02,  0.73,0.26,0.01,  0.62,0.36,0.02,  0.62,0.28,0.07,  0.65,0.22,0.12,  0.51,0.45,0.03];%  50% 1-13C
mij_exp_ctrl(2,:)=[0.47,0.52,0.01,  0.46,0.50,0.03,  0.73,0.25,0.01,  0.62,0.34,0.04,  0.44,0.30,0.19,  0.41,0.35,0.21,  0.45,0.49,0.05];%  50% 2-13C
mij_exp_ctrl(3,:)=[0.03,0.01,0.90,  0.06,0.02,0.81,  0.50,0.01,0.48,  0.08,0.05,0.76,  0.32,0.07,0.26,  0.07,0.39,0.14,  0.08,0.08,0.71];%  1,2-13C
mij_exp_ctrl(4,:)=[0.40,0.01,0.55,  0.43,0.02,0.48,  0.73,0.01,0.25,  0.41,0.03,0.50,  0.35,0.20,0.26,  0.45,0.26,0.17,  0.41,0.07,0.46];%  50% 1,2-13C

mij_exp_stre=zeros(4,nbr_var);
mij_exp_stre(1,:)=[0.47,0.52,0.01,  0.68,0.30,0.02,  0.85,0.12,0.00,  0.74,0.23,0.02,  0.90,0.09,0.01,  0.89,0.09,0.02,  0.57,0.40,0.02];%
mij_exp_stre(2,:)=[0.45,0.53,0.01,  0.50,0.41,0.07,  0.77,0.21,0.03,  0.64,0.29,0.05,  0.31,0.42,0.21,  0.45,0.45,0.09,  0.43,0.51,0.05];%
mij_exp_stre(3,:)=[0.03,0.01,0.88,  0.20,0.23,0.41,  0.66,0.14,0.19,  0.15,0.41,0.30,  0.07,0.24,0.50,  0.14,0.65,0.10,  0.04,0.11,0.76];%
mij_exp_stre(4,:)=[0.45,0.05,0.47,  0.62,0.11,0.23,  0.83,0.05,0.11,  0.56,0.15,0.24,  0.36,0.38,0.18,  0.55,0.33,0.09,  0.52,0.15,0.29];%



if manip==1 
    %basal/ctrl
    dataname0='mcmc_basal_reorder';
    data1=dlmread(strcat(dataname0,'.dat'),' ',1,0);
    param_minsc_ctrl=mean(data1(iniguess,1:11),1);
    mij_exp=mij_exp_ctrl;
    param_minsc=param_minsc_ctrl;
    manip_string='ctrl';
    score_min=4.8;
else
    %stress
    dataname0='mcmc_stress_reorder';
    data1=dlmread(strcat(dataname0,'.dat'),' ',1,0);
    param_minsc_stre=mean(data1(iniguess,1:11),1);
    mij_exp=mij_exp_stre;
    param_minsc=param_minsc_stre;
    manip_string='stre';
    score_min=6.2;
end


if manip==1
    %Basal/ctrl
    mij_exp=mij_exp_ctrl;
    param_minsc=param_minsc_ctrl;
    manip_string='ctrl';
elseif manip==2
    %stress
    mij_exp=mij_exp_stre;
    param_minsc=param_minsc_stre;
    manip_string='stre';
end


%% Param MCMC
save_file=1; % save to file %1=on 0=off
k=0;
ntest=10e3; %nb of test run
rmut=0.05; %param modification value

param_etoi=param_minsc; % store best flux (best score)
[score_etoi,~,~]=simu13C_score(param_etoi,mij_exp,manip_opti);%attribute score value

% exit from local minimum
randj=1:length(param_minsc); % param a changer
randinterv=randn(1,length(param_minsc))*rmut; % shift des params
param_etoi(randj)=param_etoi(randj)+randinterv.*param_etoi(randj);


npts_fit=84; %nb exp pts to fit
nparam=length(param_minsc); %nb de param to fit
sigma=score_min/abs(npts_fit-nparam);

param_vec=zeros(ntest,length(param_minsc)+1+size(mij_exp,2)/3+1+1); %vect to save params

%% MCMC
for i = 1:ntest
    %Normal distribution => convergence (ssi Normal in mcmc)
    randj=1:length(param_minsc); % param to change
    randinterv=randn(1,length(param_minsc))*rmut; % shift  params
    param_test=param_etoi;%genere child
    param_test(randj)=param_etoi(randj)+randinterv;
    
    %Controle param
    parout_x=(param_test>3);param_test=param_test.*(parout_x==0)+parout_x*3;
    parout_x=(param_test<1e-2);param_test=param_test.*(parout_x==0)+parout_x*(1e-2);
    
    [score_test,~,mij_SS]=simu13C_score(param_test,mij_exp,manip_opti); % attribute score
    
    alpha=exp(-(score_test-score_etoi)/(2*sigma)); %proba acceptance
    if score_test==1e5
        r=1e5;
    else
        r=rand();
    end
    
    if r<alpha %acceptance
        k=k+1;
        param_etoi=param_test;
        score_etoi=score_test;
        mij_SS_m0=mij_SS(1,(1:7)*3-2);
        mij_SS_ratio=sum(mij_SS_m0>0.25)/length(mij_SS_m0);
        param_vec(k,:)=[param_etoi score_etoi k mij_SS_m0 mij_SS_ratio];
    end
    
    % advancement
    if mod(i,100)==0
        msg=sprintf('%d / %d loops, k=%d',i,ntest,k);
        fprintf([reverseStr,msg]);
        reverseStr=repmat(sprintf('\b'),1, length(msg));
    end
end

%% Reorder + Save
[zerosx,~]=find(~param_vec(:,1));
param_MCMC=param_vec(1:zerosx(1)-1,:);

if k~=0
    [~,sortidx]=sort(param_MCMC(:,length(param_minsc)+1));
    param_MCMC=param_MCMC(sortidx,:);% trie les enfants + parents
end

if save_file ==1
    dataname=strcat('Result_MCMC_',manip_string,'_',num2str(iniguess),'_',strrep(num2str(manip_opti),' ',''),'_',tim,'_',h,'h',m,'.dat');
    fileID = fopen(dataname,'w');
    fprintf(fileID, '%s %s %s %s %s %s %s %s %s %s %s %s\n','gpip','pfkp','aldp','tpip','g6pd','rpep','rpip','tkt1p','talp','tkt2p','tkt1m','score');
    formatSpec = [repmat('%f ',1,size(param_MCMC,2)-1),'%f\n'];
    for i=1:k
        fprintf(fileID, formatSpec, param_MCMC(i,:));
    end
    fclose(fileID);
end

fprintf('\n');
toc
end
