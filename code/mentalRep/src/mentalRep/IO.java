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
import java.util.LinkedHashMap;

public class IO {

	public static ArrayList<int[]> readFile(String filename) {
		
		ArrayList<int[]> seqs = new ArrayList<int[]>();
		
		try {
			FileInputStream fstream;
			fstream = new FileInputStream(filename);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null)   {
				// Print the content on the console
				String str[] = strLine.split(","); 
				int [] seq = new int[str.length];
				for (int i = 0; i < seq.length; i++) {
					seq[i] = Integer.parseInt(str[i]);
				}
				seqs.add(seq);
			}
			in.close();
		}
		catch (FileNotFoundException e) {
			throw new RuntimeException("Error!: " + e.getMessage());
		} catch (NumberFormatException e) {
			throw new RuntimeException("Error!: " + e.getMessage());
		} catch (IOException e) {
			throw new RuntimeException("Error!: " + e.getMessage());
		}			
		return seqs;
	}
	
	public static void outputStats(ArrayList<Double> decaySamps, 
            int treeAcceptTotal, int decayAcceptTotal, 
            ArrayList<Tree> trees, int ITERS, PrintStream out) {

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
	public static void outputMostLikelyGens(ArrayList<ArrayList<HashMap<Long, Double>>> childParRules, ArrayList<String> partList, PrintStream out) {
		
		for (int i = 0; i < childParRules.size(); i++) {
			out.println("=== Child: " + partList.get(i) + "===");

			ArrayList<HashMap<Long, Double>> child = childParRules.get(i);	

			HashMap<String,Double> parentProbs = new HashMap<String,Double>();
			for (int j = 0; j < child.size(); j++) {
				HashMap<Long,Double>childParProbs = child.get(j);
				double totParentProb = 0;
				for (long rule : childParProbs.keySet()) {
					totParentProb += childParProbs.get(rule);
				}
				parentProbs.put(partList.get(j),totParentProb);
			}

			LinkedHashMap<String, Double> parentProbsSorted = Utils.getSortedHashMap(parentProbs);
			for (String rule : parentProbsSorted.keySet()) {
				if (parentProbsSorted.get(rule) > 0.001) {
					out.println("   --- Parent: " + rule + ": " + parentProbsSorted.get(rule)); 
				}
			}
		}

		out.println("---------------------");
		for (int i = 0; i < childParRules.size(); i++) {
			out.println("=== Child: " + partList.get(i) + "===");
			ArrayList<HashMap<Long, Double>> child = childParRules.get(i);	

			for (int j = 0; j < child.size(); j++) {

				LinkedHashMap<Long, Double> childParProbs = Utils.getSortedHashMap(child.get(j));

				double totParentProb = 0;
				for (long rule : childParProbs.keySet()) {
					totParentProb += childParProbs.get(rule);
				}



				out.println("   --- Parent: " + partList.get(j) + ": " + totParentProb + "---");

				for (long rule : childParProbs.keySet()) {
					if (childParProbs.get(rule) > 0.001) {
						out.println("         " + Node.getRuleListStrings(rule, partList) + "/" + childParProbs.get(rule));
					}
				}
			}
		}
	}

	public static void outputPosteriorRuleCounts(ArrayList<HashMap<Long, Double>> postRules, ArrayList<String> partList, PrintStream out) {

		for (int par = 0; par < postRules.size(); par++) {

			LinkedHashMap<Long, Double> parentRules = Utils.getSortedHashMap(postRules.get(par));

			out.println("===" + partList.get(par) + "===");

			for (long rule : parentRules.keySet())
				if (parentRules.get(rule) > 0.001)
					out.println(Node.getRuleListStrings(rule, partList) + "/" + parentRules.get(rule));
		}
	}

	public static void outputRuleCounts(ArrayList<ArrayList<HashMap<Long, Integer>>> allRuleCounts, String filename) throws IOException {
			FileOutputStream fo = new FileOutputStream(filename);  
		    ObjectOutputStream oo=new ObjectOutputStream(fo); 
		    oo.writeObject(allRuleCounts);
		    oo.close();
	}
	
	public static ArrayList<ArrayList<HashMap<Long, Integer>>> readRuleCounts(String filename) throws IOException, ClassNotFoundException {
		
		FileInputStream fi=new FileInputStream(filename);  
	    ObjectInputStream oi=new ObjectInputStream(fi);  

		ArrayList<ArrayList<HashMap<Long,Integer>>> allRuleCounts=(ArrayList<ArrayList<HashMap<Long,Integer>>>)oi.readObject();  
	    oi.close();
	    
	    return allRuleCounts;
	}
	
	public static void outputDecaySamps(ArrayList<Double> decaySamps, String filename) throws IOException {
		FileOutputStream fo = new FileOutputStream(filename);  
	    ObjectOutputStream oo=new ObjectOutputStream(fo); 
	    oo.writeObject(decaySamps);
	    oo.close();
	}

	public static ArrayList<Double> readDecaySamps(String filename) throws IOException, ClassNotFoundException {
		FileInputStream fi=new FileInputStream(filename);  
	    ObjectInputStream oi=new ObjectInputStream(fi);  

		ArrayList<Double> decaySamps=(ArrayList<Double>)oi.readObject();  
	    oi.close();
	    
	    return decaySamps;
		
	}

	public static void outputInferProbs(ArrayList<Double> logProbsPost, PrintStream out) {
		double totalLogProb = 0;
		for (double logProb : logProbsPost) {
			totalLogProb += logProb;
		}
		
		out.println("Overall logProb: " + totalLogProb);
		out.println("Seq probs: ");
		
		for (double logProb : logProbsPost) {
			out.println(logProb);
		}
	}


	
}
