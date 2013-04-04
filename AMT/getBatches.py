import os;
import glob;
import random;
import HIT_IO;

NUM_BATCHES = 1;

NUM_EXAMPLES_PER_CLASS= 80;
NUM_PARTITIONS_PER_CLASS = 1;

READ_SOURCE_DIR = 'svgSubset/';

READ_OUT_WWW = 'https://cs.brown.edu/people/jchua/sketchy/svgSubset/'
OUT_DIR = "batches/";
BATCH_FILE = "batch2_";

RES_DIR = 'results/';
HIT_OUT = RES_DIR + 'HIT_OUT';


headers = ["class","image_url","parts"];

def getPartNames(classNames):
    res = {};
    for d in classNames:
        dirUse = READ_SOURCE_DIR+d;
        partFile = dirUse + "/" + d + "Parts.txt";
        f = open(partFile,'r');
        cont = f.readlines();

        partNames = "";
        for s in cont:
            if (len(partNames) != 0):
                partNames += ",";
            partNames += s.strip();
        partNames = "\"" + partNames + "\"";

        res[d] = partNames;
    return res;
    
def partition(arr, n):
    division = len(arr) / float(n) 
    return [arr[int(round(division * i)): int(round(division * (i + 1)))] for i in xrange(n)]

#for given class names, retrieves images from it, up to NUM_EXAMPLES_PER_CLASS of each class
def getClassIms(classNames):
    res = {};
    
    for d in classNames:
        imListAll = os.listdir(READ_SOURCE_DIR+d);

        imList = [];

        randRange = range(80);
        #random.shuffle(randRange);
        
        for j in range(NUM_EXAMPLES_PER_CLASS):
            i = randRange[j];
            if(not imListAll[i].endswith(".svg")):
                continue;
            imList.append(imListAll[i]);

        for i in range(len(imList)):
            imList[i] = READ_OUT_WWW + d + "/" + imList[i];

        random.shuffle(imList);
        res[d] = partition(imList,NUM_PARTITIONS_PER_CLASS);        
    return res;

def reorder(arr,order):
    return [arr[i] for i in order];

doneHIT = set(HIT_IO.read_done_HIT(HIT_OUT));
classNames = os.listdir(READ_SOURCE_DIR);
classIms = getClassIms(classNames);
partNames = getPartNames(classNames);

# only get already existing HITS; for no-parts experiment
##for c in classIms:
##    partitionTemp = [];
##    for partitionImgs in classIms[c]:
##        temp = [];
##        for img in partitionImgs:
##            if img in doneHIT:
##                temp.append(img);
##        partitionTemp.append(temp);
##    classIms[c] = partitionTemp;
# only get already existing HITS; for no-parts experiment

# Build list of partitions and corresponding classes
partitionList = [];
classList = [];
for n in classIms:
    for p in classIms[n]:
        partitionList.append(p);
        classList.append(n);

batchInds = range(0,len(classList));
random.shuffle(batchInds);

partitionList = reorder(partitionList,batchInds);
classList = reorder(classList,batchInds);

partitionList = partition(partitionList,NUM_BATCHES);
classList = partition(classList,NUM_BATCHES);

### Now output batches
for i in range(0,len(classList)):
    f = open(OUT_DIR + BATCH_FILE + str(i) + ".csv",'w');
    f.write(",".join(headers) +"\n");

    pListUse = partitionList[i];
    cListUse = classList[i];
    
    for j in range(0,len(cListUse)):
        classUse = cListUse[j];
        for k in range(0,len(pListUse[j])):
            f.write(classUse + "," +
                    pListUse[j][k] + "," +
                    partNames[classUse] + "\n");
    f.close();
        
s = 0;
for key in classIms:
    s = s+len(classIms[key]);















