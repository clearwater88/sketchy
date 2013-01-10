package mentalRep;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class Utils {
	
	private static final Random gen = new Random();
	
	public static int sampleArrayList(ArrayList<Double> probs) {
		int totProb = 0;
		for (double d : probs) {
			totProb += d;
		}
		double genProb = gen.nextDouble();
		for (int i=0; i < probs.size(); i++) {
			double probUse = probs.get(i)/totProb;
			if (probUse > genProb) {
				return i;
			}
		}
		throw new RuntimeException("aw nuts");
	}
	
	public static <T> LinkedHashMap<T, Double> getSortedHashMap(HashMap<T, Double> hashMap) {
		List<Map.Entry<T, Double>> list = new LinkedList<Map.Entry<T, Double>>(hashMap.entrySet());

		Collections.sort(list, new Comparator<Map.Entry<T, Double>>() {
			public int compare(Map.Entry<T, Double> m1, Map.Entry<T, Double> m2) {
				return (m2.getValue()).compareTo(m1.getValue());
			}
		});

		LinkedHashMap<T, Double> res = new LinkedHashMap<T, Double>();
		for (Map.Entry<T, Double> entry : list) {
			res.put(entry.getKey(), entry.getValue());
		}
		return res;
	}
	

	public static <T, V> ArrayList<HashMap<T,V>> cloneRuleList(ArrayList<HashMap<T,V>> ruleCounts) {
		ArrayList<HashMap<T,V>> res = new ArrayList<HashMap<T,V>>();
		
		for (int i = 0; i < ruleCounts.size(); i++) {
			HashMap<T,V> temp = new HashMap<T,V>(ruleCounts.get(i));
			res.add(temp);
		}		
		return res;
	}
	
	
}
