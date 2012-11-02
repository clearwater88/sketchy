package mentalRep;
import java.util.ArrayList;
import java.util.Collections;

import net.sf.javaml.utils.GammaFunction;

public class Node implements Comparable<Node> {

	/* remove private, just for debugging */
	ArrayList<Node> children; //guaranteed to be sorted in increasing id order
	
	/* Only updated through updateTraverse(), which is only called
	 * from addChild, and removeChild
	 */
	private double logNumTravs;
	private int numNodes;
	
	private Node parent;
	final int id;
	
	public Node(int id)  {
		this.id = id;
		children = new ArrayList<Node>();
		logNumTravs = 0;
		numNodes = 1;
		parent = null;
	}
	
	public Node addChild(Node child) {
		if(child.parent != null) {
			throw new RuntimeException("Child already has parent: " + 
		                               child.id + ":" + id);
		}
		children.add(child);
		Collections.sort(children);
		child.parent = this;
		updateTraverse();
		return this;
	}
	
	public Node removeChild(Node child) {
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
		updateTraverse();
		return this;
	}
	
	private void updateTraverse() {
		double logNumTravCombs = 0;
		double logDenomCombs = 0;
		int nChildSubTrees = 0;
		for (Node c: children) {
			logNumTravCombs += c.logNumTravs;
			int nChildSub = c.numNodes;
			nChildSubTrees += nChildSub;
			logDenomCombs += GammaFunction.logGamma(nChildSub+1);
		}
		numNodes = nChildSubTrees+1;
		logNumTravs = logNumTravCombs 
				      + (GammaFunction.logGamma(nChildSubTrees+1) 
				      - logDenomCombs);
		
		if(parent != null) {
			parent.updateTraverse();
		}
	}
	
	/*
	 * Probability of sequence
	 */
	public double seqProb(int[] seq) {
		if (seq[0] != id) {
			return 0;
		}
		ArrayList <Node> frontier = new ArrayList<Node>();
		frontier.addAll(children);
		return doSeqProb(seq, 1, frontier,1);
	}
	
	private double doSeqProb(int[] seq, int root, ArrayList<Node> frontier, double prob) {
		if (root == seq.length)
			return prob;
		
		Node foundNode = null;
		for (Node f: frontier) {
			if (f.id == seq[root]) {
				foundNode = f;
				break;
			}
		}
		if (foundNode == null) {
			return 0;
		}
		
		/*Assume all frontier nodes equal-probably*/
		prob /= frontier.size();
		frontier.remove(foundNode);
		frontier.addAll(foundNode.children);
		return doSeqProb(seq, root+1, frontier,prob);
	}
	
	public long getNumTravers() {
		return Math.round(Math.exp(logNumTravs));
	}
	
	@Override
	public boolean equals(Object n) {
		return this.id == ((Node) n).id;
	}
	@Override
	public int hashCode() {
		/*
		 * DOES NOT SUPPORT TREES WITH SAME ID! BAD DESIGN!
		*/		
		return id;
	}
	
	public String toSubTree() {
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
