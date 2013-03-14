import os;
import re;
import time;

RES_DIR = 'results/';
OUT_FILE = RES_DIR + 'allResults.csv';

def stupidParse(line,mapping):
    strDblQt = "(?!,)\"\"(?!,)";
    strSentinel = "&&&";
    m="\",\"";
    
    res = [];

    line = re.sub(strDblQt,strSentinel,line);

    sp = re.split(m,line);
    
    for i in range(len(sp)):
        sp[i] = re.sub(strSentinel,"\"",sp[i]); # only single-quote string
        print mapping[i] + ":" + sp[i];
        time.sleep(0.2);
    return res;

def readFields(outFile):
    f = open(outFile,'r');
    m="\",\"";
    
    res = {}

    mapping = [];
    isFirstLine = True;
    for line in f.readlines():
        line = line.rstrip();
        line = line[1:-1]; # slice off " marks

        if (isFirstLine):
            mapping = re.split(m,line);
            for m in mapping:
                res[m] = [];
        else:
            stupidParse(line,mapping);
        
        isFirstLine = False;
    return res;



def compile_results(resDir,outFile):
    out = open(outFile,'w');
    isFirstFile = True;

    fList = os.listdir(resDir);

    for f in fList:
        if (f in outFile):
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


compile_results(RES_DIR, OUT_FILE);
dic= readFields(OUT_FILE);

    
