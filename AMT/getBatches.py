import os
import random;

NUM_BATCHES = 500;

NUM_PARTITIONS_PER_CLASS = 10; #80 examples per class

READ_SOURCE_DIR = 'png/';

READ_OUT_WWW = 'http://cs.brown.edu/people/jchua/sketchy/'
OUT_DIR = "batches/";

headers = ["class","image_url"];

def partition(arr, n):
    division = len(arr) / float(n) 
    return [ arr[int(round(division * i)): int(round(division * (i + 1)))] for i in xrange(n) ]

def getClassPartitions(dirs):
    res = {};
    
    for d in dirs:
        dirUse = READ_SOURCE_DIR+d;
        imList = os.listdir(dirUse);
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
        for k in range(0,len(pListUse[j])):
            f.write(cListUse[j] + "," + pListUse[j][k] + "\n");        

    f.close();
        



















