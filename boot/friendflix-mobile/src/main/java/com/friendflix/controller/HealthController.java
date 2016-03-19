package com.friendflix.controller;

import java.sql.Date;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@EnableAutoConfiguration
public class HealthController {

	@RequestMapping("/")
	@ResponseBody
	public String home(){
		return "Server up at" + new Date(System.currentTimeMillis());
	}
	
	
	
}
