% Read data
readChannelID = 2792954;
tempData = thingSpeakRead(readChannelID, 'Field', 1, 'NumPoints', 30);
humidData = thingSpeakRead(readChannelID, 'Field', 2, 'NumPoints', 30);
pressData = thingSpeakRead(readChannelID, 'Field', 3, 'NumPoints', 30);

% Remove NaN values
valid = ~isnan(tempData) & ~isnan(humidData) & ~isnan(pressData);
tempData = tempData(valid);
humidData = humidData(valid);
pressData = pressData(valid);

% Calculate moving averages
window = 3;
temp_ma = movmean(tempData, window);
humid_ma = movmean(humidData, window);
press_ma = movmean(pressData, window);

% Detect anomalies (values far from moving average)
temp_anomalies = abs(tempData - temp_ma) > 2*std(tempData);
humid_anomalies = abs(humidData - humid_ma) > 2*std(humidData);
press_anomalies = abs(pressData - press_ma) > 2*std(pressData);

% Combined anomaly flag
anomalies = temp_anomalies | humid_anomalies | press_anomalies;

% Plot results
plot(tempData, 'b-', 'LineWidth', 1);
hold on;
plot(humidData, 'g-', 'LineWidth', 1);
plot(pressData, 'r-', 'LineWidth', 1);
scatter(find(anomalies), tempData(anomalies), 100, 'k*');
title('Weather Parameters with Anomalies');
xlabel('Time Points');
ylabel('Values');
legend('Temperature', 'Humidity', 'Pressure', 'Anomalies');
grid on;