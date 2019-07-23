% Automated .c and .cpp into .mex file compilation.
% Traversing the directory hierarchy, this function compiles any .c or .cpp
% source files it finds into .mex (MatLab executable) functions if their
% modification date is later than the compiled version.

% Copyright 2008-2009 Levente Hunyadi
function make(mode, varargin)

fprintf( ...
    [ 'Automated .mex compiler\n', ...
      'Copyright 2008-2009 Levente Hunyadi\n', ...
      '\n' ...
    ]);

if nargin >= 1
    switch mode
        case 'clean'
            args = varargin;
            mode = 'clean';
        case 'build'
            args = varargin;
            mode = 'build';
        otherwise
            args = [{mode}, varargin];
            mode = 'make';
    end
else
    mode = 'make';
    args = {};
end

fprintf('Compiling source files...\n');
if exist('lib', 'dir')
    deflibpath = fullfile(matlabroot, 'extern', 'lib', computer('arch'), 'microsoft');  % default library path
    addlibpath = fullfile(cd, 'lib', computer('arch'));  % additional library path

    libraryswitch = sprintf('-L%s', addlibpath);
    linkswitch = sprintf('LINK_LIB=%s', [deflibpath ';' addlibpath]);
    setenv('LIB', [deflibpath ';' addlibpath]);

    args = [{libraryswitch}, {linkswitch}, args];
    fprintf('"lib" library directory added.\n');
end
if exist('include', 'dir')
    includeswitch = sprintf('-I%s', fullfile(cd, 'include'));
    args = [{includeswitch}, args];
    fprintf('"include" source header directory added.\n');
end
make_walker(cd, cd, mode, args);

% Traverses a directory structure compiling files in each directory if needed.
function make_walker(dirpath, rootpath, mode, args)

items = dir(dirpath);
dict = dictionary(items, 'name');
for i = 1 : length(items)
    item = items(i);
    itempath = fullfile(dirpath, item.name);
    
    if item.isdir && ~any(strcmp(item.name, {'.','..','include','SDPT','yalmip'}))
        make_walker(itempath, rootpath, mode, args);  % look for MEX source files in subdirectory
    else
        [dirpath, filename, fileext] = fileparts(itempath);
        switch fileext
            case {'.c','.cpp'}
                mexfileext = ['.', mexext];
                itemmex = dict.TryGet([filename, mexfileext]);  % compiled MEX file that belongs to source
                switch mode
                    case 'build'
                        make_mex(itempath, args);
                    case 'make'
                        if isempty(itemmex) || itemmex.datenum < item.datenum  % compiled file does not exist, or not up-to-date, or user requested full build
                            make_mex(itempath, args);
                        else
                            fprintf('%s%s [up-to-date]\n', filename, fileext);
                        end
                    case 'clean'
                        if ~isempty(itemmex)
                            fprintf('%s%s [deleted]\n', filename, mexfileext);
                            delete(fullfile(dirpath, [filename mexfileext]));
                        end
                end
        end
    end
end

function make_mex(itempath, args)

[dirpath, filename, fileext] = fileparts(itempath); %#ok<NASGU>
try
    mex('-largeArrayDims', args{:}, '-outdir', dirpath, itempath);
    fprintf('%s%s [ok]\n', filename, fileext);
catch me %#ok<NASGU>
    fprintf('%s%s [error]\n', filename, fileext);
end