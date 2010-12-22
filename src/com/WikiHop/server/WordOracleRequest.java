package com.WikiHop.server;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import com.WikiHop.client.WordOracle;
import com.WikiHop.jdo.Pw;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Query;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import static com.google.appengine.api.datastore.FetchOptions.Builder.*;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.FilterOperator;

@SuppressWarnings("serial")
public class WordOracleRequest extends RemoteServiceServlet implements WordOracle {
	
	public Collection<String> seer( String search ) throws IllegalArgumentException {
		Query q = new Query(Pw.class.getSimpleName());
		q.setKeysOnly();
//		q.addFilter("w", Query.FilterOperator.GREATER_THAN_OR_EQUAL, search);
//		q.addFilter("w", Query.FilterOperator.LESS_THAN_OR_EQUAL, search+"z");
		q.setFilter(CompositeFilterOperator.and(
				FilterOperator.GREATER_THAN_OR_EQUAL.of("w", search),
				FilterOperator.LESS_THAN_OR_EQUAL.of("w", search+"z")));
		q.addSort("w");
		q.addSort("p",Query.SortDirection.DESCENDING);	
		List<String> result = new ArrayList<String>();
		for (Entity e : DatastoreServiceFactory.getDatastoreService().
				prepare(q).asList(withLimit(20))) {
			result.add(e.getKey().getName());
		}
		return result;
	}
}
