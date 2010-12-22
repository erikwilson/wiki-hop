package com.WikiHop.jdo;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

/* Page Keywords */
@PersistenceCapable
public class Pw  {

	/* Page name, with spaces instead of underscores */
	@PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private String n;

	/* Words which compose the name for this page */
    @Persistent
    private String[] w;

    /* Popularity ranking for a page, higher is better */
    @Persistent
    private int p;
    
    /* Accessors & mutators */
	public void setName(String n) { this.n = n; }
	public String getName() { return n; }

	public void setWords(String[] w) { this.w = w; }
	public String[] getWords() { return w; }

	public void setPopularity(Integer p) { this.p = p; }
	public Integer getPopularity() { return p; }
}
