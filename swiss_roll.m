function [data,tt]=swiss_roll()
% GENERATE SAMPLED DATA
  N=500;
  tt = (3*pi/2)*(1+2*rand(1,N));  height = 21*rand(1,N);
  x = [tt.*cos(tt); height; tt.*sin(tt)]+50;
  data=x';
% SCATTERPLOT OF SAMPLED DATA
    scatter3(x(1,:),x(2,:),x(3,:),20,tt,'+');