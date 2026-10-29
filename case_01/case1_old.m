pkg load signal
clc; clear; close all;

% Describing filter requirements
fs = 2;
omega_p = 0.15*pi;
omega_s = 0.3*pi;
Rp = 1;
As = 40;

% Performing frequency pre-warping
T = 1/fs;
Omega_p = 2/T * tan(omega_p/2);
Omega_s = 2/T * tan(omega_s/2);

% Defining analog filter order proposed elliptic
[N, Omega_c] = ellipord(Omega_p/pi, Omega_s/pi, Rp, As,'s');

% Designing the Elliptic filter
[b_analog, a_analog] = ellip(N, Rp, As, Omega_c,'s');

% Performing Billiniar Transformation
[b, a] = bilinear(b_analog, a_analog, 1/T);

% Direct form to cascaded form
[sos, g] = tf2sos(b, a);

% Finding frequency response
nfft = 2048;
[H, omega] = freqz(b, a, nfft);
H_mag_db = 20*log10(abs(H));

H_phase = angle(H) / pi; 

% Plotting resposnes
figure;
subplot(221);
plot(omega/pi, H_mag_db, 'k', 'LineWidth', 1.8);
grid on;
ylim([-100, 2]);
title('Frequency Response');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude (dB)');

subplot(222);
plot(omega/pi, abs(H), 'k', 'LineWidth', 1.8);
grid on;
title('Frequency Response');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude |H|');

subplot(223);
plot(omega/pi, H_mag_db, 'k', 'LineWidth', 1.8);
grid on;
ylim([-2, 1]);
xlim([0 0.2]);
title('Passband Ripple');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude (dB)');

subplot(224);
plot(omega/pi, H_phase, 'k', 'LineWidth', 1.8);
grid on;
title('Phase Response @ Passband');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Normalized Phase \angleH ([-\pi, \pi])');
xlim([0, 0.17]);


% Print Result to console
fprintf('Calculated Order (N)   = %d\n', N);
fprintf('Analog Cutoff Frequency = %.4f rad/s\n', Omega_c);
disp('Direct Form Filter Coefficients');
disp('b=');
disp(b);
disp('a=');
disp(a);
disp('Cascaded Filter Coefficients(S0S), matrix of series second-order sections, one per row');
disp(sos);
disp('Filter Gain(g)');
disp(g);