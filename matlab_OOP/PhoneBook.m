% name :PheneBook.m
% from 《MATLAB面向对象编程》P200
classdef PhoneBook < handle
    properties
        name
        number
    end
    methods
        function o  =PhoneBook(n,p)
            o.name=n;
            o.number=p;
        end
    end
end