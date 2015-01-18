function [ r ] = rms( x )

r = sqrt(sum(x.^2)/length(x));

end
