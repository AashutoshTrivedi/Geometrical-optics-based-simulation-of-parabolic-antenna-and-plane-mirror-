%this is class for parabola ojects. It's parent class is surface.
classdef Parabola < Surface 
    
    properties
        D = [ 0; 1 ]; % lens diameter (inner, outer)
     end
    
    methods
        function self = Parabola( ar, aD, aR, ak )
            if nargin == 0
                return;
            end
            if size( aD, 1 ) < size( aD, 2 )
                aD = aD';
            end
            if size( aD, 1 ) == 1
                aD = [ 0; aD ];
            end
            self.r = ar;
            self.D = aD;
            self.R = aR;
            self.k = ak;
;
            if ( self.D(2) / 2 / self.R(1) )^2 * ( 1 + self.k ) > 1
                % error( 'Lens Diameter is too large for its radius and k' );
                self.D(1) = -1; % signal bad parameters
            end
        end
       
        
        function h = draw( self, color )
            % DISPLAY the lens surface
            if nargin < 2
                color = [ 1 1 1 .5 ];
            end
            nrad = 50;
            rad = linspace( self.D(1) / 2, self.D(2) / 2, nrad );
            nang = 100;
            ang = linspace( 0, 2 * pi, nang );
            [ ang, rad ] = meshgrid( ang, rad );
            
            [ y, z ] = pol2cart( ang, rad );
            if length( self.R ) == 1
                r2yz = ( y.^2 + z.^2 ) / self.R^2;
                x = r2yz * self.R / 2;   
            else % asymmetric conic
                r2yz = y.^2 / self.R(1) + z.^2 / self.R(2);
                x = r2yz / 2;    
            end
            

            S = [ x(:) y(:) z(:) ];
            
            % rotate and shift
            if self.rotang ~= 0
                S = rot( S, self.rotax, self.rotang );
            end
            x(:) = S( :, 1 ) + self.r( 1 );
            y(:) = S( :, 2 ) + self.r( 2 );
            z(:) = S( :, 3 ) + self.r( 3 );
            
            c = repmat( reshape( color( 1:3 ), [ 1 1 3 ] ), size( x, 1 ), size( x, 2 ), 1 );
            h = surf( x, y, z, c, ...
                'EdgeColor', 'none', 'FaceLighting','phong', 'FaceColor', 'interp', 'FaceAlpha', color(4), ...
                'AmbientStrength', 0., 'SpecularStrength', 1 ); % grey color, shiny
        end
        
    end
    
end

