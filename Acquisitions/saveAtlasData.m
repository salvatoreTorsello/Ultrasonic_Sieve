function saveAtlasData(inData, name)
%saveAtlasData is used to extract chnnels in structure into the workspace and save it all.    
    chNames = fieldnames(inData);
    for n = 1:length(chNames)
        eval(strcat(chNames{n},' = ','inData.',chNames{n},';'));
    end
    clear n
    clear chNames
    clear inData
    clear freq
    save(name);
end