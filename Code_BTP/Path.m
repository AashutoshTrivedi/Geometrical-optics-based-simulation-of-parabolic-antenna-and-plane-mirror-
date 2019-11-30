%this class is base class for creating and handling all the objects in the
%path.Ex if I put a mirror be it parabolic or plane, I will put it inside
%the path class's object. Here there are draw function, append option and trace functions. 

classdef Path < handle

    properties
        elem = {};     
        cnt = 0;   
    end
    
    methods
        function self = Path()

            if nargin == 0
                return;
            end
        end
         
 
            %   rays - array of rays 
            %   draw_fl - display rays as 'arrows', 'lines', or 'rays'
            %   alpha - opacity of optical surfaces from 0 to 1, default .33
            %   scale - scale of the arrow heads for the 'arrows' draw_fl
            %   new_figure_fl - 0, do not open, or 1, open (default)
        
        function draw( self, rays, draw_fl, alpha, new_figure_fl )
            if nargin < 5 || isempty( new_figure_fl )
                new_figure_fl = 1; % open a new figure by default
            end
            if nargin < 4 || isempty( alpha )
                alpha = 0.33;
            end
            if nargin < 3 || isempty( draw_fl )
                draw_fl = 'clines';
            end
            if nargin < 2 || isempty( rays )
                rays = [];
            end
            
            if new_figure_fl == 1
                figure( 'Name','FIGURE ', 'NumberTitle', 'Off', ...
                    'Position', [ 0 0 1024 1024 ], ...
                    'Color', 'k' );
            end
            hold on;
            for i = 1 : self.cnt
                obj = self.elem{ i };
                color = [ 0 1 0 alpha ];
                obj.draw( color );
            end
            
            if ~isempty( rays )
                if strcmp( draw_fl, 'lines' ) || strcmp( draw_fl, 'clines' ) || strcmp( draw_fl, 'rays' ) % draw ray bundles as lines
                    if strcmp( draw_fl, 'lines' )
                        sym = '-';
                    else
                        sym = '*:';
                    end
                    for i = 1 : length( rays ) - 1
                        [ unique_colors ] = unique( rays( i ).color, 'rows' );
                        for j = 1 : size( unique_colors, 1 )
                            plot3( [ rays( i ).r( :, 1 )';  rays( i + 1 ).r( :, 1 )' ], ...
                                   [ rays( i ).r( :, 2 )';  rays( i + 1 ).r( :, 2 )' ], ...
                                   [ rays( i ).r( :, 3 )';  rays( i + 1 ).r( :, 3 )' ], sym, 'Color', [1 0 0] );
                        end
                    end
                    rays(length(rays)).draw(50);
                end
            end
            
                axis equal vis3d off;
                camlight( 'left' );
                camlight( 'right' );
                camlight( 'headlight' );
                view( -54, 54 );
                lighting phong;
                rotate3d on;
        end

        
        function append( self, obj)
          
            nobj = length( obj );
                for i = 1 : nobj
                    self.cnt = self.cnt + 1;
                    if nobj == 1
                        self.elem{ self.cnt } = obj;
                    elseif iscell( obj )   % other benches or cell arrays of Surfaces
                        self.elem{ self.cnt } = obj{ i };
                    elseif isvector( obj ) % Rays
                        self.elem{ self.cnt } = obj( i );
                    end
                end
        end
        

       
        function rays = trace( self, rays_in, out_fl )
            if nargin < 3
                out_fl = 1; 
            end
            rays( 1, self.cnt + 1 ) = Rays; 
            rays( 1 ) = rays_in;
            for i = 1 : self.cnt 
                rays( i + 1 ) = rays( i ).interaction( self.elem{ i }, out_fl );
            end
        end
    end
    
end

