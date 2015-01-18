function ma = moving_avg(x,m)
%ma = tsmovavg(x,'s',m,1);
ma = slidefun(inline('sum(x)/length(x)','x'), m, x);
