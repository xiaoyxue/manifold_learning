function T=TangentSpace(data,options)

[nSmp,nFea] = size(data);
T=zeros(nFea,options.d,nSmp);
% Label = unique(options.gnd);
% nLabel = length(Label);
neighborhood=options.neighborhood;
options.ReducedDim=options.d;
for i=1:nSmp
    [eigvector,eigvalue]=PCA(data(neighborhood{i},:), options);
    T(:,:,i)=eigvector;
end
