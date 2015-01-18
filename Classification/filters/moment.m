function [ r ] = moment( x, k )

r = sum( (x  - mean(x)).^k );
%r = (1/length(x))*sum( x.^k );
end