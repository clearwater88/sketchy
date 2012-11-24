package mentalRep;
import java.util.ArrayList;


class Node implements Comparable<Node> {

	/* remove private, just for debugging */
	private ArrayList<Node> children; //guaranteed to be sorted in increasing id order
		
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
	
	/*
	 * Probability of sequence
	 */
	public double seqProb(ArrayList<Node> nodes, int root, ArrayList<Node> frontier, ArrayList<Double> frontierWeights, double prob, double decayTrav) {
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
					frontierWeightsCurr.set(j, decayTrav*frontierWeightsCurr.get(j));
				}
				
				frontierCurr.addAll(f.children);
				for (int j = 0; j < f.children.size(); j++) {
					frontierWeightsCurr.add(1.0);
				}

				totalProb += seqProb(nodes, root+1,frontierCurr,frontierWeightsCurr,probNode, decayTrav);

			}
		}
		
		return totalProb;

		
		/*Assume all frontier nodes equal-probably*/
		/*
		prob /= frontier.size();
		frontier.remove(foundNode);
		frontier.addAll(foundNode.children);
		return doSeqProb(nodes, root+1, frontier,prob);
		*/
	}
	
	String toSubTree() {
		String str = Integer.toString(id) + "(";
		for (Node c: children) {
			str += c.toSubTree()+ ",";
		}
		str += ")";
		return str;
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
