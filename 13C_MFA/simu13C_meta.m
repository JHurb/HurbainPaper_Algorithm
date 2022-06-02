function [meta_pop,meta_nb]=simu13C_meta()
% Initialise meta matrix
nmeta=100;%100
% meta_names=[' G6P';'  PG';'Ru5P';' X5P';' R5P';' S7P';' E4P';' F6P';' FBP';'DHAP';' GAP'];
meta_sizepop=[6, 6, 5, 5, 5, 7, 4, 6, 6, 3, 3];

meta_pop=zeros(nmeta*2,max(meta_sizepop),length(meta_sizepop));
meta_nb=ones(1,length(meta_sizepop))*nmeta;
end
