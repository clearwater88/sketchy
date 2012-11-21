package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;

public class Main {

	private static int MAX_ID = 15;
	private static double alpha = 0.1;
	
	private enum Ctype {airplane,apple,personWalking};
	
	public static void main(String [ ] args) {
		
		int thin = 250;
		int burnin = 1000;
		int iters = 100000;
		
		Ctype ct = Ctype.personWalking;
		
		
		String file = getSeqFile(ct);
		ArrayList<String> partList = getPartList(ct);

		for (String str : partList) {
			System.out.println(str);
		}
		
		// Index on parent
		ArrayList<HashMap<Integer,Integer>> ruleCounts = new ArrayList<HashMap<Integer,Integer>>();
		for (int i = 0; i < MAX_ID; i++) {
			ruleCounts.add(new HashMap<Integer,Integer>());
		}
		
		
		ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts = new ArrayList<ArrayList<HashMap<Integer,Integer>>>();
		ArrayList<Tree> trees = makeList(file,alpha,ruleCounts);
		System.out.println("sz: " + trees.size());
		
		System.out.println("Rule counts: ");
		for (int key=0; key < MAX_ID; key++) {
			System.out.println(key + "/" + ruleCounts.get(key));
		}
		System.out.println("trees: ");
		for (Tree t : trees) {
			System.out.println(t);
		}
		
		
		for (int i=0;i<iters;i++) {
			if (i % 1000 == 0)
				System.out.println("On iteration: " + i);


			for (int j=0; j < trees.size(); j++) {	
				trees.get(j).sampleNewConfig();
				if ((i % thin == 0) & i > burnin) {
					allRuleCounts.add(cloneRuleList(ruleCounts));
				}
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
					System.out.println(Tree.getRuleList(rule, partList) + "/" + parentRules.get(rule));
		}
		
		System.out.println("Done!");
	}
	
	private static String getSeqFile(Ctype ct) {
		String filename = "";
		switch(ct) {
			case airplane:
				filename = "../airplane.txt";
				break;
			case personWalking:
				filename = "../person-walkingManual.txt";
				break;
			case apple:
				filename = "../apple.txt";
				break;
			default:
				throw new RuntimeException("Bad partlist: " + ct);
		}
		return filename;
	}
	
	private static ArrayList<String> getPartList(Ctype ct) {
		ArrayList<String> partList = new ArrayList<String>();

		String filename = "";
		switch(ct) {
			case airplane:
				filename = "../airplaneParts.txt";
				break;
			case personWalking:
				filename = "../person-walkingParts.txt";
				break;
			case apple:
				filename = "../appleParts.txt";
				break;
			default:
				throw new RuntimeException("Bad partlist: " + ct);
				
		}
		
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
		
		for (int i = 0; i < allRuleCounts.size(); i+= 1) {
			ArrayList<HashMap<Integer,Integer>> ruleCount = allRuleCounts.get(i);
			
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
	
	private static ArrayList<Tree> makeList(String filename, double alpha,ArrayList<HashMap<Integer,Integer>> ruleCounts) {
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
