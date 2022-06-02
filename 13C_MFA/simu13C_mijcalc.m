function mij=simu13C_mijcalc(pop,nb)
%Compute mij distribution for each metabolite

% mij_vec_save=[1 9 11 8 6 5 2];
nbC=[6, 6, 5, 5, 5, 7, 4, 6, 6, 3, 3];

mij_nbC=sum(pop,2);
mij_full=zeros(length(nbC),max(nbC)+1);
for i=1:length(nbC)
    mij_full(i,1:nbC(i)+1)=sum((mij_nbC(1:nb(i),:,i)==0:nbC(i)))/nb(i);
end

mij=mij_full(1:length(nbC),1:3);
mij=mij';%(mij_vec_save,:)
mij=mij(:)';
end
