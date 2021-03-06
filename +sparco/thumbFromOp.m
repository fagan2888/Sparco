function P = thumbFromOp(op,m,n,sm,sn,grayscale)
% Output matrix P, of size m x n, sampled at
% sm x sn upper top

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: thumbFromOp.m 1027 2008-06-24 23:42:28Z ewout78 $

if nargin < 6, grayscale = 0; end
    
sm = min(op.m,sm);
sn = min(op.n,sn);
M  = zeros(sm,sn);

for i=1:sn
   v = zeros(op.n,1); v(i) = 1;
   w = real(op * v);

   M(:,i) = w(1:sm);
end

mn = min(min(M));
mx = max(max(M));
M  = (M - mn) / (mx-mn);

idxm = floor(linspace(1,sm+1,m+1)); idxm = idxm(1:end-1);
idxn = floor(linspace(1,sn+1,n+1)); idxn = idxn(1:end-1);

if grayscale
   P = 1-M(idxm,idxn);
else
   clrmap = hsv;
   M = 1 + round(M * (length(clrmap)-1));
   P = zeros(m,n,3);
   for j1=1:m
       for j2=1:n
           P(j1,j2,:) = clrmap(M(idxm(j1),idxn(j2)),:);
       end
   end
end
