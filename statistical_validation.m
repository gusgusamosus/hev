%% statistical_validation.m
% Compares K-Means Clustered NREL vs WLTC

%% Load Real Trip Reference
optimized1 = readtable("C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\optimized_cycle.csv");
wltc = readtable("C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\wltc.csv");

% Create flat-line series for fair comparison
t = optimized1.time;


%% MAE vs Real Trip Average
opt_avg_speed = mean(optimized1.speed);
mae_speed_wltc = abs(opt_avg_speed - mean(wltc.speed));
fprintf('MAE vs WLTC (Speed): %.2f km/h\n', mae_speed_wltc);

%% Correlation Coefficients
speed_corr_wltc = corr(optimized1.speed, wltc.speed(1:length(t)), 'Rows', 'complete');
accel_corr_wltc = corr(optimized1.accel, wltc.accel(1:length(t)), 'Rows', 'complete');

fprintf('\nCorrelation with WLTC: Speed = %.2f | Accel = %.2f\n', speed_corr_wltc, accel_corr_wltc);

%% Boxplots for Energy
figure;
boxplot([optimized1.energy_density, wltc.energy_density(1:length(t))], ...
    'Labels', {'K-Means Clustered NREL','WLTC'});
ylabel('Rolling Energy Density (Wh/km)');
title('Energy Density Comparison (Boxplot)');

%% Histograms of Acceleration
figure;
histogram(optimized1.accel, 'FaceColor','r'); hold on;
histogram(wltc.accel, 'FaceColor','g');
legend('K-Means Clustered NREL', 'WLTC', 'Real Avg');
xlabel('Acceleration (m/s^2)');
title('Acceleration Distribution');

%% Regression Setup (Fuel Prediction)
inputs = {'speed', 'accel', 'energy_density'};

% K-Means Clustered NREL
opt_input = optimized1(:, inputs);
opt_target = optimized1.fuel;

% WLTC
wltc_input = wltc(:, inputs);
wltc_target = wltc.fuel;

%% Regression Models
fprintf('\n--- REGRESSION: WLTC ---\n');
mdl_wltc = fitlm(wltc_input, wltc_target);
fprintf('R²: %.2f\n', mdl_wltc.Rsquared.Ordinary);

fprintf('\n--- REGRESSION: K-Means Clustered NREL ---\n');
mdl_opt = fitlm(opt_input, opt_target);
fprintf('R²: %.2f\n', mdl_opt.Rsquared.Ordinary);

%% Predicted vs Actual Fuel
figure;
subplot(1,3,1);
plot(wltc_target, predict(mdl_wltc, wltc_input), 'go');
title('WLTC'); xlabel('Actual Fuel'); ylabel('Predicted'); grid on; refline(1,0);

subplot(1,3,2);
plot(opt_target, predict(mdl_opt, opt_input), 'ro');
title('K-Means Clustered NREL'); xlabel('Actual Fuel'); ylabel('Predicted'); grid on; refline(1,0);