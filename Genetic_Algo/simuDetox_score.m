function [score_test]=simuDetox_score(param)
% Test param, return score value from param vector
% tic

%1 = on ; 0 = off
secondrun=1; %to apply stress 
plot_var=0; %to plot variable temporal variation
plot_speed=0; %to plot flow temporal variation

tmaxv=[100000 300]; %time for each simu
nbptsv=[10000 1000]; %nb of points for each simu

Fglu=40;%glucose flow (uM)
penteIv=[0.0 0.0;0.0 0.0]; %stress slope microM/s
Imaxv=[0.00 500;Fglu Fglu]; %maximum value of stress
ITimev=[tmaxv(1) tmaxv(2);tmaxv(1) tmaxv(2)]; % bolus time
Tperiodv=[tmaxv(1) tmaxv(2);tmaxv(1) tmaxv(2)]; % repetition time (>=tmax = off)
stress_noisev=[0 0;0 0]; % percentage of max noise (0% = off), module noise freq with nbpts
starting_stress=[0 0;0 0]; % starting point of stress

%% Concentrations Ratio data at 5min
%( H, GSH, Nh, G6P, 6PGL, 6PG, Ru5P, X5P, R5P, S7P, E4P, Glc, F6P, F26P2, F16P2, DHAP, GAP)
R_H=1;R_GSH=-0.5;R_NH=-0.5; R_G6P=0.52; R_6PGL=1; R_6PG=4.2;
R_Ru5P=4.33; R_X5P=5.01; R_R5P=3.89; R_S7P=3.45; R_E4P=2;
R_GLC=1; R_F6P=-0.09; R_FBP=0.24; R_DHAP=1.89; R_GAP=2;
conc_ratio=[R_H R_GSH R_NH R_G6P R_6PGL R_6PG R_Ru5P R_X5P R_R5P R_S7P R_E4P R_GLC R_F6P R_FBP R_DHAP R_GAP];



%% Concentrations Basales
Gltot=10^param(48);
Ntot=10^param(47);
% H=0.01;
% Ratio_GL=599;%180
% GSH=Ratio_GL*Gltot/(2+Ratio_GL);
% Ratio_N=6.5;
% NH=Ratio_N*Ntot/(1+Ratio_N);
% G6P=100;PGL=300;PG=300;Ru5P=20;X5P=20;R5P=20;S7P=20;E4P=20;
% F6P=25;FBP=25;DHAP=50;GAP=25;GLC=4000;

%% Flows data at 10min
%   1   2   3   4      5    6    7     8    9   10   11   12    13   14
%[gpx;grx;nnhp;nnhm;g6pd;glcase;pgd;rpep;rpem;rpip;rpim;tkt1p;tkt1m;talp;
%  15   16   17   18  19  20   21   22   23   24   25   26    27   28    29
%talm;tkt2p;tkt2m;hk;hkr;gpip;gpim;pfk1;FBPs;aldp;aldm;tpip;tpim;Fh2o2v;Fglu;
% 30    31
%prpps;gapd];
flow_vect_index=[5 15 17 30 31];%+tkt +gpi(21)

Result_13C_mean=[0.2275,1.4612,1.2986,1.2986,1.0121,0.0988,0.1721,0.5529,1.3094,0.1705,1.6401,0.01902,1.3922;... %basal mean 13C result
    0.9484,0.4301,1.1549,1.1549,0.7983,0.5827,0.041,1.309,1.4953,0.6556,0.5912,0.0976,1.1100];% stress mean 13C result
Result_13C_var=[0.0593,0.3892,0.4684,0.4684,0.4807,0.0808,0.1001,0.4000,0.5030,0.1180,0.2100,0.0306,0.0485;...,%basal var 13C result
   0.0613,0.1177,0.5508,0.5508,0.5452,0.3280,0.0521,0.4473,0.3472,0.1386,0.2362,0.0465,0.0439];% stress var 13C result
%             ppp talm tkt2m prpps gapd tkt gpi-
scored_result_basal=[1 7 6 10 11 12];
scored_result_stress=[scored_result_basal 2];

flow_vect_basal=Result_13C_mean(1,scored_result_basal);
flow_vect_basal_error=Result_13C_var(1,scored_result_basal);
flow_vect_stress=Result_13C_mean(2,scored_result_stress);
flow_vect_stress_error=Result_13C_var(2,scored_result_stress);

flow_vect=[flow_vect_basal flow_vect_stress];
flow_vect_error=[flow_vect_basal_error flow_vect_stress_error];



%% Simulation
Fext=[];
Fext.IC=[ 1 2950 26 1 1 1 1 1 1 1 1 1 1 1 1 1];%Initiale condition %;[H GSH NH G6P PGL PG Ru5P X5P R5P S7P E4P GLC F6P FBP DHAP GAP];
Fext.IT=[];
Fext.Tspan=[];
Fext=simuDetox_Iinput(Fext, 'Fh2o2', penteIv(1,1), Imaxv(1,1),ITimev(1,1), tmaxv(1), nbptsv(1),Tperiodv(1,1),stress_noisev(1,1),starting_stress(1,1)); %Stress shape
Fext=simuDetox_Iinput(Fext, 'Fgluv', penteIv(2,1), Imaxv(2,1),ITimev(2,1), tmaxv(1), nbptsv(1),Tperiodv(2,1),stress_noisev(2,1),starting_stress(2,1)); %Glucose flow shape


% Basal Run
[t1,x1,f1]=simuDetox_reso(param,Fext);


xf=x1;
tf=t1;
ff=f1;
f1b=[f1(:,flow_vect_index) f1(:,12)-f1(:,13)];
tmax=tmaxv(1);

gpx=f1(end,1);grx=f1(end,2);nnhp=f1(end,3);nnhm=f1(end,4);g6pd=f1(end,5);glcase=f1(end,6);pgd=f1(end,7);rpep=f1(end,8);rpem=f1(end,9);rpip=f1(end,10);rpim=f1(end,11);tkt1p=f1(end,12);tkt1m=f1(end,13);talp=f1(end,14);
talm=f1(end,15);tkt2p=f1(end,16);tkt2m=f1(end,17);hk=f1(end,18);hkr=f1(end,19);gpip=f1(end,20);gpim=f1(end,21);pfk1=f1(end,22);FBPs=f1(end,23);aldp=f1(end,24);aldm=f1(end,25);tpip=f1(end,26);tpim=f1(end,27);Fh2o2v=f1(end,28);Fgluv=f1(end,29);prpps=f1(end,30);gapd=f1(end,31);
    
dxdt=[Fh2o2v-gpx;... 1 h2o2
    2*grx-2*gpx;... 2 gsh
    g6pd+pgd+(nnhp-nnhm)-grx;... 3 nh
    (hk-hkr)-g6pd-(gpip-gpim);... 4 g6p
    g6pd-glcase;... 5 6pgl
    glcase-pgd;... 6 6pg
    pgd-(rpip-rpim)-(rpep-rpem);... 7 ru5p
    (rpep-rpem)-(tkt1p-tkt1m)-(tkt2p-tkt2m);... 8 x5p
    (rpip-rpim)-(tkt1p-tkt1m)-prpps;... 9 r5p
    (tkt1p-tkt1m)-(talp-talm);... 10 s7p
    (talp-talm)-(tkt2p-tkt2m);... 11 e4p
    Fgluv-(hk-hkr); ... 12 glc
    (gpip-gpim)-(pfk1-FBPs)+(talp-talm)+(tkt2p-tkt2m);... 13 f6p
    (pfk1-FBPs)-(aldp-aldm);... 14 fbp
    (aldp-aldm)-(tpip-tpim);... 15 dhap
    (aldp-aldm)+(tkt1p-tkt1m)-(talp-talm)+(tkt2p-tkt2m)+(tpip-tpim)-gapd];



%Input fonction of Fh2o2 and Fgluv
% Fext.IC=x1(end,:);

cond_vect=[x1(end,:) (Ntot-Fext.IC(3)) (Gltot-Fext.IC(2))]; % IC after basal run

if sum(cond_vect>1e-4)/(length(Fext.IC)+2)==1 && sum(cond_vect<1e4)/(length(Fext.IC)+2)==1 && sum(abs(f1(size(f1,1),:))<1e5)/length(f1(size(f1,1),:))==1 && (sum(dxdt<1e-4)/length(dxdt))==1 % && sum(f1(size(f1,1),:)>1e-4)/length(f1)==1
    %% 2e run for Stress
    if secondrun==1
        Fext.IC=x1(end,:);
        Fext.IT=[];% vecteur time
        Fext.Tspan=[];% Tspan for ode
        Fext=simuDetox_Iinput(Fext, 'Fh2o2', penteIv(1,2), Imaxv(1,2),ITimev(1,2), tmaxv(2), nbptsv(2),Tperiodv(1,2),stress_noisev(1,2),starting_stress(1,2));
        Fext=simuDetox_Iinput(Fext, 'Fgluv',penteIv(2,2), Imaxv(2,2),ITimev(2,2), tmaxv(2), nbptsv(2),Tperiodv(2,2),stress_noisev(2,2),starting_stress(2,2));
        
        
        %Stress run
        [t2,x2,f2]=simuDetox_reso(param,Fext);
        
        
        tf=[(t1-tmaxv(1));t2];
        xf=[x1;x2];
        ff=[f1;f2];
        f2b=[f2(:,flow_vect_index) f2(:,12)-f2(:,13) f2(:,21)];
        
%         Hmax=max(x2(:,1));
        x_steady=[x1(end,:);x2(end,:)];
        f_steady=[f1(end,:);f2(end,:)];
%         x_steady=zeros(2,size(x2,2));
        f_steadyb=[f1b(end,:),f2b(end,:)];
        f_5min=zeros(2,size(f2,2));
        
%         for j=1:size(x2,2) % basal SS + stress 10min
%             x_steady(:,j)=[x1(size(x1,1),j);interp1(t2,x2(:,j),300)];
%         end
        
        
        f_steady_time=300;%5min
        f_5min(1,:)=f_steady(1,:);
        for j=1:size(f2,2)% basal SS + stress 5min
            f_5min(2,j)=interp1(t2,f2(:,j),f_steady_time);
        end
        
        tmax=tmaxv(2);
        
    end
    
    %% PLot
    if plot_var == 1 || plot_speed==1
        varvect=[' H2O2';'  GSH';'NADPH';'  G6P';' 6PGL';'  6PG';' Ru5P';'  X5P';'  R5P';'  S7P';'  E4P';'  Glc';'  F6P';'  FBP';' DHAP';'  GAP';]; % length 5
        flowsvect=['   Fgpx';'   Fgrx';'   Fnnh';' Fg6pdh';'Fglcase';'  F6pgd';'   Frpe';'   Frpi';'  Ftkt1';'   Ftal';'  Ftkt2';'    Fhk';'   Fpgi';'   Fpfk';'   Fald';'   Ftpi';'  Fh2o2';'   Fglu';' Fprpps';' Fgapdh']; %length 7
        ff2=[ff(:,1:2) ff(:,3)-ff(:,4) ff(:,5:7) ff(:,8)-ff(:,9) ff(:,10)-ff(:,11) ff(:,12)-ff(:,13) ff(:,14)-ff(:,15) ff(:,16)-ff(:,17) ff(:,18)-ff(:,19) ff(:,20)-ff(:,21) ff(:,22)-ff(:,23) ff(:,24)-ff(:,25) ff(:,26)-ff(:,27) ff(:,28:end)];  
        simuDetox_plot(tf,xf,ff2,plot_var,plot_speed,varvect,flowsvect,tmax)
    end
    
    %% Calculation of Score
    %  flows=[gpx;grx;nnhp;nnhm;g6pd;glcase;pgd;rpep;rpem;rpip;rpim;tkt1p./dentkt1;tkt1m./dentkt1;talp./dental;talm./dental;tkt2p./dentkt2;tkt2m./dentkt2;hk;hkr;gpip;gpim;pfk1;FBPs;aldp;aldm;tpip;tpim;Fh2o2v;Fglu;prpps;gapd];

    %   1   2   3   4      5    6    7     8    9   10   11   12    13   14
    %[gpx;grx;nnhp;nnhm;g6pd;glcase;pgd;rpep;rpem;rpip;rpim;tkt1p;tkt1m;talp;
    %  15   16   17   18  19  20   21   22   23   24   25   26    27   28    29
    %talm;tkt2p;tkt2m;hk;hkr;gpip;gpim;pfk1;FBPs;aldp;aldm;tpip;tpim;Fh2o2v;Fglu;
    % 30    31
    %prpps;gapd];
    
    if t2(length(t2))>=300
        gpx=f_5min(:,1);grx=f_5min(:,2);nnhp=f_5min(:,3);nnhm=f_5min(:,4);g6pd=f_5min(:,5);glcase=f_5min(:,6);pgd=f_5min(:,7);rpep=f_5min(:,8);rpem=f_5min(:,9);rpip=f_5min(:,10);rpim=f_5min(:,11);tkt1p=f_5min(:,12);tkt1m=f_5min(:,13);talp=f_5min(:,14);
        talm=f_5min(:,15);tkt2p=f_5min(:,16);tkt2m=f_5min(:,17);hk=f_5min(:,18);hkr=f_5min(:,19);gpip=f_5min(:,20);gpim=f_5min(:,21);pfk1=f_5min(:,22);FBPs=f_5min(:,23);aldp=f_5min(:,24);aldm=f_5min(:,25);tpip=f_5min(:,26);tpim=f_5min(:,27);Fh2o2v=f_5min(:,28);Fgluv=f_5min(:,29);prpps=f_5min(:,30);gapd=f_5min(:,31);
    
        dxdt=[Fh2o2v-gpx;... 1 h2o2
            2*grx-2*gpx;... 2 gsh
            g6pd+pgd+(nnhp-nnhm)-grx;... 3 nh
            (hk-hkr)-g6pd-(gpip-gpim);... 4 g6p
            g6pd-glcase;... 5 6pgl
            glcase-pgd;... 6 6pg
            pgd-(rpip-rpim)-(rpep-rpem);... 7 ru5p
            (rpep-rpem)-(tkt1p-tkt1m)-(tkt2p-tkt2m);... 8 x5p
            (rpip-rpim)-(tkt1p-tkt1m)-prpps;... 9 r5p
            (tkt1p-tkt1m)-(talp-talm);... 10 s7p
            (talp-talm)-(tkt2p-tkt2m);... 11 e4p
            Fgluv-(hk-hkr); ... 12 glc
            (gpip-gpim)-(pfk1-FBPs)+(talp-talm)+(tkt2p-tkt2m);... 13 f6p
            (pfk1-FBPs)-(aldp-aldm);... 14 fbp
            (aldp-aldm)-(tpip-tpim);... 15 dhap
            (aldp-aldm)+(tkt1p-tkt1m)-(talp-talm)+(tkt2p-tkt2m)+(tpip-tpim)-gapd];
%         [f_5min(:,28)-f_5min(:,1),... 1 h2o2
%             2*f_5min(:,2)-2*f_5min(:,1),... 2 gsh
%             f_5min(:,5)+f_5min(:,7)+(f_5min(:,3)-f_5min(:,4))-f_5min(:,2),... 3 nh
%             f_5min(:,18)-f_5min(:,5)-(f_5min(:,20)-f_5min(:,21)),... 4 g6p
%             f_5min(:,5)-f_5min(:,6),... 5 6pgl
%             f_5min(:,6)-f_5min(:,7),... 6 6pg
%             f_5min(:,7)-(f_5min(:,10)-f_5min(:,11))-(f_5min(:,8)-f_5min(:,9)),... 7 ru5p
%             (f_5min(:,8)-f_5min(:,9))-(f_5min(:,12)-f_5min(:,13))-(f_5min(:,16)-f_5min(:,17)),... 8 x5p
%             (f_5min(:,10)-f_5min(:,11))-(f_5min(:,12)-f_5min(:,13))-f_5min(:,30),... 9 r5p
%             (f_5min(:,12)-f_5min(:,13))-(f_5min(:,14)-f_5min(:,15)),... 10 s7p
%             (f_5min(:,14)-f_5min(:,15))-(f_5min(:,16)-f_5min(:,17)),... 11 e4p
%             f_5min(:,29)-f_5min(:,18), ... 12 glc
%             (f_5min(:,20)-f_5min(:,21))-(f_5min(:,22)-f_5min(:,23))+(f_5min(:,14)-f_5min(:,15))+(f_5min(:,16)-f_5min(:,17)),... 13 f6p
%             (f_5min(:,22)-f_5min(:,23))-(f_5min(:,24)-f_5min(:,25)),... 15 fbp
%             (f_5min(:,24)-f_5min(:,25))-(f_5min(:,26)-f_5min(:,27)),... 16 dhap
%             (f_5min(:,24)-f_5min(:,25))+(f_5min(:,12)-f_5min(:,13))-(f_5min(:,14)-f_5min(:,15))+(f_5min(:,16)-f_5min(:,17))+(f_5min(:,26)-f_5min(:,27))-f_5min(:,31)]; %17 gap
        
        
        %%%%%%%%%%%%%%%%%%%%%%
        
        %% Delta
        
        % score weighted by error
        
        %Concentration
        delta_ratio_vect=[2:4 6:10 13:15];%Ratio in Kuehne 2015
        delta_ratio_N=numel(delta_ratio_vect)+1;
        delta_ratio_error=ones(1,delta_ratio_N);
        
        delta_ratio=zeros(1,delta_ratio_N);
        delta_ratio(1:delta_ratio_N-1)=((log2(x_steady(2,delta_ratio_vect)./x_steady(1,delta_ratio_vect))-conc_ratio(delta_ratio_vect))./delta_ratio_error(1:end-1)).^2;
        delta_ratio(end)=((log2((Gltot-x_steady(2,2))/(Gltot-x_steady(1,2)))-(1.5))/delta_ratio_error(end))^2;%Ratio GSSG
        
        %Flow
        % fb + gpim        
        delta_flow_N=numel(f_steadyb);%flow at 10min from 13C MFA
        delta_flow=((f_steadyb./Fglu-flow_vect)./flow_vect_error).^2;
        
        
        %Score total
        delta_details=[delta_ratio,delta_flow]/(delta_flow_N+delta_ratio_N);
        
        score_test=sqrt(sum(delta_details));
        
        %%%%%%%%%%%%%%%%%%%%%%
        
        %SteadyState
        delta_dxdt=sum(sum(abs(dxdt')).^2)/2;
        delta_dxdt=sqrt(delta_dxdt);
        
        %Var borne
%         vect_borne=[5 7:11 13:16];
%         delta_borne=sum(x2(:,vect_borne)<1,'all')+sum((x2(:,vect_borne)>700),'all');
%         delta_borne=sqrt(delta_borne/length(vect_borne));

        
%         H2O2_s<50 et GSH_S<2500
        
        if x_steady(2,1)<50 || x_steady(2,2)<2500
            score_test=1e5;
        end
        if delta_dxdt>1e-4
            score_test=1e5;
        end
        
        
%         GSH_ratio=(log2(x_steady(2,2)./x_steady(1,2)));
%         if delta_dxdt>1e-4 || delta_borne>0 % if no SS or out of bound 
%             score_test=1e5;
%         elseif x_steady(2,1)>50 || GSH_ratio>-0.4 || Hmax/x_steady(2,1)<1.3
%             %if h2o2|s > 50uM or log2(GSH|s/GSH|b)<0.5
%             score_test=1e5;
%         end
        
    else % if simulation is not long enough
        score_test=1e5;
    end
else % if bad IC
    score_test=1e5;
end
 
% toc
end