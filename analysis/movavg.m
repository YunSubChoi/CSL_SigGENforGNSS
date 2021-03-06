function [short,long] = movavg(asset,lead,lag,alpha) 
%MOVAVG Leading and lagging moving averages chart. 
%   [SHORT,LONG] = MOVAVG(ASSET,LEAD,LAG,ALPHA) plots leading and lagging  
%   moving averages.  ASSET is the security data, LEAD is the number of  
%   samples to use in leading average calculation, and LAG is the number 
%   of samples to use in the lagging average calculation.  ALPHA is the 
%   control parameter which determines what type of moving averages are
%   calculated.  ALPHA = 0 (default) corresponds to a simple moving average,  
%   ALPHA = 0.5 to a square root weighted moving average, ALPHA = 1 
%   to a linear moving average, ALPHA = 2 to a square weighted moving  
%   average, etc.  To calculate the exponential moving averages,   
%   let ALPHA = 'e'.  
% 
%   MOVAVG(ASSET,3,20,1) plots linear 3 sample leading and 20 sample  
%   lagging moving averages.   
% 
%   [SHORT,LONG] = MOVAVG(ASSET,3,20,1) returns the leading and lagging  
%   average data without plotting it. 
% 
%   See also BOLLING, HIGHLOW, CANDLE, POINTFIG. 
 
%       Copyright 1995-2010 The MathWorks, Inc.
%       $Revision: 1.6.2.5 $   $Date: 2011/02/28 01:22:29 $ 
 
if nargin < 4 
  alpha = 0; % Default is simple moving average 
end 
if nargin < 3 
  error(message('finance:movavg:missingInputs')) 
end 
[m,n] = size(asset); 
if m > 1 & n > 1 
  error(message('finance:movavg:invalidInputSize')) 
end 
if lead > lag 
 error(message('finance:movavg:badLeadInput')) 
end 
asset = asset(:); 
r = length(asset); 
if lead < 1 | lead > r | lag < 1 | lag > r 
 error(message('finance:movavg:badLeadLagInput', num2str( r ))) 
end 
 
if lower(alpha) == 'e' 
  % compute exponential moving average 
  % calculate smoothing constant (alpha) 
  alphas = 2/(lead+1); 
  alphal = 2/(lag+1); 
  % first exponential average is first price 
  a(1) = asset(1); 
  b(1) = asset(1); 
  % preallocate matrices 
  a = [a;zeros(r-1,1)]; 
  b = [b;zeros(r-1,1)]; 
  % lagging average 
  % For large matrices of input data, FOR loops are more efficient 
  % than vectorization. 
  for j = 2:r
    a(j) = a(j-1) + alphal*(asset(j) - a(j-1)); 
  end
  % leading average 
  for j = 2:r
    b(j) = b(j-1) + alphas*(asset(j) - b(j-1)); 
  end
else 
  % compute general moving average (ie simple, linear, etc) 
  % build weighting vectors 
  i = 1:lag; 
  wa(i) = (lag - i + 1).^alpha./sum([1:lag].^alpha); 
  i = 1:lead; 
  wb(i) = (lead - i + 1) .^alpha/sum([1:lead].^alpha); 
  % build moving average vectors by filtering asset through weights 
  a = filter(wa,1,asset); 
  b = filter(wb,1,asset); 
end 
 
if nargout == 0 
  % If no output arguments, plot moving averages 
	h = plot(1:r-lag+1,asset(lag:r),1:r-lag+1,a(lag:r),1:r-lag+1,b(lag:r));  
  if get(0,'screendepth') > 1 
    cls = get(gca,'colororder'); 
    set(h(1),'color',cls(1,:)) 
    set(h(2),'color',cls(2,:)) 
    set(h(3),'color',cls(3,:)) 
  end 
else 
  % output data to workspace 
  short = b; 
  long = a; 
end
