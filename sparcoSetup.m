function sparcoSetup(varargin)
%SPARCOSETUP Setup the SPARCO toolbox.
%
%   SPARCOSETUP will install the SPARCO toolbox.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: sparcoSetup.m 1027 2008-06-24 23:42:28Z ewout78 $

pathlist = {};

% Get root location of sparcoSetup
root = fileparts(which(mfilename));

% ----------------------------------------------------------------------
% Add Sparco subdirs to path.
% ----------------------------------------------------------------------
addtopath(root,'');
addtopath(root,'examples');
%addtopath(root,'operators');
addtopath(root,'problems');
addtopath(root,'tools');
addtopath(root,['tools' filesep 'nufft']);
addtopath(root,['tools' filesep 'rwt']);

% Make sure that the build subdir exists
buildpath = {['build'],                          ...
             ['build' filesep 'figures'],        ...
             ['build' filesep 'html'],           ...
             ['build' filesep 'latex'],          ...
             ['build' filesep 'thumbs']};
for i=1:length(buildpath)
    p = buildpath{i};
    if ~exist([root filesep p],'dir')
       [success,message,messageid] = mkdir(root, p);
       if ~success
          error('Could not create directory %s%s\n',root,p);
       end
    end
end

% ----------------------------------------------------------------------
% Parse parameters.
% ----------------------------------------------------------------------
[opts,varg]= parseOptions(varargin,{'norwt'},{});

% % ----------------------------------------------------------------------
% % Check for external dependencies.
% % ----------------------------------------------------------------------
% 
% % Commented May 25th
% 
% % CurveLab: Req'd for 51-52
% if exist('curvelab.pdf','file')
%    crvroot = fileparts(which('curvelab.pdf'));
%    addtopath(crvroot,'fdct_usfft_matlab');
%    addtopath(crvroot,'fdct_wrapping_matlab');
%    addtopath(crvroot,'fdct_wrapping_cpp/mex');
%    addtopath(crvroot,'fdct3d/mex');
% else
%    fprintf(['\nWarning: CurveLab is not in the path. Problems 50-51 ' ...
%             'will not work.\n\n']);
% end
% 
% [T,result] = evalc('savepath;');
% rehash path;
% if result == 1
%    fprintf(['\n' ...
%             '\n Warning: SPARCO successfully added to your path,' ...
%             '\n          but couldn''t make these changes permanent.' ...
%             '\n          To permanently add SPARCO to your path,'...
%             '\n          copy and paste the following lines into your'...
%             '\n          startup.m file (e.g., ~/matlab/startup.m).'...
%             '\n\n']);
%    for i=1:length(pathlist)
%      fprintf(' addpath(''%s'');\n',pathlist{i});
%    end
%    fprintf('\n');
% end
% 
% % --'+sparco/',--------------------------------------------------------------------
% % Compile the Rice Wavelet Toolbox
% % ----------------------------------------------------------------------
% 
% if ~opts.norwt
%    cd([root filesep 'tools' filesep 'rwt'])
%    fprintf('Compiling the Rice Wavelet Toolbox MEX interfaces...');
%    try
%       if exist('mdwt'  ,'file')~=3, mex mdwt.c   mdwt_r.c;   end
%       if exist('midwt' ,'file')~=3, mex midwt.c  midwt_r.c;  end
%       if exist('mrdwt' ,'file')~=3, mex mrdwt.c  mrdwt_r.c;  end
%       if exist('mirdwNew Foldert','file')~=3, mex mirdwt.c mirdwt_r.c; end
%       fprintf('Success!\n');
%   catch
%       warning('Could not compile Rice Wavelet Toolbox MEX interfaces.');
%   end
%   cd(root)
% end

% ----------------------------------------------------------------------
% Check if Spot toolbox is installed and install it if not 
% ----------------------------------------------------------------------

isspot = strfind(ls,'spotbox');

if(~isempty(isspot))
    fprintf('Spot toolbox found\n')
else
    fprintf('Spot toolbox not found\n');
    fprintf('   Downloading Spot...\n');
    spotwebsite = 'http://www.cs.ubc.ca/labs/scl/spot/';
    website = urlread(spotwebsite);
    dl = strfind(website, 'Download');
    website = website(dl(1):size(website,2));
    spotURL = strfind(website, '<a href="');
    website = website((spotURL(1)+9):size(website,2));
    endofURL = strfind(website,'"');
    website = website(1:(endofURL-1));

    if(isempty(strfind(website,'www'))&&isempty(strfind(website,'http')))
        website = strcat(spotwebsite,website);
    end
    
    [path,status] = urlwrite(website,'spot.zip');

    if(status==0)
        warning('Could not download Spot toolbox from website\n');
    else
        fprintf('   Unzipping Spot toolbox...\n')
        unzip(path,'')
    end

    delete(path)

    list = dir;

    for i=1:length(list)
        if(~isempty(strfind(list(i).name,'spotbox')))
            if(list(i).isdir)
                spotDirName = list(i).name;
                newspotDirname = 'spotbox';
                movefile(spotDirName,newspotDirname);
                break
            end
        end
    end
    addtopath(root,'spotbox');
    
end
% ----------------------------------------------------------------------
% NESTED FUNCTIONS
% ----------------------------------------------------------------------

function addtopath(root,dirname)
if ~exist([root filesep dirname],'dir')
   error('Required directory "%s%s%s" is missing!.\n',root,filesep,dirname);
else
   newdir = [root filesep dirname];
   fprintf('Adding to path: %s\n',newdir);
   addpath(newdir);
   pathlist{end+1} = newdir;
end
end % function adddirtopath

end % function sparcoSetup


% ----------------------------------------------------------------------
% PRIVATE FUNCTIONS
% ----------------------------------------------------------------------

function available = checkFunction(funname)

available = false;
w = which(funname);
if ~isempty(w)
   available = true;
   [root, name, ext, versn] = fileparts(w);
   if ~strcmp(name,funname)
      available = false;
      fprintf('Warning: Found case-insensitive match for %s.\n', funname);
   end
end

end % function checkFunction


