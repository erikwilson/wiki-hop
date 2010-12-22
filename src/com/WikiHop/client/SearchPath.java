package com.WikiHop.client;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("searchpath")
public interface SearchPath extends RemoteService {
	String find( String fromPage, String toPage ) throws IllegalArgumentException;
}
