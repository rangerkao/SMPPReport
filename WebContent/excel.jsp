<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<%
	response.setContentType("application/vnd.ms-excel");
	response.setHeader("Content-Disposition", "inline; filename="+ "excel.xls");
	if (session.getAttribute("mytype")==null){
		response.sendRedirect("index.html");
		return;
	}
String u=null;
if (((String)session.getAttribute("mytype")).equals("99")){
	u=request.getParameter("userid");
}else{
	u=(String)session.getAttribute("memberid");
}

String rMsg="";
String m=request.getParameter("msgid");
String f=request.getParameter("dfrom");
String t=request.getParameter("dto");
SimpleDateFormat fromUser = new SimpleDateFormat("yyyyMMddHHmmss");
SimpleDateFormat fromInput = new SimpleDateFormat("yyyy/MM/dd");
SimpleDateFormat myFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
if (u!=null||m!=null||f!=null||t!=null){
	if ((f!=null&&t==null)||(t!=null&&f==null)){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		return;
	}
        if (f!=null&&t!=null)
	if ((!f.equals("")&&t.equals(""))||(!t.equals("")&&f.equals(""))){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		return;
	}
	String sql="select s.userid,i.msgid,seq,schedule,phoneno,msgbody,tries,status,donetime,m.createtime,orgcode from smppuser s, messages m, msgitem i where s.userid=m.userid and i.msgid=m.msgid ";
	String cc="";
	if (u!=null)
	if (!u.equals("")){
		cc+="and s.userid=?  ";
	}
	if (m!=null){
		if (!m.equals(""))
			cc+="and i.msgid=?  ";
	}
	/*
	if (r!=null){
		cc+="and i.rid=?  ";
	}
	*/
	if (f!=null&&t!=null)
  if (!f.equals("")&&!t.equals("")){
		cc+="and m.createtime >=? and m.createtime<=? ";
		f=fromUser.format(fromInput.parse(f));
		t=fromUser.format(fromInput.parse(t));
		t=t.substring(0,8)+"235959";
		out.println(t);
	}
	PreparedStatement ps=null;
	ResultSet rs = null;
	Context ctx = new InitialContext();
	Context env=(Context)ctx.lookup("java:comp/env");
	DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
	Connection conn = ds.getConnection();
	String [] statusmsg={"未發送","交換機已轉送","已送出","已到期","已刪除","無法送出","交換機已收到","未知","拒絕"};
	try {
		ps = conn.prepareStatement(sql+cc+" order by s.userid,i.msgid,createtime");
		int pcount=1;
//out.print(sql+cc+" order by s.userid,createtime desc,i.msgid");
		if (u!=null)
    if (!u.equals("")){
			ps.setString(pcount,u);
			pcount++;
		}
		if (m!=null)
    if (!m.equals("")){
			ps.setString(pcount,m);
			pcount++;
		}
		/*
		if (r!=null){
			ps.setString(pcount,r);
			pcount++;
		}
		*/
		if (f!=null&&t!=null)
    if (!f.equals("")&&!t.equals("")){
			ps.setString(pcount,f);
			pcount++;
			ps.setString(pcount,t);
			pcount++;
		}
		rs = ps.executeQuery();
%>
<table border="1" cellpadding="0" cellspacing="0" width="1383">
    <tr height="27">
      <td bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">Message ID</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="117" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">組織代碼</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="44" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">序號</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訂單接收時間</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">預計發送日期</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">完成時間</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="111" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">手機號碼</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="60" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">狀態</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="256" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訊息</font><u></u><u></u></span></p></td>
    </tr>
<%
		String rsMsgid="";
		int fcount=0;
		int scount=0;
		int tcount=0;
		while (rs.next()){
			if (rs.getString("msgid").equals(rsMsgid)){
				if (!rsMsgid.equals("")){
%>
  <tr>
		<td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="right">發送失敗</td>
    <td><%=fcount%></td>
    <td>發送成功</td>
    <td><%=scount%></td>
  </tr>
<%
				}
				rsMsgid=rs.getString("msgid");
				fcount=0;
				scount=0;
			}
			fcount++;
			scount++;
			tcount++;
%>
    <tr height="27">
      <td nowrap="nowrap" width="331" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgid")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="117" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("orgcode")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="44" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("seq")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=myFormat.format(fromUser.parse(rs.getString("createtime")))%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("schedule")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=myFormat.format(fromUser.parse(rs.getString("donetime")))%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="111" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("phoneno")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="60" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=statusmsg[rs.getInt("status")]%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="256" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgbody")%><u></u><u></u></span></p></td>
    </tr>
<%
		}
		if (!rsMsgid.equals("")){
%>
  <tr>
		<td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td align="right">發送失敗</td>
    <td><%=fcount%></td>
    <td>發送成功</td>
    <td><%=scount%></td>
  </tr>
<%
		}
%>
  <tr>
		<td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">總計</td>
    <td><%=tcount%></td>
  </tr>
<%
	} catch (SQLException sqle) {
		rMsg="Query Exception:"+sqle.getMessage();
		out.println(rMsg);
	}finally{
		try{
			rs.close();
			ps.close();
			conn.close();
		}catch(Exception e){
		}
%>
</table>
  <%
	}
}//check if there submit something
%>
</body>
</html>
