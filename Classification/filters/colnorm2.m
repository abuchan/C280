function [ Scolnorm ] = colnorm2( S )
%COLNORM Column-wise 2-norm of a matrix
% 
Scolnorm = sqrt( sum( S.^2, 1 ) );

end

