<%@ page isErrorPage="true"  contentType="text/html; charset=UTF-8"%>

<HTML>

<BODY>

 

<H1>Error page</H1>

 

<BR>An error occured in the bean. Error Message is: <%= exception.getMessage() %><BR>

Stack Trace is : <PRE><FONT COLOR="RED"><%

 java.io.CharArrayWriter cw = new java.io.CharArrayWriter();

 java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);

 exception.printStackTrace(pw);

 System.out.println(cw.toString());

 %></FONT></PRE>

<BR></BODY>

</HTML>
