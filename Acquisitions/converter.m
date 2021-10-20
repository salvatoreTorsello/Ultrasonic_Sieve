function converter

% List .CSV files in input folder
inputPath = dir(strcat('Acquisitions/input/*.csv'));
noInFiles = size(inputPath,1);

% Loop through the files and import .CSV to Matlab
    for n = 1:noInFiles
        % Reconstruct file name and open the file 
        file = fullfile(inputPath(n).folder, inputPath(n).name);
        fid = fopen(file,'r');
        
        % Check number of columns in the file and read raw data 
        delim = ','; 
        fLine = fgets(fid);
        noCol = numel(strfind(fLine,delim))+1;
        format = repmat('%s',1,noCol);
        header{1} = textscan(fLine, format, 'Delimiter', ',', 'CollectOutput',0);
        format = repmat('%f',1,noCol);
        rawData = textscan(fid, format, 'Delimiter', ',', 'CollectOutput',0);
        
        % Pull data into matricies
        % First find correct variable name 
        for c = 1:size(rawData,2)-1
            varName = header{1,1}{1,c}{:};
            data.(varName) = rawData{1,c};
        end
        output = ['Acquisitions/output/', strrep(inputPath(n).name, '.csv', '_Session.mat')];
                
        saveAtlasData(data,output);
    end
    clear name
end