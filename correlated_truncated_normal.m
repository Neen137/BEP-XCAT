function [Z] = correlated_truncated_normal(X,n,mu,sd,min, max,rho)
%creates a truncated normal sample of size n, with mean mu, standard
%deviation sd, min and max. Correlated with distribution X by correlation 
%coefficient rho

Y = TruncatedNormal(n, mu, sd, min, max);
A = normalize(X);
B = normalize(Y);
C = A*rho + sqrt(1 - (rho^2))*B;
Z = mu + C * sd;

end

