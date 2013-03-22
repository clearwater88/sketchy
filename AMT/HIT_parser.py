import os;
import re;

# combines all result files in resDir and outputs outFile
def compile_HIT_results(resDir,outFile):
    out = open(outFile,'w');
    isFirstFile = True;

    fList = os.listdir(resDir);

    for f in fList:
        if ((f in outFile) or not (f.endswith('.csv'))):
            continue;
        print "Analyzing file: " + f;
        isFirstLine = True;
        res_f = open(resDir + f,'r');
        lines = res_f.readlines();
        for line in lines:
            line = line.rstrip(); # standardize
            if (isFirstLine):
                if (isFirstFile):
                    out.write(line+"\n");                
            else:
                out.write(line+"\n");
                
            isFirstLine = False;

        isFirstFile = False;
        res_f.close();
        
    out.close();

def _parse_HIT_line(line,mapping):
    strDblQt = "(?!,)\"\"(?!,)";
    strSentinel = "&&&";
    m="\",\"";

    res = re.split(m,re.sub(strDblQt,strSentinel,line));    
    for i in range(len(res)):
        res[i] = re.sub(strSentinel,"\"",res[i]); # only single-quote string
        res[i] = re.sub("\"\"","\"",res[i]);
    return res;

def parse_HIT_lines(outFile):
    f = open(outFile,'r');
    m="\",\"";
    
    parsed = [];
    res = {};

    mapping = {};
    isFirstLine = True;
    for line in f.readlines():
        line = line.rstrip();
        line = line[1:-1]; # slice off " marks

        if (isFirstLine):
            temp = re.split(m,line);
            for i in range(len(temp)):
                mapping[temp[i]] = i;
        else:
            parsed.append(_parse_HIT_line(line,mapping));
        isFirstLine = False;
        
    res['mapping'] = mapping;
    res['parsed'] = parsed;
    return res;

