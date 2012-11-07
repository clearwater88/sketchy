package mentalRep;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class Tree {
	
	// Key is parent, value is hashmap of childrenRuleId,counts
	private HashMap<Integer,HashMap<Integer,Integer>> ruleCounts;
	private final Random gen = new Random();
	private final int[] primes = {2,3,5,7,11,13,17,19,23,29};
	
	private final int MAX_NODES;
	private final double alpha;
	
	private ArrayList<Node> nodes;
	private final Node root;
	private final int[] seq;
	
	public Tree(int [] seq, int MAX_NODES, double alpha) {
		this.seq = seq.clone();
		this.MAX_NODES = MAX_NODES;
		this.alpha = alpha;
		
		ruleCounts = new HashMap<Integer,HashMap<Integer,Integer>>();
		
		nodes = new ArrayList<Node>();
		
		for (int id: seq) {
			Node n = new Node(id);
			nodes.add(n);
			
			HashMap<Integer,Integer> temp = new HashMap<Integer,Integer>();
			temp.put(getRuleId(n),1);
			ruleCounts.put(id,temp);	
		}
		root = nodes.get(0);
		
		initializeTree();
	}
	
	public double getSeqProb() {
		return root.seqProb(seq);
	}
	
	public double treeProb(double alpha) {
		double res = 0;
		for (Node n : nodes) {
			
		}
		return res;
	}
	
	public long getNumTraversals() {
		return root.getNumTravers();
	}
	
	/*
	 * should clone for safety-defensive copying.
	 */
	public HashMap<Integer,HashMap<Integer,Integer>> getRuleCounts() {
		return ruleCounts;
	}
	
	public Tree sampleNewConfig() {
		// Generate child between 2->last (no point resampling root and 2nd elem)
		int childId = gen.nextInt(seq.length-2)+2;
		Node child = nodes.get(childId);
		Node originalParent = child.parent;
		
		int newParentId = gen.nextInt(childId);
		Node newParent = nodes.get(newParentId);
		
		
		//unlinkNode(nodes.get(childId));
		if (accept(originalParent,newParent,child)) {
			unlinkNode(child);
			linkNodes(newParent,child);
		}
		return this;
	}
	
	private boolean accept(Node originalParent, Node newParent, Node child) {
		if(originalParent==newParent)
			return true;
		
		int originalRuleId = getRuleId(originalParent);
		int newRuleId = getRuleId(newParent)*primes[child.id];
		
		HashMap<Integer,Integer> origParentRules = ruleCounts.get(originalParent.id);
		double origRuleFactor = alpha+origParentRules.get(originalRuleId)-1;
		
		System.out.println("X: " + origRuleFactor);
		
		int totOrigRuleCounts = 0;
		for (Integer n : origParentRules.keySet())
			totOrigRuleCounts += origParentRules.get(n);
		origRuleFactor /= (alpha*Math.pow(2, MAX_NODES)+totOrigRuleCounts-1);
		
		HashMap<Integer,Integer> newParentRules = ruleCounts.get(newParent.id);
		
		Integer newRule = newParentRules.get(newRuleId);
		int counts = 0;
		if (newRule != null)
			counts = newRule.intValue();
		
		double newRuleFactor = 1/(counts+alpha);
		
		int totNewRuleCounts = 0;
		for (Integer n : newParentRules.keySet())
			totNewRuleCounts += newParentRules.get(n);
		newRuleFactor *= (alpha*Math.pow(2, MAX_NODES)+totNewRuleCounts-1);
		
		
		double acceptFactor = newRuleFactor*origRuleFactor;
		//BUG: removing child does not mean removing a rule!
		//acceptFactor NEED TO DO PROB OF W NOW! 
		
		System.out.println("Factor: " + acceptFactor);

		boolean res = acceptFactor > gen.nextDouble(); 
		System.out.println("Decision: " + res);
		
		return res;
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
		decrementRule(parent);
		parent.addChild(child);
		incrementRule(parent);
	}
	
	private void unlinkNode(Node child) {
		Node parent = child.parent;
		decrementRule(parent);
		parent.removeChild(child);
		incrementRule(parent);
	}
	
	private void decrementRule(Node parent) {
		HashMap<Integer,Integer> parentRules = ruleCounts.get(parent.id);
		int ruleId = getRuleId(parent);
		Integer count = parentRules.get(ruleId);
		if (count == null) {
			throw new RuntimeException("Rules does not exist: " + ruleId);
		}
		int newVal = count.intValue()-1;
		if (newVal == 0) {
			parentRules.remove(ruleId);
		} else {
			parentRules.put(ruleId, newVal);
		}
		return;
	}
	
	private void incrementRule(Node parent) {
		HashMap<Integer,Integer> parentRules = ruleCounts.get(parent.id);
		int ruleId = getRuleId(parent);
		Integer count = parentRules.get(ruleId);

		int oldVal = 0;
		if (count != null) {
			oldVal = count.intValue();
		}
		parentRules.put(ruleId, oldVal+1);
		return;
	}
	
	/*
	 * children of parent guaranteed to be sorted
	 * Stop symbol: T
	 * Rule-ids guaranteed to be unique to parent,children pair,
	 * but not guaranteed to be in any sort of order
	 * 1 is the special 'stop' rule
	 */
	private int getRuleId(Node parent) {
		
		int res = 1;
		ArrayList<Node> children = parent.children;
		for (Node c: children) {
			res *= primes[c.id];
		}
		return res;
	}
	
	@Override
	public String toString() {
		return root.toSubTree();
	}
	
	
}
