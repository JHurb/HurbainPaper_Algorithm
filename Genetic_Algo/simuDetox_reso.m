function [t_out,x_out,flows_out]=simuDetox_reso(param,Fext)
%,te,ye,ie]
options=odeset('NonNegative',1:16,'RelTol',1e-4,'AbsTol',1e-4*ones(1,16),'MaxOrder',5);%,'Stats','on','MaxStep',0.5*abs(Fext.Tspan(1)-Fext.Tspan(2))
% 'Events',@MyEvent,
[t_out,x_out] = ode15s(@(t,x) simuDetox_eqlin(t,x,param,Fext),Fext.Tspan,Fext.IC,options);%,te,ye,ie
[~,flows_out]= cellfun(@(t,x)  simuDetox_eqlin(t,x,param,Fext), num2cell(t_out), num2cell(x_out,2),'uni',0);
flows_out=cell2mat(flows_out.');
flows_out=flows_out';
end



function [dxdt,flows]=simuDetox_eqlin(t,x,param,Fext)
%x = ( H, GSH, Nh, G6P, 6PGL, 6PG, Ru5P, X5P, R5P, S7P, E4P, Glc, F6P, FBP, DHAP, GAP)
%    (x1,  x2, x3,  x4,  x5,   x6,   x7,  x8,  x9, x10, x11, x12, x13, x14,  x15, x16)

%% Variable
H=x(1);GSH=x(2);NADPH=x(3);G6P=x(4);PGL=x(5);PG=x(6);Ru5P=x(7);X5P=x(8);R5P=x(9);
S7P=x(10);E4P=x(11);Glc=x(12);F6P=x(13);FBP=x(14);DHAP=x(15);GAP=x(16);



%% Param
param=10.^param;
%kgpx kshgpx ksggpx kgrx ksngrx ksggrx knad knadph Kinnh kg6pd
%   1      2      3    4      5      6    7      8     9    10
%Kig6pd kglase k6pgd Ki6pgd Ks6pgd krpe1 krpe2 krpi1 krpi2 ktkt11
%    11     12    13     14     15    16    17    18    19     20
%ktkt12 kstkt1 ktal1 ktal2 kstal ktkt21 ktkt22 kstkt2 khk Kihk
%    21     22    23    24    25     26     27     28  29   30
%kgpi1 kgpi2 Kigpi kpfk1 kfbp kald1 kald2 ktpi1 ktpi2 kox
%   31    32    33    34   35    36    37    38    39  40
%kdiff kcat kprpps Ksprpps kgapd Kigapd NADtot Gluttot
%   41   42     43      44    45     46     47      48
kgpx=param(1);kshgpx=param(2);ksggpx=param(3);kgrx=param(4);ksngrx=param(5);ksggrx=param(6);knad=param(7);knadph=param(8);Kinnh=param(9);kg6pd=param(10);
Kig6pd=param(11);kglase=param(12);k6pgd=param(13);Ki6pgd=param(14);Ks6pgd=param(15);krpe1=param(16);krpe2=param(17);krpi1=param(18);krpi2=param(19);ktkt11=param(20);
ktkt12=param(21);kstkt1=param(22);ktal1=param(23);ktal2=param(24);kstal=param(25);ktkt21=param(26);ktkt22=param(27);kstkt2=param(28);khk=param(29);Kihk=param(30);
kgpi1=param(31);kgpi2=param(32);Kigpi=param(33);kpfk1=param(34);kfbp=param(35);kald1=param(36);kald2=param(37);ktpi1=param(38);ktpi2=param(39);kox=param(40);
kdiff=param(41);kcat=param(42);kprpps=param(43);Ksprpps=param(44);kgapd=param(45);Kigapd=param(46);Ntot=param(47);GLtot=param(48);



%% FLow
gpx=kgpx/(kshgpx/H+ksggpx/GSH);
grx=kgrx/(1+ksngrx/NADPH+ksggrx/((GLtot-GSH)/2));
nnhp=knad*(Ntot-NADPH);
nnhm=knadph*NADPH./(1+H/Kinnh);%


g6pd=kg6pd*(Ntot-NADPH).*G6P./(1+NADPH/Kig6pd);% Kig6pd
pgd=k6pgd*(Ntot-NADPH).*PG./(1+NADPH/Ki6pgd+PG/Ks6pgd);% Ki6pgd
   

% if rupture==2
%     g6pd=kg6pd*(Ntot-NADPH).*G6P;
% else
%     g6pd=kg6pd*(Ntot-NADPH)./(1+NADPH/Kig6pd).*G6P;
% end
glcase=kglase*PGL;
% % pgd=k6pgd*(Ntot-NADPH).*PG./(1+PG/Ks6pgd+NADPH/Ki6pgd);%
% if rupture==3
%     pgd=k6pgd*(Ntot-NADPH).*PG./(1+PG/Ks6pgd);
% else
%     pgd=k6pgd*(Ntot-NADPH).*PG./(1+PG/Ks6pgd+NADPH/Ki6pgd);%
% end
%
% if rupture==4
%     g6pd=kg6pd*(Ntot-NADPH).*G6P;
%     pgd=k6pgd*(Ntot-NADPH).*PG./(1+NADPH/Ki6pgd);%
% else
%     g6pd=kg6pd*(Ntot-NADPH)./(1+NADPH/Kig6pd).*G6P;
%     pgd=k6pgd*(Ntot-NADPH).*PG./(1+PG/Ks6pgd+NADPH/Ki6pgd);%
% end

rpep=krpe1*Ru5P;
rpem=krpe1*X5P/krpe2;
rpip=krpi1*Ru5P;
rpim=krpi1*R5P/krpi2;

dentkt1=(1+(X5P.*R5P+S7P.*GAP)/kstkt1);
dental=(1+(S7P.*GAP+E4P.*F6P)/kstal);
dentkt2=(1+(X5P.*E4P+F6P.*GAP)/kstkt2);
tkt1p=ktkt11*R5P.*X5P;
tkt1m=ktkt11*GAP.*S7P/ktkt12;
% dentkt1=(1+(X5P.*R5P+S7P.*GAP)/kstkt1);
talp=ktal1*GAP.*S7P;
talm=ktal1*F6P.*E4P/ktal2;
% dental=(1+(S7P.*GAP+E4P.*F6P)/kstal);
tkt2p=ktkt21*E4P.*X5P;
tkt2m=ktkt21*F6P.*GAP/ktkt22;
% dentkt2=(1+(X5P.*E4P+F6P.*GAP)/kstkt2);


hk=khk*Glc./(1+G6P/Kihk);%
hkr=00.00000;

gpip=kgpi1*G6P./(1+PG/Kigpi);% rupture==4 Kigpi
gpim=kgpi1*F6P/kgpi2./(1+PG/Kigpi);


pfk1=kpfk1*F6P;
FBPs=kfbp*FBP;
aldp=kald1*FBP;
aldm=kald1*DHAP.*GAP/kald2;
tpip=ktpi1*DHAP;
tpim=ktpi1*GAP/ktpi2;
prpps=kprpps*R5P./(1+R5P/Ksprpps);

gapd=kgapd*GAP./(1+H/Kigapd);%rupture == 5 Kigapd


% interpolation I on the time t
% Fh2o2=interp1(Fext.IT,Fext.Fh2o2,t);
% Fglu=interp1(Fext.IT,Fext.Fgluv,t);
Fh2o2=Fext.Fh2o2(1);
Fglu=Fext.Fgluv(1);


Fh2o2v=kox+kdiff*(Fh2o2-H)-kcat*H;

%   1   2   3   4      5    6    7     8    9   10   11   12    13   14
%[gpx;grx;nnhp;nnhm;g6pd;glcase;pgd;rpep;rpem;rpip;rpim;tkt1p;tkt1m;talp;
%  15   16   17   18  19  20   21   22   23   24   25   26    27   28    29
%talm;tkt2p;tkt2m;hk;hkr;gpip;gpim;pfk1;FBPs;aldp;aldm;tpip;tpim;Fh2o2v;Fglu;
% 30    31
%prpps;gapd];
flows=[gpx;grx;nnhp;nnhm;g6pd;glcase;pgd;rpep;rpem;rpip;rpim;tkt1p./dentkt1;tkt1m./dentkt1;talp./dental;talm./dental;tkt2p./dentkt2;tkt2m./dentkt2;hk;hkr;gpip;gpim;pfk1;FBPs;aldp;aldm;tpip;tpim;Fh2o2v;Fglu;prpps;gapd];

%% Equations
dxdt = [Fh2o2v-gpx;... 1 h2o2
    2*grx-2*gpx;... 2 gsh
    g6pd+pgd+(nnhp-nnhm)-grx;... 3 nh
    (hk-hkr)-g6pd-(gpip-gpim);... 4 g6p
    g6pd-glcase;... 5 6pgl
    glcase-pgd;... 6 6pg
    pgd-(rpip-rpim)-(rpep-rpem);... 7 ru5p
    (rpep-rpem)-(tkt1p-tkt1m)./dentkt1-(tkt2p-tkt2m)./dentkt2;... 8 x5p
    (rpip-rpim)-(tkt1p-tkt1m)./dentkt1-prpps;... 9 r5p
    (tkt1p-tkt1m)./dentkt1-(talp-talm)./dental;... 10 s7p
    (talp-talm)./dental-(tkt2p-tkt2m)./dentkt2;... 11 e4p
    Fglu-(hk-hkr); ... 12 glc
    (gpip-gpim)-(pfk1-FBPs)+(talp-talm)./dental+(tkt2p-tkt2m)./dentkt2;... 13 f6p
    (pfk1-FBPs)-(aldp-aldm);... 14 fbp
    (aldp-aldm)-(tpip-tpim);... 15 dhap
    (aldp-aldm)+(tkt1p-tkt1m)./dentkt1-(talp-talm)./dental+(tkt2p-tkt2m)./dentkt2+(tpip-tpim)-gapd];% 16 gap

end


function [value,isterminal,direction]=MyEvent(~,x)
%avoid divergence ; limit [1e-3,1e4]
value=1-any(x<1e-4 | x>1e5);
% for i=1:length(x)
%     if (x(i)>1e-3) && (x(i)<1e4)
%         value=1;%;%
%     end
%     if value==0
%         break;
%     end
% end


if 3000-x(2)<1e-2 %GSSG limit
    value=0;
elseif 30-x(3)<1e-2 %NADP+ limit
    value=0;
end
isterminal = 1;   % Stop the integration
direction  = 0;

end