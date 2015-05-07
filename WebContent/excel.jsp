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
	
	//建立狀態對應Map
		/* String [] statusmsg={"未發送","交換機已轉送","已送出","已到期","已刪除","無法送出","交換機已收到","未知","拒絕","已送出",
	            "10","11","12","13","14","15","16","17","18","19",
				 "20","21","22","23","24","25","26","27","28","29",
				 "30","31","32","33","34","35","36","37","38","39",
				 "40","41","42","43","44","45","46","47","48","49",
				 "50","51","52","53","54","55","56","57","58","59",
				 "60","61","62","63","64","65","66","67","68","69",
				 "70","71","72","73","74","75","76","77","78","79",
				 "80","81","82","83","84","85","86","87","88","89",
				 "90","91","92","93","94","95","96","查詢中(97)","處理中(98)","排程中(99)"}; */
	Map <Integer,String>map = new HashMap<Integer,String>();
	 /* map.put(0,"未發送");
		map.put(1,"交換機已轉送");
		map.put(2,"已送出");
		map.put(3,"已到期");
		map.put(4,"已刪除");
		map.put(5,"無法送出");
		map.put(6,"交換機已收到");
		map.put(7,"未知");
		map.put(8,"拒絕");
		map.put(9,"已送出");
		map.put(95,"傳送失敗");
		map.put(96,"逾期");
		map.put(97,"查詢中");
		map.put(98,"處理中");
		map.put(99,"排程中"); */
		
		//20150324 change
		map.put(0,"傳送中");
		map.put(1,"傳送中");
		map.put(2,"成功");
		map.put(3,"失敗");
		map.put(4,"失敗");
		map.put(5,"失敗");
		map.put(6,"傳送中");
		map.put(7,"失敗");
		map.put(8,"失敗");
		map.put(9,"成功");
		map.put(95,"傳送中");
		map.put(96,"失敗");
		map.put(97,"傳送中");
		map.put(98,"傳送中");
		map.put(99,"傳送中");
	
	
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
String s=request.getParameter("status");
String l=request.getParameter("limit");
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
    if(s!=null && !"".equals(s)){
    	 try {  
             Integer.parseInt(s);  
         } catch (NumberFormatException e) {  
        	 out.print("狀態代碼必須為數字");
             return ;  
         }  
    }
   	if(l!=null && !"".equals(l)){
   		try {  
               Integer.parseInt(l);  
           } catch (NumberFormatException e) {  
          	 out.print("載入數量必須為數字");
               return ;  
           }  
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
	if (s!=null){
		if (!s.equals(""))
			cc+="and i.status=?  ";
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
	//String [] statusmsg={"未發送","交換機已轉送","已送出","已到期","已刪除","無法送出","交換機已收到","未知","拒絕"};
	try {
		cc+=" order by s.userid,createtime desc,i.msgid";
		
		if (l!=null){
			if (!l.equals(""))
				cc+=" limit ? ";
		}
		ps = conn.prepareStatement(sql+cc);
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
	if (!s.equals("")){
		ps.setInt(pcount,Integer.parseInt(s));
		pcount++;
	}
	
	if (!l.equals("")){
			ps.setInt(pcount,Integer.parseInt(l));
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
			
			
			String donetime="";
			if(rs.getString("donetime")!=null&&!"".equals(rs.getString("donetime"))){
				donetime=myFormat.format(fromUser.parse(rs.getString("donetime")));
			}
			String createtime="123";
			if(rs.getString("createtime")!=null&&!"".equals(rs.getString("createtime"))){
				createtime=myFormat.format(fromUser.parse(rs.getString("createtime")));
			}
%>
    <tr height="27">
      <td nowrap="nowrap" width="331" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgid")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="117" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("orgcode")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="44" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("seq")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=createtime%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("schedule")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=donetime%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="111" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("phoneno")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="60" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=map.get(rs.getInt("status"))%><u></u><u></u></span></p></td>
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
