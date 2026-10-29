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

% Coefficient quantization
factor = 13;
scale = 2^factor;

sos_quantized = round(sos * scale) / scale;

%Verifing quantization
[b_q, a_q] = sos2tf(sos_quantized, g);

% Finding frequency response
nfft = 2048;
[H, W] = freqz(b, a, nfft);
H_mag_db = 20*log10(abs(H));
H_phase = angle(H) / pi; 
[H_quant, ~] = freqz(b_q, a_q, nfft);
H_quant_mag_db = 20*log10(abs(H_quant));

% Plotting resposnes
figure;
subplot(221);
plot(W/pi*(Fs/2), H_mag_db, 'k', 'LineWidth', 1.8);
hold on;
plot(W/pi*(Fs/2), H_quant_mag_db, 'r:', 'LineWidth', 1.4);
grid on;
ylim([-100, 2]);
title('Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
legend('Original', 'Quantized');

subplot(222);
plot(W/pi*(Fs/2), abs(H), 'k', 'LineWidth', 1.8);
grid on;
title('Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude |H|');

subplot(223);
plot(W/pi*(Fs/2), H_mag_db, 'k', 'LineWidth', 1.8);
grid on;
ylim([-1, 0.5]);
xlim([0 180]);
title('Passband Ripple');
xlabel('Frequency(Hz)');
ylabel('Magnitude (dB)');

subplot(224);
plot(W/pi*(Fs/2), H_phase, 'k', 'LineWidth', 1.8);
grid on;
title('Phase Response @ Passband');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Normalized Phase \angleH ([-\pi, \pi])');
xlim([0 200]);

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
disp('Quantized Coefficients(Q2.13)');
disp(sos_quantized);
% Print quantized coefficients as integers (what you'll actually paste into C code)
disp('Integer values for C code (Q2.13 format):');
disp(round(sos * scale));

