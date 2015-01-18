function [ r ] = moving_moment( v, k, w )

mfun = inline('sum( (x  - mean(x)).^m )','x','m') ;
r = slidefun(mfun,w,v,'',k) ;

end