package com.friendflix.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.friendflix.util.CodeGenerator;

@Controller
public class UIController {
	
	@RequestMapping(value="/home", method=RequestMethod.GET)
	public String homePage(){
		return "index";
	}
	
	public String newRedirection(){
		//String code = CodeGenerator.createCode(4);
		return "";
	}
	
	public String newPage(){
		return "home";
	}

}
