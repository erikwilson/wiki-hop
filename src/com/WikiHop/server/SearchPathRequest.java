package com.WikiHop.server;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Random;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;

import javax.jdo.JDOObjectNotFoundException;

import net.sf.jsr107cache.Cache;

import com.WikiHop.client.SearchPath;
import com.WikiHop.jdo.Pi;
import com.WikiHop.shared.FieldScrubber;

@SuppressWarnings("serial")
public class SearchPathRequest extends RemoteServiceServlet implements SearchPath {

	static final int MAX_PATHS = 1;
	static final int MAX_DEPTH = 1024;
	
	private class PathMap {
		public HashMap<Long,Long> path, next;
		public LinkedList<Long> keyList, newKeys;
		public Long root, target;
		public Long connect = null;
		public Random rng;
		public boolean found = false, forward = true;
		@SuppressWarnings("unused")
		StringBuilder log;
		
		public PathMap(Long root, Long target, boolean forward, Random rng) {
			this.root = root;
			this.target = target;
			this.rng = rng;
			this.path = new HashMap<Long,Long>();	
			this.next = new HashMap<Long,Long>();	
			this.next.put(root,new Long(0));
			this.keyList = new LinkedList<Long>();	
			this.keyList.push(root);
			this.newKeys = new LinkedList<Long>();
			this.log = new StringBuilder();
			this.forward = forward;
		}
		
		public boolean match(Long link) {
			if (this.next.containsKey(link)) {
				this.path.put(link,this.next.remove(link));
				return true;
			} else
				return this.path.containsKey(link);
		}
		
		public void addNext(Long link, Long id) {
			if (!this.path.containsKey(link)) {
				if (!this.next.containsKey(link)) { 
					this.next.put(link,id);
					this.newKeys.add(this.rng.nextInt(this.newKeys.size()+1),link);
				}
				//this.newKeys.push(link);
			}
		}
		
		public void addNewKeys() {
			while (!this.newKeys.isEmpty()) {
				//this.keyList.push(this.newKeys.pop());
				this.keyList.addLast(this.newKeys.pop());
				//this.keyList.add(this.rng.nextInt(this.keyList.size()+1),this.newKeys.pop());
			}
		}

		public Long nextKey() {
			Long link = this.keyList.pop();
			Long id = this.next.remove(link);
			if (id!=null) {
				this.path.put(link,id);
				return link;
			} else return null;
		}
		
		public Long[] getLinks(Long id) {
			Long[] links = null;
			try { 
				if (id!=null) {
					if (this.forward) links = Pi.getById(id).getLinks();
					else links = Pi.getById(id).getLinkedFrom();
					Collections.shuffle(Arrays.asList(links),this.rng);
				}
			} catch (JDOObjectNotFoundException e) {}
			return links;
		}
		
		public void complete(
				final PathMap reverse, 
				Long to, 
				Long from
		) {
			if (!this.path.containsKey(to)) this.path.put(to,from);
			if (!reverse.found) this.found = true;
			this.connect = to;
			from = reverse.path.get(to);
			int depth=1;
			while(from!=0 && (depth++<=MAX_DEPTH)) {
				this.path.put(from,to);
				to = from;
				from = reverse.path.get(to);
			}
		}
		
		int nextPathSize(final int paths, final int size) {
			return	((paths<size) ? paths : 
				((!this.forward || size==MAX_PATHS) ? size :
					((size*2)>=MAX_PATHS ? MAX_PATHS : size*2 )));
		}
	}
	
	static public boolean search(
			final PathMap forward, 
			final PathMap backward 
	) throws IllegalArgumentException {
		if (!forward.root.equals(backward.target) || !backward.root.equals(forward.target))
			throw new IllegalArgumentException("PathMap root and targets do not match");
		if (forward.root.equals(backward.root))
			throw new IllegalArgumentException("Start and end pages must not match.");
		return search(forward,backward,0,1);
	}
	
	static private boolean search(
			final PathMap forward, 
			final PathMap backward, 
			final int depth,
			final int path_size
	) throws IllegalArgumentException {
		
		if (depth >= MAX_DEPTH) 
			throw new IllegalArgumentException("Max depth reached at " + depth);
		
		int paths = 1;
		boolean found = false;

		while(!found && !forward.keyList.isEmpty() && (paths<=path_size)) {

			Long id = forward.nextKey();
			Long[] links = forward.getLinks(id);

			if (links!=null) {
				for (int i=0; !found && i<links.length; i++) {
					Long link = links[i];
					if (backward.match(link)){
						forward.complete(backward,link,id);
						backward.complete(forward,id,link);
						found = true;
					} else {
						forward.addNext(link,id);
					}
				}
				paths++;
			}
		}
		
		if (found || forward.next.isEmpty() || backward.next.isEmpty()) {
			return found;
		} else {
			forward.addNewKeys();
			return search(backward,forward,depth+1,backward.nextPathSize(paths,path_size));
		}
	}
	
	private static String getPageName(Long id) {
		try { return getPageName(Pi.getById(id),id); }
		catch (Exception e) { return getPageName(null,id); }
	}
	
	private static String getPageName(Pi page, Long id) {
		return (page != null ? page.getName() : "?id="+id );
	}
	
	private static String getPageLabel(Long id) {
		try { return getPageLabel(Pi.getById(id),id); }
		catch (Exception e) { return getPageLabel(null,id); }
	}
	
	private static String getPageLabel(Pi page, Long id) {
		return "\""+(page != null 
				? page.getName() + " ("+page.getLinks().length+","+page.getLinkedFrom().length+")"
				: "?id="+id ).
			replace("\"","\\\"").replace("'","%27").replace("_"," ")+"\"";
	}

	private class GraphIds {
		private HashMap<Long,Long> new_ids = new HashMap<Long,Long>();
		private long id_count = 0;				
		public boolean hasId(Long id) { return new_ids.containsKey(id); }
		public Long getId(Long id) { return new_ids.get(id); }
		public Long addId(Long id) {
			new_ids.put(id,id_count);
			return id_count++;
		}
		public long size() { return id_count; }
	}
	
	private static class GraphHelper {
		public GraphIds gi;
		public HashMap<Long,LinkedList<Long>> map = new HashMap<Long,LinkedList<Long>>();
		public String graph = "";
		LinkedList<String> labels = new LinkedList<String>();
		
		public GraphHelper(final GraphIds ids) { gi = ids; }
		
		public void addLabel(Long id) {
			labels.add(gi.getId(id)+"[label="+getPageLabel(id)+"]\n");
		}
		
		public Long add(final Long id) {
			if (!gi.hasId(id)) {
				Long newid = gi.addId(id);
				addLabel(id);
				return newid;
			} else 
				return gi.getId(id);
		}

		public void remap(final HashMap<Long,Long> oldmap) {
			Iterator<Long> et=oldmap.keySet().iterator();
			while (et.hasNext()) {
				Long id = et.next();
				Long to = oldmap.get(id);
				if (to != 0) {
					if (!map.containsKey(to)) map.put(to,new LinkedList<Long>());
					map.get(to).add(id);
				} else oldmap.remove(to);
			}
		}

		public LinkedList<Long> connected(Long id) { return map.get(id); }
		public Iterator<Long> iterator() { return map.keySet().iterator(); }
		
		public void addGraph(String g) {
			graph += g;
		}
	}
	
	public String find( String fromPage, String toPage ) throws IllegalArgumentException {
		
		Long pageA=null, pageB=null;
		String result = "";
		
		try { pageA = Pi.find(FieldScrubber.scrub(fromPage)); }
		catch (JDOObjectNotFoundException e) { result += e.getMessage() + "<br>"; }
		try { pageB = Pi.find(FieldScrubber.scrub(toPage));} 
		catch (JDOObjectNotFoundException e) { result += e.getMessage() + "<br>"; }
		if (!result.equals(""))	throw new IllegalArgumentException(result);
		
		Pair<Long,Long> request = new Pair<Long,Long>(pageA,pageB);
		Cache cache = null;
		try {
			cache = Cacher.getCache("path");
			if (cache != null) {
				String cacheResult = (String) cache.get(request);
				if (cacheResult != null) return cacheResult + "<div id='cached'>(cached)</div>";
			}
		} catch (Exception e) {}
		
		
		boolean found = false;
		Random rng = new Random(0);
		PathMap start = new PathMap(pageA,pageB,true,rng);
		PathMap end = new PathMap(pageB,pageA,false,rng);

		found = search(start,end);
		LinkedList<Long> path = new LinkedList<Long>();
		GraphIds gids = new GraphIds();
		GraphHelper gviz = new GraphHelper(gids); 
		GraphHelper fromViz = new GraphHelper(gids);
		GraphHelper toViz = new GraphHelper(gids);
		
        //gviz.addGraph((new StringBuilder("fontsize=10;label=\"\251 ")).append(Calendar.getInstance().get(1)).append(" Wiki-Hop (www.wiki-hop.org)\";\n").toString());
        //gviz.addGraph("rankdir=LR;node[shape=folder,style=filled,color=yellowgreen]\n");

        gviz.addGraph("fontsize=10;label=\"\251 " + Calendar.getInstance().get(Calendar.YEAR) 
				+	" Wiki-Hop (www.wiki-hop.org)\";\n");
		gviz.addGraph("rankdir=LR;node[shape=folder,style=filled,color=yellowgreen]\n");
		
		String crumbs = "";
		if (found) {
			Long id = pageA;
			int depth=1;
			while (id!=0 && (depth++<=MAX_DEPTH)) {
				String pageName = getPageName(id);
				crumbs += "<a target='_blank' href='http://en.wikipedia.org/wiki/"+
							pageName.replace("\"","%22").replace("'","%27")+"'>"+
							pageName.replace("_"," ")+"</a>";
				start.path.remove(id);
				path.add(id);
				gviz.add(id);
				id = end.path.remove(id);
				if (id!=0) {
					crumbs += " // ";
				}
			}
		} else {
			crumbs += "Path not found";
		}
		
		if (!path.isEmpty()) {
			Long first = null;
			gviz.addGraph("{edge[arrowhead=dot]");
			for (Long next: path) {
				if (first!=null) gviz.addGraph("->");
				gviz.addGraph(Long.toString((gids.getId(next))));
				first = next;
			}
			gviz.addGraph("}\n");
		}
		
		if (start.connect!=null && end.connect!=null) {
			gviz.addGraph("{edge[arrow"+(end.found?"tail":"head")+"=box,"
					+(end.found?"dir=back,":"")+"color=indigo]");
			gviz.addGraph(gids.getId(end.connect)+"->"+gids.getId(start.connect)+"}\n");
		}

		int not_shown = 0;

		if (start.path.size()>0 || end.path.size()>0)
			gviz.addGraph("edge[arrowhead=odot]node[color=lightgrey]\n");

		Iterator<Long> st=null,et=null;		

		fromViz.remap(start.path);
		st = fromViz.iterator();

		if (st.hasNext()) fromViz.addGraph("edge[color=royalblue]\n");
		else if (!found) fromViz.add(start.root);

		while (st.hasNext()) {
			Long to = st.next();
			LinkedList<Long> ids = fromViz.connected(to);
			fromViz.add(to);
			fromViz.addGraph(gids.getId(to)+"->"+(ids.size()>1?"{":""));
			String del = "";
			for (Long id:ids) {
				fromViz.addGraph(del+fromViz.add(id));
				del=",";
			}
			fromViz.addGraph((ids.size()>1?"}":"")+";\n");
		}

		toViz.remap(end.path);
		et = toViz.iterator();
		if (et.hasNext()) toViz.addGraph("edge[color=crimson]\n");
		else if (!found) toViz.add(end.root);

		while (et.hasNext()) {
			Long to = et.next();
			LinkedList<Long> ids = toViz.connected(to);
			toViz.add(to);
			toViz.addGraph((ids.size()>1?"{":""));
			String del = "";
			for (Long id:ids) {
				toViz.addGraph(del+toViz.add(id));
				del=",";
			}
			toViz.addGraph((ids.size()>1?"}":"")+"->");
			toViz.addGraph(gids.getId(to)+";\n");
		}

		String graph = gviz.graph + fromViz.graph + toViz.graph;
		String extra_labels = "";
		
		final int GRAPH_LIMIT=1500;
		final int NODE_LIMIT=200;
		
		Iterator<String> gL=gviz.labels.iterator();
		while (gL.hasNext()) {
			String gLN=(gL.hasNext()?gL.next():null);
			if (gLN!=null) {
				if (graph.length()<GRAPH_LIMIT ) { graph += gLN; }
				else { extra_labels += gLN; not_shown++; }
			}
		}

		Iterator<String> fL=fromViz.labels.iterator(), tL=toViz.labels.iterator();
		while (fL.hasNext() || tL.hasNext()) {
			String fLN=(fL.hasNext()?fL.next():null), tLN=(tL.hasNext()?tL.next():null);
			if (fLN!=null) {
				if (graph.length()<GRAPH_LIMIT ) graph += fLN; 
				else  { extra_labels += fLN; not_shown++; }
			}
			if (tLN!=null) {
				if (graph.length()<GRAPH_LIMIT ) graph += tLN; 
				else { extra_labels += tLN; not_shown++; }
			}
		}
		
		result += "<div id='crumbs'>"+crumbs+"</div>";
		if (gids.size()<NODE_LIMIT) {
			result += "<p><img src='http://chart.apis.google.com/chart?cht=gv&chl=digraph{size=\"12,48\";"+graph+"}'/></p>";
			result += (not_shown!=0 ? "<p>"+not_shown+" names not shown.</p>" : "");
			result += "<a target='_blank' href='http://chart.apis.google.com/chart?cht=gv&chl=digraph{"+graph+"}'>graph permalink</a> // ";
		} else {
			result += "<h2>Graph too large</h2>";
		}
		result += "<a onclick='dataView();return false;' id='graph_link'>view data</a><div id='graph_data'><pre>" + graph + extra_labels + "</pre></div>";
		
		try {
			if (cache != null) cache.put(request,result);
		} catch (Exception e) {}
		
		return result;
	}
}