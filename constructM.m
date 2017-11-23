function M=constructM(data,options)
%M=W+W'-W*W',其中W是NPE中的权值矩阵
%     Input:
%          data         ----训练样本集，每行表示一副人脸;
%          options      ----MATLAB中的结构体,它的参数包括
%              'Mode'       ----包括非监督形式'KNN'和监督形式'Supervised',默认为'KNN'
%              'gnd'        ----训练数据所属类别标签，用在Mode为'Supervised'下，且必须提供
%              'k'          ----用在Mode为'KNN'下，选取的近邻个数，默认为5,不大于样本总个数
%     Output:
%          M            ----权值矩阵M，M_ij为x_i被除自己以为的近邻x_j最优重构的最小二乘解
%     Example:
%          DataBase='Yale';train_num=6;group=1;
%          [face_train,face_test,gnd_train,gnd_test]=loadData(DataBase,train_num,group,'Scale');
%          options=[];options.Mode='KNN';options.k=6;
%          W=constructW(face_train,options);
%     Written By 谭延琪，苏州大学计算机科学与技术学院, tyq0502@gmail.com    
%     2011/7/21
if (~exist('options','var'))
   options = [];
end
if (~isfield(options,'Mode'))
    options.Mode='KNN';
end
[nSmp, nFea] = size(data);
%直接采用EuDist2来求距离矩阵，data*data'可能会由与维度过大造成内存溢出
%若维度太大，采取分块的方法
maxM = 62500000; 
BlockSize = floor(maxM/(nSmp*5));
tol=1e-12;
switch options.Mode
    case 'KNN'
        if (~isfield(options,'k'))
            options.k=5;
        end
        if (options.k>nSmp||options.k==1)
            error('近邻数k未正确设置，应小于样本个数且大于1！');
        end
        if nSmp<BlockSize
            Dist=EuDist2(data);
            W=[];
            W=sparse(W);
            for i=1:nSmp
                max_temp=max(Dist(i,:));
                Dist(i,i)=max_temp+1;      %将x_i移去
                for j=1:options.k-1        %由于近邻K通常远小于nSmp，不用sort方法而采用find方法加速
                    idx=find(Dist(i,:)==min(Dist(i,:)));         %找到当前最小值
                    neighborhood(j)=idx(1);
                    Dist(i,idx(1))=max_temp+1+Dist(i,idx(1));    %将最小值增大
                end
                %注：下面的求最小二乘解的方法暂时也不是很懂，参照蔡登里NPE的写法写的，希望有人能把它弄清楚
                z=data(neighborhood,:)-repmat(data(i,:),options.k-1,1);
                C = z*z';
                C = C + eye(size(C))*tol*trace(C);                   % regularlization
                tW = C\ones(length(neighborhood),1);                           % solve Cw=1
                tW = tW/sum(tW);                  % enforce sum(w)=1
                W(neighborhood,i)=tW;
            end 
            clear Dist;
        else   %nSmp太大，采取分块的方法
            W=[];
            W=sparse(W);
            for i=1:ceil(nSmp/BlockSize)
                if i==ceil(nSmp/BlockSize)   %如果是最后一块，有可能没有BlockSize大小
                    smpIdx = (i-1)*BlockSize+1:nSmp;
                else
                    smpIdx = (i-1)*BlockSize+1:i*BlockSize;
                end
                dist=EuDist2(data,data(smpIdx,:));
                for j=1:size(dist,1)
                    max_temp=max(dist(j,:));
                    dist(j,j)=max_temp+1;
                    for ii=1:options.k-1
                        idx=find(dist(j,:)==min(dist(j,:)));
                        neighborhood(ii)=idx(1);
                        dist(j,idx(1))=max_temp+1+dist(j,idx(1));
                    end
                    z=data(neighborhood,:)-repmat(data((i-1)*BlockSize+j,:),options.k-1,1);
                    C = z*z';
                    C = C + eye(size(C))*tol*trace(C);                   % regularlization
                    tW = C\ones(length(neighborhood),1);                           % solve Cw=1
                    tW = tW/sum(tW);                  % enforce sum(w)=1
                    W(neighborhood,data((i-1)*BlockSize+j))=tW;
                end
            end
            clear dist;
        end
    case 'Supervised'
        W=[];
        W=sparse(W);
        if (~isfield(options,'gnd'))
            error('必须提供训练数据类别标签信息！');
        end
        classLabel=unique(options.gnd);
        nClass=length(classLabel);
        for i=1:nSmp
            idx=find(options.gnd==options.gnd(i));
            idx(find(idx==i)) = [];
            z = data(idx,:)-repmat(data(i,:),length(idx),1);
            C = z*z';
            C = C + eye(size(C))*tol*trace(C);
            tW = C\ones(length(idx),1);
            tW = tW/sum(tW);
            W(idx,i) = tW;
        end
    otherwise
        error('options.Mode未正确设置!');
end
M=W+W'-W*W';

%PS:  constructM中最终要的参数是options.k，k值的不同对性能影响比较大，根据本人
%     的实验经验，对于小规模数据库，k一般选值为每类训练样本的个数，例如对于Yale
%     库每类如果选择6个样本进行训练，那么k设置为6的识别性能比较好。如果大于大规
%     模数据库，如果采用NN分类器，k选择为2比较合适。里面的求最小二乘解的方法，自
%     己相当的懒就不研究了，尽管悲剧的是本人本科的专业就是弄这些的--信息与计算科
%     学，希望有专家能给他加上注解

%    Reference:
%        X.F. He, D. Cai, S.C. Yan, H.J. Zhang. Neighborhood preserving 
%        embedding [C]. IEEE International Conference on Computer Vision, 
%        2005, 2: 1208-1213.