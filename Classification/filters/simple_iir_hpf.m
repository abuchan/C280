function [ y ] = simple_iir_hpf( x, alpha )

y = zeros(size(x));
y(1) = x(1);

for i = 2:length(x)
    y(i) = alpha*( y(i-1) + x(i) - x(i-1) );
end

end

