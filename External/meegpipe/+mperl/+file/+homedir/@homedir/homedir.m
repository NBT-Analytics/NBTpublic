classdef homedir
    % HOMEDIR - Wraps Perl module File::HomeDir
    %
    % import mperl.file.homedir.homedir;
    % obj = homedir;
    % desktop = obj.my_desktop;
    % home    = obj.my_home;
    % 
    % See <a href="http://search.cpan.org/~adamk/File-HomeDir-0.97/lib/File/HomeDir.pm">File::HomeDir</a> for more information.
    
  
    
    
    
    methods (Access = public)
        
        function out = subsref(this, s)
            
            switch s(1).type
                case '.'
                    import mperl.join;
                    import mperl.perl_eval;
                    import mperl.root_path;
                    import mperl.file.spec.catdir;
                    import mperl.file.spec.abs2rel;
                    
                    funcName = s(1).subs;
                    if numel(s) > 1,
                        funcArgs = s(2).subs;
                    else
                        funcArgs = {};
                    end
                    
                    funcArgs = cellfun(@(x) ['''' x ''''], funcArgs, ...
                        'UniformOutput', false);                    
                   
                    libDir = catdir(root_path, 'lib');                   
                    libDir = abs2rel(libDir, pwd);
                    libDir = strrep(libDir, '\', '/');
                    
                    cmd = sprintf(...
                        '-MFile::HomeDir -I%s -e "print File::HomeDir->%s(%s)"', ...
                        libDir, funcName, join(', ', funcArgs));
                        
                    [~, out] = perl_eval(cmd);
                   
                otherwise
                    out = builtin('subsref', this, s);
            end
            
        end
        
    end
    
    
    
    
    
    
end