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

public class utils {
	
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
	
	public static LinkedHashMap<Long, Double> getSortedHashMap(HashMap<Long, Double> hashMap) {
		List<Map.Entry<Long, Double>> list = new LinkedList<Map.Entry<Long, Double>>(hashMap.entrySet());

		Collections.sort(list, new Comparator<Map.Entry<Long, Double>>() {
			public int compare(Map.Entry<Long, Double> m1, Map.Entry<Long, Double> m2) {
				return (m2.getValue()).compareTo(m1.getValue());
			}
		});

		LinkedHashMap<Long, Double> res = new LinkedHashMap<Long, Double>();
		for (Map.Entry<Long, Double> entry : list) {
			res.put(entry.getKey(), entry.getValue());
		}
		return res;
	}
	
}
