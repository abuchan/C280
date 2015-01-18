function [ r ] = moving_rms( v, w )

RMSfun = inline('sqrt(sum(x.^2))','x') ;
r = sqrt((1/w))*slidefun(RMSfun,w,v) ;

end

