import os
import glob
import random;

NUM_BATCHES = 20;

NUM_PARTITIONS_PER_CLASS = 10; #80 examples per class

READ_SOURCE_DIR = 'pngSubset/';

READ_OUT_WWW = 'http://cs.brown.edu/people/jchua/sketchy/'
OUT_DIR = "batches/";

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
    return [ arr[int(round(division * i)): int(round(division * (i + 1)))] for i in xrange(n) ]

def getClassPartitions(classNames):
    res = {};
    
    for d in classNames:
        dirUse = READ_SOURCE_DIR+d;
        imListAll = os.listdir(dirUse);

        imList = [];
        for i in range(len(imListAll)):
            if(not imListAll[i].endswith(".png")):
                continue;
            imList.append(imListAll[i]);

        for i in range(len(imList)):
            imList[i] = READ_OUT_WWW + d + "/" + imList[i];

        random.shuffle(imList);
        res[d] = partition(imList,NUM_PARTITIONS_PER_CLASS);        
    return res;

def printPartitions(classDict):
    for d in classDict:
        print "====" + d + "====";
        for l in classDict[d]:
            print "   " + ','.join(l);

def printPartitionSizes(classDict):
    for d in classDict:
        print "====" + d + "====";
        for l in classDict[d]:
            print str(len(l)) + ",";

def reorder(arr,order):
    return [arr[i] for i in order];

classNames = os.listdir(READ_SOURCE_DIR);
classDict = getClassPartitions(classNames);
partNames = getPartNames(classNames);

# Build list of partitions and corresponding classes
partitionList = [];
classList = [];
for n in classDict:
    for p in classDict[n]:
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
    f = open(OUT_DIR + "batch" + str(i) + ".csv",'w');
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
        



















