package com.WikiHop.client;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface SearchPathAsync {
	void find(String fromPage, String toPage, AsyncCallback<String> callback) throws IllegalArgumentException;;
}
