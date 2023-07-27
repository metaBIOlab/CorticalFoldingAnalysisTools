function X = logspace(X1, X2, N)

X0 = X1 - 1;
X = X0 + 2.^(linspace(0, log(X2 - X0)/log(2), N));

end