classdef Surface < handle
    
    properties   
        r = [ 0 0 0 ];  % location vector
        R = [];       % radius of the tangent sphere
        k = [];         % conic constant
    end
    
    properties ( SetAccess = private )
        rotax = [ 1 0 0 ];  % rotation axis for rotation transformation
        rotang = 0;        % rotation angle about the rotax, radians      
        n = [ 1 0 0 ];      % orientation (normal) vector, can be set by a rotate function only
    end
    
    methods
        


        function rotate( self, rot_axis, rot_angle )
            if abs( rot_angle ) > pi
                error( 'Rotation angle should be [ -pi pi ]!' );
            end
            % rotate the normal about the rot_axis by rot_angle (radians)
            self.rotax = rot_axis;
            self.rotang = self.rotang + rot_angle;
            self.n = rot( self.n, rot_axis, rot_angle );
            if abs( self.rotang ) > pi/2
                self.rotang = self.rotang - sign( self.rotang ) * pi;
                self.R = -self.R;  % surface upside-down
            end
        end
 
    end
    
end