function [data,tt] = swiss_roll2(N)
% GENERATE SAMPLED DATA
R=rand(1,N);T=rand(1,N);
tt=(3*pi/2)*(1+2*R);height = 21*T;
R2=zeros(1,N);T2=zeros(1,N);
index=[];
for i=1:N
    if ((3*pi/2)*(1+2*R(i))>=(5*pi/2)) & ((3*pi/2)*(1+2*R(i))<=(8*pi/2)) & (21*T(i)>=7 & 21*T(i)<=12)
        index=[index i];
    end 
end
R(index)=[];T(index)=[];
tt=(3*pi/2)*(1+2*R);height=21*T;
x=[tt.*cos(tt);height;tt.*sin(tt)]+50;
data=x';
figure;
scatter3(x(1,:),x(2,:),x(3,:),90,tt,'.');
end

