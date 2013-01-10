package mentalRep;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class Tree {
	
	// arraylist index is parent id; start from 0 for start symbol
	private ArrayList<HashMap<Long,Integer>> ruleCounts;
	private static final Random gen = new Random();

	private final double alpha;
	
	private ArrayList<Node> nodes;
	private final Node root;
	
	public Tree(int [] seq, double alpha, ArrayList<HashMap<Long,Integer>> ruleCounts) {
		this.alpha = alpha;
		this.ruleCounts = ruleCounts;
		
		nodes = new ArrayList<Node>();
		
		for (int id: seq) {
			Node n = new Node(id);
			nodes.add(n);
			long ruleId = Node.getRuleId(n);
			
			HashMap<Long,Integer> rule = ruleCounts.get(id);

			if (rule.get(ruleId) == null)
				rule.put(ruleId,1);
			else
				rule.put(ruleId,rule.get(ruleId)+1);

		}
		root = nodes.get(0);
		
		initializeTree();
	}
	
	private void initializeTree() {
		for (int i = nodes.size()-1; i>0; i--) {
			int parentNode = gen.nextInt(i);
			//int parentNode = i-1;
			linkNodes(nodes.get(parentNode),nodes.get(i));
		}
		
		ArrayList <Node> frontier = new ArrayList<Node>();
		ArrayList <Double> frontierWeights = new ArrayList<Double>();
		frontier.addAll(root.getChildren());
		for (int i = 0; i < frontier.size(); i++)
			frontierWeights.add(1.0);
	}

	public double sampleNewConfig(double decayTrav) {
		// Generate child between 2->last (no point resampling root and 2nd elem)
		if (nodes.size() <= 2) return 1.0; // propose and accept same move
		
		int childId = gen.nextInt(nodes.size()-2)+2;
		Node child = nodes.get(childId);
		Node originalParent = child.parent;
		
		int newParentId = gen.nextInt(childId);
		Node newParent = nodes.get(newParentId);
		
		boolean accepted = accept(originalParent,newParent,child,decayTrav);
		if (accepted) {
			unlinkNode(child);
			linkNodes(newParent,child);
		}
		return accepted ? 1.0 : 0.0;
	}
	
	private boolean accept(Node originalParent, Node newParent, Node child, double decayTrav) {
		if(originalParent==newParent)
			return true;
		
		long origParent_origRule = Node.getRuleId(originalParent);
		long origParent_newRule = Node.getRuleId(originalParent)/Node.factors[child.id];
		
		long newParent_origRule = Node.getRuleId(newParent);
		long newParent_newRule = Node.getRuleId(newParent)*Node.factors[child.id];
			
		HashMap<Long,Integer> origParentRules = ruleCounts.get(originalParent.id);
		HashMap<Long,Integer> newParentRules = ruleCounts.get(newParent.id);
	
		double count_origPar_origRule = alpha+origParentRules.get(origParent_origRule);
		double count_newPar_origRule = alpha+newParentRules.get(newParent_origRule);
		
		Integer temp = origParentRules.get(origParent_newRule);
		double count_origPar_newRule = temp == null ? alpha : alpha+temp.intValue();
		temp = newParentRules.get(newParent_newRule);
		double count_newPar_newRule = temp == null ? alpha : alpha+temp.intValue();
		
		double acceptFactorTreeLike = (count_origPar_newRule/(count_origPar_origRule-1))
				                      *(count_newPar_newRule/(count_newPar_origRule-1));

		double acceptFactorSeq = 1/Node.getSeqProb(nodes,decayTrav);
		
		// ugly
		unlinkNode(child);
		linkNodes(newParent,child);
		acceptFactorSeq *= Node.getSeqProb(nodes,decayTrav);
		unlinkNode(child);
		linkNodes(originalParent,child);
		// ugly
		
		double acceptprob = acceptFactorTreeLike*acceptFactorSeq;			
		return acceptprob > gen.nextDouble(); 
	}
	
	public ArrayList<Node> getNodes() {
		return nodes;
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
	
	private void incrementRule(Node parent) {
		HashMap<Long,Integer> parentRules = ruleCounts.get(parent.id);
		long ruleId = Node.getRuleId(parent);
		Integer count = parentRules.get(ruleId);

		int oldVal = 0;
		if (count != null) {
			oldVal = count.intValue();
		}
		parentRules.put(ruleId, oldVal+1);
		return;
	}
	
	private void decrementRule(Node parent) {
		HashMap<Long,Integer> parentRules = ruleCounts.get(parent.id);
		long ruleId = Node.getRuleId(parent);
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
	
	
	
	@Override
	public String toString() {
		return root.toSubTree();
	}
}
