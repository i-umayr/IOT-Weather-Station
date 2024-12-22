% Read data
readChannelID = 2792954;
tempData = thingSpeakRead(readChannelID, 'Field', 1, 'NumPoints', 30);
tempData = rmmissing(tempData);

% Prepare data for ML
X = (1:length(tempData))';
y = tempData;

% Simple linear regression (removed polynomial to avoid overfitting)
beta = X\y;

% Make predictions (only 3 steps ahead)
X_pred = (1:length(tempData)+3)';
predictions = X_pred * beta;

% Constrain predictions to realistic values
predictions = min(max(predictions, -10), 50);  % Between -10°C and 50°C

% Plot results
plot(X, y, 'bo-', 'LineWidth', 1);
hold on;
plot(X_pred, predictions, 'r--', 'LineWidth', 2);
title('Temperature Prediction (Linear Regression)');
xlabel('Time Points');
ylabel('Temperature (°C)');
legend('Actual', 'Predicted');
grid on;

% Add prediction metrics for actual data points only
rmse = sqrt(mean((y - X * beta).^2));
text(1, min(y), sprintf('RMSE: %.2f°C', rmse), 'FontSize', 10);