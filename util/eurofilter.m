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
		%private
		function al = alpha2(cutoff)
			te = 1.0/(obj.freq);
			pii = 4.0*(atan(1));
			tau = 1.0/(2*pii*cutoff);
			den = tau/te;
			al = 1.0/(1.0 + den);
		end
		function setFrequency(f)
			if (freq<=0)
				obj.freq = 1;
			else
				obj.freq = f;
			end
		end
		function setMinCutoff(mc)
			if (mc<=0)
				obj.minicutoff = 0.1;
			else
				obj.minicutoff = mc;
			end
		end
		function setBeta(b)
			beta1 = b;
		end
		function setDerivateCutoff(dc)
			if (dc<=0)
				obj.dcutoff = 0.1;
			else
				obj.dcutoff = dc;
			end
		end
		%public
		function obj = OneEuroFilter(fre,mincutoff,b1)
			setFrequency(fre);
			setMinCutoff(mincutoff);
			setBeta(b1);
			setDerivateCutoff(1.0);
			x = LowPassFilter(alpha2(mincutoff));
			dx = LowPassFilter(alpha2(obj.dcutoff));
			lasttime = -1;
		end
		function new_val1 = filter2(value,timestamp1)
			if(obj.lasttime~=(-1))
				obj.freq = 1.0/(timestamp1 - obj.lasttime) ;
			end
			obj.lasttime = timestamp1;
			dvalue = 0.0
			if(x.hasLastRawValue())
				dvalue = (value - x.lastRawValue()).obj.freq;
			edvalue = dx.filterWithAlpha(dvalue,alpha2(obj.dcutoff));
			cutoff1 = obj.minicutoff + (obj.beta1)*abs(edvalue);
			new_val1 = x.filterWithAlpha(value,alpha2(cutoff1));

	end
end


% f1 = OneEuroFilter(frequency,minicutoff,betaa);
% filteredvalue = f1.filter2(originalvalue,time);

		
