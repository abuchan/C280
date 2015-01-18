function [ y ] = simple_iir_lpf( x, alpha )

y = zeros(size(x));
y(1) = x(1);

for i = 2:length(x)
    y(i) = x(i) + alpha*y(i-1);
end

end

