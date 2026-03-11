% Get a list of all CSV files in the current directory
fileList = dir('*.csv');

% Read the first file to determine the size of the data
exampleData = readtable(fileList(1).name);
numRows = height(exampleData); % Exclude header row
numCols = width(exampleData) - 1; % Exclude header column

% Initialize a 3D tensor to hold data from all files
dataTensor = zeros(numRows, numCols, length(fileList));

% Loop to read each file into the tensor
for i = 1:length(fileList)
    % Read the CSV file
    filename = fileList(i).name;
    opts = detectImportOptions(filename);
    opts.VariableNamesLine = 1; 
    opts.VariableTypes(1) = {'string'}; % First column as string for headers
    opts.DataLine = 2; % Skip the first row
    
    % Read the data and convert it to numeric
    data = readtable(filename, opts);
    numericData = table2array(data(:,2:end));
    
    % Store in the tensor
    dataTensor(:, :, i) = numericData;
end

% Calculate the averages and standard deviations along the 3rd dimension
averages = mean(dataTensor, 3); % Average across files
stdDevs = std(dataTensor, 0, 3); % Standard deviation across files

% Prepare tables for writing to Excel
avgTable = array2table(averages, 'VariableNames', data.Properties.VariableNames(2:end), 'RowNames', table2array(data(:,1)));
stdTable = array2table(stdDevs, 'VariableNames', data.Properties.VariableNames(2:end), 'RowNames', table2array(data(:,1)));

% Write to Excel file
excelFilename = 'Results.xlsx';
% Write the averages to the first sheet with a specific name
writetable(avgTable, excelFilename, 'Sheet', 'Averages', 'WriteRowNames', true);

% Write the standard deviations to the second sheet with a specific name
writetable(stdTable, excelFilename, 'Sheet', 'Standard Deviations', 'WriteRowNames', true);