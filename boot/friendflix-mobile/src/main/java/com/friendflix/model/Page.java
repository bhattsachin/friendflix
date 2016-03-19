package com.friendflix.model;

import java.security.Timestamp;

/**
 * represents one unit of interaction
 * @author bhatt
 *
 */
public class Page {
	//whenver this page first came into existence
	private long startTimestamp;
	//if a page has active sessions and not reached expiration limit 
	//it is valid. invalid sessions need to be destroyed
	private boolean valid;
	

	

}
