package mentalRep;

import java.util.ArrayList;

public class Main {

	public static void main(String [ ] args) {
		int NUM_NODES = 5;
		
		int [] seq = new int[NUM_NODES];
		seq[0] = 0;
		seq[1] = 1;
		seq[2] = 2;
		seq[3] = 3;
		seq[4] = 4;
		Tree t = new Tree(seq,NUM_NODES);
		System.out.println("======");
		System.out.println("Num traversals: " + t.getNumTraversals());
		System.out.println(t);
		System.out.println("Prob of tree seq: " + t.getSeqProb());
		
		
		/*
		ArrayList<Node> a = new ArrayList<Node>();
		for (int i=0; i < NUM_NODES; i++) {
			a.add(new Node(i));
		}
		
		a.get(1).addChild(a.get(3));
		a.get(0).addChild(a.get(1));
		a.get(2).addChild(a.get(4));
		a.get(0).addChild(a.get(2));

		System.out.println("number of traversals: " + a.get(0).getNumTravers());
		System.out.println(a.get(0));
		
		
		int [] arr = new int[NUM_NODES];
		arr[0] = 0;
		arr[1] = 1;
   	    arr[2] = 3;
    	arr[3] = 2;
    	arr[4] = 4;
    	System.out.println("traversal possible: " + a.get(0).verifySeq(arr));
    	*/
	}

}
