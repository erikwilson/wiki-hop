package com.WikiHop.bulky;

import org.apache.hadoop.io.NullWritable;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.tools.mapreduce.AppEngineMapper;

public class DeleteAllMapper extends
		AppEngineMapper<Key, Entity, NullWritable, NullWritable> {

	@Override
	public void map(Key key, Entity value, Context context) {
		this.getAppEngineContext(context).getMutationPool().delete(value.getKey());
	}
}
