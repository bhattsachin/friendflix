package com.friendflix.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.friendflix.util.CodeGenerator;

@Controller
public class UIController {
	
	@RequestMapping(value="/home", method=RequestMethod.GET)
	public String homePage(){
		return "index";
	}
	
	@RequestMapping(value="/new")
	public String newRedirection(){
		String code = CodeGenerator.createCode(4);
		//fixme: add a session checker here, if this session is already
		//assigned and in use, create a new one.
		return "redirect:/page/" + code;
	}
	/**
	 * Thought: since this will be most use page, 
	 * we should move it out and make it primary access
	 * ie: make code suffix to host name directly
	 * @return
	 */
	@RequestMapping(value="/page/{code}")
	public String newPage(@PathVariable String code){
		return "home";
	}

}
