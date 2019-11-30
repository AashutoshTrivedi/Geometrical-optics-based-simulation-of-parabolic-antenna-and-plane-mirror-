% p = Plane( r, D) or Plane(r,w,h)
% r - 1x3 position vector
% D - surface diameter
% p = Plane( r, w, h)
% w - width
% h - height
% p.draw() - draws the plane p in the current axes
classdef Plane < Surface
    properties
        w = []  
        h = []   
        D = []   
    end
    
    methods
        function self = Plane( varargin )       
            if nargin == 0
                return;
            elseif nargin == 2
                self.r = varargin{1};
                self.D = varargin{2};
            elseif nargin == 3
                self.r = varargin{1};
                self.w = varargin{2};
                self.h = varargin{3};
            end
        end
                

        
        function h = draw( self, color )
            % draw self
            if nargin < 2
                color = [ 1 1 1 .5 ];
            end
            if ~isempty( self.w == 0 ) && ~isempty( self.h )
                y = [-self.w/2 self.w/2 ];
                z = [-self.h/2 self.h/2 ];
                [ y, z ] = meshgrid( y, z );
            elseif ~isempty( self.D )
                nrad = 50;
                if length( self.D ) == 1
                    rad = linspace( 0, self.D / 2, nrad );
                else
                    rad = linspace( self.D(1)/2, self.D(2) / 2, nrad );
                end
                nang = 50;
                ang = linspace( 0, 2 * pi, nang );
                [ ang, rad ] = meshgrid( ang, rad );                
                [ y, z ] = pol2cart( ang, rad );
            end
            x = zeros( size( y ) );
            S = [ x(:) y(:) z(:) ];
            
            % rotate and shift
            if self.rotang ~= 0
                S = rot( S, self.rotax, self.rotang );
            end
            x(:) = S( :, 1 ) + self.r( 1 );
            y(:) = S( :, 2 ) + self.r( 2 );
            z(:) = S( :, 3 ) + self.r( 3 );
            
            % draw
            c = repmat( reshape( color( 1:3 ), [ 1 1 3 ] ), size( x, 1 ), size( x, 2 ), 1 );
            h = surf( x, y, z, c, ...
                'EdgeColor', 'none', 'FaceLighting','phong', 'FaceColor', 'interp', 'FaceAlpha', color(4), ...
                'AmbientStrength', 0., 'SpecularStrength', 1 ); % grey color, shiny
        end
        
    end
    
end

