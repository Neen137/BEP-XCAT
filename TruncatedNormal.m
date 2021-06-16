function samples = TruncatedNormal(n, mu,sigma, lower, upper)
% Truncated normal distribution for generating samples
%   Detailed explanation goes here
pd = makedist('Normal','mu',mu,'sigma',sigma);
t = truncate(pd,lower,upper);
samples = random(t,1,n);
end

