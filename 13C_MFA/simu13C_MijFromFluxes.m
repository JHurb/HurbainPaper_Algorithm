function simu13C_MijFromFluxes()
dataname0='mcmc_basal_reorder';%mcmc_basal_reorder
data=dlmread(strcat(dataname0,'.dat'),' ',1,0);
Result=data(:,1:11);
save_file=1;


start=1;
finish=size(Result,1);

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

mij_vec_save=[1 9 11 8 6 5 2];%position des meta dans format mij_exp

if strfind(dataname0,'basal')==6
    mij_exp=mij_exp_ctrl;
    name='basal';
else
    mij_exp=mij_exp_stre;
    name='stress';
end

reverseStr='';

l=0;
mij_theo=zeros(size(mij_exp,1),size(mij_exp,2),size(Result,1));
mij_save=zeros((finish-start+1),numel(mij_exp));
for k = start:finish
    l=l+1;
    if mod(k,1)==0
        msg=sprintf('%d / %d loops',k,finish);
        fprintf([reverseStr,msg]);
        reverseStr=repmat(sprintf('\b'),1, length(msg));
    end
    
    
    %     Result=data(1,1:11);
    [~,mij,~]=simu13C_score(Result(k,:),mij_exp,1:4);
    mij_theo(:,:,k)=mij(:,(mij_vec_save-1)*3+(1:3)',end);
    mij_pre=mij(:,(mij_vec_save-1)*3+(1:3)',end)';
    mij_save(l,:)=mij_pre(:)';
    

end


if save_file ==1
    if (finish-start+1)==size(Result,1)
        dataname=['MIJdistri_' name '_full.dat'];
    else
        dataname=['MIJdistri_' name '_' num2str(start) '-' num2str(finish) '.dat'];
    end
    fileID = fopen(dataname,'w');
    fprintf(fileID, '%s %s %s %s %s %s %s %s %s %s %s %s\n','gpip','pfkp','aldp','tpip','g6pd','rpep','rpip','tkt1p','talp','tkt2p','tkt1m','score');
    formatSpec = [repmat('%f ',1,size(mij_save,2)-1),'%f\n'];
    for i=1:size(mij_save,1)
        fprintf(fileID, formatSpec, mij_save(i,:));
    end
    fclose(fileID);
end


fprintf('\n');
end

