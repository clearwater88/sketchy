import os;
import re;
import time;
import HIT_IO;
import HIT_parser;
import Stroke_parser;

RES_DIR = 'results/noParts2/';
RES_ANNOT_DIR = RES_DIR+ 'annotations/';
OUT_FILE = RES_DIR + 'allResults.csv';
HIT_OUT = RES_DIR + "HIT_OUT";

HIT_parser.compile_HIT_results(RES_DIR, OUT_FILE);
res = HIT_parser.parse_HIT_lines(OUT_FILE);
mapping = res['mapping'];
parsed = res['parsed'];

HIT_IO.output_done_HIT(mapping,parsed,HIT_OUT);

annotOnlyPref = 'annotOnly-'; # json strokes
totalPref = ''; # svg overlay
svgAnnotePref = 'annotOnly-'; # svg annotation only

classMatch = '/(.+?)/(\d+)\.svg';
imNumCounts = {};
for imgs in parsed:
    strokes = Stroke_parser.parse_strokes(imgs[mapping['Answer.strokes']]);

    svgMatch = '(svgSubset/.+)';
    svgName = re.search(svgMatch,imgs[mapping['Input.image_url']]).group(0);
    print svgName

    svgFile = open(svgName,'r');
    svgSketch = svgFile.readlines();
    for i in range(len(svgSketch)):
        svgSketch[i] = svgSketch[i].rstrip();
    svgFile.close();

    m = re.search(classMatch,svgName);
    classType = m.group(1);
    imNum = m.group(2);    

    if not(imNum in imNumCounts):
        imNumCounts[imNum] = 0;

    numUse = imNumCounts[imNum];
    annotOnlyDir = RES_ANNOT_DIR + str(classType) +'/'; 
    annotFile = annotOnlyPref + str(imNum) + '-' + str(numUse) + '.json';
    totalOut = RES_ANNOT_DIR + str(classType) +'/' + totalPref + str(imNum) + '-' + str(numUse) + '.svg';
    svgAnnotOnlyOut = RES_ANNOT_DIR + str(classType) + '/' + svgAnnotePref + str(imNum) + '-' + str(numUse) + '.svg';
    
    imNumCounts[imNum] = imNumCounts[imNum]+1;
    HIT_IO.output_strokes(imgs[mapping['Answer.strokes']],annotOnlyDir, annotFile);

    overlaySvg = Stroke_parser.mergeSvgs(svgSketch,strokes);
    f = open(totalOut,'w');
    for i in overlaySvg:
        f.write(i+'\n');
    f.close();

    Stroke_parser.outputStrokeSvg(strokes,svgAnnotOnlyOut);



