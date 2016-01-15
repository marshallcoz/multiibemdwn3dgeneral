function [ batch ] = batch_run
%RUN all cases inside batch.mat variable {:,1} and save results {:,2}

cd ..
cd out
if exist(fullfile(cd, 'batch.mat'), 'file')
  load('batch.mat','batch') %cargar variable
  [pathstr1,pathstr2,~] = fileparts(pwd);
cd ..
cd multi-dwn-ibem.matlab
if iscell(batch)
  nCasos = size(batch,1);
  for iCaso = 1:nCasos
    disp('**********************************************')
    disp(['************** caso' num2str(iCaso) '/' num2str(nCasos) '************************'])
    disp('**********************************************')
    
    % ajustar variables dependientes del sistema
    [~,name,ext] = fileparts(batch{iCaso,1}.name);
    batch{iCaso,1}.name = [pathstr1,pathstr1(1),pathstr2,pathstr1(1),name,ext];
    batch{iCaso,1}.nametmp = batch{iCaso,1}.name;
    batch{iCaso,1}.nomcarpeta = pwd;
    batch{iCaso,1}.nomrep = [pathstr1,pathstr1(1),pathstr2];
    % correr programa
    [batch{iCaso,2},batch{iCaso,1}] = calculo(batch{iCaso,1});
  end
  disp('****************** done **********************')
  disp('saving results and parameters onto batch.mat')
cd ..
cd out
  save('batch.mat','batch')
else
  disp('problem with variable batch ')
  whos batch
end
else
  disp('batch.mat does not exist in')
  pwd
end
cd ..
cd multi-dwn-ibem.matlab
end

