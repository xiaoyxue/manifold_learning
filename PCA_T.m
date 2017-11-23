function [eigvector, eigvalue, meanData, elapse] = PCA_T(data, options)
%主成分分析(Principal Component Analysis, PCA)
%     Input:
%          data         ----训练样本集，每行表示一副人脸;
%          options      ----MATLAB中的结构体,主成分保留的维数
%              'PCARatio'   ----保留的主成分所占能量，默认为1.
%                               当为(0,1]时，表示保留的特征值占原始特征值的比重
%                               当大于1时，表示保留的维数，最大不超过原始特征值维数
%     Output:
%          eigvector    ----特征向量;
%          eigvalue     ----特征值
%          elapse       ----PCA训练耗费时间;
%     Example:
%          DataBase='Yale';train_num=6;group=1;
%          [face_train,face_test,gnd_train,gnd_test]=loadData(DataBase,train_num,group,'Scale');
%          options=[];options.PCARatio=0.9;
%          [eigvector, eigvalue]=PCA(face_train,options);
%     Written By 谭延琪，苏州大学计算机科学与技术学院, tyq0502@gmail.com    
%     2011/7/21
time_temp=cputime;
[nSmp,nFea] = size(data);
if (~exist('options','var'))
   options = [];
end
if (~isfield(options,'PCARatio'))
    options.PCARatio=1;
end

ReducedDim=nFea;
if options.PCARatio>1
    ReducedDim = options.PCARatio;
end
meanData = mean(data);
data = data - repmat(meanData,nSmp,1);
if nFea/nSmp > 1.0713
    %%% 当人脸图像的维数大于人脸个数时，先求取data*data'的特征向量，再将其转回data'*data的特征向量
    ddata = data*data';
    dimMatrix = size(ddata,2);
    if dimMatrix > 1000 && ReducedDim < dimMatrix/10
        %%% 当协方差矩阵维数过大且保留的主成分明显少于维数，采用MATLAB中的eigs快速进行特征分解
        option = struct('disp',0);
        [eigvector, eigvalue] = eigs(ddata,ReducedDim,'la',option);
        eigvalue = diag(eigvalue);
    else
        [eigvector, eigvalue] = eig(ddata);
        eigvalue = diag(eigvalue);
        [junk, index] = sort(-eigvalue);         %eig分解从小到大排列，将其转为从大到小排列
        eigvalue = eigvalue(index);
        eigvector = eigvector(:, index);
    end
    clear ddata;
    eigvector = data'*eigvector;   %转回求data'*data的特征向量
    eigvector = eigvector*diag(1./(sum(eigvector.^2).^0.5));   %对特征向量进行归一化
else
    %%% 直接求取data'*data的特征向量
    ddata = data'*data;
    ddata = max(ddata, ddata');
    dimMatrix = size(ddata,2);
    if dimMatrix > 1000 && ReducedDim < dimMatrix/10
        %%% 当协方差矩阵维数过大且保留的主成分明显少于维数，采用MATLAB中的eigs快速进行特征分解
        option = struct('disp',0);
        [eigvector, eigvalue] = eigs(ddata,ReducedDim,'la',option);
        eigvalue = diag(eigvalue);
    else
        [eigvector, eigvalue] = eig(ddata);
        eigvalue = diag(eigvalue);
        [junk, index] = sort(-eigvalue);
        eigvalue = eigvalue(index);
        eigvector = eigvector(:, index);
    end
    clear ddata;
    eigvector = eigvector*diag(1./(sum(eigvector.^2).^0.5)); 
end

if options.PCARatio>1
    ReducedDim = options.PCARatio;
    if ReducedDim < length(eigvalue)
        eigvalue = eigvalue(1:ReducedDim);
        eigvector = eigvector(:, 1:ReducedDim);
    end
else
    eigIdx = find(eigvalue < 1e-10);
    eigvalue (eigIdx) = [];
    eigvector(:,eigIdx) = [];
    sumEig = sum(eigvalue);
    sumEig = sumEig*options.PCARatio;
    sumNow = 0;
    for idx = 1:length(eigvalue)
        sumNow = sumNow + eigvalue(idx);
        if sumNow >= sumEig
            break;
        end
    end
    eigvector = eigvector(:,1:idx);
    eigvalue=eigvalue(1:idx);
end 
elapse=cputime-time_temp;

%PS:  人脸识别领域的双子星之一，需要指出的是PCA最先并不是用在人脸识别领域的，它
%     为什么这么出名，是人脸识别用了它之后，开创了一个新世界，所以它有了令一个名
%     字：盘古（玩笑）。PCA耳熟能详，自己也不做过多介绍，指出两点：第一，那个用
%     data*data'代替求data'*data的特征向量方法一定要多加注意，由于经常性的遭遇
%     样本维数远大于样本个数，所以使用它的人渐渐都快忘了它的原始形式，在特定情况
%     下，当样本个数大于样本维数时就不需要再绕弯了，直接求data'*data的特征分解；
%     第二，均值向量，在很多PCA代码中，可能许多都没有减去均值，这是因为大部分最后
%     分类都是以欧氏距离为标准，所以减不减去均值对性能没有影响，同学们可以自己试
%     验一下，不过需要注意，如果你用PCA分类时，训练样本如果减去均值以后再投影，
%     测试样本也应该相应的减去均值再投影，如果一开始，训练样本并没有减去均值就进
%     行投影，那么测试样本也不需要减去均值。

%    Reference:
%        M.A. Turk, A.P. Pentland. Eigenface for recognition [J]. Cognitive 
%        Neuroscience, 1991, 3(1): 71-86.