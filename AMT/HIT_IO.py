import pickle;

def output_done_HIT(mapping,parsed,outFile):
    imUrlKey = "Input.image_url";
    key = mapping[imUrlKey];

    res = [];
    for ex in parsed:
        res.append(ex[key]);
    
    pickle.dump(res,open(outFile,'w'));

# convenience
def read_done_HIT(inFile):
   return pickle.load(open(inFile,'r')); 

def output_strokes(strokes,fileOut):
    f = open(fileOut,'w');
    f.write(strokes);
    f.close();
        
