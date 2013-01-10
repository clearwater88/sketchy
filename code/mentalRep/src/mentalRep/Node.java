package mentalRep;
import java.util.ArrayList;


class Node implements Comparable<Node> {

	/* remove private, just for debugging */
	private ArrayList<Node> children; //guaranteed to be sorted in increasing id order
	static final int[] factors = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59};
	
	Node parent;
	final int id;
	
	Node(int id)  {
		this.id = id;
		children = new ArrayList<Node>();
		parent = null;
	}
	
	Node addChild(Node child) {
		if(child.parent != null) {
			throw new RuntimeException("Child already has parent: " + 
		                               child.id + ":" + id);
		}
		children.add(child);
		child.parent = this;
		return this;
	}
	
	ArrayList<Node> getChildren() {
		return children;
	}
	
	Node removeChild(Node child) {
		if(child.parent != this) {
			throw new RuntimeException("Trying to remove child from node which " +
					                   "is not its parent: " +
		                               (child.id) + " from " + (id));
		}
		if(!children.remove(child)) {
			throw new RuntimeException("Child is not recognized by parent: " + 
		                                child.id + " from " + (id));
		}
		child.parent = null;
		return this;
	}
	
	String toSubTree() {
		String str = Integer.toString(id) + "(";
		for (Node c: children) {
			str += c.toSubTree()+ ",";
		}
		str += ")";
		return str;
	}
	
	/*
	 * Probability of sequence
	 */
	
	public static double getSeqProb(ArrayList<Node> nodes, double decayTrav) {
		ArrayList <Node> frontier = new ArrayList<Node>();
		ArrayList <Double> frontierWeights = new ArrayList<Double>();
		frontier.addAll(nodes.get(0).getChildren());
		for (int i = 0; i < frontier.size(); i++) {
			frontierWeights.add(1.0);
		}
		return seqProb(nodes, 1, frontier,frontierWeights,1.0,decayTrav);
	}
	
	public static double seqProb(ArrayList<Node> nodes, int root, ArrayList<Node> frontier, ArrayList<Double> frontierWeights, double prob, double decayTrav) {
		if(frontier.size() != frontierWeights.size())
			throw new RuntimeException("Frontier nodes and weight sizes do not match");
				
		if (root == nodes.size())
			return prob;
		
		double totWeightFrontier = 0;
		for (double d : frontierWeights) {
			totWeightFrontier += d;
		}
		
		double totalProb = 0;
		for (int i = 0;i < frontier.size(); i++) {
			Node f = frontier.get(i);
			if (f.id == nodes.get(root).id) {
				
				ArrayList<Node> frontierCurr = new ArrayList<Node>(frontier);
				ArrayList<Double> frontierWeightsCurr = new ArrayList<Double>(frontierWeights);
				
				double probNode = prob*frontierWeights.get(i)/totWeightFrontier;
				//double probNode = prob/frontierCurr.size();
				frontierCurr.remove(i);
				frontierWeightsCurr.remove(i);
				
				for (int j = 0; j < frontierWeightsCurr.size(); j++) {
					frontierWeightsCurr.set(j, Math.exp(-decayTrav)*frontierWeightsCurr.get(j));
				}
				
				frontierCurr.addAll(f.getChildren());
				for (int j = 0; j < f.getChildren().size(); j++) {
					frontierWeightsCurr.add(1.0);
				}

				totalProb += seqProb(nodes, root+1,frontierCurr,frontierWeightsCurr,probNode, decayTrav);
			}
		}
		
		return totalProb;
	}
	
	/*
	 * 1 is the special 'stop' rule
	 */
	public static long getRuleId(Node parent) {
		
		long res = 1;
		ArrayList<Node> children = parent.getChildren();
		long old = res;
		for (Node c: children) {
			res *= factors[c.id];
			if (res < old) {
				System.out.println(old);
				System.out.println(res);
				throw new RuntimeException("Rule id went over");
			}
			old = res;
		}
		return res;
	}
	
	public static ArrayList<Integer> getRuleList(long ruleId) {
		ArrayList<Integer> res = new ArrayList<Integer>();

		for (int i=factors.length-1; i>= 0; i--) {
			while (true) {
				if (ruleId % factors[i] != 0) break;
				ruleId /= factors[i];
				res.add(i);	
			}
		}
		return res;
	}
	
	// stop rule not included (null terminator, in a sense)
	public static ArrayList<String> getRuleListStrings(long ruleId, ArrayList<String> partList) {
		ArrayList<String> res = new ArrayList<String>();
		ArrayList<Integer> rules = getRuleList(ruleId);
		
		for (int rule : rules) {
			res.add(partList.get(rule));
		}
		return res;
	}
	
	
	
	@Override
	public String toString() {
		return Integer.toString(id);
	}

	@Override
	public int compareTo(Node n) {
		if (this.id < n.id) return -1;
		if (this.id == n.id) return 0;
		return 1;
	}
}
