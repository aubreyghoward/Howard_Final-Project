function Seq = MC_GetRegularExpression(file)
%This function returns a regular expression string from a meme output file.

%retrieve information
fid = fopen(file);
extraction = textscan(fid,'%s');
fclose(fid);

   %retrieve expression from file
   for j = 1:length(extraction{1,1})-4
        %revcomp version
        if ~isempty(strmatch(extraction{1,1}{j,1},'Motif')) && ...
                ~isempty(strmatch(extraction{1,1}{j+1,1},'1')) && ...
                ~isempty(strmatch(extraction{1,1}{j+2,1},'regular')) &&...
                ~isempty(strmatch(extraction{1,1}{j+3,1},'expression')) 

            expression = extraction{1,1}{j+5,1};
        end
        
   end
   
   %translate to common language
   Seq = [];
   j = 1;
   while j <= length(expression)
       
       %check for regular nucleotide expressions
       if strmatch(expression(j),'A')
           Seq = strcat(Seq,'A');
           j = j + 1;
       elseif strmatch(expression(j),'C')
           Seq = strcat(Seq,'C');
           j = j + 1;
       elseif strmatch(expression(j),'G')
           Seq = strcat(Seq,'G');
           j = j + 1;
       elseif strmatch(expression(j),'T')
           Seq = strcat(Seq,'T');
           j = j + 1;
              
       else %evaluate nested expression
           stop = min(strfind(expression(j:length(expression)),']'))+j-1;
           
           if length(j+1:stop-1) == 2; %2-ples
               
               frag = expression(j+1:stop-1);
               
               if ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'C'))
                   Seq = strcat(Seq,'M');
               elseif ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'G'))
                   Seq = strcat(Seq,'R');
               elseif ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'W');
               elseif ~isempty(strfind(frag,'C')) && ~isempty(strfind(frag,'G'))
                   Seq = strcat(Seq,'S');
               elseif ~isempty(strfind(frag,'C')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'Y');
               elseif ~isempty(strfind(frag,'G')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'K');
               end
               
               j = j + 4;
               
           elseif length(j+1:stop-1) == 3; %3-ples
               
               
               frag = expression(j+1:stop-1);
               
               if ~isempty(strfind(frag,'C')) && ~isempty(strfind(frag,'G')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'B');
               elseif ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'G')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'D');
               elseif ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'C')) && ~isempty(strfind(frag,'T'))
                   Seq = strcat(Seq,'H');
               elseif ~isempty(strfind(frag,'A')) && ~isempty(strfind(frag,'C')) && ~isempty(strfind(frag,'G'))
                   Seq = strcat(Seq,'V');
               end
               
               j = j + 5;
               
          
           else %4-ples
               
              Seq = strcat(Seq,'N');
              j = j + 6;
              
           end
       end
       
   end
   
   %return value 'Seq' is in the appropriate format
   
end