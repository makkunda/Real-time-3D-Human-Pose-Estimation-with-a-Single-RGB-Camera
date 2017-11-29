classdef OneEuroFilter
	properties
		freq
		minicutoff
		beta1
		dcutoff
		x
		dx
		lasttime
	end
	methods
		function obj = OneEuroFilter(fre,mincutoff,b1)
			if nargin > 0 
				obj = obj.setFrequency(fre);
				obj = obj.setMinCutoff(mincutoff);
				obj = obj.setBeta(b1);
				obj = obj.setDerivateCutoff(1.0);
				% fprintf('mincutoff')
				
				a1 = obj.alpha2(mincutoff);
				obj.x = LowPassFilter(a1,0.0);
				% fprintf('dcutoff')
				% fprintf(dcutoff)
				a2 = obj.alpha2(obj.dcutoff);
				obj.dx = LowPassFilter(a2,0.0);
				obj.lasttime = -1;
			end
		end
		%private
		function al = alpha2(obj,cutoff)
			te = 1.0/(obj.freq);
			pii = 4.0*(atan(1));
			tau = 1.0/(2*pii*cutoff);
			den = tau/te;
			al = 1.0/(1.0 + den);
		end
		function obj= setFrequency(obj,f)
			if (f<=0.0)
				obj.freq = 1.0;
				fprintf('**********')
			else
				obj.freq = f;
			end
		end
		function obj = setMinCutoff(obj,mc)
			if (mc<=0)
				obj.minicutoff = 0.1;
			else
				obj.minicutoff = mc;
			end
		end
		function obj =  setBeta(obj,b)
			obj.beta1 = b;
		end
		function obj = setDerivateCutoff(obj,dc)
			if (dc<=0)
				obj.dcutoff = 0.1;
			else
				obj.dcutoff = dc;
			end
		end
		%public
		function [obj,new_val1] = filter2(obj,value,timestamp1)
			if(obj.lasttime~=(-1))
				denom = (timestamp1 - obj.lasttime);
				obj.freq = 60.0/denom ;
			end
			obj.lasttime = timestamp1;
			dvalue = 0.0;
			if(obj.x.hasLastRawValue())
				dvalue = (value - obj.x.lastRawValue())*obj.freq;
			end
			% fprintf('dcutoff-filter2')
			% fprintf(dcutoff)
			[obj.dx,edvalue] = obj.dx.filterWithAlpha(dvalue,obj.alpha2(obj.dcutoff));
			cutoff1 = obj.minicutoff + (obj.beta1)*abs(edvalue);
			% fprintf('cutoff1-filter2')
			% fprintf(cutoff1)
			[obj.x,new_val1] = obj.x.filterWithAlpha(value,obj.alpha2(cutoff1));
		end
	end
end


% f1 = OneEuroFilter(frequency,minicutoff,betaa);
% filteredvalue = f1.filter2(originalvalue,time);

		
