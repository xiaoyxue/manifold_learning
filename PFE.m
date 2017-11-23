function Y=PFE(data,options)
[nSmp,nFea] = size(data);
T=zeros(nFea,options.d,nSmp);
% Label = unique(options.gnd);
% nLabel = length(Label);
W=zeros(nSmp,nSmp);
nei=zeros(nSmp,nSmp);
Nei=cell(1,nSmp);
Distance = EuDist2(data,[],0); 
[sorted,index] = sort(Distance,2);
neighborhood = index(:,2:(1+options.k));
for i=1:nSmp
    Nei{i}=neighborhood(i,:);
end
for idx=1:nSmp
   for j=1:size(Nei{idx},2)
       Nei{Nei{idx}(j)}=[Nei{Nei{idx}(j)} idx];
       nei(idx,Nei{idx}(j))=1;
       nei(Nei{idx}(j),idx)=1;
   end
end
for idx=1:nSmp
   Nei{idx}=unique(Nei{idx});
end
options.neighborhood=Nei;
T=TangentSpace(data,options);
A=zeros(options.d*nSmp,options.d*nSmp);
B=mat2cell(A,options.d*ones(1,nSmp),options.d*ones(1,nSmp));
for i=1:nSmp
    W(i,Nei{i})=1;
end
% for i=1:nSmp
%     for j=1:nSmp
%         if nei(i,j)==1
%              W(i,j)=1/norm(data(i,:)-data(j,:));
%         end
%     end
% end
for i=1:nSmp
    for j=1:size(Nei{i},2)
        jj=Nei{i}(j);
        Q=T(:,:,i)'*T(:,:,jj);
        B{i,i}=B{i,i}+W(i,jj)*(Q*Q'+eye(size(Q,1)));
    end
end
for i=1:nSmp
    for j=1:nSmp
        if nei(i,j)==1
            Q=T(:,:,i)'*T(:,:,j);
            B{i,j}=-2*W(i,j)*Q;
        end
    end
end
B=cell2mat(B);
[VV,VA]=eig(B);
VA = diag(VA);
[junk, index] = sort(VA);
VA = VA(index);
VV = VV(:,index);
VV =VV(:,1:options.d);
Vm=mat2cell(VV,options.d*ones(1,nSmp),ones(1,options.d));
Y=[];
for i=1:options.d
    L=zeros(nSmp,nSmp);
    c=zeros(nSmp,1);
    for j=1:nSmp
        Vx=T(:,:,j)*Vm{j,i};
        Vx=Vx/norm(Vx);
        for k=1:size(Nei{j},2)
            s=zeros(nSmp,1);
            s(j)=-1;
            s(Nei{j}(k))=1;
            L=L+W(j,Nei{j}(k))*s*s';
            c=c+W(j,Nei{j}(k))*s*(data(Nei{j}(k),:)-data(j,:))*T(:,:,j)*T(:,:,j)'*Vx;
        end
    end
    i
    rank(L)
    L=[L;zeros(1,nSmp)];
    c=[c;0];
    y=L\c;
    Y=[Y y];
end
end


