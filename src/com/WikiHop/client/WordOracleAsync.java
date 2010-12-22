package com.WikiHop.client;

import java.util.Collection;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface WordOracleAsync {
	void seer(String search, AsyncCallback<Collection<String>> callback) throws IllegalArgumentException;
}
