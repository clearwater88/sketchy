package mentalRep;
import java.util.ArrayList;
import java.util.Collections;

import net.sf.javaml.utils.GammaFunction;

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
	double seqProb(ArrayList<Node> nodes) {
		ArrayList <Node> frontier = new ArrayList<Node>();
		frontier.addAll(children);
		double temp = doSeqProb(nodes, 1, frontier,1.0);
		if (temp == 0) {
			System.out.println(temp);
			System.out.println("========");
			System.out.println(nodes);
			System.out.println(nodes.get(0).toSubTree());		
			throw new RuntimeException("aw nuts");
		}			
		return temp; 
	}
	
	private double doSeqProb(ArrayList<Node> nodes, int root, ArrayList<Node> frontier, double prob) {
		if (root == nodes.size())
			return prob;
		
		double totalProb = 0;
		for (Node f: frontier) {
			if (f.id == nodes.get(root).id) {
				
				ArrayList<Node> frontierCurr = new ArrayList<Node>(frontier);				
				frontierCurr.remove(f);
				frontierCurr.addAll(f.children);
								
				totalProb += doSeqProb(nodes, root+1, frontierCurr,prob/frontier.size());

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
