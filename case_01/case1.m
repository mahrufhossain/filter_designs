pkg load signal
clc; clear; close all;

% Describing filter requirements
Fs = 2000;
fp = 150;
fs = 300;

% digital frequency normalized to Nuyquist range [0,1]
omega_p = fp/(Fs/2);
omega_s = fs/(Fs/2);
Rp = 0.5;
As = 50;

% Defining analog filter order proposed elliptic
[N, Wc] = ellipord(omega_p, omega_s, Rp, As);

% Designing the Elliptic filter
[b, a] = ellip(N, Rp, As, Wc);

% Direct form to cascaded form
[sos, g] = tf2sos(b, a);

% Finding frequency response

nfft = 2048;
[H, W] = freqz(b, a, nfft);
H_mag_db = 20*log10(abs(H));

figure;
plot(W/pi*(Fs/2), abs(H), 'k', 'LineWidth', 1.8);
grid on;
hold on;
%ylim([-100,1]);
title('Frequency Response');
xlabel('Frequency(Hz)');
ylabel('Magnitude');


% Print Result to console
fprintf('Calculated Order (N)   = %d\n', N);
fprintf('Cutoff Frequency = %dHz\n', Wc*(Fs/2));
disp('Direct Form Filter Coefficients');
disp('b=');
disp(b);
disp('a=');
disp(a);
disp('Cascaded Filter Coefficients(S0S), matrix of series second-order sections, one per row');
disp(sos);
disp('Filter Gain(g)');
disp(g);
