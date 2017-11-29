classdef LowPassFilter
	properties
		y
		a
		s
		initialised
	end

	methods
		function obj = LowPassFilter(alpha1,initval)
			obj.y = initval;
			obj.s = initval;
			obj.initialised = false;
			if(alpha1<=0.0)
				obj.a = 0.001;
			elseif (alpha1>1.0)
				obj.a = 1.0;
			else
				obj.a = alpha1;
			end
		end
		function [obj,new_val] = filter1(obj,value)
			if(obj.initialised)
				new_val = (obj.a * value) + ((1.0 - obj.a)*obj.s);
			else
				new_val = value;
				obj.initialised = true;
			end
			obj.y = value ;
			obj.s = new_val ;
		end
		function [obj,result] = filterWithAlpha(obj,value,alpha1)
			if(alpha1<=0.0)
				obj.a = 0.001;
			elseif (alpha1>1.0)
				obj.a = 1.0;
			else
				obj.a = alpha1;
			end
			[obj,result] = obj.filter1(value);
		end
		function ret = hasLastRawValue(obj)
			ret = obj.initialised;
		end
		function ret = lastRawValue(obj)
			ret = obj.y ;
		end
	end
end