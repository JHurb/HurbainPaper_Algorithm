function simu13C_plotmij()
dataname0='MIJdistri_stress_full';%mcmc_basal_reorder
data=dlmread(strcat(dataname0,'.dat'),' ',1,0);
Result=data(:,:);

%%%%%%%%%%%%%%%%%%%%%%%%G6P%%%%%%%%%%%%%%FBP%%%%%%%%%%%%%%GAP%%%%%%%%%%%%%%F6P%%%%%%%%%%%%%%S7P%%%%%%%%%%%%%%R5P%%%%%%%%%%%%%%6PG%%%%%%%%
nbr_var=21;
mij_exp_ctrl=zeros(4,nbr_var);
mij_exp_ctrl(1,:)=[0.47,0.52,0.01,  0.48,0.49,0.02,  0.73,0.26,0.01,  0.62,0.36,0.02,  0.62,0.28,0.07,  0.65,0.22,0.12,  0.51,0.45,0.03];%  50% 1-13C
mij_exp_ctrl(2,:)=[0.47,0.52,0.01,  0.46,0.50,0.03,  0.73,0.25,0.01,  0.62,0.34,0.04,  0.44,0.30,0.19,  0.41,0.35,0.21,  0.45,0.49,0.05];%  50% 2-13C
mij_exp_ctrl(3,:)=[0.03,0.01,0.90,  0.06,0.02,0.81,  0.50,0.01,0.48,  0.08,0.05,0.76,  0.32,0.07,0.26,  0.07,0.39,0.14,  0.08,0.08,0.71];%  1,2-13C
mij_exp_ctrl(4,:)=[0.40,0.01,0.55,  0.43,0.02,0.48,  0.73,0.01,0.25,  0.41,0.03,0.50,  0.35,0.20,0.26,  0.45,0.26,0.17,  0.41,0.07,0.46];%  50% 1,2-12C

mij_exp_stre=zeros(4,nbr_var);
mij_exp_stre(1,:)=[0.47,0.52,0.01,  0.68,0.30,0.02,  0.85,0.12,0.00,  0.74,0.23,0.02,  0.90,0.09,0.01,  0.89,0.09,0.02,  0.57,0.40,0.02];%
mij_exp_stre(2,:)=[0.45,0.53,0.01,  0.50,0.41,0.07,  0.77,0.21,0.03,  0.64,0.29,0.05,  0.31,0.42,0.21,  0.45,0.45,0.09,  0.43,0.51,0.05];%
mij_exp_stre(3,:)=[0.03,0.01,0.88,  0.20,0.23,0.41,  0.66,0.14,0.19,  0.15,0.41,0.30,  0.07,0.24,0.50,  0.14,0.65,0.10,  0.04,0.11,0.76];%
mij_exp_stre(4,:)=[0.45,0.05,0.47,  0.62,0.11,0.23,  0.83,0.05,0.11,  0.56,0.15,0.24,  0.36,0.38,0.18,  0.55,0.33,0.09,  0.52,0.15,0.29];%


if contains(dataname0,'basal')
    mij_exp=mij_exp_ctrl;
else
    mij_exp=mij_exp_stre;
end

mij_theo=Result;

x=[-0.2;0;0.2]+(1:nbr_var/3);
x=x(:);
namevect=['   ';'G6P';'   ';'   ';'FBP';'   ';'   ';'GAP';'   ';'   ';'F6P';'   ';'   ';'S7P';'   ';'   ';'R5P';'   ';'   ';'6PG';'   '];


clf(figure(1))
figure(1)
for j =1:4
    subplot(2,2,j)
    hold on
    grid on
    
    b=boxplot((mij_theo(:,(1:nbr_var) +(j-1)*nbr_var)),'Position',x,'Widths',0.1,'colors',[[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.4660 0.6740 0.1880]], 'orientation', 'vertical', 'symbol', '');%,group(:)'
    set(b,{'linew'},{1});
    plot(x(:),mij_exp(j,:),'k*','LineWidth',2)
    
    
    set(gca,'xtick',x','xticklabel',namevect);
    xlim([0.5 21/3+0.5])
    
    ylim([-0.05 1.05])
    set(gca,'FontSize',16)
    
    if contains(dataname0,'basal')
        cond='Basal';
    else
        cond='Stress';
    end
    
    %     ylabel('Basal M^{}_{i,j}'
    if j ==1
        %         title('50% 1-13C');
        ylabel([cond ' M^{50% 1-13C}_{i,j}'])
    elseif j==2
        %         title('50% 2-13C');
        ylabel([cond ' M^{50% 2-13C}_{i,j}'])
    elseif j==3
        %         title('100% 1,2-13C');
        ylabel([cond ' M^{100% 1,2-13C}_{i,j}'])
    elseif j==4
        %         title('50% 1,2-13C');
        ylabel([cond ' M^{50% 1,2-13C}_{i,j}'])
    end
    
end

end


