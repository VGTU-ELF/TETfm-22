clc;

% Aproksimavimo intervalas:
x = 0.1:1/22:1;
fprintf("x:"); disp(x);

% Aproksimuojamoji funkcija (tikrosios vertės):
d = 5*sin(8*x) + 4*cos(16*x + pi/3);
fprintf("d:"); disp(d);

plot(x, d, 'kx'); grid;

% Pasirenku naudoti 4 neuronų paslėptąjį sl.

% Pradines koeficientų reikšmes imu atsitiktines:
w1_11_n0 = rand(1);  b1_1_n0  = rand(1);
w1_21_n0 = rand(1);  b1_2_n0  = rand(1);
w1_31_n0 = rand(1);  b1_3_n0  = rand(1);
w1_41_n0 = rand(1);  b1_4_n0  = rand(1);

% Skaičiuoju tinklo atsaką,
% visų paslėptųjų neuronų įėjimai:
v1(1) = x(1) * w1_11_n0 + b1_1_n0;
v2(1) = x(1) * w1_21_n0 + b1_2_n0;
v3(1) = x(1) * w1_31_n0 + b1_3_n0;
v4(1) = x(1) * w1_41_n0 + b1_4_n0;

%for i=1:length(x)
%    y1 = tanh(v1(i));
%end

fprintf("Pabaiga.\n");
