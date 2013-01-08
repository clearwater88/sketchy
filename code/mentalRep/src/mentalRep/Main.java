package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Random;

public class Main {

	private static enum Ctype {airplane,apple,personWalking,face,violin,camera};

	private static final double alpha = 0.1;
	
	private static final double DECAY_TRAV_MIN = 0;
	private static final double DECAY_TRAV_MAX = 2;
	
	private static final int THIN = 25;
	private static final int BURNIN = 10000;
	private static final int ITERS = 200000;
	
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
		
		seqFiles.put(Ctype.airplane,ROOT_DATA_FOLDER.concat("airplaneManual"));
		seqFiles.put(Ctype.personWalking,ROOT_DATA_FOLDER.concat("person-walkingManual"));
		seqFiles.put(Ctype.apple,ROOT_DATA_FOLDER.concat("appleManual"));
		seqFiles.put(Ctype.face,ROOT_DATA_FOLDER.concat("faceManual"));
		seqFiles.put(Ctype.violin,ROOT_DATA_FOLDER.concat("violinManual"));
		seqFiles.put(Ctype.camera,ROOT_DATA_FOLDER.concat("cameraManual"));
		
		outFiles.put(Ctype.airplane,ROOT_RES_FOLDER.concat("airplaneManual").concat(resSuffix));
		outFiles.put(Ctype.personWalking,ROOT_RES_FOLDER.concat("person-walkingManual").concat(resSuffix));
		outFiles.put(Ctype.apple,ROOT_RES_FOLDER.concat("appleManual").concat(resSuffix));
		outFiles.put(Ctype.face,ROOT_RES_FOLDER.concat("faceManual").concat(resSuffix));
		outFiles.put(Ctype.violin,ROOT_RES_FOLDER.concat("violinManual").concat(resSuffix));
		outFiles.put(Ctype.camera,ROOT_RES_FOLDER.concat("cameraManual").concat(resSuffix));
	}
	
	public static void main(String [ ] args) throws FileNotFoundException {
		/*
		for (Ctype ct : Ctype.values()) {
			partList = getPartList(ct);
			doMain(ct);
		}
		*/
		Ctype ct = Ctype.camera;
		partList = getPartList(ct);
		doMain(ct);
	}
	private static void doMain(Ctype ct) throws FileNotFoundException {
		
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
				allRuleCounts.add(cloneRuleList(ruleCounts));
				decaySamps.add(decayTrav);
			}
		}

		PrintStream out = new PrintStream(outFiles.get(ct).concat("-parentView").concat(".txt"));
		outputPosteriorRuleCounts(allRuleCounts,out);
		out.close();
		outputPosteriorRuleCounts(allRuleCounts,System.out);
		
		out = new PrintStream(outFiles.get(ct).concat("-childView").concat(".txt"));
		outputMostLikelyGens(allRuleCounts, out);
		out.close();
		outputMostLikelyGens(allRuleCounts,System.out);
		
		out = new PrintStream(outFiles.get(ct).concat("-childStats").concat(".txt"));
		outputStats(decaySamps, treeAcceptTotal, decayAcceptTotal, trees, out);
		out.close();
		outputStats(decaySamps, treeAcceptTotal, decayAcceptTotal, trees, System.out);
		

		
		System.out.println("Done!");
	}

	private static void outputStats(ArrayList<Double> decaySamps, 
			                        int treeAcceptTotal, int decayAcceptTotal, 
			                        ArrayList<Tree> trees, PrintStream out) {
		
		// Decay stats
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
		
		// Decay stats
		out.println("Decay mean/var: " + decayTravMean + "/" + decayTravVar);
		out.println("Tree accept ratio: " + ((double) treeAcceptTotal)/(ITERS*trees.size()));
		out.println("Decay accept ratio: " + ((double) decayAcceptTotal)/(ITERS));
		
	}
	private static void outputMostLikelyGens(ArrayList<ArrayList<HashMap<Long, Integer>>> allRuleCounts, PrintStream out) {
		ArrayList<ArrayList<HashMap<Long, Double>>> childParRules = getParentCounts(allRuleCounts);
		for (int i = 0; i < childParRules.size(); i++) {
			
			ArrayList<HashMap<Long, Double>> child = childParRules.get(i);	
			
			Collections.sort(child,new Comparator<HashMap<Long,Double>>() {
	            public int compare(HashMap<Long,Double> m1, HashMap<Long,Double> m2) {
	            	
	            	double tot1 = 0;	
	            	for (long rule : m1.keySet()) {
	            		tot1 += m1.get(rule);
					}
	            	double tot2 = 0;	
	            	for (long rule : m2.keySet()) {
	            		tot2 += m2.get(rule);
					}
	            	
	                if (tot1 <= tot2) return 1;
	                else return -1;
	            }
	        });
			
			out.println("=== Child: " + partList.get(i) + "===");
			for (int j = 0; j < child.size(); j++) {
				
				LinkedHashMap<Long, Double> childParProbs = utils.getSortedHashMap(child.get(j));
				
				double totParentProb = 0;
				for (long rule : childParProbs.keySet()) {
					totParentProb += childParProbs.get(rule);
				}
				out.println("   --- Parent: " + partList.get(j) + ": " + totParentProb + "---");
				
				for (long rule : childParProbs.keySet()) {
					if (childParProbs.get(rule) > 0.01) {
						out.println("         " + Tree.getRuleListStrings(rule, partList) + "/" + childParProbs.get(rule));
					}
				}
			}
		}
	}
	
	private static void outputPosteriorRuleCounts(ArrayList<ArrayList<HashMap<Long, Integer>>> allRuleCounts, PrintStream out) {
		
		ArrayList<HashMap<Long,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);
		for (int par = 0; par < postRules.size(); par++) {
			
			LinkedHashMap<Long, Double> parentRules = utils.getSortedHashMap(postRules.get(par));

			out.println("===" + partList.get(par) + "===");
			
			for (long rule : parentRules.keySet())
				if (parentRules.get(rule) > 0.01)
					out.println(Tree.getRuleListStrings(rule, partList) + "/" + parentRules.get(rule));
		}
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

	// not actual posterior of rule probs: need alpha for that
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

	private static ArrayList<HashMap<Long,Integer>> cloneRuleList(ArrayList<HashMap<Long,Integer>> ruleCounts) {
		ArrayList<HashMap<Long,Integer>> res = new ArrayList<HashMap<Long,Integer>>();
		
		for (int i = 0; i < ruleCounts.size(); i++) {
			HashMap<Long,Integer> temp = new HashMap<Long,Integer>(ruleCounts.get(i));
			res.add(temp);
		}		
		return res;
	}
	
}
