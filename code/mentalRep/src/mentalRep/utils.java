package mentalRep;

import java.util.ArrayList;
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
	
}
