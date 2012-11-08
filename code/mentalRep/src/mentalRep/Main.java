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

	public static void main(String [ ] args) {

		double alpha = 0.1;
		
		HashMap<Integer,HashMap<Integer,Integer>> ruleCounts = new HashMap<Integer,HashMap<Integer,Integer>>();
		
		HashMap<String,Integer> dist = new HashMap<String,Integer>();
		ArrayList<Tree> trees = makeList("../test.txt",alpha,ruleCounts);
		System.out.println("sz: " + trees.size());
		
		System.out.println("Rule counts: ");
		for (int key: ruleCounts.keySet()) {
			System.out.println(key + "/" + ruleCounts.get(key));
		}
		System.out.println("trees: ");
		for (Tree t : trees) {
			System.out.println(t);
		}
		
		
		for (int i=0;i<100000;i++) {
			for (int j=0; j < trees.size(); j++) {
			//for (int j=0; j < 1; j++) {
				Tree t = trees.get(j);
				String tr = t.toString();
				Integer temp =dist.get(tr);
				if (temp == null)
					dist.put(tr, new Integer(1));
				else
					dist.put(tr, temp+1);
				
				//System.out.println(tr);
				/*
				System.out.println("Rule counts: ");
				for (int key: ruleCounts.keySet()) {
					System.out.println(key + "/" + ruleCounts.get(key));
				}
				*/
				t.sampleNewConfig();
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
		
		System.out.println("Rule counts: ");
		for (int key: ruleCounts.keySet()) {
			System.out.println(key + "/" + ruleCounts.get(key));
		}
		
	}
	
	private static ArrayList<Tree> makeList(String filename, double alpha,HashMap<Integer,HashMap<Integer,Integer>> ruleCounts) {
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

}
