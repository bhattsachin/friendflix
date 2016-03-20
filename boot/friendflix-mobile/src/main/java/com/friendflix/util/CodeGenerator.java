package com.friendflix.util;

import java.util.Random;

public class CodeGenerator {
	
	private static Random random = new Random();
	private static int ALPHA_ASCII_START = 97;
	private static int NUMBER_ASCII_START = 48;
	
		
	public static String createCode(int length){
		StringBuilder sb = new StringBuilder();
		
		for(int i=0;i<length;i++){
			sb.append(getCharForNum(giveMeRandom()));
		}
		return sb.toString();
	}
	
	public static int giveMeRandom(){
		return random.nextInt(36);
	}
	
	/**
	 * return a char value based on input
	 * @param num
	 * @return
	 */
	public static char getCharForNum(int num){
		if(num>35 || num<0){
			return '-';
		}
		if(num<26){
			return (char)(ALPHA_ASCII_START + num);
		}else{
			return(char)(NUMBER_ASCII_START+num-26);
		}
		
		
	}
	
	
	

}
