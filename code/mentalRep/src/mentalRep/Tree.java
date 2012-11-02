package mentalRep;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class Tree {
	
	private HashMap<Integer,Integer> ruleCounts;
	private final Random gen = new Random();
	private final int MAX_ID;
	
	private ArrayList<Node> nodes;
	private final Node root;
	private final int[] seq;
	
	public Tree(int [] seq, int MAX_ID) {
		this.seq = seq.clone();
		this.MAX_ID = MAX_ID;
		
		nodes = new ArrayList<Node>();
		
		for (int id: seq) {
			nodes.add(new Node(id));
		}
		root = nodes.get(0);
		ruleCounts = new HashMap<Integer,Integer>();
		initializeTree();
	}
	
	public double getSeqProb() {
		return root.seqProb(seq);
	}
	
	public long getNumTraversals() {
		return root.getNumTravers();
	}
	
	private void initializeTree() {
		for (int i = nodes.size()-1; i>0; i--) {
			int parentNode = gen.nextInt(i);
			nodes.get(parentNode).addChild(nodes.get(i));
		}
		if(root.seqProb(seq) == 0) {
			throw new RuntimeException("invalid initialized tree!");
		}
	}
	@Override
	public String toString() {
		return root.toSubTree();
	}
	
	
}
