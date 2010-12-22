package com.WikiHop.bulky;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.logging.Logger;

import org.apache.hadoop.io.NullWritable;

import com.WikiHop.jdo.Pi;
import com.WikiHop.jdo.Pw;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.tools.mapreduce.AppEngineMapper;
import com.google.appengine.tools.mapreduce.BlobstoreRecordKey;
import com.google.appengine.tools.mapreduce.DatastoreMutationPool;


public class ImportFromBlobstoreMapper extends
		AppEngineMapper<BlobstoreRecordKey, byte[], NullWritable, NullWritable> {
	
	private static final Logger log = Logger.getLogger(ImportFromBlobstoreMapper.class.getName());

	static private ArrayList<Long> createLongs(String s) {
		ArrayList<Long> l = null;
		if (!s.isEmpty()) {
			String[] v = s.split(",");
			l = new ArrayList<Long>(v.length);
			for (int i=0; i<v.length; i++) {
				l.add(new Long(v[i]));
			}
		}
		return l;
	}

	@Override
	public void map(BlobstoreRecordKey key, byte[] segment, Context context) {
			String[] values = null;
			try {
				values = new String(segment,"UTF-8").split("\t",-1);
			} catch (UnsupportedEncodingException e) {
				log.warning(e.toString());
			}
	
			DatastoreMutationPool mutationPool = this.getAppEngineContext(context).getMutationPool();
			
			if(values!=null && values.length==6) {
				long pageId = Long.parseLong(values[0]);
				
				String pageName = values[1];
				Entity pageInfo = new Entity(KeyFactory.createKey(Pi.class.getSimpleName(),pageId));
				Entity pageWords = new Entity(KeyFactory.createKey(Pw.class.getSimpleName(),pageName.replace("_"," ")));
				pageInfo.setProperty("n",pageName);
				int popularity = 0;
				
				if (!values[2].equals("")) {
					ArrayList<Long> links = createLongs(values[2]);
					pageInfo.setUnindexedProperty("l",links);
					popularity += links.size();
				}
												
				if (!values[3].equals("")) {
					ArrayList<Long> linkedFrom = createLongs(values[3]);
					pageInfo.setUnindexedProperty("f",linkedFrom);
					popularity += linkedFrom.size();
				}

				if (!values[4].equals("")) {
					String[] a = values[4].split("(?<!\\\\),");
					for (int i=0; i<a.length; i++)
						a[i] = a[i].replace("\\","");
					pageInfo.setProperty("a",Arrays.asList(a));
				}
				
				if (!values[5].equals("")) {
					String[] w = values[5].split("(?<!\\\\),");
					for (int i=0; i<w.length; i++)
						w[i] = w[i].replace("\\","");
					pageWords.setProperty("w",Arrays.asList(w));
					pageWords.setProperty("p",popularity);
				}

				mutationPool.put(pageInfo);
				mutationPool.put(pageWords);
				mutationPool.flush();
				
			} else {
				log.warning("Got entry of size " + values.length);
			}
	}
}