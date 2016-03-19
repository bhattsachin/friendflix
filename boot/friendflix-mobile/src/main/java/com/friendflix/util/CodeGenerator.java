package com.friendflix.util;

import java.util.Random;

public class CodeGenerator {
	
	private static Random random = new Random();
	
	public static void main(String args[]){
	
	}
	
	public static String createCode(int length){
		StringBuilder sb = new StringBuilder();
		
		for(int i=0;i<length;i++){
			sb.append(giveMeRandom());
		}
		return sb.toString();
	}
	
	public static int giveMeRandom(){
		return random.nextInt(37);
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
			return (char)(65 + num);
		}else{
			return(char)(48+num-26);
		}
		
		
	}
	
	
	

}
