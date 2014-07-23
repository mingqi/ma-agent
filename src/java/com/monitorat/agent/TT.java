package com.monitorat.agent;

public class TT {

	public static void main(String[] args) {
		try{
			System.out.println("aaaa");
			if(true){
				return;
			}
			System.out.println("bbbb");
		}finally{
			System.out.println("DONE");
		}
	}

}
