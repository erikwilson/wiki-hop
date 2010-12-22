package com.WikiHop.jdo;

import java.io.Serializable;
import java.util.List;
import java.util.ListIterator;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.jdo.annotations.Extension;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.WikiHop.server.Cacher;
import net.sf.jsr107cache.Cache;

@PersistenceCapable
public class Pi implements Serializable {
	
	private static final long serialVersionUID = 0xC0FFEE;

	static Cache cache = null;
	
	/* Numeric page id */
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Long id;

	/* Page name, with mixed case and underscores */
	@Persistent
	private String n;

	/* Pages linked to */
	@Persistent
	@Extension(vendorName = "datanucleus", key = "gae.unindexed", value="true")
	private Long[] l;

	/* Pages linked from */
	@Persistent
	@Extension(vendorName = "datanucleus", key = "gae.unindexed", value="true")
	private Long[] f;

	/* Aliases for this page, lowercase, with spaces instead of underscores */
	@Persistent
	private String[] a;

	public static Pi getById(Long id) throws JDOObjectNotFoundException {
		try {
			if (cache == null) cache = Cacher.getCache("Pi");
			if (cache != null) {
				Pi cacheResult = (Pi) cache.get(id);
				if (cacheResult != null) return cacheResult;
			}
		} catch (Exception e) {}
		try {
			Pi result = PMF.get().getPersistenceManager().getObjectById(Pi.class,id);
			try { if (cache != null) cache.put(id,result); } catch (Exception  e) {}
			return result;
		} catch (Exception e) {
			throw new JDOObjectNotFoundException();
		}
	}

	@SuppressWarnings("unchecked")
	public static Long findName(String name) {
		name = name.replace(" ","_");
		Long result = new Long(0);
		try {
			if (cache == null) cache = Cacher.getCache("Pi");
			if (cache != null ) {
				Long cacheResult = (Long) cache.get(name);
				if (cacheResult != null) return cacheResult; 
			}
		} catch (Exception e) {}

		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(Pi.class);
		query.setFilter("n == name");
		query.declareParameters("String name");
		List<Pi> results = (List<Pi>) query.execute(name);
		for (Pi p : results) result = p.getPageId();
		query.closeAll();
		try { if (cache != null) cache.put(name,result); } catch (Exception e) {}                
		return result;
	}


	@SuppressWarnings("unchecked")
	public static Long find(String alias) throws JDOObjectNotFoundException {
		String searchAlias = alias.toLowerCase().replace("_"," ");
		Long result = new Long(0);	
		if (cache == null) cache = Cacher.getCache("Pi");
		if (cache != null) {
			Long cacheResult = null;
			try {
				cacheResult = (Long) cache.get(searchAlias);
			} catch (Exception e) {}
			if (cacheResult != null) { 
				if (cacheResult != 0) return cacheResult;
				else throw new JDOObjectNotFoundException(alias + " not found.");
			}
		}

		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(Pi.class);
		query.setFilter("a == alias");
		query.declareParameters("String alias");

		try {
			List<Pi> results = (List<Pi>) query.execute(searchAlias);
			if (results.size()>1) {
				Long nameId = findName(alias);
				if (nameId != 0) {
					return nameId;
				} else {
					String error = "Found multiple pages for alias "+alias+": ";
					ListIterator<Pi> itr = results.listIterator();
					while (itr.hasNext()) {
						Pi p = (Pi) itr.next();
						error += p.getName();
						if (itr.hasNext()) error += ", ";
					}
					throw new JDOObjectNotFoundException(error);
				}
			} else for (Pi p : results) result = p.getPageId();
		} 
		finally { query.closeAll(); }

		try { if (cache != null) cache.put(searchAlias,result); } catch (Exception e) {}
		if (result != 0) return result;
		else throw new JDOObjectNotFoundException(alias + " not found.");
	}


	/* Accessors & mutators */
	public void setPageId(Long id) { this.id = id; }
	public Long getPageId() { return id; }

	public void setName(String n) { this.n = n; }
	public String getName() { return n; }

	public void setLinks(Long[] l) { this.l = l; }
	public Long[] getLinks() { return l; }

	public void setLinkedFrom(Long[] f) { this.f = f; }
	public Long[] getLinkedFrom() { return f; }

	public void setAliases(String[] a) { this.a = a; }
	public String[] getAliases() { return a; }
}
