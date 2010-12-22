package com.WikiHop.server;

import java.util.Collections;

import net.sf.jsr107cache.Cache;
import net.sf.jsr107cache.CacheFactory;
import net.sf.jsr107cache.CacheManager;

public class Cacher {
	public static Cache getCache(String name) {
		Cache cache = null;
		try {
			cache = CacheManager.getInstance().getCache(name);
			if (cache == null) {
				CacheFactory cacheFactory =
					CacheManager.getInstance().getCacheFactory();
				cache = cacheFactory.createCache(Collections.emptyMap());
				CacheManager.getInstance().registerCache(name, cache);
			}
		} catch (Exception e) {} 
		return cache;
	}
}
