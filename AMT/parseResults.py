import os;
import re;
import time;
import HIT_IO;
import HIT_parser;
import Stroke_parser;

RES_DIR = 'results/';
OUT_FILE = RES_DIR + 'allResults.csv';
HIT_OUT = RES_DIR + "HIT_OUT";

#HIT_parser.compile_HIT_results(RES_DIR, OUT_FILE);
res = HIT_parser.parse_HIT_lines(OUT_FILE);
mapping = res['mapping'];
parsed = res['parsed'];

HIT_IO.output_done_HIT(mapping,parsed,HIT_OUT);
HIT_IO.output_strokes(parsed[0][32],'example.txt');

for imgs in parsed:
    strokes = Stroke_parser.parse_strokes(imgs[mapping['Answer.strokes']]);

    svgMatch = '(svgSubset/.+)';
    svgName = re.search(svgMatch,imgs[mapping['Input.image_url']]).group(0);
    svgFile = open(svgName,'r');
    svgSketch = svgFile.readlines();
    for i in range(len(svgSketch)):
        svgSketch[i] = svgSketch[i].rstrip();
    svgFile.close();

    print svgName;
    overlaySvg = Stroke_parser.mergeSvgs(svgSketch,strokes);
    f = open('exampleSvg.svg','w');
    for i in overlaySvg:
        f.write(i+'\n');
    f.close();

    Stroke_parser.outputStrokeSvg(strokes,'strokes.svg');
    print 'done';
    input();



