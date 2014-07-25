package com.monitorat.agent;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

public class SQLQuery {

	public static void main(String[] args) throws Exception {

		int curr = 0;
		String host = null;
		int port = 1521;
		String user = null;
		String password = null;
		String database = null;
		String query = null;
		String sid = null;

		while (curr <= args.length - 1) {
			if (args[curr].equals("--host")) {
				curr++;
				host = args[curr];
			}

			if (args[curr].equals("--port")) {
				curr++;
				port = Integer.parseInt(args[curr]);
			}

			if (args[curr].equals("--user")) {
				curr++;
				user = args[curr];
			}

			if (args[curr].equals("--password")) {
				curr++;
				password = args[curr];
			}

			if (args[curr].equals("--database")) {
				curr++;
				database = args[curr];
			}
			if (args[curr].equals("--sid")) {
				curr++;
				sid = args[curr];
			}
			if (args[curr].equals("--query")) {
				curr++;
				query = args[curr];
			}
			curr++;
		}
		
		try{
			BufferedReader br = 
	                      new BufferedReader(new InputStreamReader(System.in));
			String input;
			while((input=br.readLine())!=null){
				if(input.startsWith("password:")){
					password = input.split(":", 2)[1].trim();
				}
			}
	 
		}catch(IOException io){
			io.printStackTrace();
		}

		int exitCode = 0;
		Class.forName("oracle.jdbc.driver.OracleDriver");
		Connection connection = null;
		Statement stmt = null;
		try {
			DriverManager.setLoginTimeout(3);
			connection = DriverManager.getConnection("jdbc:oracle:thin:@"
					+ host + ":" + port + ":" + sid, user, password);
			connection.createStatement().execute("alter session set current_schema="+database);
			
			stmt = connection.createStatement();
			ResultSet rs = stmt.executeQuery(query);
			int rowCount = 0;
			Object value = null;
			ResultSetMetaData meta = rs.getMetaData();
			while(rs.next()){
				rowCount ++;
				value = rs.getObject(1);
			}

			if(rowCount == 0){
				exitCode = 11;
				return;
			}

			if(meta.getColumnCount() > 1){
				exitCode = 12;
				return;
			}
			
			if(rowCount > 1){
				exitCode = 13;
				return;
			}
			
			System.out.println(value.toString());
		} catch (Exception e) {
			System.out.println(e.getMessage());
			exitCode = 255;
		}finally{
			if(stmt !=null && !stmt.isClosed()){
				stmt.close();
			}
			if(connection != null && !connection.isClosed()){
				connection.close();
			}
			System.exit(exitCode);
		}
		
	}
}
