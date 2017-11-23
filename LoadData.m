function [trainSet,testSet,trainLabel,testLabel,classNo,faceNo]=LoadData(Database,trainNo)
%--------train set,test set,trainlable,testlable

eval(['load ' 'DataBase\' Database '.mat']);
%          DataBase     -----选择数据库用于实验，参数选择为'ORL','Yale','YaleB' or 'PIE'
%          group        -----生成的随机标签，即随机选取不同的人脸用于训练，总共有50组;
%          type         -----数据加载的方式，参数包括：'Original','Scale','Normalize'.
%              'Original'    ----加载原始图像灰度值
%              'Scale'       ----将灰度值映射到[0,1]上
%              'Normalize'   ----对每张人脸进行归一化
%          Data_type    -----数据的构造方式,默认为随机选择,即 Data_type = 1;
%               0           -----数据是按类别大小选择
%               1           -----数据是类别的随机选择
% fea=XX;
% gnd=YY;
[nSmp,nFea] = size(fea);
showData(32,32,fea);
if (~exist('type','var'))
   type = 'Scale';
end
switch lower(type)
    case 'scale'
        maxValue = max(max(fea));                                 %除以最大值，将像素值映射到[0,1]上
        fea = fea/maxValue;
    case 'normalize'
        for i=1:nSmp
            fea(i,:) = fea(i,:) ./ max(1e-12,norm(fea(i,:)));     %防止除以0，进行向量归一化运算
        end
    case 'original';
    otherwise;
        error('请选取正确的数据加载方式！');
end
switch lower(Database(1:findstr(Database,'_')-1))%%ORL_32x32这种，寻找ORL
%     lower(faceMat(1:findstr(faceMat,'_')-1))
    case 'orl'
        classNo=40;faceNo=10;
    case 'yale'
         classNo=15;faceNo=11;
    case 'ar'
        classNo=120;faceNo=14;
    case 'yaleb'
        classNo=38;faceNo=64;
    case 'pie'
        classNo=68;faceNo=170;
    case 'feret'
        classNo=200;faceNo=7;

%  classNo -----选择的人脸数据库人数。ORL为40，Yale为15，YaleB为38，PIE为68
%  faceNo-----所选择的人脸数据库的每类人脸数.ORL为10,Yale为11,YaleB为64，PIE为170
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%选择训练集和测试集
trainIndex=[];testIndex=[];
for i=1:classNo  %%%对于每一类人脸都要去训练集和测试集
    r=rand(1,faceNo);%%%生成1*faceNo的矩阵
    [index,p]=sort(r);%%%index：是大小顺序的索引
    trainIndex=[trainIndex p(1:trainNo)+(i-1)*faceNo];
    testIndex=[testIndex p(trainNo+1:faceNo)+(i-1)*faceNo];
end
trainSet=fea(trainIndex,:);
testSet=fea(testIndex,:);
trainLabel=gnd(trainIndex);
testLabel=gnd(testIndex);
end