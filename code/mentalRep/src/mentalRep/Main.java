package mentalRep;

import java.util.ArrayList;
import java.util.HashMap;

public class Main {

	public static void main(String [ ] args) {
		int NUM_NODES = 7;
		
		int [] seq = new int[NUM_NODES];
		seq[0] = 0;
		seq[1] = 1;
		seq[2] = 2;
		seq[3] = 3;
		seq[4] = 4;
		seq[5] = 5;
		seq[6] = 6;
		Tree t = new Tree(seq,6,0.01);
		
		for (int i=0;i<100;i++) {
			System.out.println("========");
			System.out.println(t);
			System.out.println("Prob of tree seq: " + t.getSeqProb());
	 		HashMap<Integer,HashMap<Integer,Integer>> ruleCounts = t.getRuleCounts();
	 		
	 		/*
			System.out.println("Rule counts: ");
			for (int key: ruleCounts.keySet()) {
				System.out.println(key + "/" + ruleCounts.get(key));
			}
			*/
			t.sampleNewConfig();
		}
	}

}
