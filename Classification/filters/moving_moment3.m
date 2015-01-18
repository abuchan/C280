function [ r ] = moving_moment3( v, w )

RMSfun = inline('nthroot(sum((abs(x).^3)-mean(abs(x))),3)','x') ;
r = (1/nthroot(w,3))*slidefun(RMSfun,w,v) ;

end
