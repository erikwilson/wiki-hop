package com.WikiHop.shared;

public class FieldScrubber {
	public static String scrub(String s) {
		return s.replace("<","&lt;").replace(">","&gt;");
	}
}
