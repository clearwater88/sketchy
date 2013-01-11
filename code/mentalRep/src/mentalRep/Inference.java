package mentalRep;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;
import net.sf.javaml.utils.GammaFunction;

public class Inference {

	private static final Random gen = new Random();
	private static final int NUM_SAMPLES = 1000;
	
	public static double inferLogProbSeq(int seq[],  ArrayList<HashMap<Long,Double>> postRules, ArrayList<Double> decaySamps) {
		ArrayList<Node> nodes = new ArrayList<Node>();
		
		for (int id: seq) {
			nodes.add(new Node(id));
		}
		// Just make a chain to initialize
		for (int i = 1; i < nodes.size(); i++) {
			nodes.get(i-1).addChild(nodes.get(i)); 
		}
		
		double logProbSample = net.sf.javaml.utils.GammaFunction.logGamma(nodes.size());
		
		double logProbTot = 0;
		for (int ns = 0; ns < NUM_SAMPLES; ns++) {
			double logProb = 0;
			
			nodes = sampleProposal(nodes);
			double decayTrav = decaySamps.get(gen.nextInt(decaySamps.size()));
			
			for (Node n : nodes) {
				long ruleId = Node.getRuleId(n);
				Double prob = postRules.get(n.id).get(ruleId);
				if (prob == null) // zero-prob; actually alpha, but forget it 
					prob = 0.0001; // assign small non-zero prob
				
				logProb += Math.log(prob);
			}
			logProb -= logProbSample;
			logProb += Node.getSeqProb(nodes, decayTrav);
			
			logProbTot += logProb;
		}
		return logProbTot/NUM_SAMPLES;
	}
	
	public static ArrayList<Node> sampleProposal(ArrayList<Node> nodes) {
		for (int childId = 1; childId < nodes.size(); childId++) {
			Node child = nodes.get(childId);
			
			Node originalParent = child.parent;
			originalParent.removeChild(child);
			
			Node newParent = nodes.get(gen.nextInt(childId));
			newParent.addChild(child);
		}
		
		return nodes;
	}
	
}
