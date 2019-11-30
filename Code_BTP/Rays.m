
classdef Rays
    
    properties
        r = []; % a matrix of ray starting positions
        n = []; % a matrix of ray directions
        I = [];         % a vector of ray intensities
        color = [];   % color to draw the bundle rays
        cnt = 0;      % number of rays in the bundle
    end
    
    methods            
        function self = Rays( cnt, geometry, pos, dir, diameter, rflag, acolor ) % constructor of ray bundles
            
            if nargin == 0 % used to allocate arrays of Rays
                return;
            end
            
            if nargin < 7 || isempty( acolor )
                self.color = [ 0 1  0 ];
            else
                self.color = acolor;
            end
            if nargin < 6 || isempty( rflag )
                rflag = 'hexagonal'; % hexagonal lattice of rays
            end
            if nargin < 5 || isempty( diameter )
                diameter = 1;
            end
            if nargin < 4 || isempty( dir )
                dir = [ 1 0 0 ];
            end
            if nargin < 3 || isempty( pos )
                pos = [ 0 0 0 ];
            end
            if nargin < 2 || isempty( geometry )
                geometry = 'collimated';
            end
                    
            dir = dir ./ norm( dir );
            ex = [ 1 0 0 ];
            ax = cross( ex, dir );

            
            if strcmp( rflag, 'hexagonal' )
                % find the closest hexagonal number to cnt
                cnt1 = round( cnt * 2 * sqrt(3) / pi );
                tmp = (-3 + sqrt( 9 - 12 * ( 1 - cnt1 ) ) ) / 6;
                cn( 1 ) = floor( tmp );
                cn( 2 ) = ceil(  tmp );
                totn = 1 + 3 * cn .* ( 1 + cn );
                [ ~, i ] = min( abs( totn - cnt1 ) );
                cn = cn( i );
                % generate hexagonal grid
                p = [];
                for i = cn : -1 : -cn % loop over rows starting from the top
                    nr = 2 * cn + 1 - abs( i ); % number in a row
                    hn = floor( nr / 2 );
                    if rem( nr, 2 ) == 1
                        x = ( -hn : hn )';
                    else
                        x = ( -hn : hn - 1 )' + 1/2;
                    end
                    p = [ p; [ x, i * sqrt( 3 ) / 2 * ones( nr, 1 ) ] ]; % add new pin locations
                end
                if cn > 0
                    p = p * diameter / 2 / cn * 2 / sqrt( 3 ); % circubscribe the hexagon by an inward circle
                end

            elseif strcmp( rflag, 'square' )
                % find the closest square number to cnt
                rad = diameter / 2;
                %per = sqrt( pi * rad^2 / cnt ); % sqrt( area per ray )
                per = sqrt( diameter^2 / cnt ); % sqrt( area per ray )
                nr = ceil( rad / per ); % number of rays in each direction
                [ x, y ] = meshgrid( -nr * per : per : nr * per, -nr * per : per : nr * per );
                p( :, 1 ) = y( : );
                p( :, 2 ) = x( : );


            else
                error( [ 'Ray arrangement flag ' rflag ' is not defined!' ] );
            end
            
                self.cnt = size( p, 1 );            
                p = [ zeros( self.cnt, 1 ) p ]; % add x-positions
                pos = repmat( pos, self.cnt, 1 );
                if norm( ax ) ~= 0
                    p = rot( p, ax, asin( norm( ax ) ) );
                end
                if strcmp( geometry, 'collimated' ) % parallel rays
                    % distribute over the area
                    self.r = pos + p;
                    dir = repmat( dir, self.cnt, 1 );
                    self.n = dir;
                elseif strcmp( geometry, 'source' ) % assume p array at dir, source at pos.
                    self.r = pos;
                    self.n = p + repmat( dir, self.cnt, 1 );
                else
                    error( [ 'Source geometry' source ' is not defined!' ] );
                end
                % normalize directions
            self.n = self.n ./ repmat( sqrt( sum( self.n.^2, 2 ) ), 1, 3 );
            self.color = repmat( self.color, self.cnt, 1 );
            self.I = ones( self.cnt, 1 );
        end
        
        
        
        function draw( self, scale )
            if nargin == 0 || isempty( scale )
                scale = 1;
            end
             
             [ unique_colors ] = unique( self.color, 'rows' );
             nrms = scale * self.n;
             for i = 1 : size( unique_colors, 1 )
                 
                 quiver3( self.r( :, 1 ), self.r( :, 2 ), self.r( :, 3 ), ...
                          nrms( :, 1 ),   nrms( :, 2 ),   nrms( :, 3 ), ...
                          0, 'Color', unique_colors( i, : ), 'ShowArrowHead', 'off' );
             end


        end
         
        
        function [ rays_out, nrms ] = intersection( self, surf )
            % instantiate Rays object
            rays_out = self; % copy incoming rays
            
            switch class( surf )
                
                case {'Plane'} % intersection with a plane
                    % distance to the plane along the ray
                    d = dot( repmat( surf.n, self.cnt, 1 ), repmat( surf.r, self.cnt, 1 ) - self.r, 2 ) ./ ...
                        dot( self.n, repmat( surf.n, self.cnt, 1 ), 2 );
                    
                    % calculate intersection vectors and normals
                    rinter = self.r + repmat( d, 1, 3 ) .* self.n;
                    nrms = repmat( surf.n, self.cnt, 1 );
                    
                    % bring surface to the default position
                    rtr = rinter - repmat( surf.r, self.cnt, 1 );
                    if surf.rotang ~= 0
                        rtr = rot( rtr, surf.rotax, -surf.rotang ); % rotate rays to the default plane orientation
                    end
                    
                    rays_out.r = rinter;
                    rinter = rtr;
                    
                    % handle rays that miss the element
                    out = [];
                    if isprop( surf, 'w' ) && ~isempty( surf.w ) && isprop( surf, 'h' ) && ~isempty( surf.h )
                        out =  rinter( :, 2 ) < -surf.w/2 | rinter( :, 2 ) > surf.w/2 | ...
                            rinter( :, 3 ) < -surf.h/2 | rinter( :, 3 ) > surf.h/2;
                    elseif isprop( surf, 'D' ) && ~isempty( surf.D )
                        if length( surf.D ) == 1
                            out = sum( rinter( :, 2:3 ).^2, 2 ) - 1e-12 > ( surf.D / 2 )^2;
                        end
                    end
                    rays_out.I( out ) = -1 * rays_out.I( out ); % mark for processing in the interaction function
                    
                    
                    case {'Parabola'} % intersection with a conical surface of rotation

                    r_in = self.r - repmat( surf.r, self.cnt, 1 ); % shift to RF with surface origin at [ 0 0 ]
                    
                    if surf.rotang ~= 0 % rotate so that the surface axis is along [1 0 0]
                        r_in = rot( r_in, surf.rotax, -surf.rotang ); % rotate rays to the default surface orientation
                        e = rot( self.n, surf.rotax, -surf.rotang );
                    else
                        e = self.n;
                    end
                    
                    if size( surf.R, 2 ) > 1 % asymmetric quadric, scale z-dimension to make the surface symmetric
                        sc = surf.R( 1 ) / surf.R( 2 );
                        r_in( :, 3 ) = r_in( :, 3 ) * sc;
                        e( :, 3 ) = e( :, 3 ) * sc;
                    end
                        rinter = conic( r_in, e, surf );
                        % find normals
                        r2yz = ( rinter( :, 2 ).^2 + rinter( :, 3 ).^2 ) / surf.R(1)^2; % distance to the mirror center along the mirror plane in units of R
                        c = 1 ./ sqrt( 1 + r2yz );
                        s = sqrt( 1 - c.^2 );
                       
                        s = -sign( surf.R(1) ) * s; % sign of the transverse component to the ray determined by the lens curvature
                        th = atan2( rinter( :, 3 ), rinter( :, 2 ) ); % rotation angle to bring r into XZ plane
                        en = [ c, s .* cos( th ), s .* sin( th ) ]; % make normal sign positive wrt ray
                        
                                        
                    % handle rays that miss the element
                    out = [];

                        if isprop( surf, 'D' ) && ~isempty( surf.D )
                            if length( surf.D ) == 1
                                out = sum( rinter( :, 2:3 ).^2, 2 ) - 1e-12 > ( surf.D / 2 )^2;
                            else
                                r2 = sum( rinter( :, 2:3 ).^2, 2 );
                                out = isnan( r2 ) | ( r2 + 1e-12 < ( surf.D(1) / 2 )^2 ) | ( r2 - 1e-12 > ( surf.D(2) / 2 )^2 );
                            end
                        end               
                    

                    rays_out.I( out ) = -1 * rays_out.I( out ); % mark for processing in the interaction function
                    % return to the original RF
                    if surf.rotang ~= 0 % needs rotation
                        rays_out.r = rot( rinter, surf.rotax, surf.rotang );
                        nrms = rot( en, surf.rotax, surf.rotang );
                    else
                        rays_out.r = rinter;
                        nrms = en;
                    end
                    nrms = nrms ./ repmat( sqrt( sum( nrms.^2, 2 ) ), 1, 3 );
                    rays_out.r = rays_out.r + repmat( surf.r, self.cnt, 1 );
                    
                otherwise
                    error( [ 'Surface ' class( surf ) ' is not defined!' ] );
            end
        end

         
        
        function rays_out = interaction( self, surf, out_fl )

            [ rays_out, nrms ] = self.intersection( surf );
            
            miss = rays_out.I < 0; 
            cs1 = dot( nrms, self.n, 2 ); % cosine between the ray direction and the surface direction        
            rays_out.n = self.n - 2 * repmat( cs1, 1, 3 ) .* nrms; 
                                          
            % process rays that missed the element
            if out_fl == 0 % if tracing rays missing elements or for apertures
                % use the original rays here
                rays_out.I( miss ) = self.I( miss );
                rays_out.r( miss, : ) = self.r( miss, : );
                rays_out.n( miss, : ) = self.n( miss, : );
            else
                % default, exclude such rays
                rays_out.I( miss ) = 0;
                rays_out.r( miss, : ) = Inf;
            end
            rays_out.I( isnan( rays_out.I ) ) = 0;
        end       
        
   end
end


