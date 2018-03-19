% name :Square.m
% from 《MATLAB面向对象编程》P195
classdef Square < handle
    properties
        a
    end
    methods
        function obj = Square(val)
            if nargin == 1                      % if there is a parameter of Constructor
                obj.a = val;
            elseif nargin == 0                  % if the number of parameter is 0 
                obj.a = 1;
                disp('default CTOR called');    % this sentence is used to count how many times execute the code;
            end
        end
    end
end