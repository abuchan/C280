function mx = moving_max(v,w)
% Moving  maximum
% 
% max = movingmax(x,m)
%
% x is the timeseries.
% m is the window length.
% v is the variance.
%
% Ryan Julian 2011


% n=size(x,1);
% 
% mx = zeros(size(x));
% for i = 1:n
%     if i <= floor(m/2)
%         left = 1;
%     else
%         left = i - floor(m/2);
%     end
%     
%     if n - i < ceil(m/2)
%         right = n;
%     else
%         right = i + (ceil(m/2));
%     end
%     
%     mx(i) = max(x(left:right,:));
% end

MAXfun = inline('max(abs(x))','x') ;
mx = slidefun(MAXfun,w,v) ;
