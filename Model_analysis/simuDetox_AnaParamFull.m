function simuDetox_AnaParamFull(KOpar)
%Analysis Dose response + param
tic

dataname1='mcmcpar_100k';
Result_brut=dlmread(strcat(dataname1,'.dat'),' ',1,0);


dataname2='mcmcfpb_100k';
Result_IC=dlmread(strcat(dataname2,'.dat'),' ',1,0);
param_Benjorder=[15 17 16 2 8 9 10 12 11 14 13 1 3 4 5 6];
Result_ic_brut=Result_IC(:,param_Benjorder);

%%%%%%%%%%%%%
nbpar=2000;%min(size(Result,1),size(Result_IC,1));
%%%%%%%%%%%%%

Result_idxrand_min=1;
Result_idxrand_max=min(size(Result_brut,1),size(Result_IC,1));
Result_idxrand=floor((Result_idxrand_max-Result_idxrand_min+1)*rand(1,nbpar)+Result_idxrand_min);
Result=Result_brut(Result_idxrand,:);
Result_ic=Result_ic_brut(Result_idxrand,:);

reverseStr='';

%% Param_simu
%Dose vector
paramvarDose=(100:20:1000)/500;%10.^(log10(100):0.05:log10(1000))/500%10.^(-0.7:0.2:0.3)%[sort(reshape(paramvar_matrix,[1,paramvar_nbr])) 10^(paramvar_puismax-floor(paramvar_puismax/2)-paramvar_center+1)]; %vecteur param ordre croissant  -1
paramvarDose_nbr = numel(paramvarDose);%paramvar_nbr +1;
%KO vector
paramvarPar=(-1:0.05:1);%[sort(reshape(paramvar_matrix,[1,paramvar_nbr])) 10^(paramvar_puismax-floor(paramvar_puismax/2)-paramvar_center+1)]; %vecteur param ordre croissant  -1
paramvarPar_nbr = numel(paramvarPar);%paramvar_nbr +1;
% 
% paramvarPar=(-1:0.05:1);
% 
% paramDose=(100:20:1000)/500;
% 
% Matrix size 46 x 41 x 2000




tmaxv=[10000 1800]; %Simulation time
nbptsv=[10000 1000]; %nb of point


Fglu=40; %Glucose flow
penteIv=[0.0 0.0;0.0 0.0]; %slope, microM/s
Imaxv=[0.000 500;Fglu Fglu]; % Maximum stress value
ITimev=[tmaxv(1) tmaxv(2);tmaxv(1) tmaxv(2)]; % bolus time
Tperiodv=[tmaxv(1) tmaxv(2);tmaxv(1) tmaxv(2)]; % repetition periode (>=tmax = off)
stress_noisev=[0 0;0 0]; % percentage of max noise (0% = off), module noise freq with nbpts
starting_stress=[0 0;0 0]; % starting point of stress




%% KO
KO_param_x=[10 13 20]; %param to modify

Var_nbr=16;


DoseResp_5min=zeros(nbpar,(Var_nbr+3)*paramvarDose_nbr+1,paramvarPar_nbr);
DoseResp_30min=zeros(nbpar,(Var_nbr+3)*paramvarDose_nbr+1,paramvarPar_nbr);
Hmax=zeros(paramvarDose_nbr,paramvarPar_nbr);
GSHmax=zeros(paramvarDose_nbr,paramvarPar_nbr);
NHmax=zeros(paramvarDose_nbr,paramvarPar_nbr);


%% Simulations
for i = 1:nbpar
    
    param_i=Result(i,1:48);
    
    for k= 1:paramvarPar_nbr
        
        %param modification
        param=param_i;
        param(KO_param_x(KOpar))=param(KO_param_x(KOpar))+paramvarPar(k);
        if KO_param_x(KOpar)==20
            param(26)=param(26)+paramvarPar(k);
        end
        
        
        delta_dxdt_5m=zeros(2,paramvarDose_nbr);
        delta_dxdt_30m=zeros(2,paramvarDose_nbr);
        
        %% Basal simulation
        Fext.IC=Result_ic(i,:);
        Fext.IT=[];
        Fext.Tspan=[];
        Fext=simuDetox_Iinput(Fext, 'Fh2o2', penteIv(1,1), Imaxv(1,1),ITimev(1,1), tmaxv(1), nbptsv(1),Tperiodv(1,1),stress_noisev(1,1),starting_stress(1,1));
        Fext=simuDetox_Iinput(Fext, 'Fgluv', penteIv(2,1), Imaxv(2,1),ITimev(2,1), tmaxv(1), nbptsv(1),Tperiodv(2,1),stress_noisev(2,1),starting_stress(2,1));
        
        [~,x1,f1]=simuDetox_reso(param,Fext);
        
        for j= 1 : paramvarDose_nbr
        %% Stress Simulation
            %Input fonction of Fh2o2 and Fgluv
            Fext.IC=x1(end,:);
            
            Fext.IT=[];
            Fext.Tspan=[];
            Imaxs=Imaxv(1,2)*paramvarDose(j);
            Fext=simuDetox_Iinput(Fext, 'Fh2o2', penteIv(1,2), Imaxs,ITimev(1,2), tmaxv(2), nbptsv(2),Tperiodv(1,2),stress_noisev(1,2),starting_stress(1,2));
            Fext=simuDetox_Iinput(Fext, 'Fgluv',penteIv(2,2), Imaxv(2,2),ITimev(2,2), tmaxv(2), nbptsv(2),Tperiodv(2,2),stress_noisev(2,2),starting_stress(2,2));
            
            
            
            [t2,x2,f2]=simuDetox_reso(param,Fext);
            
            %% Store into a matrix / DoseResp_5min t=5min / DoseResp_30min t=30min
            %Conc 5 min
            x_steady=[x1(end,:);x2(end,:)];
            %Flow 5min
            f_steady=[f1(end,:);f2(end,:)];
            
            
            x_5min=zeros(2,size(x2,2));
            f_steady_time=300;%5min
            x_5min(1,:)=x_steady(1,:);
            for l=1:size(x2,2)% basal SS + stress 5min
                x_5min(2,l)=interp1(t2,x2(:,l),f_steady_time);
            end
            
            f_5min=zeros(2,size(f2,2));
            
            f_5min(1,:)=f_steady(1,:);
            for l=1:size(f2,2)% basal SS + stress 5min
                f_5min(2,l)=interp1(t2,f2(:,l),f_steady_time);
            end
            dxdt_5m=[f_5min(:,28)-f_5min(:,1),... 1 h2o2
                2*f_5min(:,2)-2*f_5min(:,1),... 2 gsh
                f_5min(:,5)+f_5min(:,7)+(f_5min(:,3)-f_5min(:,4))-f_5min(:,2),... 3 nh
                f_5min(:,18)-f_5min(:,5)-(f_5min(:,20)-f_5min(:,21)),... 4 g6p
                f_5min(:,5)-f_5min(:,6),... 5 6pgl
                f_5min(:,6)-f_5min(:,7),... 6 6pg
                f_5min(:,7)-(f_5min(:,10)-f_5min(:,11))-(f_5min(:,8)-f_5min(:,9)),... 7 ru5p
                (f_5min(:,8)-f_5min(:,9))-(f_5min(:,12)-f_5min(:,13))-(f_5min(:,16)-f_5min(:,17)),... 8 x5p
                (f_5min(:,10)-f_5min(:,11))-(f_5min(:,12)-f_5min(:,13))-f_5min(:,30),... 9 r5p
                (f_5min(:,12)-f_5min(:,13))-(f_5min(:,14)-f_5min(:,15)),... 10 s7p
                (f_5min(:,14)-f_5min(:,15))-(f_5min(:,16)-f_5min(:,17)),... 11 e4p
                f_5min(:,29)-f_5min(:,18), ... 12 glc
                (f_5min(:,20)-f_5min(:,21))-(f_5min(:,22)-f_5min(:,23))+(f_5min(:,14)-f_5min(:,15))+(f_5min(:,16)-f_5min(:,17)),... 13 f6p
                (f_5min(:,22)-f_5min(:,23))-(f_5min(:,24)-f_5min(:,25)),... 15 fbp
                (f_5min(:,24)-f_5min(:,25))-(f_5min(:,26)-f_5min(:,27)),... 16 dhap
                (f_5min(:,24)-f_5min(:,25))+(f_5min(:,12)-f_5min(:,13))-(f_5min(:,14)-f_5min(:,15))+(f_5min(:,16)-f_5min(:,17))+(f_5min(:,26)-f_5min(:,27))-f_5min(:,31)]; %17 gap
            delta_dxdt_5m(:,j)=sum(abs(dxdt_5m').^2)/2;
            delta_dxdt_5m(:,j)=sqrt(delta_dxdt_5m(:,j));
            
            
            dxdt_30m=[f_steady(:,28)-f_steady(:,1),... 1 h2o2
                2*f_steady(:,2)-2*f_steady(:,1),... 2 gsh
                f_steady(:,5)+f_steady(:,7)+(f_steady(:,3)-f_steady(:,4))-f_steady(:,2),... 3 nh
                f_steady(:,18)-f_steady(:,5)-(f_steady(:,20)-f_steady(:,21)),... 4 g6p
                f_steady(:,5)-f_steady(:,6),... 5 6pgl
                f_steady(:,6)-f_steady(:,7),... 6 6pg
                f_steady(:,7)-(f_steady(:,10)-f_steady(:,11))-(f_steady(:,8)-f_steady(:,9)),... 7 ru5p
                (f_steady(:,8)-f_steady(:,9))-(f_steady(:,12)-f_steady(:,13))-(f_steady(:,16)-f_steady(:,17)),... 8 x5p
                (f_steady(:,10)-f_steady(:,11))-(f_steady(:,12)-f_steady(:,13))-f_steady(:,30),... 9 r5p
                (f_steady(:,12)-f_steady(:,13))-(f_steady(:,14)-f_steady(:,15)),... 10 s7p
                (f_steady(:,14)-f_steady(:,15))-(f_steady(:,16)-f_steady(:,17)),... 11 e4p
                f_steady(:,29)-f_steady(:,18), ... 12 glc
                (f_steady(:,20)-f_steady(:,21))-(f_steady(:,22)-f_steady(:,23))+(f_steady(:,14)-f_steady(:,15))+(f_steady(:,16)-f_steady(:,17)),... 13 f6p
                (f_steady(:,22)-f_steady(:,23))-(f_steady(:,24)-f_steady(:,25)),... 15 fbp
                (f_steady(:,24)-f_steady(:,25))-(f_steady(:,26)-f_steady(:,27)),... 16 dhap
                (f_steady(:,24)-f_steady(:,25))+(f_steady(:,12)-f_steady(:,13))-(f_steady(:,14)-f_steady(:,15))+(f_steady(:,16)-f_steady(:,17))+(f_steady(:,26)-f_steady(:,27))-f_steady(:,31)]; %17 gap
            delta_dxdt_30m(:,j)=sum(abs(dxdt_30m').^2)/2;
            delta_dxdt_30m(:,j)=sqrt(delta_dxdt_30m(:,j));
            
            
            
            
            Hmax(j,k)=max(x2(:,1));
            GSHmax(j,k)=min(x2(:,2));
            NHmax(j,k)=min(x2(:,3));
            
            %x_steady_reshape=x_5min';
            DoseResp_5min(i,(1:Var_nbr)+(j-1)*Var_nbr,k)=x_5min(2,:);%x_steady_reshape(:)';
            %x_steady_reshape=x_steady';
            DoseResp_30min(i,(1:Var_nbr)+(j-1)*Var_nbr,k)=x_steady(2,:);%x_steady_reshape(:)';
        
        end
        
        
        DoseResp_5min(i,((Var_nbr)*paramvarDose_nbr+1):(Var_nbr+1)*paramvarDose_nbr,k)=Imaxv(1,2)*paramvarDose;
        DoseResp_5min(i,((Var_nbr+1)*paramvarDose_nbr+1):(Var_nbr+2)*paramvarDose_nbr,k)= delta_dxdt_5m(1,:);
        DoseResp_5min(i,((Var_nbr+2)*paramvarDose_nbr+1):(Var_nbr+3)*paramvarDose_nbr,k)= delta_dxdt_5m(2,:);
        DoseResp_5min(i,end,k)=Result(i,end);
        
        DoseResp_30min(i,((Var_nbr)*paramvarDose_nbr+1):(Var_nbr+1)*paramvarDose_nbr,k)=Imaxv(1,2)*paramvarDose;
        DoseResp_30min(i,((Var_nbr+1)*paramvarDose_nbr+1):(Var_nbr+2)*paramvarDose_nbr,k)= delta_dxdt_30m(1,:);
        DoseResp_30min(i,((Var_nbr+2)*paramvarDose_nbr+1):(Var_nbr+3)*paramvarDose_nbr,k)= delta_dxdt_30m(2,:);
        DoseResp_30min(i,end,k)=Result(i,end);
         
    end
    
    %% Advancement
    if mod(i,1)==0
        msg=sprintf('%d / %d loops',i,nbpar);
        fprintf([reverseStr,msg]);
        reverseStr=repmat(sprintf('\b'),1, length(msg));
    end
end
    

    



%% save file

KO_name=['g6pd';'6pgd';' tkt'];

for j=1:paramvarPar_nbr
    dataname11=[dataname1 '_APF_5m_' strrep(KO_name(KOpar,:),' ','') '_' num2str(j) '.dat'];
    fileID = fopen(dataname11,'w');
    fprintf(fileID, '%s\n','Result_Analyse_MCMC_DoseRep_AnaPar');
    formatSpec = [repmat('%f ',1,size(DoseResp_5min,2)-1),'%f\n'];
    for i=1:size(DoseResp_5min,1)
        fprintf(fileID, formatSpec, DoseResp_5min(i,:,j));
    end
    fclose(fileID);
end

% dataname12=[dataname1 '_AnaPar' num2str(Dose) 'uM_30m_' strrep(KO_name(KOpar,:),' ','') '.dat'];
% fileID = fopen(dataname12,'w');
% fprintf(fileID, '%s\n','Result_Analyse_MCMC_DoseRep');
% formatSpec = [repmat('%f ',1,size(DoseResp_30min,2)-1),'%f\n'];
% for i=1:size(DoseResp_30min,1)
%     fprintf(fileID, formatSpec, DoseResp_30min(i,:));
% end
% fclose(fileID);




toc
end
