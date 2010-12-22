package com.WikiHop.client;

import java.util.Collection;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("wordoracle")
public interface WordOracle extends RemoteService {
	Collection<String> seer(String search) throws IllegalArgumentException;
}
