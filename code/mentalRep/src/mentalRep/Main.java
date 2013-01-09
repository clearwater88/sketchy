package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class Main {

	private static enum Ctype {airplane,apple,personWalking,face,violin,camera,personSitting,test};
	
	private static final double DECAY_TRAV_MIN = 0;
	private static final double DECAY_TRAV_MAX = 2;
	
	private static final int THIN = 25;
	private static final int BURNIN = 1000;
	private static final int ITERS = 20000;
	
	private static final Random GEN = new Random();
	private static final String ROOT_DATA_FOLDER = "../mentalData/";
	private static final String ROOT_RES_FOLDER = "../mentalRes/";

	private static ArrayList<String> partList;
	private static final String resSuffix = "-res";
	
	private static HashMap<Ctype,String> partFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> seqFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> outFiles = new HashMap<Ctype,String>();
	
	static {
		partFiles.put(Ctype.airplane,ROOT_DATA_FOLDER.concat("airplaneParts.txt"));
		partFiles.put(Ctype.personWalking,ROOT_DATA_FOLDER.concat("person-walkingParts.txt"));
		partFiles.put(Ctype.apple,ROOT_DATA_FOLDER.concat("appleParts.txt"));
		partFiles.put(Ctype.face,ROOT_DATA_FOLDER.concat("faceParts.txt"));
		partFiles.put(Ctype.violin,ROOT_DATA_FOLDER.concat("violinParts.txt"));
		partFiles.put(Ctype.camera,ROOT_DATA_FOLDER.concat("cameraParts.txt"));
		partFiles.put(Ctype.personSitting,ROOT_DATA_FOLDER.concat("person-sittingParts.txt"));
		
		seqFiles.put(Ctype.airplane,ROOT_DATA_FOLDER.concat("airplaneManual"));
		seqFiles.put(Ctype.personWalking,ROOT_DATA_FOLDER.concat("person-walkingManual"));
		seqFiles.put(Ctype.apple,ROOT_DATA_FOLDER.concat("appleManual"));
		seqFiles.put(Ctype.face,ROOT_DATA_FOLDER.concat("faceManual"));
		seqFiles.put(Ctype.violin,ROOT_DATA_FOLDER.concat("violinManual"));
		seqFiles.put(Ctype.camera,ROOT_DATA_FOLDER.concat("cameraManual"));
		seqFiles.put(Ctype.personSitting,ROOT_DATA_FOLDER.concat("person-sittingManual"));
		
		outFiles.put(Ctype.airplane,ROOT_RES_FOLDER.concat("airplaneManual").concat(resSuffix));
		outFiles.put(Ctype.personWalking,ROOT_RES_FOLDER.concat("person-walkingManual").concat(resSuffix));
		outFiles.put(Ctype.apple,ROOT_RES_FOLDER.concat("appleManual").concat(resSuffix));
		outFiles.put(Ctype.face,ROOT_RES_FOLDER.concat("faceManual").concat(resSuffix));
		outFiles.put(Ctype.violin,ROOT_RES_FOLDER.concat("violinManual").concat(resSuffix));
		outFiles.put(Ctype.camera,ROOT_RES_FOLDER.concat("cameraManual").concat(resSuffix));
		outFiles.put(Ctype.personSitting,ROOT_RES_FOLDER.concat("person-sittingManual").concat(resSuffix));
		
		partFiles.put(Ctype.test,ROOT_DATA_FOLDER.concat("testParts.txt"));
		seqFiles.put(Ctype.test,ROOT_DATA_FOLDER.concat("test"));
		outFiles.put(Ctype.test,ROOT_RES_FOLDER.concat("test"));
	
	}
	
	public static void main(String [ ] args) throws FileNotFoundException {

		/*
		double[] alphaTry = {0.01,0.1,0.2,0.5,1,2,5};
		for (double alpha : alphaTry)
			for (Ctype ct : Ctype.values()) {
				partList = getPartList(ct);
				doMain(ct,alpha);
			}
		}*/
		
		
		double alpha = 0.1;
		Ctype ct = Ctype.personSitting;
		partList = getPartList(ct);
		doMain(ct,alpha);
	}
		
	
	private static void doMain(Ctype ct, double alpha) throws FileNotFoundException {
		
		String filePref = seqFiles.get(ct);
		String file = filePref.concat(".txt");
		
		// Index on parent
		ArrayList<HashMap<Long,Integer>> ruleCounts = new ArrayList<HashMap<Long,Integer>>();
		for (int i = 0; i < partList.size(); i++) {
			ruleCounts.add(new HashMap<Long,Integer>());
		}
		ArrayList<Tree> trees = makeTrees(file,alpha,ruleCounts);
		
		ArrayList<ArrayList<HashMap<Long,Integer>>> allRuleCounts = new ArrayList<ArrayList<HashMap<Long,Integer>>>();
		
		
		int treeAcceptTotal = 0;
		int decayAcceptTotal = 0;
		double decayTrav = (DECAY_TRAV_MAX + DECAY_TRAV_MIN)/2;
		ArrayList<Double> decaySamps= new ArrayList<Double>();
		
		for (int i=0;i<ITERS;i++) {
			if (i % 1000 == 0) System.out.println("On iteration: " + i);

			// Sample all trees
			for (int j=0; j < trees.size(); j++) treeAcceptTotal += trees.get(j).sampleNewConfig(decayTrav);
			
			double decayTravPropose = proposeDecay(decayTrav);
			if (acceptDecay(decayTrav, decayTravPropose, trees)) {
				decayTrav = decayTravPropose; 
				decayAcceptTotal++;
			}
			
			if (((i-BURNIN) % THIN == 0) && (i > BURNIN)) {
				allRuleCounts.add(utils.cloneRuleList(ruleCounts));
				decaySamps.add(decayTrav);
			}
		}

		String outFilesPrefix = outFiles.get(ct).concat("-" + new Double(alpha).toString());
		
		PrintStream out = new PrintStream(outFilesPrefix.concat("-parentView").concat(".txt"));
		ArrayList<HashMap<Long,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);
		IO.outputPosteriorRuleCounts(postRules,partList,out);
		out.close();
		IO.outputPosteriorRuleCounts(postRules,partList,System.out);
		
		out = new PrintStream(outFilesPrefix.concat("-childView").concat(".txt"));
		ArrayList<ArrayList<HashMap<Long, Double>>> childParRules = getParentCounts(allRuleCounts);
		IO.outputMostLikelyGens(childParRules, partList, out);
		out.close();
		IO.outputMostLikelyGens(childParRules, partList, System.out);
		
		out = new PrintStream(outFilesPrefix.concat("-childStats").concat(".txt"));
		IO.outputStats(decaySamps, treeAcceptTotal, decayAcceptTotal, trees, ITERS, out);
		out.close();
		IO.outputStats(decaySamps, treeAcceptTotal, decayAcceptTotal, trees, ITERS, System.out);
		

		System.out.println("Done!");
	}

	

	private static double proposeDecay(double decayTrav) {
		return DECAY_TRAV_MIN + (DECAY_TRAV_MAX-DECAY_TRAV_MIN)*GEN.nextDouble();
	}
	
	private static boolean acceptDecay(double decayTrav, double decayTravPropose, ArrayList<Tree> trees) {
		double logDecayProbNew = 0;
		double logDecayProbOld = 0;
		for (int j=0; j < trees.size(); j++) {	
			logDecayProbNew += Math.log(trees.get(j).getSeqProb(decayTravPropose));
			logDecayProbOld += Math.log(trees.get(j).getSeqProb(decayTrav));
		}
		return Math.exp(logDecayProbNew - logDecayProbOld) >= GEN.nextDouble();
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
			throw new RuntimeException("Error!: " + e.getMessage());
		} catch (NumberFormatException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Error!: " + e.getMessage());
			e.printStackTrace();
		}			
		return partList;
	}

	// not actual posterior of rule probs: need alpha for that\
	// List on parents, hash on ruleID and probs
	private static ArrayList<HashMap<Long,Double>> getPosteriorRuleCounts(ArrayList<ArrayList<HashMap<Long,Integer>>> allRuleCounts) {
		ArrayList<HashMap<Long,Double>> res = new ArrayList<HashMap<Long,Double>>(); 
		for (int i = 0; i < partList.size(); i++) {
			res.add(new HashMap<Long,Double>());
		}
		double totSamp = allRuleCounts.size();
		
		for (ArrayList<HashMap<Long,Integer>> ruleCount : allRuleCounts) {			
			for (int par = 0; par < ruleCount.size(); par++) {
				int totRules = 0;
				HashMap<Long,Double> resPar = res.get(par);
				
				HashMap<Long,Integer> parentRules = ruleCount.get(par);
				// this should be a constant, with the current model
				for (long key : parentRules.keySet()) {
					totRules += parentRules.get(key);
				}
				
				for (long key : parentRules.keySet()) {
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
	
	private static ArrayList<ArrayList<HashMap<Long, Double>>> getParentCounts(ArrayList<ArrayList<HashMap<Long, Integer>>> allRuleCounts) {
		ArrayList<ArrayList<HashMap<Long,Double>>> res = new ArrayList<ArrayList<HashMap<Long,Double>>>(); 
		for (int i = 0; i < partList.size(); i++) {
			ArrayList<HashMap<Long,Double>> temp = new ArrayList<HashMap<Long,Double>>();
			for (int j = 0; j < partList.size(); j++) {
				temp.add(new HashMap<Long,Double>());
			}
			res.add(temp);
		}
		
		for (ArrayList<HashMap<Long,Integer>> ruleCounts : allRuleCounts) {
			for (int par = 0; par < ruleCounts.size(); par++) {
				HashMap<Long, Integer> parentRules = ruleCounts.get(par);
				for (long ruleId : parentRules.keySet()) {
					ArrayList<Integer> childIds = Tree.getRuleList(ruleId);

					for (int child : childIds) {
						
						HashMap<Long, Double> childParHashMap = res.get(child).get(par);
						
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
			ArrayList<HashMap<Long,Double>> child = res.get(i);
			for (int j = 0; j < child.size(); j++) {
				HashMap<Long,Double> parRules = child.get(j);
				for (long ruleId : parRules.keySet()) totCount += parRules.get(ruleId);
			}
			
			for (int j = 0; j < child.size(); j++) {
				HashMap<Long,Double> parRules = child.get(j);
				for (long ruleId : parRules.keySet()) {
					parRules.put(ruleId,((double) parRules.get(ruleId))/((double) totCount));
				}
			}
			
		}
		return res;
	}
	private static ArrayList<Tree> makeTrees(String filename, double alpha, ArrayList<HashMap<Long,Integer>> ruleCounts) {
		ArrayList<Tree> trees = new ArrayList<Tree>();

		ArrayList<int[]> seqs = IO.readFile(filename);
		for (int[] seq : seqs) {
			trees.add(new Tree(seq,alpha,ruleCounts));
		}
		return trees;
	}

}
