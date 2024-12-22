% Read temperature data
readChannelID = 2792954;
tempData = thingSpeakRead(readChannelID, 'Field', 1, 'NumPoints', 30);
tempData = rmmissing(tempData);

% Calculate trend
X = (1:length(tempData))';
trend = X\tempData;

% Make short-term predictions (3 steps ahead)
num_pred = 3;
future_points = (length(tempData)+1):(length(tempData)+num_pred);
predictions = trend * future_points';

% Constrain predictions to realistic values
predictions = min(max(predictions, tempData(end)-5), tempData(end)+5);

% Plot results
plot(tempData, 'b-', 'LineWidth', 2);
hold on;
plot(future_points, predictions, 'r--', 'LineWidth', 2);
title('Temperature Forecast');
xlabel('Time Points');
ylabel('Temperature (°C)');
legend('Historical', 'Forecast');
grid on;