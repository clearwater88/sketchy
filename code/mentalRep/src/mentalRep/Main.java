package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class Main {

	private static int MAX_ID = 16;
	private static double alpha = 0.1;
	
	private static final double decayTravMin = 0.01;
	private static final double decayTravMax = 1;
	private static final Random gen = new Random();
	
	private enum Ctype {airplane,apple,personWalking,face,violin};
	private static final Ctype ct = Ctype.airplane;
	
	private static HashMap<Ctype,String> partFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> seqFiles = new HashMap<Ctype,String>();
	
	static {
		partFiles.put(Ctype.airplane,"../airplaneParts.txt");
		partFiles.put(Ctype.personWalking,"../person-walkingParts.txt");
		partFiles.put(Ctype.apple,"../appleParts.txt");
		partFiles.put(Ctype.face,"../faceParts.txt");
		partFiles.put(Ctype.violin,"../violinParts.txt");

		
		seqFiles.put(Ctype.airplane,"../airplane.txt");
		seqFiles.put(Ctype.personWalking,"../person-walkingManual.txt");
		seqFiles.put(Ctype.apple,"../apple.txt");
		seqFiles.put(Ctype.face,"../face.txt");
		seqFiles.put(Ctype.violin,"../violinManual.txt");
		
	}
	
	public static void main(String [ ] args) {
		
		int thin = 100;
		int burnin = 1000;
		int iters = 100000;
		
		String file = seqFiles.get(ct);
		ArrayList<String> partList = getPartList(ct);

		for (String str : partList) {
			System.out.println(str);
		}
		
		// Index on parent
		ArrayList<HashMap<Integer,Integer>> ruleCounts = new ArrayList<HashMap<Integer,Integer>>();
		for (int i = 0; i < MAX_ID; i++) {
			ruleCounts.add(new HashMap<Integer,Integer>());
		}
		
		double decayTrav = (decayTravMax + decayTravMin)/2;
		ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts = new ArrayList<ArrayList<HashMap<Integer,Integer>>>();
		ArrayList<Tree> trees = makeList(file,alpha,ruleCounts);
		ArrayList<Double> decaySamps= new ArrayList<Double>();
		
		double treeAcceptTotal = 0;
		double decayAcceptTotal = 0;
		
		for (int i=0;i<iters;i++) {
			if (i % 1000 == 0)
				System.out.println("On iteration: " + i);

			for (int j=0; j < trees.size(); j++) {	
				treeAcceptTotal += trees.get(j).sampleNewConfig(decayTrav);
			}
			
			double decayTravPropose = proposeDecay(decayTrav);
			boolean decayAccept = acceptDecay(decayTrav, decayTravPropose, trees);
			if (decayAccept) {
				decayTrav = decayTravPropose; 
				decayAcceptTotal += decayAccept ? 1.0 : 0.0;
			}
			
			if (((i-burnin) % thin == 0) & i > burnin) {
				allRuleCounts.add(cloneRuleList(ruleCounts));
				decaySamps.add(decayTrav);
			}
		}
		
		ArrayList<HashMap<Integer,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);
		for (int par = 0; par < postRules.size(); par++) {
			HashMap<Integer, Double> parentRules = postRules.get(par);
			if (par >= partList.size())
				break;
			System.out.println("===" + partList.get(par) + "===");
			for (int rule : parentRules.keySet())
				if (parentRules.get(rule) > 0.01)
					System.out.println(Tree.getRuleListStrings(rule, partList) + "/" + parentRules.get(rule));
		}
		
		ArrayList<ArrayList<HashMap<Integer, Double>>> childParRules = getParentCounts(allRuleCounts);
		for (int i = 0; i < childParRules.size(); i++) {
			if (i >= partList.size())
				break;
			
			ArrayList<HashMap<Integer, Double>> child = childParRules.get(i);			
			System.out.println("===" + partList.get(i) + "===");
			for (int j = 0; j < child.size(); j++) {
				if (j >= partList.size())
					break;
				HashMap<Integer, Double> childParProbs = child.get(j);
				
				double totParentProb = 0;
				for (int rule : childParProbs.keySet()) {
					totParentProb += childParProbs.get(rule);
				}
				System.out.println("   ---" + partList.get(j) + ": " + totParentProb + "---");
				
				for (int rule : childParProbs.keySet()) {
					if (childParProbs.get(rule) > 0.01) {
						System.out.println("      " + Tree.getRuleListStrings(rule, partList) + "/" + childParProbs.get(rule));
					}
				}
			}
		}
		
		double decayTravMean = 0;
		for (double d : decaySamps) {
			decayTravMean += d;
		}
		decayTravMean /= decaySamps.size();
		double decayTravVar = 0;
		for (double d : decaySamps) {
			decayTravVar += Math.pow(d-decayTravMean,2);
		}
		decayTravVar /= decaySamps.size();
		System.out.println("Decay mean/var: " + decayTravMean + "/" + decayTravVar);
		
		System.out.println("Tree accept ratio: " + treeAcceptTotal/(iters*trees.size()));
		System.out.println("Decay accept ratio: " + decayAcceptTotal/(iters));
		
		System.out.println("Done!");
	}
	
	private static double proposeDecay(double decayTrav) {
		//return Math.exp(Math.log(decayTravMin) + Math.log(decayTravMax/decayTravMin)*gen.nextDouble());
		return decayTravMin + (decayTravMax-decayTravMin)*gen.nextDouble();
		
		/*
		double temp = decayTrav+0.1*gen.nextGaussian();
		return temp > 0 ? temp : decayTrav;
		*/		
	}
	
	private static boolean acceptDecay(double decayTrav, double decayTravPropose, ArrayList<Tree> trees) {
		double logDecayProbNew = 0;
		double logDecayProbOld = 0;
		for (int j=0; j < trees.size(); j++) {	
			logDecayProbNew += Math.log(trees.get(j).getSeqProb(decayTravPropose));
			logDecayProbOld += Math.log(trees.get(j).getSeqProb(decayTrav));
		}
		return Math.exp(logDecayProbNew - logDecayProbOld) > gen.nextDouble();
	}
	
	private static ArrayList<String> getPartList(Ctype ct) {
		ArrayList<String> partList = new ArrayList<String>();

		String filename = partFiles.get(ct);
		
		try {
			FileInputStream fstream;
			fstream = new FileInputStream(filename);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null)   {
				partList.add(strLine);
			}
			//Close the input stream
			in.close();
		} catch (FileNotFoundException e) {
			System.err.println("Error!: " + e.getMessage());
		} catch (NumberFormatException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		}			
		return partList;
	}

	// not actual posterior of rule probs: need alpha for that
	private static ArrayList<HashMap<Integer,Double>> getPosteriorRuleCounts(ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts) {
		ArrayList<HashMap<Integer,Double>> res = new ArrayList<HashMap<Integer,Double>>(); 
		for (int i = 0; i < MAX_ID; i++) {
			res.add(new HashMap<Integer,Double>());
		}
		double totSamp = allRuleCounts.size();
		
		for (ArrayList<HashMap<Integer,Integer>> ruleCount : allRuleCounts) {			
			for (int par = 0; par < ruleCount.size(); par++) {
				int totRules = 0;
				HashMap<Integer,Double> resPar = res.get(par);
				
				HashMap<Integer,Integer> parentRules = ruleCount.get(par);
				// this should be a constant, with the current model
				for (int key : parentRules.keySet()) {
					totRules += parentRules.get(key);
				}
				
				for (int key : parentRules.keySet()) {
					// adjust by totSamp, so we don't have to loop later
					double rulePostProb = ((double) parentRules.get(key))/(totRules*totSamp);
					Double rulePostSum = resPar.get(key);
					if (rulePostSum == null) {
						resPar.put(key,rulePostProb);
					} else {
						resPar.put(key,rulePostSum+rulePostProb);
					}
				}
			}
			
		}
		return res;
	}
	
	private static ArrayList<ArrayList<HashMap<Integer, Double>>> getParentCounts(ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts) {
		ArrayList<ArrayList<HashMap<Integer,Double>>> res = new ArrayList<ArrayList<HashMap<Integer,Double>>>(); 
		for (int i = 0; i < MAX_ID; i++) {
			ArrayList<HashMap<Integer,Double>> temp = new ArrayList<HashMap<Integer,Double>>();
			for (int j = 0; j < MAX_ID; j++) {
				temp.add(new HashMap<Integer,Double>());
			}
			res.add(temp);
		}
		
		for (ArrayList<HashMap<Integer,Integer>> ruleCount : allRuleCounts) {
			for (int par = 0; par < ruleCount.size(); par++) {
				HashMap<Integer, Integer> parentRules = ruleCount.get(par);
				for (int ruleId : parentRules.keySet()) {
					ArrayList<Integer> childIds = Tree.getRuleList(ruleId);
					for (int child : childIds) {
						HashMap<Integer, Double> childParHashMap = res.get(child).get(par);
						Double temp = childParHashMap.get(ruleId);
						if (temp == null) {
							childParHashMap.put(ruleId,(double) parentRules.get(ruleId));
						} else {
							childParHashMap.put(ruleId,temp + (double) parentRules.get(ruleId));
						}
					}
				}
			}
		}
		
		for (int i = 0; i < res.size(); i++) {
			int totCount = 0;
			ArrayList<HashMap<Integer,Double>> child = res.get(i);
			for (int j = 0; j < child.size(); j++) {
				HashMap<Integer,Double> parRules = child.get(j);
				for (int ruleId : parRules.keySet()) {
					totCount += parRules.get(ruleId);
				}
			}
			
			for (int j = 0; j < child.size(); j++) {
				HashMap<Integer,Double> parRules = child.get(j);
				for (int ruleId : parRules.keySet()) {
					parRules.put(ruleId,(double) parRules.get(ruleId)/(double) totCount);
				}
			}
			
		}
		
		return res;
		
	}
	private static ArrayList<Tree> makeList(String filename, double alpha, ArrayList<HashMap<Integer,Integer>> ruleCounts) {
		ArrayList<Tree> trees = new ArrayList<Tree>();

		try {
			FileInputStream fstream;
			fstream = new FileInputStream(filename);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null)   {
				// Print the content on the console
				System.out.println("==A==");
				System.out.println(strLine);
				String str[] = strLine.split(","); 
				int [] seq = new int[str.length];
				for (int i = 0; i < seq.length; i++) {
					seq[i] = Integer.parseInt(str[i]);
				}
				trees.add(new Tree(seq,alpha,ruleCounts));
			}
			//Close the input stream
			in.close();
		} catch (FileNotFoundException e) {
			System.err.println("Error!: " + e.getMessage());
		} catch (NumberFormatException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		}			
		return trees;
	}

	private static ArrayList<HashMap<Integer,Integer>> cloneRuleList(ArrayList<HashMap<Integer,Integer>> ruleCounts) {
		ArrayList<HashMap<Integer,Integer>> res = new ArrayList<HashMap<Integer,Integer>>();
		
		for (int i = 0; i < ruleCounts.size(); i++) {
			HashMap<Integer,Integer> temp = new HashMap<Integer,Integer>(ruleCounts.get(i));
			res.add(temp);
		}		
		return res;
	}
	
}
