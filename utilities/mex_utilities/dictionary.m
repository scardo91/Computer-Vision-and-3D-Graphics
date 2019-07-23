% A dictionary that stores name-value pairs.

% Copyright 2008-2009 Levente Hunyadi
classdef dictionary < handle
    properties (Access = public)
        keys = {};
        values = {};
    end
    methods
        function this = dictionary(varargin)
            switch nargin
                case 0
                    % default empty constructor
                case 1
                    arg = varargin{1};
                    if iscell(arg)  % constructor using name-value pair list in cell array
                        this = this.SetPairs(arg);
                    else  % copy constructor
                        this = this.CopyFrom(arg);
                    end
                case 2
                    arg = varargin{1};
                    fieldname = varargin{2};
                    if isstruct(arg) && ischar(fieldname)  % constructor using struct array
                        this = this.SetFromStructure(arg, fieldname);
                    else
                        this = this.SetPairs(varargin);
                    end
                otherwise
                    this = this.SetPairs(varargin);  % constructor using name-value pair list
            end                
        end
        
        function disp(this)
            if isempty(this.keys)
                fprintf('[empty]\n');
            else
                maxkeylen = max(cellfun(@numel, this.keys));  % maximum key length
                for i = 1 : numel(this.keys)
                    key = this.keys{i};
                    value = this.values{i};
                    if ischar(value)
                        fprintf('%*s  %s\n', maxkeylen, key, value);
                    else
                        fprintf('%s\n', key);
                        disp(value);
                        fprintf('\n');
                    end
                end
            end
        end
        
        function tf = HasKey(this, key)
            tf = ~isempty(find(strcmp(key, this.keys), 1, 'first'));
        end
        
        function value = TryGet(this, key)
            i = find(strcmp(key, this.keys), 1, 'first');
            if ~isempty(i)
                value = this.values{i};
            else
                value = [];
            end
        end
        
        function value = Get(this, key)
            i = find(strcmp(key, this.keys), 1, 'first');
            if ~isempty(i)
                value = this.values{i};
            else
                error('collection:dict:MissingKey', 'Failure: key %s does not exist in dictionary.', key);
            end
        end
        
        function this = Set(this, key, value)
            this = this.AddPairs(key, value);
        end
        
        function this = CopyFrom(this, obj)
            validateattributes(obj, {'dictionary'}, {'scalar'});
            this.keys = obj.keys;
            this.values = obj.values;
        end

        % Initializes the dictionary using the elements in the structure array.
        %
        % Input arguments:
        % arg:
        %    the structure array from which the elements are copied to the
        %    dictionary
        % fieldname:
        %    the structure field name that serves as a key
        function this = SetFromStructure(this, arg, fieldname)
            [this.keys, this.values] = dictionary.FromStructure(arg, fieldname);
            this = this.MakeUnique();
        end        
        
        % Sets the dictionary contents to the specified keys and values.
        % When the keys contain duplicates, the later value prevails.
        % 
        % Input arguments:
        % args:
        %    the key-value pairs to add, either one after the other or
        %    encapsulated in a cell array.
        function this = SetPairs(this, arg, varargin)
            [this.keys, this.values] = dictionary.ToKeysValues(arg, varargin{:});
            this = this.MakeUnique();
        end

        % Adds the specified key-value pairs to the dictionary.
        % When a value with the same key is found within the dictionary,
        % the newly added element prevails.
        %
        % Input arguments:
        % args:
        %    the key-value pairs to add, either one after the other or
        %    encapsulated in a cell array.
        function this = AddPairs(this, arg, varargin)
            [keys, values] = dictionary.ToKeysValues(arg, varargin{:});
            this.keys = [ this.keys ; keys ];
            this.values = [ this.values ; values ];
            this = this.MakeUnique();
        end
        
        % Removes duplicate keys and corresponding values from dictionary.
        function this = MakeUnique(this)
            [this.keys, m] = unique(this.keys);  % last occurrence is preserved
            this.values = this.values(m);
        end
    end
    methods (Static)
        % Converts key-value pairs to a cell array of keys and values.
        function [keys, values] = ToKeysValues(arg, varargin)
            if nargin > 1
                args = { arg, varargin{:} };
            else
                args = arg;
            end
            n = numel(args);
            validateattributes(n, {'numeric'}, {'even','positive','scalar'});
            n = n / 2;
            keys = cell(n, 1);
            values = cell(n, 1);
            for i = 1 : n
                key = args{2*i-1};
                validateattributes(key, {'char'}, {'nonempty','vector'});
                keys{i} = key;
                values{i} = args{2*i};
            end
        end
        
        % Extracts keys and values from a structure array.
        %
        % Input arguments:
        % arg:
        %    the structure array from which the elements are to be extracted
        % fieldname:
        %    the structure field name that serves as a key
        function [keys, values] = FromStructure(arg, fieldname)
            n = numel(arg);
            keys = cell(n, 1);
            values = cell(n, 1);
            for i = 1 : n
                keys{i} = arg(i).(fieldname);
            end
            arg = rmfield(arg, fieldname);
            for i = 1 : n
                values{i} = arg(i);
            end
        end
    end
end