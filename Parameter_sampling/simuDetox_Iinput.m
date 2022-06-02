function param=simuDetox_Iinput(param,f,pente,Imax,ITime,tmax,nbpts,Tperiod,stress_noise,starting_stress)
 %tmax; temps total de la simulation
 %nbpts; nombre de points
 %ITime : bolus time
 
 
 %% time calibration 
if pente==0
    t_Imax=0;
else
    t_Imax=Imax/pente; %temps pour atteindre Imax selon la pente
end

if t_Imax>tmax 
    t_Imax=tmax;
end

%% curve
nbpts_Imax=floor(nbpts*t_Imax/tmax); %nbpts pour atteindre Imax

param.IT=linspace(0,tmax,nbpts);
param.(f)=zeros(1,nbpts);
nbpts2=nbpts;
if ITime<=tmax
    nbpts2=floor(ITime/tmax*nbpts);
end

for i=1:nbpts_Imax
    param.(f)(i)=i*pente/nbpts_Imax*t_Imax;
end
for i = 1:nbpts2-nbpts_Imax
    param.(f)(i+nbpts_Imax)=Imax;
end


%% periode
if Tperiod<=tmax && Tperiod~=0
    param.(f)=repmat(param.(f)(1:Tperiod/tmax*nbpts),1,floor(tmax/Tperiod)+1);
    param.(f)=param.(f)(1:nbpts);
%     param.(f)
end

%% noise
noiseI=(-1 + 2*rand(1,nbpts))*stress_noise/100; % random noise, max to stress_noise
param.(f)=param.(f)+param.(f).*noiseI;

%% starting point
param.(f)=[zeros(1,starting_stress/tmax*nbpts) param.(f)(1:nbpts-starting_stress/tmax*nbpts)];


param.Tspan=[0 tmax];

%% plot
%  figure(3)
%  plot(param.IT,param.(f))
% legend('I')
% grid on
% if Imax~=0
%     ylim([0 max(param.(f))*1.1])
% end
%  xlim([-0.01*tmax tmax]);

end
