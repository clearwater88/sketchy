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
	
	/*
	 * should clone for safety-defensive copying.
	 */
	public HashMap<Integer,Integer> getRuleCounts() {
		return ruleCounts;
	}
	
	private void initializeTree() {
		for (int i = nodes.size()-1; i>0; i--) {
			int parentNode = gen.nextInt(i);
			linkNodes(nodes.get(parentNode),nodes.get(i));
		}
		if(root.seqProb(seq) == 0) {
			throw new RuntimeException("invalid initialized tree!");
		}
	}
	private void linkNodes(Node parent, Node child) {
		if (!parent.children.isEmpty())
			decrementRule(getRuleId(parent));
		parent.addChild(child);
		incrementRule(getRuleId(parent));
	}
	
	private void unlinkNodes(Node parent, Node child) {
		if (!parent.children.isEmpty())
			decrementRule(getRuleId(parent));
		parent.removeChild(child);
		incrementRule(getRuleId(parent));
	}
	
	private void decrementRule(int ruleCode) {
		Integer count = ruleCounts.get(ruleCode);
		if (count == null) {
			throw new RuntimeException("Rules does not exist: " + ruleCode);
		}
		int newVal = count.intValue()-1;
		if (newVal == 0) {
			ruleCounts.remove(ruleCode);
		} else {
			ruleCounts.put(ruleCode, newVal);
		}
		return;
	}
	
	private void incrementRule(int ruleCode) {
		Integer count = ruleCounts.get(ruleCode);
		int oldVal = 0;
		if (count != null) {
			oldVal = count.intValue();
		}
		ruleCounts.put(ruleCode, oldVal+1);
		return;
	}
	
	/*
	 * children of parent guaranteed to be sorted
	 * 1-based rules.
	 * Rule 0 = no rule (no kids)
	 * Rule-ids guaranteed to be unique to parent,children pair,
	 * but not guaranteed to be in any sort of order
	 */
	private int getRuleId(Node parent) {
		ArrayList<Node> children = parent.children;
		if (children.isEmpty())
			return 0;
		
		int res = 0;
		for (Node c: children) {
			res = res*(MAX_ID+1) + (c.id+1);
		}
		res = res*(MAX_ID+1) + (parent.id+1);
		return res;
		
		/*	
  	     * Compute Godel number;
	     */
		/*
			double res = Math.pow(primes[0],parent.id);
			int childId = children.get(0).id;
			int count = 1;
			for (Node c : children.subList( 1, children.size() )) {
				if (childId == c.id)
					count++;
				else {
					res *= Math.pow(primes[childId+1],count);
					childId = c.id;
					count = 1;
				}	
			}
			res *= Math.pow(primes[childId+1],count);
			return (int) res;
		 */
		
	}
	
	@Override
	public String toString() {
		return root.toSubTree();
	}
	
	
}
