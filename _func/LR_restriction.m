function B = LR_restriction(phi, SIGMA, p)
% LR_RESTRICTION Imposes Blanchard-Quah (1989) long-run restrictions
% tailored to the King & Morley (2007) macro-labor framework.
%
% Variables:  \Delta x_t = [\Delta y_t, \Delta p_t, \Delta u_t]'
% Shocks:     \varepsilon_t = [\varepsilon_t^AS, \varepsilon_t^AD, \varepsilon_t^NRU]'
%
% Identification Restrictions on C(1):
%   1. AD shock has no long-run effect on output:       C_12(1) = 0
%   2. AD shock has no long-run effect on unemployment: C_32(1) = 0
%   3. NRU shock has no long-run effect on inflation:   C_23(1) = 0

N = size(phi, 2); % N = 3

% 1. Construct Companion Matrix
Companion = [phi(2:end, :)';
             eye(N*(p-1)), zeros(N*(p-1), N)];

% 2. Invert VAR lag polynomial at L = 1: C = [I - sum(A_i)]^(-1)
invC = eye(p*N) - Companion;
C_full = inv(invC);
C = C_full(1:N, 1:N);

% 3. Long-run Covariance Matrix
LR_cov = C * SIGMA * C';

% 4. Permutation Matrix to Triangularize KM2007 Restrictions
% Under variable order [u, y, p]:
% Shock 1 = NRU (affects u and y permanently, 0 on p)
% Shock 2 = AS  (affects y, 0 on u)
% Shock 3 = AD  (0 on u and y)
% P maps [y; p; u] -> [u; y; p]
P = [0 0 1;
     1 0 0;
     0 1 0];

% Permute long-run covariance, factorize, and un-permute
LR_cov_perm = P * LR_cov * P';
D_perm = chol(LR_cov_perm, 'lower');

% Map structural long-run multiplier back: C(1) = P' * D_perm * S_perm
% S_perm reorders shocks to [AS, AD, NRU]:
% Shock 1 = AS  (Col 2 of permuted system)
% Shock 2 = AD  (Col 3 of permuted system)
% Shock 3 = NRU (Col 1 of permuted system)
S_perm = [0 0 1;
          1 0 0;
          0 1 0];

C1 = P' * D_perm * S_perm;

% 5. Contemporaneous Structural Impact Matrix: B = C(0) = C^(-1) * C(1)
B = C \ C1;

% 6. Structural Sign Normalizations matching King & Morley (2007):
% AS Shock  (Col 1): Increases long-run output (C1(1,1) > 0)
if C1(1, 1) < 0
    B(:, 1)  = -B(:, 1);
    C1(:, 1) = -C1(:, 1);
end

% AD Shock  (Col 2): Increases contemporaneous output (B(1,2) > 0)
if B(1, 2) < 0
    B(:, 2)  = -B(:, 2);
    C1(:, 2) = -C1(:, 2);
end

% NRU Shock (Col 3): Increases long-run unemployment (C1(3,3) > 0)
if C1(3, 3) < 0
    B(:, 3)  = -B(:, 3);
    C1(:, 3) = -C1(:, 3);
end

end