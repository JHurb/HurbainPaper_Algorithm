function param_MCMC=simuDetox_MCMC()
%MCMC : scan param space
tic
reverseStr='';

rngval=2;
rng(rngval);

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

%% analyse param
dataname0='0.648_1000000_Result_2021-02-12_18h51';  %file to start
Result=dlmread(strcat(dataname0,'.dat'),' ',1,0); %read file
[~,sortidx]=sort(Result(:,size(Result(1,:),2)-1)); % sort the lower score
Result_sorted=Result(sortidx,:);
% selection du jeu
param_minsc=Result_sorted(1,1:48); % keep parameter vector
score_min=Result_sorted(1,49); % keep the score value

save_file=1; % 1 to save, 0 don't

k=0;
ntest=500e3; %nb of test run 
rmut=0.05; % value of modification

param_etoi=param_minsc;
score_etoi=score_min;

npts_fit=25;%nb of fitted value : Ratio:12 / Flow:13
nparam=length(param_minsc);
sigma=score_min/abs(npts_fit-nparam);%score_min/abs(npts_fit-nparam)

param_vec=zeros(ntest,length(param_minsc)+2);

for i = 1:ntest
    %param vector modification
    randj=1:(length(param_minsc)); % param a changer
    randinterv=randn(1,length(param_minsc))*rmut; % shift des params /!\ must be normal distrib
    param_test=param_etoi;%genere enfant
    param_test(randj)=param_etoi(randj)+randinterv;
    
    %Controle/fixed param
    param_borne_interval=log10([1e-3 1e6]);
    parout_x=(param_test<param_borne_interval(1));param_test=param_test.*(parout_x==0)+parout_x*(param_borne_interval(1));
    parout_x=(param_test>param_borne_interval(2));param_test=param_test.*(parout_x==0)+parout_x*param_borne_interval(2);
    
    paramkxi_vect=[7 8 10 12 16 18 29 31 34 35 36 38 41 42 43 45];
    param_test(nonzeros(((param_test(paramkxi_vect)>log10(1e2)).*paramkxi_vect))')=log10(1e2);% force kxi<10
    
    param_benfkue_vect=[1:6 33];param_benfkue_val=log10([1 4e-2 9.72 49 8.5 65 200]);
    param_benfkue_index=param_benfkue_vect(param_test(param_benfkue_vect)>(log10(1e1)+param_benfkue_val));% borne supp Benfeitas + kuehne
    param_test(param_benfkue_index)=log10(1e1)+param_benfkue_val(ismember(param_benfkue_vect,param_benfkue_index));
    param_benfkue_index=param_benfkue_vect(param_test(param_benfkue_vect)<(log10(1e-1)+param_benfkue_val));% borne inf Benfeitas + kuehne
    param_test(param_benfkue_index)=log10(1e-1)+param_benfkue_val(ismember(param_benfkue_vect,param_benfkue_index));
    
    param_inib_vect=[11 14];%kig6pd ki6gpd
    param_test(nonzeros((param_test(param_inib_vect)>log10(1e2)).*param_inib_vect)')=log10(1e2);
    param_test(nonzeros((param_test(param_inib_vect)<log10(10^0.5)).*param_inib_vect)')=log10(10^0.5);
%     
    param_inib_vect=46; %kigapd
    param_test(nonzeros(((param_test(param_inib_vect)>log10(10^2.5)).*param_inib_vect))')=log10(10^2.5);
    param_test(nonzeros(((param_test(param_inib_vect)<log10(10^0.5)).*param_inib_vect))')=log10(10^0.5);
    
    param_test([47 48])=log10([30 3000]);% fixed parameters
    
    
    score_test=simuDetox_score(param_test(1:48)); % take score value from the new param vector
    
    
    alpha=exp(-(score_test^2-score_etoi^2)/(2*sigma)); % proba of acceptance

    if score_test==1e5
        r=1e5;
    else
        r=rand();
    end
    
    if r<alpha
        k=k+1;
        param_etoi=param_test;
        score_etoi=score_test;
        param_vec(k,:)=[param_etoi score_etoi k];
        
    end

    
    if mod(i,100)==0 %advancement 
        msg=sprintf('%d / %d loops, k=%d',i,ntest,k);
        fprintf([reverseStr,msg]);
        reverseStr=repmat(sprintf('\b'),1, length(msg));
    end
    
    % restart from min
%     if mod(i,5e5)==0
%         param_etoi=param_minsc;
%         score_etoi=score_min;
%     end
end

[zerosx,~]=find(~param_vec(:,1));
param_MCMC=param_vec(1:zerosx(1)-1,:);

if k~=0
    [~,sortidx]=sort(param_MCMC(:,size(Result_sorted,2)));
    param_MCMC=param_MCMC(sortidx,:);% trie les enfants + parents
end


if save_file ==1
    if k==0
        dataname=['0.00_k0_MCMC_',tim,'_',h,'h',m,'.dat'];
    else
        dataname=strcat(num2str(param_MCMC(1,49),'%.2f'),'_',num2str(mean(param_MCMC(:,49)),'%.3f'),'_',num2str(std(param_MCMC(:,49)),'%.2f'),'_','_k',num2str(k),'_MCMC_',tim,'_',h,'h',m,'.dat');
    end
    fileID = fopen(dataname,'w');
    fprintf(fileID, '%s\n','Result_Analyse_MCMC');
    formatSpec = [repmat('%f ',1,size(param_MCMC,2)-1),'%f\n'];
    for i=1:k
        fprintf(fileID, formatSpec, param_MCMC(i,:));
    end
    fclose(fileID);
end

fprintf('\n');
toc
end

