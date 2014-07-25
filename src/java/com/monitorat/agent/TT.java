package com.monitorat.agent;

public class TT {

	public static void main(String[] args) {
		String a = "password: thisis password: faf";
		String s = a.split(":", 2)[1];
		System.out.println(s);
	}

}
