package mentalRep;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

public class Main {

	private static int MAX_ID = 12;
	private static double alpha = 0.1;
	
	public static void main(String [ ] args) {
		
		// Index on parent
		ArrayList<HashMap<Integer,Integer>> ruleCounts = new ArrayList<HashMap<Integer,Integer>>();
		for (int i = 0; i < MAX_ID; i++) {
			ruleCounts.add(new HashMap<Integer,Integer>());
		}
		
		
		ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts = new ArrayList<ArrayList<HashMap<Integer,Integer>>>();
		
		
		HashMap<String,Integer> dist = new HashMap<String,Integer>();
		ArrayList<Tree> trees = makeList("../airplane.txt",alpha,ruleCounts);
		System.out.println("sz: " + trees.size());
		
		System.out.println("Rule counts: ");
		for (int key=0; key < MAX_ID; key++) {
			System.out.println(key + "/" + ruleCounts.get(key));
		}
		System.out.println("trees: ");
		for (Tree t : trees) {
			System.out.println(t);
		}
		
		
		for (int i=0;i<10000;i++) {
			for (int j=0; j < trees.size(); j++) {
			//for (int j=0; j < 1; j++) {
				Tree t = trees.get(j);
				String tr = t.toString();
				Integer temp =dist.get(tr);
				if (temp == null)
					dist.put(tr, new Integer(1));
				else
					dist.put(tr, temp+1);
				
				t.sampleNewConfig();
				allRuleCounts.add(cloneRuleList(ruleCounts));
			}
			
		}
		
		int totCount = 0;
		for (String tr : dist.keySet()) {
			totCount += dist.get(tr);
		}
		
		
		int max = 0;
		String maxTr = "";
		for (String tr : dist.keySet()) {
			System.out.println(tr + ":" + ((double) dist.get(tr))/totCount);
			if (dist.get(tr) > max) {
				max = dist.get(tr);
				maxTr = tr;
			}
		}
		System.out.println("Max: " + maxTr + ":" + ((double) max)/totCount);
		
		for (int i = 0; i < allRuleCounts.size(); i += 1000) {
			System.out.println("XXXXXX");
			ArrayList<HashMap<Integer,Integer>> temp = allRuleCounts.get(i);
			for (int par = 0; par < temp.size(); par++) {
				HashMap<Integer, Integer> parentRules = temp.get(par);
				System.out.println("===" + par + "===");
				for (int rule : parentRules.keySet())
					System.out.println(Tree.getRuleList(rule) + "/" + parentRules.get(rule));
			}
		}
		
		ArrayList<HashMap<Integer,Double>> postRules = getPosteriorRuleCounts(allRuleCounts,1000,100);
		for (int par = 0; par < postRules.size(); par++) {
			HashMap<Integer, Double> parentRules = postRules.get(par);
			System.out.println("===" + par + "===");
			for (int rule : parentRules.keySet())
				if (parentRules.get(rule) > 0.01)
					System.out.println(Tree.getRuleList(rule) + "/" + parentRules.get(rule));
		}
		
		System.out.println("Done!");
	}
	
	// not actual posterior of rule probs: need alpha for that
	private static ArrayList<HashMap<Integer,Double>> getPosteriorRuleCounts(ArrayList<ArrayList<HashMap<Integer,Integer>>> allRuleCounts, int thin, int burnin) {
		ArrayList<HashMap<Integer,Double>> res = new ArrayList<HashMap<Integer,Double>>(); 
		for (int i = 0; i < MAX_ID; i++) {
			res.add(new HashMap<Integer,Double>());
		}
		double totSamp = Math.floor(((double) allRuleCounts.size()-burnin)/ thin);
		
		for (int i = burnin; i < allRuleCounts.size(); i+= thin) {
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
