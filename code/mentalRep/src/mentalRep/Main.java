package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
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
	private static final int ITERS = 100000;
	
	private static final Random GEN = new Random();
	private static final String ROOT_DATA_FOLDER = "../../mentalData/";
	private static final String ROOT_RES_FOLDER = "../../mentalRes/";

	private static ArrayList<String> partList;
	
	private static final String CHILD_VIEW = "-childView";
	private static final String PARENT_VIEW = "-parentView";
	private static final String STATS = "-stats";
	private static final String RULE_COUNTS = "-rulesCounts";
	private static final String DECAY_SAMPLES = "-decay";
	private static final String INFER_PROBS = "-infer_probs";
	
	private static HashMap<Ctype,String> partFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> seqFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> outFiles = new HashMap<Ctype,String>();
	private static HashMap<Ctype,String> splitFilesPrefix = new HashMap<Ctype,String>();
	
	static {
		
		seqFiles.put(Ctype.airplane,ROOT_DATA_FOLDER.concat("airplane"));
		seqFiles.put(Ctype.personWalking,ROOT_DATA_FOLDER.concat("person-walking"));
		seqFiles.put(Ctype.apple,ROOT_DATA_FOLDER.concat("apple"));
		seqFiles.put(Ctype.face,ROOT_DATA_FOLDER.concat("face"));
		seqFiles.put(Ctype.violin,ROOT_DATA_FOLDER.concat("violin"));
		seqFiles.put(Ctype.camera,ROOT_DATA_FOLDER.concat("camera"));
		seqFiles.put(Ctype.personSitting,ROOT_DATA_FOLDER.concat("person-sitting"));
		
		outFiles.put(Ctype.airplane,ROOT_RES_FOLDER.concat("airplaneManual"));
		outFiles.put(Ctype.personWalking,ROOT_RES_FOLDER.concat("person-walkingManual"));
		outFiles.put(Ctype.apple,ROOT_RES_FOLDER.concat("appleManual"));
		outFiles.put(Ctype.face,ROOT_RES_FOLDER.concat("faceManual"));
		outFiles.put(Ctype.violin,ROOT_RES_FOLDER.concat("violinManual"));
		outFiles.put(Ctype.camera,ROOT_RES_FOLDER.concat("cameraManual"));
		outFiles.put(Ctype.personSitting,ROOT_RES_FOLDER.concat("person-sittingManual"));
		
		seqFiles.put(Ctype.test,ROOT_DATA_FOLDER.concat("test"));
		outFiles.put(Ctype.test,ROOT_RES_FOLDER.concat("test"));
		
		
		for (Ctype ct: seqFiles.keySet()) {
			partFiles.put(ct, seqFiles.get(ct).concat("Parts.txt"));
			splitFilesPrefix.put(ct, seqFiles.get(ct).concat("SplitTrial"));
		}		
	
	}
	
	public static void main(String [] args) throws IOException, ClassNotFoundException {

	    int trialStart = 0;
	    int trialEnd = 20;
		
		
		for (int t= trialStart; t < trialEnd; t++) {
			//double[] alphaTry = {0.01,0.1,0.2,0.5,1,2,5};
			double[] alphaTry = {0.01,0.1,0.2,0.5,1,2,5};
			for (double alpha : alphaTry) {
				for (Ctype ct : Ctype.values()) {
					partList = getPartList(ct);
					String outFilesPrefix = outFiles.get(ct).concat("-alpha" + new Double(alpha).toString()).concat("-trial" + new Integer(t).toString());
					
					//Learn
					
					ArrayList<int[]> seqs = IO.readFile(seqFiles.get(ct).concat(".txt"));
					// train and test
					ArrayList<ArrayList<int[]>> splitSeqs = splitTrainTest(ct,t);
					ArrayList<int[]> trainSeqs = splitSeqs.get(0);
					ArrayList<int[]> testSeqs = splitSeqs.get(1);
					
					/*
					for (int[] temp: trainSeqs) {
						System.out.println("=====");
						for (int i : temp)
							System.out.print(i+",");
						System.out.println("");
					}
					System.out.println("XXXXXX");
					for (int[] temp: testSeqs) {
						System.out.println("=====");
						for (int i : temp)
							System.out.print(i+",");
						System.out.println("");
					}
					*/
					
					
					doMain(trainSeqs,alpha,outFilesPrefix);
					
					//Inference
					
					// Load stats from learning
					ArrayList<ArrayList<HashMap<Long,Integer>>> allRuleCounts = IO.readRuleCounts(outFilesPrefix.concat(RULE_COUNTS).concat(".txt"));		    
				    ArrayList<HashMap<Long,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);
				    ArrayList<Double> decaySamps = IO.readDecaySamps(outFilesPrefix.concat(DECAY_SAMPLES).concat(".txt"));	

				    // find probs
				    ArrayList<Double> logProbsPost = new ArrayList<Double>();
				    for (int[] seq : testSeqs) {
				    	logProbsPost.add(Inference.inferLogProbSeq(seq,postRules,decaySamps));
				    }

				    // output inference results
				    PrintStream out = new PrintStream(outFilesPrefix.concat(INFER_PROBS).concat(".txt"));
				    IO.outputInferLogProbs(logProbsPost,out);
				    out.close();
				    IO.outputInferLogProbs(logProbsPost,System.out);
					
				}
			}
		}
		
		
		
	    /*
	    Ctype ct = Ctype.personSitting;
	    double alpha = 0.5;
	    partList = getPartList(ct);

	    String outFilesPrefix = outFiles.get(ct).concat("-alpha" + new Double(alpha).toString()).concat("-trial" + 0);
	    
		ArrayList<int[]> seqs = IO.readFile(seqFiles.get(ct).concat(".txt"));
	    doMain(seqs,alpha, outFilesPrefix);

	    ArrayList<ArrayList<HashMap<Long,Integer>>> allRuleCounts = IO.readRuleCounts(outFilesPrefix.concat(RULE_COUNTS).concat(".txt"));		    
	    ArrayList<HashMap<Long,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);

	    ArrayList<Double> decaySamps = IO.readDecaySamps(outFilesPrefix.concat(DECAY_SAMPLES).concat(".txt"));	

	    String filePref = seqFiles.get(ct);
	    String file = filePref.concat(".txt");

	    ArrayList<Double> logProbsPost = new ArrayList<Double>();
	    for (int[] seq : seqs) {
	    	logProbsPost.add(Inference.inferLogProbSeq(seq,postRules,decaySamps));
	    }

	    PrintStream out = new PrintStream(outFilesPrefix.concat(INFER_PROBS).concat(".txt"));
	    IO.outputInferProbs(logProbsPost,out);
	    out.close();
	    IO.outputInferProbs(logProbsPost,System.out);
	    */
	}
		
	
	private static ArrayList<ArrayList<int[]>> splitTrainTest(Ctype ct, int t) throws IOException, ClassNotFoundException {
		
		String splitFile = splitFilesPrefix.get(ct).concat(new Integer(t).toString()).concat(".ser");
		
		ArrayList<ArrayList<int[]>> res = new ArrayList<ArrayList<int[]>>();
		try {
			FileInputStream fi = new FileInputStream(splitFile);
			ObjectInputStream oi=new ObjectInputStream(fi);
			System.out.println("Reading in existing split file: " + splitFile);
			res=(ArrayList<ArrayList<int[]>>)oi.readObject();  
		    oi.close();

		} catch (FileNotFoundException e) { // we haven't made the split file yet
			System.out.println("Split file does not exist. Creating...");
			ArrayList<int[]> seqs = IO.readFile(seqFiles.get(ct).concat(".txt"));
			java.util.Collections.shuffle(seqs);
			
			ArrayList<int[]> trainSeqs = new ArrayList<int[]>();
			ArrayList<int[]> testSeqs = new ArrayList<int[]>();
			for (int i = 0; i < seqs.size(); i++) {
				if (i < seqs.size()/2)
					trainSeqs.add(seqs.get(i));
				else
					testSeqs.add(seqs.get(i));
			}
			res.add(trainSeqs);
			res.add(testSeqs);
			
			FileOutputStream fo = new FileOutputStream(splitFile);  
		    ObjectOutputStream oo=new ObjectOutputStream(fo); 
		    oo.writeObject(res);
		    oo.close();
		}  
	    
		return res;
		

	}


	private static void doMain(ArrayList<int[]> seqs, double alpha, String outFilesPrefix) throws IOException {
	
		
		// Index on parent
		ArrayList<HashMap<Long,Integer>> ruleCounts = new ArrayList<HashMap<Long,Integer>>();
		for (int i = 0; i < partList.size(); i++) {
			ruleCounts.add(new HashMap<Long,Integer>());
		}
		ArrayList<Tree> trees = makeTrees(seqs,alpha,ruleCounts);
		
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
				allRuleCounts.add(Utils.cloneRuleList(ruleCounts));
				decaySamps.add(decayTrav);
			}
		}


		// Output all rule counts- for inference later
		IO.outputRuleCounts(allRuleCounts,outFilesPrefix.concat(RULE_COUNTS).concat(".txt"));

		// Output decay samples- for inference later
		IO.outputDecaySamps(decaySamps,outFilesPrefix.concat(DECAY_SAMPLES).concat(".txt"));
		
		// Output posterior rules
	    ArrayList<HashMap<Long,Double>> postRules = getPosteriorRuleCounts(allRuleCounts);
		PrintStream out = new PrintStream(outFilesPrefix.concat(PARENT_VIEW).concat(".txt"));
		IO.outputPosteriorRuleCounts(postRules,partList,out);
		out.close();
		IO.outputPosteriorRuleCounts(postRules,partList,System.out);
		
		//Output child-oriented version
		out = new PrintStream(outFilesPrefix.concat(CHILD_VIEW).concat(".txt"));
		ArrayList<ArrayList<HashMap<Long, Double>>> childParRules = getParentCounts(allRuleCounts);
		IO.outputMostLikelyGens(childParRules, partList, out);
		out.close();
		IO.outputMostLikelyGens(childParRules, partList, System.out);
		
		//Output stats
		out = new PrintStream(outFilesPrefix.concat(STATS).concat(".txt"));
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
			logDecayProbNew += Math.log(Node.getSeqProb(trees.get(j).getNodes(),decayTravPropose));
			logDecayProbOld += Math.log(Node.getSeqProb(trees.get(j).getNodes(),decayTrav));
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
					ArrayList<Integer> childIds = Node.getRuleList(ruleId);

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
	private static ArrayList<Tree> makeTrees(ArrayList<int[]> seqs, double alpha, ArrayList<HashMap<Long,Integer>> ruleCounts) {
		ArrayList<Tree> trees = new ArrayList<Tree>();

		for (int[] seq : seqs) {
			trees.add(new Tree(seq,alpha,ruleCounts));
		}
		return trees;
	}

}
